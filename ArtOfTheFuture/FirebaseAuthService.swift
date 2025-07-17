import Foundation
import FirebaseAuth
import FirebaseFirestore

@MainActor
class FirebaseAuthService: ObservableObject {
    @Published var firebaseUser: FirebaseAuth.User?
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let auth = Auth.auth()
    private let db = Firestore.firestore()
    
    init() {
        // Listen for auth state changes
        auth.addStateDidChangeListener { [weak self] _, user in
            Task { @MainActor in
                self?.firebaseUser = user
                self?.isAuthenticated = user != nil
                print("🔥 Auth state changed. User: \(user?.email ?? "none")")
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
                displayName: displayName
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
            try await auth.signIn(withEmail: email, password: password)
            print("🔥 User signed in successfully")
        } catch {
            print("🔥 Signin error: \(error.localizedDescription)")
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
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
    
    private func createUserProfile(uid: String, email: String, displayName: String) async throws {
        let userData: [String: Any] = [
            "email": email,
            "displayName": displayName,
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
    
    // MARK: - Helper Properties
    
    var currentUserUID: String? {
        return firebaseUser?.uid
    }
    
    var currentUserEmail: String? {
        return firebaseUser?.email
    }
    
    var currentUserDisplayName: String? {
        return firebaseUser?.displayName
    }
}
