import SwiftUI

// MARK: - Premium Buttons
struct PremiumButton: View {
    enum Style {
        case primary
        case secondary
        case success
        case warning
        case destructive
        
        var colors: [Color] {
            switch self {
            case .primary: return [.blue, .purple]
            case .secondary: return [Color(.systemGray5), Color(.systemGray4)]
            case .success: return [.green, .mint]
            case .warning: return [.orange, .yellow]
            case .destructive: return [.red, .pink]
            }
        }
        
        var textColor: Color {
            switch self {
            case .secondary: return .primary
            default: return .white
            }
        }
    }
    
    let title: String
    let style: Style
    let isEnabled: Bool
    let action: () -> Void
    
    init(_ title: String, style: Style = .primary, isEnabled: Bool = true, action: @escaping () -> Void) {
        self.title = title
        self.style = style
        self.isEnabled = isEnabled
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(isEnabled ? style.textColor : .secondary)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            isEnabled ?
                            LinearGradient(colors: style.colors, startPoint: .leading, endPoint: .trailing) :
                            LinearGradient(colors: [Color(.systemGray5)], startPoint: .leading, endPoint: .trailing)
                        )
                )
                .shadow(color: isEnabled ? style.colors.first!.opacity(0.3) : .clear, radius: 8, y: 4)
        }
        .disabled(!isEnabled)
        .scaleEffect(isEnabled ? 1.0 : 0.95)
        .animation(.spring(response: 0.3), value: isEnabled)
    }
}

// MARK: - Premium Card
struct PremiumCard<Content: View>: View {
    let content: Content
    let cornerRadius: CGFloat
    let shadowRadius: CGFloat
    
    init(cornerRadius: CGFloat = 16, shadowRadius: CGFloat = 5, @ViewBuilder content: () -> Content) {
        self.content = content()
        self.cornerRadius = cornerRadius
        self.shadowRadius = shadowRadius
    }
    
    var body: some View {
        content
            .background(Color(.systemBackground))
            .cornerRadius(cornerRadius)
            .shadow(color: .black.opacity(0.05), radius: shadowRadius, y: 2)
    }
}

// MARK: - Premium Progress Bar
struct PremiumProgressBar: View {
    let progress: Double
    let height: CGFloat
    let cornerRadius: CGFloat
    let gradient: LinearGradient
    let backgroundColor: Color
    
    init(
        progress: Double,
        height: CGFloat = 12,
        cornerRadius: CGFloat = 6,
        gradient: LinearGradient = LinearGradient(colors: [.blue, .purple], startPoint: .leading, endPoint: .trailing),
        backgroundColor: Color = Color(.systemGray5)
    ) {
        self.progress = progress
        self.height = height
        self.cornerRadius = cornerRadius
        self.gradient = gradient
        self.backgroundColor = backgroundColor
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(backgroundColor)
                    .frame(height: height)
                
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(gradient)
                    .frame(width: geometry.size.width * progress, height: height)
                    .animation(.spring(response: 0.6), value: progress)
            }
        }
        .frame(height: height)
    }
}

// MARK: - Premium Stat Card
struct PremiumStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    let trend: StatTrend?
    
    enum StatTrend {
        case up(String)
        case down(String)
        case neutral(String)
        
        var color: Color {
            switch self {
            case .up: return .green
            case .down: return .red
            case .neutral: return .secondary
            }
        }
        
        var icon: String {
            switch self {
            case .up: return "arrow.up"
            case .down: return "arrow.down"
            case .neutral: return "minus"
            }
        }
        
        var text: String {
            switch self {
            case .up(let text), .down(let text), .neutral(let text):
                return text
            }
        }
    }
    
    var body: some View {
        PremiumCard {
            VStack(spacing: 12) {
                HStack {
                    Image(systemName: icon)
                        .font(.title2)
                        .foregroundColor(color)
                    
                    Spacer()
                    
                    if let trend = trend {
                        HStack(spacing: 4) {
                            Image(systemName: trend.icon)
                                .font(.caption)
                            Text(trend.text)
                                .font(.caption)
                        }
                        .foregroundColor(trend.color)
                    }
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(value)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text(title)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding()
        }
    }
}

// MARK: - Premium Section Header
struct PremiumSectionHeader: View {
    let title: String
    let subtitle: String?
    let action: (() -> Void)?
    let actionTitle: String
    
    init(
        _ title: String,
        subtitle: String? = nil,
        actionTitle: String = "See All",
        action: (() -> Void)? = nil
    ) {
        self.title = title
        self.subtitle = subtitle
        self.actionTitle = actionTitle
        self.action = action
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                if let action = action {
                    Button(action: action) {
                        Text(actionTitle)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.accentColor)
                    }
                }
            }
        }
    }
}

// MARK: - Premium Alert Card
struct PremiumAlertCard: View {
    enum AlertType {
        case info
        case success
        case warning
        case error
        
        var color: Color {
            switch self {
            case .info: return .blue
            case .success: return .green
            case .warning: return .orange
            case .error: return .red
            }
        }
        
        var icon: String {
            switch self {
            case .info: return "info.circle.fill"
            case .success: return "checkmark.circle.fill"
            case .warning: return "exclamationmark.triangle.fill"
            case .error: return "xmark.circle.fill"
            }
        }
    }
    
    let type: AlertType
    let title: String
    let message: String
    let action: (() -> Void)?
    let actionTitle: String
    
