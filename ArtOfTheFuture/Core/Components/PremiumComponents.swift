// MARK: - Premium UI Components
// File: ArtOfTheFuture/Core/Components/PremiumComponents.swift

import SwiftUI

// MARK: - Floating Tab Bar (Modern Navigation)
struct FloatingTabBar: View {
    @Binding var selectedTab: Int
    @Namespace private var animation
    
    let tabs: [(String, String, Color)] = [
        ("house.fill", "Home", ColorPalette.primaryBlue),
        ("book.fill", "Learn", ColorPalette.primaryGreen),
        ("paintbrush.fill", "Draw", ColorPalette.primaryPurple),
        ("photo.stack.fill", "Gallery", ColorPalette.primaryOrange),
        ("person.fill", "Profile", ColorPalette.primaryRed)
    ]
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<tabs.count, id: \.self) { index in
                TabButton(
                    icon: tabs[index].0,
                    title: tabs[index].1,
                    color: tabs[index].2,
                    isSelected: selectedTab == index,
                    namespace: animation
                ) {
                    withAnimation(AnimationPresets.bouncy) {
                        selectedTab = index
                    }
                    HapticManager.shared.impact(.light)
                }
            }
        }
        .padding(.horizontal, Dimensions.paddingSmall)
        .padding(.vertical, Dimensions.paddingSmall)
        .background(
            Capsule()
                .fill(.ultraThinMaterial)
                .overlay(
                    Capsule()
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        )
        .shadow(
            color: ShadowStyle.elevated.color,
            radius: ShadowStyle.elevated.radius,
            x: ShadowStyle.elevated.x,
            y: ShadowStyle.elevated.y
        )
        .padding(.horizontal, DeviceType.current.isIPad ? 100 : 20)
        .padding(.bottom, DeviceType.current.isIPad ? 20 : 10)
    }
}

struct TabButton: View {
    let icon: String
    let title: String
    let color: Color
    let isSelected: Bool
    let namespace: Namespace.ID
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                ZStack {
                    if isSelected {
                        Circle()
                            .fill(color.opacity(0.2))
                            .frame(width: 48, height: 48)
                            .matchedGeometryEffect(id: "tab", in: namespace)
                    }
                    
                    Image(systemName: icon)
                        .font(.system(size: DeviceType.current.isIPad ? 26 : 22))
                        .foregroundColor(isSelected ? color : .secondary)
                        .scaleEffect(isSelected ? 1.1 : 1.0)
                }
                
                if DeviceType.current.isIPad {
                    Text(title)
                        .font(.caption2)
                        .foregroundColor(isSelected ? color : .secondary)
                        .opacity(isSelected ? 1 : 0.7)
                }
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Premium Navigation Bar
struct PremiumNavigationBar: View {
    let title: String
    let subtitle: String?
    let leadingAction: (() -> Void)?
    let trailingAction: (() -> Void)?
    let leadingIcon: String?
    let trailingIcon: String?
    
    @State private var scrollOffset: CGFloat = 0
    
    var body: some View {
        ZStack {
            // Blur background that appears on scroll
            if scrollOffset > 10 {
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .ignoresSafeArea()
                    .transition(.opacity)
            }
            
            HStack(spacing: Dimensions.paddingMedium) {
                // Leading button
                if let leadingAction = leadingAction, let leadingIcon = leadingIcon {
                    IconButton(
                        icon: leadingIcon,
                        size: .medium,
                        style: .secondary,
                        action: leadingAction
                    )
                }
                
                // Title section
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(Typography.headline)
                        .foregroundColor(ColorPalette.textPrimary)
                    
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(Typography.caption)
                            .foregroundColor(ColorPalette.textSecondary)
                    }
                }
                
                Spacer()
                
                // Trailing button
                if let trailingAction = trailingAction, let trailingIcon = trailingIcon {
                    IconButton(
                        icon: trailingIcon,
                        size: .medium,
                        style: .secondary,
                        action: trailingAction
                    )
                }
            }
            .padding(.horizontal, Dimensions.paddingMedium)
            .padding(.vertical, Dimensions.paddingSmall)
        }
        .animation(.easeOut(duration: 0.2), value: scrollOffset > 10)
    }
}

