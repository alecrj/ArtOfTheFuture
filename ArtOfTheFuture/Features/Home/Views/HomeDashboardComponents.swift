import SwiftUI

// Note: Charts framework requires iOS 16+, using custom chart implementation for compatibility

// MARK: - Weekly Stats Chart (Custom Implementation)
struct WeeklyStatsChart: View {
    let stats: WeeklyStats
    @State private var selectedDay: WeeklyStats.DayStats?
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            ForEach(stats.days) { day in
                VStack(spacing: 4) {
                    // Bar
                    ZStack(alignment: .bottom) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color(.systemGray5))
                            .frame(width: 32, height: 120)
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(
                                day.completed ?
                                LinearGradient(
                                    colors: [.blue, .purple],
                                    startPoint: .bottom,
                                    endPoint: .top
                                ) :
                                LinearGradient(
                                    colors: [Color(.systemGray4), Color(.systemGray5)],
                                    startPoint: .bottom,
                                    endPoint: .top
                                )
                            )
                            .frame(
                                width: 32,
                                height: max(8, CGFloat(day.minutes) / max(60, CGFloat(stats.days.map { $0.minutes }.max() ?? 60)) * 120)
                            )
                    }
                    
                    // Checkmark for completed days
                    if day.completed {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.caption2)
                            .foregroundColor(.green)
                    } else {
                        Spacer()
                            .frame(height: 12)
                    }
                    
                    // Day label
                    Text(dayLabel(for: day.date))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .onTapGesture {
                    selectedDay = selectedDay?.id == day.id ? nil : day
                }
            }
        }
        .overlay(alignment: .topTrailing) {
            if let selectedDay = selectedDay {
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(selectedDay.minutes) min")
                        .font(.headline)
                    Text("\(selectedDay.xp) XP")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(8)
                .background(Color(.systemBackground))
                .cornerRadius(8)
                .shadow(radius: 4)
                .padding()
            }
        }
    }
    
    private func dayLabel(for date: Date) -> String {
        if Calendar.current.isDateInToday(date) {
            return "Today"
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        return formatter.string(from: date)
    }
}

// MARK: - Streak Celebration View
struct StreakCelebrationView: View {
    let streak: Int
    let onDismiss: () -> Void
    
    @State private var isAnimating = false
    @State private var showContent = false
    
    var body: some View {
        ZStack {
            // Background
            Color.black.opacity(0.8)
                .ignoresSafeArea()
                .onTapGesture(perform: onDismiss)
            
            // Content
            VStack(spacing: 32) {
                // Animated flame
                ZStack {
                    // Glow effect
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color.orange.opacity(0.8),
                                    Color.orange.opacity(0.4),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 20,
                                endRadius: 100
                            )
                        )
                        .frame(width: 200, height: 200)
                        .blur(radius: 20)
                        .scaleEffect(isAnimating ? 1.2 : 0.8)
                    
                    // Flame icon
                    Image(systemName: "flame.fill")
                        .font(.system(size: 100))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.yellow, .orange, .red],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .scaleEffect(isAnimating ? 1.0 : 0)
                        .rotationEffect(.degrees(isAnimating ? 0 : -20))
                }
                
                // Text content
                VStack(spacing: 16) {
                    Text("\(streak) Day Streak!")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text(streakMessage)
                        .font(.title3)
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                }
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 20)
                
                // Continue button
                Button(action: onDismiss) {
                    Text("Keep Going!")
                        .font(.headline)
                        .foregroundColor(.black)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 16)
                        .background(
                            Capsule()
                                .fill(
                                    LinearGradient(
                                        colors: [.yellow, .orange],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                        )
                }
                .opacity(showContent ? 1 : 0)
                .scaleEffect(showContent ? 1 : 0.8)
            }
            .padding()
            
            // Confetti
            if isAnimating {
                SharedCelebrationView()
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                isAnimating = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.easeOut(duration: 0.5)) {
                    showContent = true
                }
            }
            
            // Auto dismiss after 3 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                onDismiss()
            }
        }
    }
    
    private var streakMessage: String {
        switch streak {
        case 1: return "Great start! Keep it up!"
        case 2...6: return "You're building a habit!"
        case 7: return "One week strong! 🎉"
        case 8...13: return "Amazing consistency!"
        case 14: return "Two weeks! You're unstoppable!"
        case 15...29: return "You're on fire! 🔥"
        case 30: return "One month! Incredible dedication!"
        default: return "Legendary streak! Keep going!"
        }
    }
}

