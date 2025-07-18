// MARK: - Debug-Enhanced FirebaseAuthService with Detailed Logging
// File: ArtOfTheFuture/FirebaseAuthService.swift

import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore
import GoogleSignIn
import AuthenticationServices
import CryptoKit

@MainActor
final class FirebaseAuthService: NSObject, ObservableObject {
    @Published var firebaseUser: FirebaseAuth.User?
    @Published var isAuthenticated = false
    @Published var hasCompletedOnboarding = false
    @Published var isCheckingOnboardingStatus = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let auth = Auth.auth()
    private let db = Firestore.firestore()
    private var currentNonce: String?
    
    override init() {
        super.init()
        
        print("🔥 FirebaseAuthService initializing...")
        
        // Listen for auth state changes
        auth.addStateDidChangeListener { [weak self] _, user in
            Task { @MainActor in
                print("🔥 Auth state changed. User: \(user?.email ?? "none"), UID: \(user?.uid ?? "none")")
                
                self?.firebaseUser = user
                self?.isAuthenticated = user != nil
                
                if let user = user {
                    print("🔥 User is authenticated, checking onboarding status...")
                    await self?.ensureUserProfileExists(for: user)
                    await self?.checkOnboardingStatus(for: user.uid)
                } else {
                    print("🔥 No authenticated user, resetting onboarding status")
                    self?.hasCompletedOnboarding = false
                    self?.isCheckingOnboardingStatus = false
                }
            }
        }
        
        // Debug current auth state
        if let currentUser = auth.currentUser {
            print("🔥 Already authenticated user found: \(currentUser.email ?? "unknown")")
        } else {
            print("🔥 No current authenticated user")
        }
    }
    
    // MARK: - Onboarding Status Management
    
    func checkOnboardingStatus(for uid: String) async {
        print("🔥 Checking onboarding status for user: \(uid)")
        isCheckingOnboardingStatus = true
        
        do {
            let document = try await db.collection("users").document(uid).getDocument()
            
            if let data = document.data() {
                let onboardingCompleted = data["hasCompletedOnboarding"] as? Bool ?? false
                hasCompletedOnboarding = onboardingCompleted
                print("🔥 Onboarding status found: \(onboardingCompleted)")
            } else {
                hasCompletedOnboarding = false
                print("🔥 No user document found, onboarding required")
            }
        } catch {
            print("🔥 Error checking onboarding status: \(error.localizedDescription)")
            hasCompletedOnboarding = false
        }
        
        isCheckingOnboardingStatus = false
        print("🔥 Finished checking onboarding status. hasCompleted: \(hasCompletedOnboarding)")
    }
    