// MARK: - Icon Button
struct IconButton: View {
    enum Size {
        case small, medium, large
        
        var dimension: CGFloat {
            switch self {
            case .small: return DeviceType.current.isIPad ? 40 : 36
            case .medium: return DeviceType.current.isIPad ? 48 : 44
            case .large: return DeviceType.current.isIPad ? 56 : 52
            }
        }
        
        var iconSize: CGFloat {
            switch self {
            case .small: return Dimensions.iconSizeSmall
            case .medium: return Dimensions.iconSizeMedium
            case .large: return Dimensions.iconSizeLarge
            }
        }
    }
    
    enum Style {
        case primary, secondary, ghost
        
        var background: some ShapeStyle {
            switch self {
            case .primary: return AnyShapeStyle(ColorPalette.primaryGradient)
            case .secondary: return AnyShapeStyle(Color(.systemGray5))
            case .ghost: return AnyShapeStyle(Color.clear)
            }
        }
        
        var foreground: Color {
            switch self {
            case .primary: return .white
            case .secondary: return ColorPalette.textPrimary
            case .ghost: return ColorPalette.primaryBlue
            }
        }
    }
    
    let icon: String
    let size: Size
    let style: Style
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            HapticManager.shared.impact(.light)
            action()
        }) {
            Image(systemName: icon)
                .font(.system(size: size.iconSize, weight: .medium))
                .foregroundColor(style.foreground)
                .frame(width: size.dimension, height: size.dimension)
                .background(style.background)
                .clipShape(Circle())
                .scaleEffect(isPressed ? 0.9 : 1.0)
        }
        .buttonStyle(PressedButtonStyle())
    }
}

// MARK: - Premium Card
struct PremiumCard<Content: View>: View {
    let content: () -> Content
    var padding: CGFloat? = nil
    var backgroundColor: Color = ColorPalette.surface
    
    var body: some View {
        content()
            .padding(padding ?? Dimensions.paddingMedium)
            .background(backgroundColor)
            .cornerRadius(Dimensions.cornerRadiusMedium)
            .shadow(
                color: ShadowStyle.subtle.color,
                radius: ShadowStyle.subtle.radius,
                x: ShadowStyle.subtle.x,
                y: ShadowStyle.subtle.y
            )
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
    
    @State private var animatedProgress: Double = 0
    
    var body: some View {
        PremiumCard {
            VStack(alignment: .leading, spacing: Dimensions.paddingMedium) {
                // Header
                HStack {
                    HStack(spacing: Dimensions.paddingSmall) {
                        Image(systemName: icon)
                            .font(.system(size: Dimensions.iconSizeMedium))
                            .foregroundColor(color)
                        
                        Text(title)
                            .font(Typography.headline)
                            .foregroundColor(ColorPalette.textPrimary)
                    }
                    
                    Spacer()
                    
                    Text("\(Int(animatedProgress * 100))%")
                        .font(Typography.headline)
                        .foregroundColor(color)
                        .monospacedDigit()
                }
                
                // Progress Bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(.systemGray5))
                            .frame(height: 12)
                        
                        RoundedRectangle(cornerRadius: 8)
                            .fill(
                                LinearGradient(
                                    colors: [color, color.opacity(0.6)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geometry.size.width * animatedProgress, height: 12)
                    }
                }
                .frame(height: 12)
                
                // Values
                HStack {
                    Text("\(currentValue) / \(targetValue)")
                        .font(Typography.subheadline)
                        .foregroundColor(ColorPalette.textSecondary)
                    
                    Spacer()
                    
                    if currentValue >= targetValue {
                        Label("Complete", systemImage: "checkmark.circle.fill")
                            .font(Typography.caption)
                            .foregroundColor(.green)
                    }
                }
            }
        }
        .onAppear {
            withAnimation(AnimationPresets.smooth.delay(0.2)) {
                animatedProgress = progress
            }
        }
    }
}

// MARK: - Animated Stats Card
struct AnimatedStatsCard: View {
    let title: String
    let value: String
    let subtitle: String
    let icon: String
    let color: Color
    let trend: TrendDirection?
    
    enum TrendDirection {
        case up(String)
        case down(String)
        case neutral
        
        var icon: String {
            switch self {
            case .up: return "arrow.up.right"
            case .down: return "arrow.down.right"
            case .neutral: return "minus"
            }
        }
        