    init(
        type: AlertType,
        title: String,
        message: String,
        actionTitle: String = "Got it",
        action: (() -> Void)? = nil
    ) {
        self.type = type
        self.title = title
        self.message = message
        self.actionTitle = actionTitle
        self.action = action
    }
    
    var body: some View {
        PremiumCard {
            HStack(spacing: 16) {
                Image(systemName: type.icon)
                    .font(.title2)
                    .foregroundColor(type.color)
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(title)
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text(message)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    if let action = action {
                        Button(action: action) {
                            Text(actionTitle)
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(type.color)
                        }
                        .padding(.top, 4)
                    }
                }
                
                Spacer()
            }
            .padding()
        }
    }
}

// MARK: - Premium Badge
struct PremiumBadge: View {
    let text: String
    let color: Color
    let size: BadgeSize
    
    enum BadgeSize {
        case small
        case medium
        case large
        
        var font: Font {
            switch self {
            case .small: return .caption2
            case .medium: return .caption
            case .large: return .subheadline
            }
        }
        
        var padding: EdgeInsets {
            switch self {
            case .small: return EdgeInsets(top: 2, leading: 6, bottom: 2, trailing: 6)
            case .medium: return EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8)
            case .large: return EdgeInsets(top: 6, leading: 12, bottom: 6, trailing: 12)
            }
        }
    }
    
    init(_ text: String, color: Color = .blue, size: BadgeSize = .medium) {
        self.text = text
        self.color = color
        self.size = size
    }
    
    var body: some View {
        Text(text)
            .font(size.font)
            .fontWeight(.bold)
            .foregroundColor(.white)
            .padding(size.padding)
            .background(
                Capsule()
                    .fill(color)
            )
    }
}

// MARK: - Premium Loading View
struct PremiumLoadingView: View {
    @State private var isAnimating = false
    let size: CGFloat
    let color: Color
    
    init(size: CGFloat = 50, color: Color = .blue) {
        self.size = size
        self.color = color
    }
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(color.opacity(0.3), lineWidth: 4)
                .frame(width: size, height: size)
            
            Circle()
                .trim(from: 0, to: 0.7)
                .stroke(color, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                .frame(width: size, height: size)
                .rotationEffect(.degrees(isAnimating ? 360 : 0))
                .animation(.linear(duration: 1).repeatForever(autoreverses: false), value: isAnimating)
        }
        .onAppear {
            isAnimating = true
        }
    }
}

// MARK: - Premium Empty State
struct PremiumEmptyState: View {
    let icon: String
    let title: String
    let message: String
    let actionTitle: String?
    let action: (() -> Void)?
    
    init(
        icon: String = "tray",
        title: String,
        message: String,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.icon = icon
        self.title = title
        self.message = message
        self.actionTitle = actionTitle
        self.action = action
    }
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: icon)
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            VStack(spacing: 12) {
                Text(title)
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text(message)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
            }
            
            if let actionTitle = actionTitle, let action = action {
                PremiumButton(actionTitle, style: .primary, action: action)
                    .frame(maxWidth: 200)
            }
        }
        .padding(.horizontal, 40)
    }
}

// MARK: - Premium Achievement Badge
struct PremiumAchievementBadge: View {
    let achievement: Achievement
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: achievement.isUnlocked ?
                            [Color.yellow.opacity(0.8), Color.orange.opacity(0.6)] :
                            [Color.gray.opacity(0.4), Color.gray.opacity(0.2)],
                            center: .center,
                            startRadius: 20,
                            endRadius: 40
                        )
                    )
                    .frame(width: 80, height: 80)
                
                Image(systemName: achievement.icon)
                    .font(.largeTitle)
                    .foregroundColor(achievement.isUnlocked ? .white : .gray)
                
                if achievement.isUnlocked {
                    VStack {
                        HStack {
                            Spacer()
                            Image(systemName: "checkmark.circle.fill")
                                .font(.title3)
                                .foregroundColor(.green)
                                .background(Circle().fill(Color.white))
                                .padding(4)
                        }
                        Spacer()
                    }
                }
            }
            
            VStack(spacing: 4) {
                Text(achievement.title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                
                Text(achievement.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            
            if !achievement.isUnlocked {
                PremiumProgressBar(
                    progress: achievement.progress,
                    height: 6,
                    cornerRadius: 3
                )
                .frame(width: 60)
            }
        }
        .frame(width: 120)
        .opacity(achievement.isUnlocked ? 1.0 : 0.6)
        .scaleEffect(achievement.isUnlocked ? 1.0 : 0.95)
        .animation(.spring(response: 0.3), value: achievement.isUnlocked)
    }
}

// MARK: - Premium Floating Action Button
struct PremiumFloatingActionButton: View {
    let icon: String
    let color: Color
    let size: CGFloat
    let action: () -> Void
    
    @State private var isPressed = false
    
    init(
        icon: String = "plus",
        color: Color = .blue,
        size: CGFloat = 56,
        action: @escaping () -> Void
    ) {
        self.icon = icon
        self.color = color
        self.size = size
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .frame(width: size, height: size)
                .background(
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [color, color.opacity(0.8)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
                .shadow(color: color.opacity(0.4), radius: 10, y: 5)
        }
        .scaleEffect(isPressed ? 0.9 : 1.0)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity) { pressing in
            withAnimation(.spring(response: 0.3)) {
                isPressed = pressing
            }
        } perform: {
            // Long press action if needed
        }
    }
}
