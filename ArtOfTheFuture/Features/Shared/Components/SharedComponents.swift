// MARK: - Shared UI Components
// **CREATE:** ArtOfTheFuture/Features/Shared/Components/SharedComponents.swift

import SwiftUI

// MARK: - Buttons
struct ModernButton: View {
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
    let icon: String?
    let style: Style
    let isEnabled: Bool
    let isFullWidth: Bool
    let action: () -> Void
    
    init(
        title: String,
        icon: String? = nil,
        style: Style = .primary,
        isEnabled: Bool = true,
        isFullWidth: Bool = true,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.style = style
        self.isEnabled = isEnabled
        self.isFullWidth = isFullWidth
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.headline)
                }
                
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            .foregroundColor(isEnabled ? style.textColor : .secondary)
            .frame(maxWidth: isFullWidth ? .infinity : nil)
            .frame(height: 50)
            .padding(.horizontal, isFullWidth ? 0 : 24)
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

// MARK: - Icon Button
struct IconButton: View {
    enum Size {
        case small, medium, large
        
        var dimension: CGFloat {
            switch self {
            case .small: return 36
            case .medium: return 44
            case .large: return 56
            }
        }
        
        var fontSize: Font {
            switch self {
            case .small: return .callout
            case .medium: return .title3
            case .large: return .title2
            }
        }
    }
    
    enum Style {
        case primary, secondary, ghost
        
        func backgroundColor(isPressed: Bool) -> Color {
            switch self {
            case .primary:
                return isPressed ? Color.blue.opacity(0.8) : Color.blue
            case .secondary:
                return isPressed ? Color(.systemGray4) : Color(.systemGray5)
            case .ghost:
                return isPressed ? Color(.systemGray5) : Color.clear
            }
        }
        
        var foregroundColor: Color {
            switch self {
            case .primary: return .white
            case .secondary, .ghost: return .primary
            }
        }
    }
    
    let icon: String
    let size: Size
    let style: Style
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(size.fontSize)
                .foregroundColor(style.foregroundColor)
                .frame(width: size.dimension, height: size.dimension)
                .background(
                    Circle()
                        .fill(style.backgroundColor(isPressed: isPressed))
                )
                .scaleEffect(isPressed ? 0.95 : 1.0)
        }
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity) { pressing in
            withAnimation(.spring(response: 0.3)) {
                isPressed = pressing
            }
        } perform: {}
    }
}

// MARK: - Card Container
struct ModernCard<Content: View>: View {
    let backgroundColor: Color
    let cornerRadius: CGFloat
    let shadowRadius: CGFloat
    let content: Content
    
    init(
        backgroundColor: Color = Color(.systemBackground),
        cornerRadius: CGFloat = 16,
        shadowRadius: CGFloat = 5,
        @ViewBuilder content: () -> Content
    ) {
        self.backgroundColor = backgroundColor
        self.cornerRadius = cornerRadius
        self.shadowRadius = shadowRadius
        self.content = content()
    }
    
    var body: some View {
        content
            .background(backgroundColor)
            .cornerRadius(cornerRadius)
            .shadow(color: .black.opacity(0.05), radius: shadowRadius, y: 2)
    }
}

// MARK: - Progress Bar
struct ModernProgressBar: View {
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

// MARK: - Circular Progress View
struct CircularProgressView: View {
    let progress: Double
    let lineWidth: CGFloat
    let size: CGFloat
    let gradient: LinearGradient
    
    init(
        progress: Double,
        lineWidth: CGFloat = 8,
        size: CGFloat = 60,
        gradient: LinearGradient = LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing)
    ) {
        self.progress = progress
        self.lineWidth = lineWidth
        self.size = size
        self.gradient = gradient
    }
    
    var body: some View {
        ZStack {
            // Background circle
            Circle()
                .stroke(Color(.systemGray5), lineWidth: lineWidth)
                .frame(width: size, height: size)
            
            // Progress circle
            Circle()
                .trim(from: 0, to: progress)
                .stroke(gradient, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .frame(width: size, height: size)
                .rotationEffect(.degrees(-90))
                .animation(.spring(response: 0.6), value: progress)
        }
    }
}

// MARK: - Interactive Progress Card
struct InteractiveProgressCard: View {
    let title: String
    let progress: Double
    let currentValue: Int
    let targetValue: Int
    let color: Color
    let icon: String
    
    var body: some View {
        ModernCard {
            VStack(spacing: 16) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(title)
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Text("\(currentValue) / \(targetValue) min")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: icon)
                        .font(.title2)
                        .foregroundColor(color)
                }
                
                ModernProgressBar(
                    progress: progress,
                    gradient: LinearGradient(colors: [color, color.opacity(0.7)], startPoint: .leading, endPoint: .trailing)
                )
                
                HStack {
                    Text("\(Int(progress * 100))% Complete")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    if progress >= 1.0 {
                        Text("Goal Reached! 🎉")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(color)
                    }
                }
            }
            .padding()
        }
    }
}

// MARK: - Lesson Card
struct PremiumLessonCard: View {
    let lesson: Lesson
    let progress: Double?
    let isLocked: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ModernCard {
                HStack(spacing: 16) {
                    // Progress indicator
                    ZStack {
                        if let progress = progress, !isLocked {
                            CircularProgressView(
                                progress: progress,
                                size: 50
                            )
                        } else {
                            Circle()
                                .fill(isLocked ? Color(.systemGray5) : lesson.category.categoryColor.opacity(0.2))
                                .frame(width: 50, height: 50)
                        }
                        
                        Image(systemName: isLocked ? "lock.fill" : lesson.category.iconName)
                            .foregroundColor(isLocked ? .gray : lesson.category.categoryColor)
                    }
                    
                    // Content
                    VStack(alignment: .leading, spacing: 4) {
                        Text(lesson.title)
                            .font(.headline)
                            .foregroundColor(.primary)
                            .lineLimit(1)
                        
                        Text(lesson.description)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                        
                        HStack {
                            Label("\(lesson.estimatedMinutes)m", systemImage: "clock")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            if !isLocked {
                                HStack(spacing: 4) {
                                    Image(systemName: "star.fill")
                                        .foregroundColor(.yellow)
                                    Text("\(lesson.xpReward)")
                                        .fontWeight(.medium)
                                }
                                .font(.caption)
                                .foregroundColor(.yellow)
                            }
                        }
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
            }
        }
        .buttonStyle(.plain)
        .opacity(isLocked ? 0.6 : 1.0)
        .disabled(isLocked)
    }
}

// MARK: - Section Header
struct ModernSectionHeader: View {
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

// MARK: - Empty State
struct ModernEmptyState: View {
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
                ModernButton(
                    title: actionTitle,
                    style: .primary,
                    isFullWidth: false,
                    action: action
                )
            }
        }
        .padding(.horizontal, 40)
    }
}

// MARK: - Loading View
struct ModernLoadingView: View {
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

// MARK: - Sheet Handle
struct SheetHandle: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 3)
            .fill(Color(.systemGray4))
            .frame(width: 40, height: 6)
            .padding(.vertical, 8)
    }
}

// MARK: - Pressed Button Style
struct PressedButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}
