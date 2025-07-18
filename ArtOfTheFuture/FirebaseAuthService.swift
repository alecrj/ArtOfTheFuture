import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore
import GoogleSignIn
import AuthenticationServices
import CryptoKit

@MainActor
final class FirebaseAuthService: NSObject, ObservableObject {
    @Published var firebaseUser: User?
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let auth = Auth.auth()
    private let db = Firestore.firestore()
    private var currentNonce: String?
    
    override init() {
        super.init()
        
        // Listen for auth state changes
        auth.addStateDidChangeListener { [weak self] _, user in
            Task { @MainActor in
                self?.firebaseUser = user
                self?.isAuthenticated = user != nil
                print("🔥 Auth state changed. User: \(user?.email ?? "none")")
                
                // Check if user profile exists in Firestore
                if let user = user {
                    await self?.ensureUserProfileExists(for: user)
                }
            }
        }
    }
    
    // MARK: - Email/Password Authentication
    
    func signUp(email: String, password: String, displayName: String) async {
        isLoading = true
        errorMessage = nil
        
        print("🔥 Attempting signup with email: \(email)")
        
        do {
            let result = try await auth.createUser(withEmail: email, password: password)
            print("🔥 User created successfully: \(result.user.uid)")
            
            // Update display name
            let changeRequest = result.user.createProfileChangeRequest()
            changeRequest.displayName = displayName
            try await changeRequest.commitChanges()
            print("🔥 Display name updated")
            
            // Create user profile in Firestore
            try await createUserProfile(
                uid: result.user.uid,
                email: email,
                displayName: displayName,
                photoURL: nil,
                provider: "password"
            )
            print("🔥 User profile created in Firestore")
            
        } catch {
            print("🔥 Signup error: \(error.localizedDescription)")
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func signIn(email: String, password: String) async {
        isLoading = true
        errorMessage = nil
        
        print("🔥 Attempting signin with email: \(email)")
        
        do {
            let result = try await auth.signIn(withEmail: email, password: password)
            print("🔥 User signed in successfully")
            
            // Ensure user profile exists
            await ensureUserProfileExists(for: result.user)
            
        } catch {
            print("🔥 Signin error: \(error.localizedDescription)")
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    // MARK: - Google Sign In
    
    func signInWithGoogle(presenting: UIViewController) async {
        isLoading = true
        errorMessage = nil
        
        do {
            // Get Google Sign In result
            guard let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: presenting) else {
                throw AuthError.signInFailed
            }
            
            let user = result.user
            guard let idToken = user.idToken?.tokenString else {
                throw AuthError.noIdToken
            }
            
            // Create Firebase credential
            let credential = GoogleAuthProvider.credential(
                withIDToken: idToken,
                accessToken: user.accessToken.tokenString
            )
            
            // Sign in to Firebase
            let authResult = try await auth.signIn(with: credential)
            print("🔥 Google Sign In successful: \(authResult.user.uid)")
            
            // Create or update user profile
            try await createOrUpdateUserProfile(
                uid: authResult.user.uid,
                email: authResult.user.email,
                displayName: authResult.user.displayName ?? user.profile?.name,
                photoURL: authResult.user.photoURL?.absoluteString,
                provider: "google.com"
            )
            
        } catch {
            print("🔥 Google Sign In error: \(error.localizedDescription)")
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    // MARK: - Apple Sign In
    
    func handleSignInWithAppleRequest(_ request: ASAuthorizationAppleIDRequest) {
        request.requestedScopes = [.fullName, .email]
        let nonce = randomNonceString()
        currentNonce = nonce
        request.nonce = sha256(nonce)
    }
    
    func handleSignInWithAppleCompletion(_ result: Result<ASAuthorization, Error>) async {
        isLoading = true
        errorMessage = nil
        
        do {
            switch result {
            case .success(let authorization):
                guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
                      let nonce = currentNonce,
                      let appleIDToken = appleIDCredential.identityToken,
                      let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                    throw AuthError.invalidCredential
                }
                
                // Create Firebase credential
                let credential = OAuthProvider.credential(
                    providerID: AuthProviderID.apple,
                    accessToken: idTokenString,
                    rawNonce: nonce
                )
                
                // Sign in to Firebase
                let authResult = try await auth.signIn(with: credential)
                print("🔥 Apple Sign In successful: \(authResult.user.uid)")
                
                // Get display name from Apple ID credential
                var displayName: String?
                if let fullName = appleIDCredential.fullName {
                    let formatter = PersonNameComponentsFormatter()
                    displayName = formatter.string(from: fullName)
                }
                
                // Create or update user profile
                try await createOrUpdateUserProfile(
                    uid: authResult.user.uid,
                    email: authResult.user.email ?? appleIDCredential.email,
                    displayName: displayName ?? authResult.user.displayName,
                    photoURL: authResult.user.photoURL?.absoluteString,
                    provider: "apple.com"
                )
                
            case .failure(let error):
                throw error
            }
        } catch {
            print("🔥 Apple Sign In error: \(error.localizedDescription)")
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    // MARK: - Sign Out
    
    func signOut() {
        do {
            try auth.signOut()
            print("🔥 User signed out successfully")
        } catch {
            print("🔥 Sign out error: \(error.localizedDescription)")
            errorMessage = error.localizedDescription
        }
    }
    
    // MARK: - User Profile Management
    
    private func createUserProfile(
        uid: String,
        email: String?,
        displayName: String?,
        photoURL: String?,
        provider: String
    ) async throws {
        let userData: [String: Any] = [
            "email": email ?? "",
            "displayName": displayName ?? "User",
            "photoURL": photoURL ?? "",
            "providers": [provider],
            "createdAt": Timestamp(),
            "lastActiveDate": Timestamp(),
            "dailyGoalMinutes": 15,
            "onboardingCompleted": false,
            "totalXP": 0,
            "currentLevel": 1,
            "currentStreak": 0,
            "longestStreak": 0,
            "completedLessons": [],
            "earnedBadges": [],
            "skillProgress": [:],
            "lessonProgress": [:]
        ]
        
        try await db.collection("users").document(uid).setData(userData)
        print("🔥 User profile created in Firestore")
    }
    
    private func createOrUpdateUserProfile(
        uid: String,
        email: String?,
        displayName: String?,
        photoURL: String?,
        provider: String
    ) async throws {
        let userRef = db.collection("users").document(uid)
        
        do {
            let document = try await userRef.getDocument()
            
            if document.exists {
                // Update existing profile
                var updateData: [String: Any] = [
                    "lastActiveDate": Timestamp()
                ]
                
                // Update fields only if they're not empty
                if let email = email, !email.isEmpty {
                    updateData["email"] = email
                }
                if let displayName = displayName, !displayName.isEmpty {
                    updateData["displayName"] = displayName
                }
                if let photoURL = photoURL, !photoURL.isEmpty {
                    updateData["photoURL"] = photoURL
                }
                
                // Add provider if not already present
                if var providers = document.data()?["providers"] as? [String],
                   !providers.contains(provider) {
                    providers.append(provider)
                    updateData["providers"] = providers
                }
                
                try await userRef.updateData(updateData)
                print("🔥 User profile updated in Firestore")
                
            } else {
                // Create new profile
                try await createUserProfile(
                    uid: uid,
                    email: email,
                    displayName: displayName,
                    photoURL: photoURL,
                    provider: provider
                )
            }
        } catch {
            print("🔥 Error managing user profile: \(error.localizedDescription)")
            throw error
        }
    }
    
    private func ensureUserProfileExists(for user: User) async {
        let userRef = db.collection("users").document(user.uid)
        
        do {
            let document = try await userRef.getDocument()
            
            if !document.exists {
                // Create profile for existing auth user
                let provider = user.providerData.first?.providerID ?? "unknown"
                try await createUserProfile(
                    uid: user.uid,
                    email: user.email,
                    displayName: user.displayName,
                    photoURL: user.photoURL?.absoluteString,
                    provider: provider
                )
            }
        } catch {
            print("🔥 Error ensuring user profile exists: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Helper Properties
    
    var currentUserUID: String? {
        firebaseUser?.uid
    }
    
    var currentUserEmail: String? {
        firebaseUser?.email
    }
    
    var currentUserDisplayName: String? {
        firebaseUser?.displayName
    }
    
    // MARK: - Apple Sign In Helpers
    
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        var randomBytes = [UInt8](repeating: 0, count: length)
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        if errorCode != errSecSuccess {
            fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
        }
        
        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        let nonce = randomBytes.map { byte in
            charset[Int(byte) % charset.count]
        }
        
        return String(nonce)
    }
    
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
}

// MARK: - Custom Errors

enum AuthError: LocalizedError {
    case signInFailed
    case noIdToken
    case invalidCredential
    
    var errorDescription: String? {
        switch self {
        case .signInFailed:
            return "Sign in failed. Please try again."
        case .noIdToken:
            return "Unable to fetch identity token."
        case .invalidCredential:
            return "Invalid credentials provided."
        }
    }
}