// MARK: - Shared Celebration View (Renamed to avoid conflicts)
struct SharedCelebrationView: View {
    @State private var confettiScale = 0.0
    @State private var confettiOpacity = 0.0
    
    var body: some View {
        ZStack {
            ForEach(0..<20, id: \.self) { index in
                SharedConfettiPiece()
                    .scaleEffect(confettiScale)
                    .opacity(confettiOpacity)
                    .animation(
                        .spring(response: 0.5)
                        .delay(Double(index) * 0.05),
                        value: confettiScale
                    )
            }
        }
        .onAppear {
            confettiScale = 1.0
            confettiOpacity = 1.0
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation(.easeOut(duration: 1)) {
                    confettiOpacity = 0
                }
            }
        }
    }
}

struct SharedConfettiPiece: View {
    @State private var position = CGPoint(x: 0, y: 0)
    @State private var rotation = 0.0
    
    let colors: [Color] = [.red, .orange, .yellow, .green, .blue, .purple, .pink]
    let size = CGFloat.random(in: 10...20)
    
    var body: some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(colors.randomElement()!)
            .frame(width: size, height: size * 0.6)
            .rotationEffect(.degrees(rotation))
            .position(position)
            .onAppear {
                let angle = Double.random(in: 0...(2 * .pi))
                let distance = CGFloat.random(in: 100...200)
                
                withAnimation(.easeOut(duration: 2)) {
                    position = CGPoint(
                        x: cos(angle) * distance,
                        y: sin(angle) * distance - 50
                    )
                    rotation = Double.random(in: -360...360)
                }
            }
    }
}

// MARK: - Animated Progress Ring
struct ProgressRing: View {
    let progress: Double
    let lineWidth: CGFloat
    let gradient: LinearGradient
    
    var body: some View {
        ZStack {
            // Background circle
            Circle()
                .stroke(Color(.systemGray5), lineWidth: lineWidth)
            
            // Progress circle
            Circle()
                .trim(from: 0, to: progress)
                .stroke(gradient, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.spring(response: 0.6), value: progress)
        }
    }
}

// MARK: - Level Badge
struct LevelBadge: View {
    let level: Int
    let xp: Int
    let nextLevelXP: Int
    
    var progress: Double {
        let currentLevelXP = xp % 100
        return Double(currentLevelXP) / 100.0
    }
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 60, height: 60)
                
                Text("\(level)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            
            // XP Progress
            VStack(spacing: 2) {
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color(.systemGray5))
                            .frame(height: 4)
                        
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.blue)
                            .frame(width: geometry.size.width * progress, height: 4)
                    }
                }
                .frame(width: 50, height: 4)
                
                Text("\(xp % 100)/100 XP")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
    }
}

// MARK: - Streak Badge
struct StreakBadge: View {
    let streak: Int
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 4) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: streak > 0 ? [.orange, .red] : [.gray, .gray],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: "flame.fill")
                        .font(.title3)
                        .foregroundColor(.white)
                }
                
                VStack(spacing: 2) {
                    Text("\(streak)")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(streak > 0 ? .orange : .gray)
                    
                    Text("Streak")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .scaleEffect(streak > 0 ? 1.0 : 0.9)
        .animation(.spring(response: 0.3), value: streak)
    }
}

// MARK: - Quick Action Button
struct QuickActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(width: 50, height: 50)
                    .background(
                        LinearGradient(
                            colors: [color, color.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(Circle())
                    .shadow(color: color.opacity(0.3), radius: 4, y: 2)
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Recommended Lesson Card
struct RecommendedLessonCard: View {
    let lesson: Lesson
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(lesson.title)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .lineLimit(1)
                        
                        Text(lesson.category.rawValue)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    // XP Badge
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.caption2)
                            .foregroundColor(.yellow)
                        
                        Text("\(lesson.xpReward)")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.yellow)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.yellow.opacity(0.2))
                    .cornerRadius(12)
                }
                
                // Description
                Text(lesson.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                
                // Footer
                HStack {
                    Label("\(lesson.estimatedMinutes)m", systemImage: "clock")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text(lesson.difficulty.rawValue)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(lesson.difficulty.difficultyColor)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(lesson.difficulty.difficultyColor.opacity(0.2))
                        .cornerRadius(8)
                }
            }
            .padding()
            .frame(width: 240)
            .background(Color(.systemBackground))
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
        }
        .buttonStyle(.plain)
    }
}
