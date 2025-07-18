// MARK: - User Data Service (Real Firestore Integration)
// File: ArtOfTheFuture/Services/UserDataService.swift

import Foundation
import FirebaseFirestore
import FirebaseAuth

@MainActor
final class UserDataService: ObservableObject {
    @Published var currentUser: User?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let db = Firestore.firestore()
    private let auth = Auth.auth()
    
    static let shared = UserDataService()
    
    private init() {
        // Listen for auth changes and load user data
        auth.addStateDidChangeListener { [weak self] _, user in
            Task { @MainActor in
                if let user = user {
                    await self?.loadUserData(uid: user.uid)
                } else {
                    self?.currentUser = nil
                }
            }
        }
    }
    
    // MARK: - Data Loading
    
    func loadUserData(uid: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let document = try await db.collection("users").document(uid).getDocument()
            
            if document.exists, let data = document.data() {
                // Convert Firestore data to User model
                let user = User(
                    id: uid,
                    displayName: data["displayName"] as? String ?? "User",
                    email: data["email"] as? String,
                    profileImageURL: data["photoURL"] as? String,
                    totalXP: data["totalXP"] as? Int ?? 0,
                    currentLevel: data["currentLevel"] as? Int ?? 1,
                    currentStreak: data["currentStreak"] as? Int ?? 0,
                    joinedDate: (data["createdAt"] as? Timestamp)?.dateValue() ?? Date()
                )
                
                currentUser = user
                print("🔥 User data loaded: \(user.displayName)")
                
            } else {
                errorMessage = "User profile not found"
                print("🔥 User document does not exist")
            }
        } catch {
            errorMessage = error.localizedDescription
            print("🔥 Error loading user data: \(error.localizedDescription)")
        }
        
        isLoading = false
    }
    
    // MARK: - Data Updates
    
    func updateUserXP(newXP: Int) async {
        guard let uid = auth.currentUser?.uid else { return }
        
        do {
            let newLevel = (newXP / 100) + 1
            
            try await db.collection("users").document(uid).updateData([
                "totalXP": newXP,
                "currentLevel": newLevel,
                "lastActiveDate": Timestamp()
            ])
            
            // Update local model
            currentUser?.totalXP = newXP
            currentUser?.currentLevel = newLevel
            
            print("🔥 User XP updated: \(newXP)")
            
        } catch {
            print("🔥 Error updating XP: \(error.localizedDescription)")
        }
    }
    
    func updateUserStreak(newStreak: Int) async {
        guard let uid = auth.currentUser?.uid else { return }
        
        do {
            try await db.collection("users").document(uid).updateData([
                "currentStreak": newStreak,
                "lastActiveDate": Timestamp()
            ])
            
            // Update local model
            currentUser?.currentStreak = newStreak
            
            print("🔥 User streak updated: \(newStreak)")
            
        } catch {
            print("🔥 Error updating streak: \(error.localizedDescription)")
        }
    }
    
    func updateDisplayName(_ newName: String) async {
        guard let uid = auth.currentUser?.uid else { return }
        
        do {
            try await db.collection("users").document(uid).updateData([
                "displayName": newName
            ])
            
            // Update local model
            currentUser?.displayName = newName
            
            print("🔥 Display name updated: \(newName)")
            
        } catch {
            print("🔥 Error updating display name: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Helper Properties
    
    var isUserLoaded: Bool {
        currentUser != nil
    }
    
    var userDisplayName: String {
        currentUser?.displayName ?? "User"
    }
    
    var userXP: Int {
        currentUser?.totalXP ?? 0
    }
    
    var userLevel: Int {
        currentUser?.currentLevel ?? 1
    }
    
    var userStreak: Int {
        currentUser?.currentStreak ?? 0
    }
}
