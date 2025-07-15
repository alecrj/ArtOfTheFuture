// Create NEW FILE: ArtOfTheFuture/Features/Gamification/GamificationEngine.swift
import SwiftUI

// Simplified but powerful gamification system
@MainActor
final class GamificationEngine: ObservableObject {
    static let shared = GamificationEngine()
    
    // MARK: - Core State
    @Published var totalXP = 0
    @Published var currentLevel = 1
    @Published var levelProgress: Double = 0
    @Published var currentStreak = 0
    
    // MARK: - Animations
    @Published var showXPAnimation = false
    @Published var xpGained = 0
    @Published var showLevelUp = false
    
    // MARK: - Daily Goals
    @Published var dailyGoal = 100 // XP
    @Published var dailyProgress = 0
    
    private let storage = UserDefaults.standard
    
    private init() {
        loadProgress()
    }
    
    // MARK: - Main XP Function
    func awardXP(_ amount: Int, reason: String) {
        // Store for animation
        xpGained = amount
        showXPAnimation = true
        
        // Update XP
        totalXP += amount
        dailyProgress += amount
        
        // Check level up
        let newLevel = calculateLevel(from: totalXP)
        if newLevel > currentLevel {
            currentLevel = newLevel
            showLevelUp = true
            
            // Haptic feedback
            Task {
                await HapticManager.shared.notification(.success)
            }
        }
        
        // Update progress
        levelProgress = calculateLevelProgress()
        
        // Save
        saveProgress()
        
        // Post notification for UI updates
        NotificationCenter.default.post(
            name: .xpGained,
            object: nil,
            userInfo: ["amount": amount, "reason": reason]
        )
        
        // Hide animation after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.showXPAnimation = false
            self.xpGained = 0
        }
    }
    
    // MARK: - Streak Management
    func updateStreak() {
        let lastActive = storage.object(forKey: "lastActiveDate") as? Date ?? Date.distantPast
        let calendar = Calendar.current
        
        if calendar.isDateInToday(lastActive) {
            // Already active today
            return
        } else if calendar.isDateInYesterday(lastActive) {
            // Continue streak
            currentStreak += 1
        } else {
            // Streak broken
            currentStreak = 1
        }
        
        storage.set(Date(), forKey: "lastActiveDate")
        storage.set(currentStreak, forKey: "currentStreak")
        
        // Streak bonus XP
        if currentStreak > 1 {
            let bonusXP = min(currentStreak * 10, 100)
            awardXP(bonusXP, reason: "Streak Bonus")
        }
    }
    
    // MARK: - Level Calculations
    private func calculateLevel(from xp: Int) -> Int {
        // Simple level curve: 100 XP per level, increasing by 50 each level
        var level = 1
        var totalRequired = 0
        var requiredForNext = 100
        
        while totalRequired <= xp {
            level += 1
            totalRequired += requiredForNext
            requiredForNext += 50
        }
        
        return level - 1
    }
    
    private func calculateLevelProgress() -> Double {
        let currentLevelXP = getXPForLevel(currentLevel)
        let nextLevelXP = getXPForLevel(currentLevel + 1)
        let progressInLevel = totalXP - currentLevelXP
        let totalNeeded = nextLevelXP - currentLevelXP
        
        return Double(progressInLevel) / Double(totalNeeded)
    }
    
    private func getXPForLevel(_ level: Int) -> Int {
        guard level > 1 else { return 0 }
        
        var total = 0
        for i in 1..<level {
            total += 100 + (i - 1) * 50
        }
        return total
    }
    
    // MARK: - Quick XP Awards (Use these throughout the app)
    func lessonCompleted(accuracy: Double) {
        let baseXP = 50
        let accuracyBonus = Int(accuracy * 50)
        awardXP(baseXP + accuracyBonus, reason: "Lesson Complete")
    }
    
    func artworkCreated(duration: TimeInterval) {
        let baseXP = 30
        let timeBonus = min(Int(duration / 60), 20) // 1 XP per minute, max 20
        awardXP(baseXP + timeBonus, reason: "Artwork Created")
    }
    
    func dailyGoalReached() {
        awardXP(100, reason: "Daily Goal Complete!")
    }
    
    // MARK: - Persistence
    private func saveProgress() {
        storage.set(totalXP, forKey: "totalXP")
        storage.set(currentLevel, forKey: "currentLevel")
        storage.set(currentStreak, forKey: "currentStreak")
        storage.set(dailyProgress, forKey: "dailyProgress")
        storage.set(Date(), forKey: "lastSaveDate")
    }
    
    private func loadProgress() {
        totalXP = storage.integer(forKey: "totalXP")
        currentLevel = storage.integer(forKey: "currentLevel")
        if currentLevel == 0 { currentLevel = 1 }
        
        currentStreak = storage.integer(forKey: "currentStreak")
        
        // Reset daily progress if new day
        if let lastSave = storage.object(forKey: "lastSaveDate") as? Date {
            if !Calendar.current.isDateInToday(lastSave) {
                dailyProgress = 0
            } else {
                dailyProgress = storage.integer(forKey: "dailyProgress")
            }
        }
        
        levelProgress = calculateLevelProgress()
    }
}

// MARK: - XP Animation View (Add to your UI)
struct XPAnimationOverlay: View {
    @ObservedObject var gamification = GamificationEngine.shared
    
    var body: some View {
        ZStack {
            if gamification.showXPAnimation {
                VStack {
                    Text("+\(gamification.xpGained) XP")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.yellow)
                        .shadow(color: .black.opacity(0.3), radius: 2)
                        .transition(.scale.combined(with: .opacity))
                    
                    if gamification.showLevelUp {
                        Text("LEVEL UP!")
                            .font(.title)
                            .fontWeight(.black)
                            .foregroundColor(.purple)
                            .transition(.scale.combined(with: .opacity))
                    }
                }
                .animation(.spring(response: 0.5), value: gamification.showXPAnimation)
            }
        }
    }
}

// MARK: - Level Progress View (Add to Profile/Home)
struct LevelProgressView: View {
    @ObservedObject var gamification = GamificationEngine.shared
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Level \(gamification.currentLevel)")
                    .font(.headline)
                
                Spacer()
                
                Text("\(gamification.totalXP) XP")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            ProgressView(value: gamification.levelProgress)
                .progressViewStyle(.linear)
                .tint(.purple)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}
