// MARK: - Design System Foundation
// File: ArtOfTheFuture/Core/Design/DesignSystem.swift

import SwiftUI

// MARK: - Device Management
enum DeviceType {
    case iPhone
    case iPad
    case iPadPro12_9
    
    static var current: DeviceType {
        if UIDevice.current.userInterfaceIdiom == .pad {
            let screenSize = UIScreen.main.bounds.size
            let maxDimension = max(screenSize.width, screenSize.height)
            return maxDimension >= 1366 ? .iPadPro12_9 : .iPad
        }
        return .iPhone
    }
    
    var isIPad: Bool {
        self == .iPad || self == .iPadPro12_9
    }
}

// MARK: - Size Classes
struct SizeClass {
    let horizontal: UserInterfaceSizeClass?
    let vertical: UserInterfaceSizeClass?
    
    var isRegularWidth: Bool {
        horizontal == .regular
    }
    
    var isCompact: Bool {
        horizontal == .compact && vertical == .regular
    }
    
    var isIPadFullScreen: Bool {
        horizontal == .regular && vertical == .regular
    }
}

// MARK: - Responsive Dimensions
struct Dimensions {
    static let device = DeviceType.current
    
    // Adaptive Spacing
    static var paddingSmall: CGFloat {
        device.isIPad ? 16 : 12
    }
    
    static var paddingMedium: CGFloat {
        device.isIPad ? 24 : 16
    }
    
    static var paddingLarge: CGFloat {
        device.isIPad ? 32 : 20
    }
    
    static var paddingXLarge: CGFloat {
        device.isIPad ? 48 : 24
    }
    
    // Corner Radius
    static var cornerRadiusSmall: CGFloat {
        device.isIPad ? 12 : 8
    }
    
    static var cornerRadiusMedium: CGFloat {
        device.isIPad ? 20 : 16
    }
    
    static var cornerRadiusLarge: CGFloat {
        device.isIPad ? 28 : 20
    }
    
    // Component Sizes
    static var buttonHeight: CGFloat {
        device.isIPad ? 56 : 48
    }
    
    static var iconSizeSmall: CGFloat {
        device.isIPad ? 24 : 20
    }
    
    static var iconSizeMedium: CGFloat {
        device.isIPad ? 32 : 24
    }
    
    static var iconSizeLarge: CGFloat {
        device.isIPad ? 48 : 36
    }
    
    // Grid Layouts
    static var gridColumns: Int {
        switch device {
        case .iPhone: return 2
        case .iPad: return 3
        case .iPadPro12_9: return 4
        }
    }
    
    static var maxContentWidth: CGFloat {
        switch device {
        case .iPhone: return .infinity
        case .iPad: return 768
        case .iPadPro12_9: return 1024
        }
    }
}

// MARK: - Color Palette
struct ColorPalette {
    // Primary Colors
    static let primaryBlue = Color(hex: "007AFF")
    static let primaryPurple = Color(hex: "5856D6")
    static let primaryGreen = Color(hex: "34C759")
    static let primaryOrange = Color(hex: "FF9500")
    static let primaryRed = Color(hex: "FF3B30")
    static let primaryYellow = Color(hex: "FFCC00")
    
