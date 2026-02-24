//
//  Spacing.swift
//  CapybaraGym
//
//  Design System - Spacing & Layout
//

import SwiftUI

// MARK: - CapySpacing
/// Spacing system for Capybara Gym app
public struct CapySpacing {
    
    // MARK: - Base Spacing (4pt grid)
    /// 4pt - Extra extra small
    public static let xxSmall: CGFloat = 4
    
    /// 8pt - Extra small
    public static let xSmall: CGFloat = 8
    
    /// 12pt - Small
    public static let small: CGFloat = 12
    
    /// 16pt - Medium (default)
    public static let medium: CGFloat = 16
    
    /// 20pt - Medium large
    public static let mediumLarge: CGFloat = 20
    
    /// 24pt - Large
    public static let large: CGFloat = 24
    
    /// 32pt - Extra large
    public static let xLarge: CGFloat = 32
    
    /// 40pt - Extra extra large
    public static let xxLarge: CGFloat = 40
    
    /// 48pt - Huge
    public static let huge: CGFloat = 48
    
    /// 64pt - Extra huge
    public static let xHuge: CGFloat = 64
    
    // MARK: - Section Spacing
    /// Section padding - 20pt
    public static let sectionPadding: CGFloat = 20
    
    /// Content padding - 16pt
    public static let contentPadding: CGFloat = 16
    
    /// Card padding - 16pt
    public static let cardPadding: CGFloat = 16
    
    /// Screen horizontal padding - 20pt
    public static let screenHorizontal: CGFloat = 20
    
    /// Screen vertical padding - 16pt
    public static let screenVertical: CGFloat = 16
}

// MARK: - CapyRadius
/// Corner radius system for Capybara Gym app
public struct CapyRadius {
    
    /// 4pt - Small radius
    public static let small: CGFloat = 4
    
    /// 8pt - Medium radius
    public static let medium: CGFloat = 8
    
    /// 12pt - Large radius
    public static let large: CGFloat = 12
    
    /// 16pt - Extra large radius (cards)
    public static let xLarge: CGFloat = 16
    
    /// 20pt - Extra extra large radius
    public static let xxLarge: CGFloat = 20
    
    /// 100pt - Fully rounded (buttons)
    public static let fullyRounded: CGFloat = 100
    
    /// Capsule shape
    public static let capsule: CGFloat = 9999
}

// MARK: - CapyShadow
/// Shadow system for Capybara Gym app
public struct CapyShadow {
    
    /// Small shadow for cards
    public static let small = ShadowStyle(
        color: CapyColors.shadow,
        radius: 4,
        x: 0,
        y: 2
    )
    
    /// Medium shadow for elevated cards
    public static let medium = ShadowStyle(
        color: CapyColors.shadow,
        radius: 8,
        x: 0,
        y: 4
    )
    
    /// Large shadow for modals/sheets
    public static let large = ShadowStyle(
        color: CapyColors.shadow,
        radius: 16,
        x: 0,
        y: 8
    )
    
    /// No shadow
    public static let none = ShadowStyle(
        color: .clear,
        radius: 0,
        x: 0,
        y: 0
    )
}

// MARK: - Shadow Style
public struct ShadowStyle {
    public let color: Color
    public let radius: CGFloat
    public let x: CGFloat
    public let y: CGFloat
    
    public init(color: Color, radius: CGFloat, x: CGFloat, y: CGFloat) {
        self.color = color
        self.radius = radius
        self.x = x
        self.y = y
    }
}

// MARK: - View Extensions for Spacing
public extension View {
    
    /// Apply standard screen padding
    func screenPadding() -> some View {
        self.padding(.horizontal, CapySpacing.screenHorizontal)
            .padding(.vertical, CapySpacing.screenVertical)
    }
    
    /// Apply horizontal screen padding only
    func horizontalScreenPadding() -> some View {
        self.padding(.horizontal, CapySpacing.screenHorizontal)
    }
    
    /// Apply card padding
    func cardPadding() -> some View {
        self.padding(CapySpacing.cardPadding)
    }
    
    /// Apply section padding
    func sectionPadding() -> some View {
        self.padding(CapySpacing.sectionPadding)
    }
    
    /// Apply custom shadow
    func capyShadow(_ style: ShadowStyle) -> some View {
        self.shadow(
            color: style.color,
            radius: style.radius,
            x: style.x,
            y: style.y
        )
    }
    
    /// Apply card style with shadow and radius
    func cardStyle(radius: CGFloat = CapyRadius.xLarge) -> some View {
        self.background(CapyColors.cardElevated)
            .cornerRadius(radius)
            .capyShadow(CapyShadow.small)
    }
}

// MARK: - Layout Constants
public struct CapyLayout {
    
    /// Standard button height - 56pt
    public static let buttonHeight: CGFloat = 56
    
    /// Small button height - 44pt
    public static let buttonHeightSmall: CGFloat = 44
    
    /// Text field height - 56pt
    public static let textFieldHeight: CGFloat = 56
    
    /// Tab bar height - 80pt (including safe area)
    public static let tabBarHeight: CGFloat = 80
    
    /// Navigation bar height - 44pt
    public static let navigationBarHeight: CGFloat = 44
    
    /// Standard icon size - 24pt
    public static let iconSize: CGFloat = 24
    
    /// Large icon size - 32pt
    public static let iconSizeLarge: CGFloat = 32
    
    /// Small icon size - 16pt
    public static let iconSizeSmall: CGFloat = 16
    
    /// Avatar size - 48pt
    public static let avatarSize: CGFloat = 48
    
    /// Large avatar size - 64pt
    public static let avatarSizeLarge: CGFloat = 64
    
    /// Card minimum width - 160pt
    public static let cardMinWidth: CGFloat = 160
    
    /// Card maximum width - 400pt
    public static let cardMaxWidth: CGFloat = 400
}

// MARK: - Safe Area Insets Helper
public struct SafeAreaInsets {
    public static var top: CGFloat {
        UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0
    }
    
    public static var bottom: CGFloat {
        UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0
    }
    
    public static var left: CGFloat {
        UIApplication.shared.windows.first?.safeAreaInsets.left ?? 0
    }
    
    public static var right: CGFloat {
        UIApplication.shared.windows.first?.safeAreaInsets.right ?? 0
    }
}
