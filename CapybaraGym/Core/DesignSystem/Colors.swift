//
//  Colors.swift
//  CapybaraGym
//
//  Design System - Colors
//

import SwiftUI

// MARK: - CapyColors
/// The main color palette for Capybara Gym app
public struct CapyColors {
    
    // MARK: - Primary Colors
    /// Primary brand color - Red-brown (#7d3e3a)
    public static let primary = Color(hex: "#7d3e3a")
    
    /// Primary color with opacity variants
    public static let primaryLight = Color(hex: "#7d3e3a").opacity(0.7)
    public static let primaryLighter = Color(hex: "#7d3e3a").opacity(0.4)
    public static let primaryDark = Color(hex: "#5a2d2a")
    
    // MARK: - Background Colors
    /// Main background color - Light gray-blue (#f4f4f9)
    public static let background = Color(hex: "#f4f4f9")
    
    /// Secondary background
    public static let backgroundSecondary = Color(hex: "#ffffff")
    
    /// Card background color - (#e8e9f2)
    public static let cardBackground = Color(hex: "#e8e9f2")
    
    /// Elevated card background
    public static let cardElevated = Color(hex: "#ffffff")
    
    // MARK: - Text Colors
    /// Primary text color - Dark (#0e0c0b)
    public static let textPrimary = Color(hex: "#0e0c0b")
    
    /// Secondary text color - Gray (#6d6f82)
    public static let textSecondary = Color(hex: "#6d6f82")
    
    /// Tertiary text color
    public static let textTertiary = Color(hex: "#9a9cb0")
    
    /// Inverse text color (for dark backgrounds)
    public static let textInverse = Color(hex: "#ffffff")
    
    // MARK: - Semantic Colors
    /// Success color
    public static let success = Color(hex: "#34c759")
    
    /// Warning color
    public static let warning = Color(hex: "#ff9500")
    
    /// Error color
    public static let error = Color(hex: "#ff3b30")
    
    /// Info color
    public static let info = Color(hex: "#007aff")
    
    // MARK: - UI Colors
    /// Divider/Separator color
    public static let divider = Color(hex: "#e0e0e0")
    
    /// Shadow color
    public static let shadow = Color(hex: "#000000").opacity(0.1)
    
    /// Disabled state color
    public static let disabled = Color(hex: "#c7c7cc")
    
    /// Placeholder text color
    public static let placeholder = Color(hex: "#9a9cb0")
    
    // MARK: - Accent Colors
    /// Secondary accent
    public static let accentSecondary = Color(hex: "#5856d6")
    
    /// Tertiary accent
    public static let accentTertiary = Color(hex: "#af52de")
}

// MARK: - Color Extension for Hex
public extension Color {
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
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
    
    /// Convert Color to UIColor
    var uiColor: UIColor {
        UIColor(self)
    }
}

// MARK: - Gradient Presets
public struct CapyGradients {
    
    /// Primary gradient for buttons and highlights
    public static let primary = LinearGradient(
        colors: [CapyColors.primary, CapyColors.primaryDark],
        startPoint: .leading,
        endPoint: .trailing
    )
    
    /// Background gradient
    public static let background = LinearGradient(
        colors: [CapyColors.background, CapyColors.cardBackground],
        startPoint: .top,
        endPoint: .bottom
    )
    
    /// Card gradient
    public static let card = LinearGradient(
        colors: [CapyColors.cardElevated, CapyColors.cardBackground],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    /// Success gradient
    public static let success = LinearGradient(
        colors: [CapyColors.success, CapyColors.success.opacity(0.7)],
        startPoint: .leading,
        endPoint: .trailing
    )
}