    // Gradient Definitions
    static let primaryGradient = LinearGradient(
        colors: [primaryBlue, primaryPurple],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let successGradient = LinearGradient(
        colors: [primaryGreen, Color(hex: "30D158")],
        startPoint: .leading,
        endPoint: .trailing
    )
    
    static let warningGradient = LinearGradient(
        colors: [primaryOrange, primaryYellow],
        startPoint: .leading,
        endPoint: .trailing
    )
    
    static let premiumGradient = LinearGradient(
        colors: [
            Color(hex: "FF6B6B"),
            Color(hex: "4ECDC4"),
            Color(hex: "45B7D1")
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    // Surface Colors
    static let surface = Color(.systemBackground)
    static let surfaceSecondary = Color(.secondarySystemBackground)
    static let surfaceTertiary = Color(.tertiarySystemBackground)
    
    // Text Colors
    static let textPrimary = Color(.label)
    static let textSecondary = Color(.secondaryLabel)
    static let textTertiary = Color(.tertiaryLabel)
    
    // Semantic Colors
    static let success = primaryGreen
    static let warning = primaryOrange
    static let error = primaryRed
    static let info = primaryBlue
}

// MARK: - Typography
struct Typography {
    static let device = DeviceType.current
    
    // Dynamic Font Sizes
    static var largeTitle: Font {
        device.isIPad ? .system(size: 38, weight: .bold, design: .rounded) : .largeTitle.weight(.bold)
    }
    
    static var title1: Font {
        device.isIPad ? .system(size: 32, weight: .semibold, design: .rounded) : .title.weight(.semibold)
    }
    
    static var title2: Font {
        device.isIPad ? .system(size: 26, weight: .semibold, design: .rounded) : .title2.weight(.semibold)
    }
    
    static var title3: Font {
        device.isIPad ? .system(size: 22, weight: .medium, design: .rounded) : .title3.weight(.medium)
    }
    
    static var headline: Font {
        device.isIPad ? .system(size: 19, weight: .semibold) : .headline
    }
    
    static var body: Font {
        device.isIPad ? .system(size: 17) : .body
    }
    
    static var callout: Font {
        device.isIPad ? .system(size: 16) : .callout
    }
    
    static var subheadline: Font {
        device.isIPad ? .system(size: 15) : .subheadline
    }
    
    static var footnote: Font {
        device.isIPad ? .system(size: 13) : .footnote
    }
    
    static var caption: Font {
        device.isIPad ? .system(size: 12) : .caption
    }
}

// MARK: - Animation Presets
struct AnimationPresets {
    static let smooth = Animation.spring(response: 0.5, dampingFraction: 0.8, blendDuration: 0)
    static let bouncy = Animation.spring(response: 0.6, dampingFraction: 0.6, blendDuration: 0)
    static let quick = Animation.easeOut(duration: 0.25)
    static let interactive = Animation.interactiveSpring(response: 0.3, dampingFraction: 0.8, blendDuration: 0.25)
}

// MARK: - Shadow Styles
struct ShadowStyle {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
    
    static let subtle = ShadowStyle(
        color: Color.black.opacity(0.08),
        radius: DeviceType.current.isIPad ? 8 : 4,
        x: 0,
        y: 2
    )
    
    static let medium = ShadowStyle(
        color: Color.black.opacity(0.12),
        radius: DeviceType.current.isIPad ? 16 : 8,
        x: 0,
        y: 4
    )
    
    static let elevated = ShadowStyle(
        color: Color.black.opacity(0.16),
        radius: DeviceType.current.isIPad ? 24 : 12,
        x: 0,
        y: 8
    )
    
    static let neumorphic = ShadowStyle(
        color: Color.black.opacity(0.2),
        radius: DeviceType.current.isIPad ? 20 : 10,
        x: 5,
        y: 5
    )
}

// MARK: - Layout Helpers
struct ResponsiveLayout {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    
    var columns: [GridItem] {
        let count = columnCount
        return Array(repeating: GridItem(.flexible(), spacing: Dimensions.paddingMedium), count: count)
    }
    
    var columnCount: Int {
        if horizontalSizeClass == .regular && verticalSizeClass == .regular {
            return 4 // iPad landscape
        } else if horizontalSizeClass == .regular {
            return 3 // iPad portrait
        } else {
            return 2 // iPhone
        }
    }
}

// MARK: - View Extensions
extension View {
    func adaptivePadding() -> some View {
        self.padding(DeviceType.current.isIPad ? 24 : 16)
    }
    
    func adaptiveFrame(maxWidth: CGFloat? = nil) -> some View {
        self.frame(maxWidth: maxWidth ?? Dimensions.maxContentWidth)
    }
    
    func cardStyle(padding: CGFloat? = nil) -> some View {
        self
            .padding(padding ?? Dimensions.paddingMedium)
            .background(ColorPalette.surface)
            .cornerRadius(Dimensions.cornerRadiusMedium)
            .shadow(
                color: ShadowStyle.subtle.color,
                radius: ShadowStyle.subtle.radius,
                x: ShadowStyle.subtle.x,
                y: ShadowStyle.subtle.y
            )
    }
    
    func glassEffect() -> some View {
        self
            .background(.ultraThinMaterial)
            .cornerRadius(Dimensions.cornerRadiusMedium)
            .overlay(
                RoundedRectangle(cornerRadius: Dimensions.cornerRadiusMedium)
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
            )
    }
}

// MARK: - Device Preview Helper
struct DevicePreview<Content: View>: View {
    let content: () -> Content
    
    var body: some View {
        Group {
            // iPhone Preview
            content()
                .previewDevice("iPhone 15 Pro")
                .previewDisplayName("iPhone")
            
            // iPad Preview
            content()
                .previewDevice("iPad Pro (11-inch) (4th generation)")
                .previewDisplayName("iPad")
            
            // iPad Pro 12.9 Preview
            content()
                .previewDevice("iPad Pro (12.9-inch) (6th generation)")
                .previewDisplayName("iPad Pro")
        }
    }
}

// MARK: - Color Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