        var color: Color {
            switch self {
            case .up: return .green
            case .down: return .red
            case .neutral: return .gray
            }
        }
    }
    
    @State private var isVisible = false
    
    var body: some View {
        PremiumCard {
            VStack(alignment: .leading, spacing: Dimensions.paddingSmall) {
                // Icon and Title
                HStack {
                    Image(systemName: icon)
                        .font(.system(size: Dimensions.iconSizeMedium))
                        .foregroundColor(color)
                        .rotationEffect(.degrees(isVisible ? 0 : -30))
                    
                    Spacer()
                    
                    if let trend = trend {
                        HStack(spacing: 4) {
                            Image(systemName: trend.icon)
                                .font(.caption)
                            
                            if case .up(let value) = trend {
                                Text(value)
                                    .font(.caption)
                            } else if case .down(let value) = trend {
                                Text(value)
                                    .font(.caption)
                            }
                        }
                        .foregroundColor(trend.color)
                        .opacity(isVisible ? 1 : 0)
                        .offset(y: isVisible ? 0 : 10)
                    }
                }
                
                // Value
                Text(value)
                    .font(Typography.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(ColorPalette.textPrimary)
                    .scaleEffect(isVisible ? 1 : 0.8)
                    .opacity(isVisible ? 1 : 0)
                
                // Subtitle
                Text(subtitle)
                    .font(Typography.subheadline)
                    .foregroundColor(ColorPalette.textSecondary)
                    .opacity(isVisible ? 1 : 0)
                
                Text(title)
                    .font(Typography.caption)
                    .foregroundColor(ColorPalette.textTertiary)
            }
        }
        .onAppear {
            withAnimation(AnimationPresets.bouncy.delay(0.1)) {
                isVisible = true
            }
        }
    }
}

// MARK: - Lesson Card (Premium)
struct PremiumLessonCard: View {
    let lesson: Lesson
    let progress: Double?
    let isLocked: Bool
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            HapticManager.shared.impact(.medium)
            action()
        }) {
            PremiumCard {
                HStack(spacing: Dimensions.paddingMedium) {
                    // Icon/Progress Circle
                    ZStack {
                        if let progress = progress {
                            CircularProgressView(
                                progress: progress,
                                lineWidth: 6,
                                size: DeviceType.current.isIPad ? 80 : 60,
                                gradient: ColorPalette.primaryGradient
                            )
                        } else {
                            Circle()
                                .fill(lesson.category.categoryColor.opacity(0.2))
                                .frame(width: DeviceType.current.isIPad ? 80 : 60, height: DeviceType.current.isIPad ? 80 : 60)
                        }
                        
                        Image(systemName: isLocked ? "lock.fill" : lesson.category.iconName)
                            .font(.system(size: Dimensions.iconSizeMedium))
                            .foregroundColor(isLocked ? .gray : lesson.category.categoryColor)
                    }
                    
                    // Content
                    VStack(alignment: .leading, spacing: 6) {
                        Text(lesson.title)
                            .font(Typography.headline)
                            .foregroundColor(ColorPalette.textPrimary)
                            .lineLimit(1)
                        
                        Text(lesson.description)
                            .font(Typography.subheadline)
                            .foregroundColor(ColorPalette.textSecondary)
                            .lineLimit(2)
                        
                        // Metadata
                        HStack(spacing: Dimensions.paddingMedium) {
                            Label("\(lesson.estimatedMinutes)m", systemImage: "clock")
                                .font(Typography.caption)
                                .foregroundColor(ColorPalette.textTertiary)
                            
                            Label("\(lesson.xpReward) XP", systemImage: "star.fill")
                                .font(Typography.caption)
                                .foregroundColor(.yellow)
                            
                            Spacer()
                        }
                    }
                    
                    // Chevron
                    Image(systemName: "chevron.right")
                        .font(.system(size: Dimensions.iconSizeSmall))
                        .foregroundColor(ColorPalette.textTertiary)
                        .opacity(isLocked ? 0 : 1)
                }
            }
            .opacity(isLocked ? 0.6 : 1)
            .scaleEffect(isPressed ? 0.98 : 1)
        }
        .buttonStyle(PressedButtonStyle())
        .disabled(isLocked)
    }
}