    func markOnboardingCompleted(with data: OnboardingData) async throws {
        guard let uid = firebaseUser?.uid else {
            print("❌ No authenticated user found when trying to complete onboarding")
            throw AuthError.noUserFound
        }
        
        print("🔥 Marking onboarding completed for user: \(uid)")
        print("🔥 Updating display name to: \(data.userName)")
        
        // First, update Firebase Auth display name
        if let user = Auth.auth().currentUser {
            let changeRequest = user.createProfileChangeRequest()
            changeRequest.displayName = data.userName
            try await changeRequest.commitChanges()
            print("🔥 Firebase Auth display name updated to: \(data.userName)")
        }
        
        // Then update Firestore with ONLY the onboarding data (not recreating profile)
        let onboardingData: [String: Any] = [
            "displayName": data.userName, // Update display name
            "hasCompletedOnboarding": true,
            "onboardingDate": Timestamp(),
            "userName": data.userName,
            "skillLevel": data.skillLevel.rawValue,
            "learningGoals": data.learningGoals.map { $0.rawValue },
            "preferredPracticeTime": data.preferredPracticeTime.rawValue,
            "interests": data.interests.map { $0.rawValue },
            "lastActiveDate": Timestamp()
        ]
        
        do {
            try await db.collection("users").document(uid).updateData(onboardingData)
            
            // Update local state
            hasCompletedOnboarding = true
            
            print("🔥 Onboarding completed and saved to Firestore successfully")
            print("🔥 User display name should now be: \(data.userName)")
        } catch {
            print("❌ Failed to save onboarding to Firestore: \(error)")
            throw error
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
            
            // Create user profile in Firestore (without onboarding completion)
            try await createUserProfile(
                uid: result.user.uid,
                email: email,
                displayName: displayName,
                photoURL: nil,
                provider: "password",
                isNewUser: true
            )
            
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
            print("🔥 User signed in successfully: \(result.user.uid)")
            
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
            let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: presenting)
            
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
            
            // Check if this is a new user
            let isNewUser = authResult.additionalUserInfo?.isNewUser ?? false
            print("🔥 Is new user: \(isNewUser)")
            
            // Create or update user profile
            try await createOrUpdateUserProfile(
                uid: authResult.user.uid,
                email: authResult.user.email,
                displayName: authResult.user.displayName ?? user.profile?.name,
                photoURL: authResult.user.photoURL?.absoluteString,
                provider: "google.com",
                isNewUser: isNewUser
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
                
                // Create Firebase credential for Apple Sign-In
                let credential = OAuthProvider.appleCredential(
                    withIDToken: idTokenString,
                    rawNonce: nonce,
                    fullName: appleIDCredential.fullName
                )
                
                // Sign in to Firebase
                let authResult = try await auth.signIn(with: credential)
                print("🔥 Apple Sign In successful: \(authResult.user.uid)")
                
                // Check if this is a new user
                let isNewUser = authResult.additionalUserInfo?.isNewUser ?? false
                print("🔥 Is new user: \(isNewUser)")
                
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
                    displayName: displayName ?? authResult.user.displayName ?? "User",
                    photoURL: authResult.user.photoURL?.absoluteString,
                    provider: "apple.com",
                    isNewUser: isNewUser
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
    
    // MARK: - User Profile Management
    
    private func createUserProfile(
        uid: String,
        email: String?,
        displayName: String?,
        photoURL: String?,
        provider: String,
        isNewUser: Bool
    ) async throws {
        print("🔥 Creating user profile for: \(uid)")
        
        // Only include the required fields for your security rules
        let userData: [String: Any] = [
            "email": email ?? "",
            "displayName": displayName ?? "User",
            "createdAt": FieldValue.serverTimestamp(),
            "lastActiveDate": FieldValue.serverTimestamp()
        ]
        
        try await db.collection("users").document(uid).setData(userData)
        print("🔥 User profile created successfully with required fields: \(uid)")
        
        // Now add the optional fields with a separate update
        let additionalData: [String: Any] = [
            "photoURL": photoURL ?? "",
            "providers": [provider],
            "totalXP": 0,
            "currentLevel": 1,
            "currentStreak": 0,
            "hasCompletedOnboarding": false,
            "isNewUser": isNewUser
        ]
        
        do {
            try await db.collection("users").document(uid).updateData(additionalData)
            print("🔥 Additional user data added successfully: \(uid)")
        } catch {
            print("🔥 Warning: Could not add additional user data (this is okay): \(error.localizedDescription)")
            // Don't throw here - the basic profile was created successfully
        }
    }
    
    private func createOrUpdateUserProfile(
        uid: String,
        email: String?,
        displayName: String?,
        photoURL: String?,
        provider: String,
        isNewUser: Bool
    ) async throws {
        let userRef = db.collection("users").document(uid)
        
        do {
            let document = try await userRef.getDocument()
            
            if document.exists && !isNewUser {
                print("🔥 Updating existing user profile: \(uid)")
                // Update existing profile - only safe fields
                var updateData: [String: Any] = [
                    "lastActiveDate": FieldValue.serverTimestamp()
                ]
                
                // Only update display name if provided and different
                if let displayName = displayName,
                   let currentDisplayName = document.data()?["displayName"] as? String,
                   displayName != currentDisplayName {
                    updateData["displayName"] = displayName
                }
                
                // Only update photoURL if provided
                if let photoURL = photoURL {
                    updateData["photoURL"] = photoURL
                }
                
                // Add provider if not already present (but only if providers field exists)
                if let providers = document.data()?["providers"] as? [String],
                   !providers.contains(provider) {
                    var mutableProviders = providers
                    mutableProviders.append(provider)
                    updateData["providers"] = mutableProviders
                }
                
                try await userRef.updateData(updateData)
                print("🔥 User profile updated in Firestore")
                
            } else {
                print("🔥 Creating new user profile for: \(uid)")
                // Create new profile with required fields first
                try await createUserProfile(
                    uid: uid,
                    email: email,
                    displayName: displayName,
                    photoURL: photoURL,
                    provider: provider,
                    isNewUser: true
                )
            }
        } catch {
            print("🔥 Error managing user profile: \(error.localizedDescription)")
            throw error
        }
    }
    
    private func ensureUserProfileExists(for user: FirebaseAuth.User) async {
        let userRef = db.collection("users").document(user.uid)
        
        do {
            let document = try await userRef.getDocument()
            
            if !document.exists {
                print("🔥 No profile exists, creating one for: \(user.uid)")
                // Create profile for existing auth user with required fields only
                let provider = user.providerData.first?.providerID ?? "unknown"
                try await createUserProfile(
                    uid: user.uid,
                    email: user.email,
                    displayName: user.displayName,
                    photoURL: user.photoURL?.absoluteString,
                    provider: provider,
                    isNewUser: false
                )
            } else {
                print("🔥 Profile already exists for: \(user.uid)")
                // Update lastActiveDate since user is active
                do {
                    try await userRef.updateData([
                        "lastActiveDate": FieldValue.serverTimestamp()
                    ])
                    print("🔥 Updated lastActiveDate for: \(user.uid)")
                } catch {
                    print("🔥 Warning: Could not update lastActiveDate: \(error.localizedDescription)")
                    // Don't throw - this is not critical
                }
            }
        } catch {
            print("🔥 Error ensuring user profile exists: \(error.localizedDescription)")
            // Don't throw - let the app continue even if profile creation fails
        }
    }
    
    // MARK: - Sign Out
    
    func signOut() {
        do {
            try auth.signOut()
            hasCompletedOnboarding = false
            print("🔥 User signed out successfully")
        } catch {
            print("🔥 Sign out error: \(error.localizedDescription)")
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
        let nonce = String(randomBytes.map { byte in
            charset[Int(byte) % charset.count]
        })
        
        return nonce
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

// MARK: - Enhanced Auth Errors
enum AuthError: LocalizedError {
    case signInFailed
    case noIdToken
    case invalidCredential
    case noUserFound
    
    var errorDescription: String? {
        switch self {
        case .signInFailed:
            return "Sign in failed. Please try again."
        case .noIdToken:
            return "Failed to get authentication token."
        case .invalidCredential:
            return "Invalid authentication credential."
        case .noUserFound:
            return "No authenticated user found."
        }
    }
}
