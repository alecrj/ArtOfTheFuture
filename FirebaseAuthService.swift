import Foundation
import FirebaseAuth
import FirebaseFirestore

@MainActor
class FirebaseAuthService: ObservableObject {
    @Published var firebaseUser: FirebaseAuth.User?  // Changed from 'user' to 'firebaseUser'
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let auth = Auth.auth()
    private let db = Firestore.firestore()
    
    init() {
        // Listen for auth state changes
        auth.addStateDidChangeListener { [weak self] _, user in
            Task { @MainActor in
                self?.firebaseUser = user  // Updated variable name
                self?.isAuthenticated = user != nil
            }
        }
    }
    
    // MARK: - Authentication
    
    func signUp(email: String, password: String, displayName: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let result = try await auth.createUser(withEmail: email, password: password)
            
            // Update display name
            let changeRequest = result.user.createProfileChangeRequest()
            changeRequest.displayName = displayName
            try await changeRequest.commitChanges()
            
            // Create user profile in Firestore
            try await createUserProfile(uid: result.user.uid, email: email, displayName: displayName)
            
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func signIn(email: String, password: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await auth.signIn(withEmail: email, password: password)
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func signOut() {
        do {
            try auth.signOut()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    // MARK: - User Profile
    
    private func createUserProfile(uid: String, email: String, displayName: String) async throws {
        let userData: [String: Any] = [
            "email": email,
            "displayName": displayName,
            "createdAt": Timestamp(),
            "dailyGoalMinutes": 15,
            "onboardingCompleted": false,
            "totalXP": 0,
            "currentLevel": 1,
            "currentStreak": 0,
            "longestStreak": 0
        ]
        
        try await db.collection("users").document(uid).setData(userData)
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