// MARK: - Circular Progress View
struct CircularProgressView: View {
    let progress: Double
    let lineWidth: CGFloat
    let size: CGFloat
    let gradient: LinearGradient
    
    @State private var animatedProgress: Double = 0
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color(.systemGray5), lineWidth: lineWidth)
                .frame(width: size, height: size)
            
            Circle()
                .trim(from: 0, to: animatedProgress)
                .stroke(gradient, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .frame(width: size, height: size)
                .rotationEffect(.degrees(-90))
        }
        .onAppear {
            withAnimation(AnimationPresets.smooth.delay(0.1)) {
                animatedProgress = progress
            }
        }
    }
}

// MARK: - Premium Button
struct PremiumButton: View {
    enum ButtonStyle {
        case primary, secondary, ghost, danger
        
        var background: some ShapeStyle {
            switch self {
            case .primary: return AnyShapeStyle(ColorPalette.primaryGradient)
            case .secondary: return AnyShapeStyle(Color(.systemGray5))
            case .ghost: return AnyShapeStyle(Color.clear)
            case .danger: return AnyShapeStyle(ColorPalette.error)
            }
        }
        
        var foreground: Color {
            switch self {
            case .primary, .danger: return .white
            case .secondary: return ColorPalette.textPrimary
            case .ghost: return ColorPalette.primaryBlue
            }
        }
    }
    
    let title: String
    let icon: String?
    let style: ButtonStyle
    let isFullWidth: Bool
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            HapticManager.shared.impact(.medium)
            action()
        }) {
            HStack(spacing: Dimensions.paddingSmall) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: Dimensions.iconSizeSmall))
                }
                
                Text(title)
                    .font(Typography.headline)
                    .fontWeight(.semibold)
                
                if isFullWidth {
                    Spacer()
                }
            }
            .foregroundColor(style.foreground)
            .padding(.horizontal, Dimensions.paddingMedium)
            .padding(.vertical, Dimensions.paddingSmall)
            .frame(maxWidth: isFullWidth ? .infinity : nil)
            .frame(height: Dimensions.buttonHeight)
            .background(style.background)
            .cornerRadius(Dimensions.cornerRadiusMedium)
            .overlay(
                style == .ghost ?
                RoundedRectangle(cornerRadius: Dimensions.cornerRadiusMedium)
                    .stroke(ColorPalette.primaryBlue, lineWidth: 2) : nil
            )
            .scaleEffect(isPressed ? 0.98 : 1)
            .shadow(
                color: style == .primary ? ColorPalette.primaryBlue.opacity(0.3) : .clear,
                radius: 8,
                y: 4
            )
        }
        .buttonStyle(PressedButtonStyle())
    }
}

// MARK: - Pressed Button Style
struct PressedButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(AnimationPresets.quick, value: configuration.isPressed)
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

// MARK: - Skeleton Loader
struct SkeletonLoader: View {
    @State private var isAnimating = false
    let height: CGFloat
    
    var body: some View {
        LinearGradient(
            colors: [
                Color(.systemGray5),
                Color(.systemGray6),
                Color(.systemGray5)
            ],
            startPoint: .leading,
            endPoint: .trailing
        )
        .frame(height: height)
        .cornerRadius(Dimensions.cornerRadiusSmall)
        .offset(x: isAnimating ? 200 : -200)
        .animation(
            Animation.linear(duration: 1.5).repeatForever(autoreverses: false),
            value: isAnimating
        )
        .onAppear {
            isAnimating = true
        }
    }
}

// MARK: - AnyShapeStyle Helper
struct AnyShapeStyle: ShapeStyle {
    private let _resolve: (EnvironmentValues) -> AnyShapeStyle._Resolved
    
    init<S: ShapeStyle>(_ style: S) {
        _resolve = { environment in
            AnyShapeStyle._Resolved(style: style.resolve(in: environment))
        }
    }
    
    func resolve(in environment: EnvironmentValues) -> some ShapeStyle {
        _resolve(environment)
    }
    
    struct _Resolved: ShapeStyle {
        let style: any ShapeStyle
        
        func resolve(in environment: EnvironmentValues) -> some ShapeStyle {
            style
        }
    }
}
