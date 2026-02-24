//
//  Typography.swift
//  CapybaraGym
//
//  Design System - Typography
//

import SwiftUI

// MARK: - CapyTypography
/// Typography system for Capybara Gym app
public struct CapyTypography {
    
    // MARK: - Font Families
    public struct FontFamily {
        /// Primary font - Outfit
        public static let outfitRegular = "Outfit-Regular"
        public static let outfitMedium = "Outfit-Medium"
        public static let outfitSemiBold = "Outfit-SemiBold"
        public static let outfitBold = "Outfit-Bold"
        public static let outfitLight = "Outfit-Light"
        
        /// Display font - Merriweather
        public static let merriweatherRegular = "Merriweather-Regular"
        public static let merriweatherBold = "Merriweather-Bold"
        public static let merriweatherItalic = "Merriweather-Italic"
        public static let merriweatherBoldItalic = "Merriweather-BoldItalic"
    }
    
    // MARK: - Display Styles (Merriweather)
    /// Large display title - for hero sections
    public static let displayLarge = Font.custom(FontFamily.merriweatherBold, size: 40)
    
    /// Medium display title
    public static let displayMedium = Font.custom(FontFamily.merriweatherBold, size: 32)
    
    /// Small display title
    public static let displaySmall = Font.custom(FontFamily.merriweatherBold, size: 24)
    
    // MARK: - Heading Styles (Outfit)
    /// Large heading - H1
    public static let heading1 = Font.custom(FontFamily.outfitBold, size: 28)
    
    /// Medium heading - H2
    public static let heading2 = Font.custom(FontFamily.outfitSemiBold, size: 24)
    
    /// Small heading - H3
    public static let heading3 = Font.custom(FontFamily.outfitSemiBold, size: 20)
    
    /// Extra small heading - H4
    public static let heading4 = Font.custom(FontFamily.outfitSemiBold, size: 18)
    
    /// Tiny heading - H5
    public static let heading5 = Font.custom(FontFamily.outfitMedium, size: 16)
    
    // MARK: - Body Styles (Outfit)
    /// Large body text
    public static let bodyLarge = Font.custom(FontFamily.outfitRegular, size: 18)
    
    /// Medium body text - default
    public static let bodyMedium = Font.custom(FontFamily.outfitRegular, size: 16)
    
    /// Small body text
    public static let bodySmall = Font.custom(FontFamily.outfitRegular, size: 14)
    
    /// Extra small body text
    public static let bodyXSmall = Font.custom(FontFamily.outfitRegular, size: 12)
    
    // MARK: - Label Styles (Outfit Medium)
    /// Large label
    public static let labelLarge = Font.custom(FontFamily.outfitMedium, size: 16)
    
    /// Medium label
    public static let labelMedium = Font.custom(FontFamily.outfitMedium, size: 14)
    
    /// Small label
    public static let labelSmall = Font.custom(FontFamily.outfitMedium, size: 12)
    
    // MARK: - Button Styles
    /// Primary button text
    public static let buttonPrimary = Font.custom(FontFamily.outfitSemiBold, size: 16)
    
    /// Secondary button text
    public static let buttonSecondary = Font.custom(FontFamily.outfitMedium, size: 14)
    
    /// Small button text
    public static let buttonSmall = Font.custom(FontFamily.outfitMedium, size: 12)
    
    // MARK: - Caption Styles
    /// Caption text
    public static let caption = Font.custom(FontFamily.outfitRegular, size: 12)
    
    /// Overline text - uppercase, small
    public static let overline = Font.custom(FontFamily.outfitMedium, size: 10)
}

// MARK: - Text Style Extensions
public extension Text {
    
    // MARK: - Display Styles
    func displayLarge() -> some View {
        self.font(CapyTypography.displayLarge)
            .foregroundColor(CapyColors.textPrimary)
    }
    
    func displayMedium() -> some View {
        self.font(CapyTypography.displayMedium)
            .foregroundColor(CapyColors.textPrimary)
    }
    
    func displaySmall() -> some View {
        self.font(CapyTypography.displaySmall)
            .foregroundColor(CapyColors.textPrimary)
    }
    
    // MARK: - Heading Styles
    func heading1() -> some View {
        self.font(CapyTypography.heading1)
            .foregroundColor(CapyColors.textPrimary)
    }
    
    func heading2() -> some View {
        self.font(CapyTypography.heading2)
            .foregroundColor(CapyColors.textPrimary)
    }
    
    func heading3() -> some View {
        self.font(CapyTypography.heading3)
            .foregroundColor(CapyColors.textPrimary)
    }
    
    func heading4() -> some View {
        self.font(CapyTypography.heading4)
            .foregroundColor(CapyColors.textPrimary)
    }
    
    // MARK: - Body Styles
    func bodyLarge() -> some View {
        self.font(CapyTypography.bodyLarge)
            .foregroundColor(CapyColors.textPrimary)
    }
    
    func bodyMedium() -> some View {
        self.font(CapyTypography.bodyMedium)
            .foregroundColor(CapyColors.textPrimary)
    }
    
    func bodySmall() -> some View {
        self.font(CapyTypography.bodySmall)
            .foregroundColor(CapyColors.textSecondary)
    }
    
    // MARK: - Label Styles
    func labelLarge() -> some View {
        self.font(CapyTypography.labelLarge)
            .foregroundColor(CapyColors.textPrimary)
    }
    
    func labelMedium() -> some View {
        self.font(CapyTypography.labelMedium)
            .foregroundColor(CapyColors.textSecondary)
    }
    
    // MARK: - Semantic Styles
    func primaryText() -> some View {
        self.foregroundColor(CapyColors.textPrimary)
    }
    
    func secondaryText() -> some View {
        self.foregroundColor(CapyColors.textSecondary)
    }
    
    func captionStyle() -> some View {
        self.font(CapyTypography.caption)
            .foregroundColor(CapyColors.textTertiary)
    }
}

// MARK: - Font Registration Helper
public struct FontRegistration {
    
    /// Register custom fonts with the app
    /// Call this in AppDelegate or App init
    public static func registerFonts() {
        let fontNames = [
            CapyTypography.FontFamily.outfitRegular,
            CapyTypography.FontFamily.outfitMedium,
            CapyTypography.FontFamily.outfitSemiBold,
            CapyTypography.FontFamily.outfitBold,
            CapyTypography.FontFamily.outfitLight,
            CapyTypography.FontFamily.merriweatherRegular,
            CapyTypography.FontFamily.merriweatherBold,
            CapyTypography.FontFamily.merriweatherItalic,
            CapyTypography.FontFamily.merriweatherBoldItalic
        ]
        
        for fontName in fontNames {
            registerFont(named: fontName)
        }
    }
    
    private static func registerFont(named name: String) {
        guard let fontURL = Bundle.main.url(forResource: name, withExtension: "ttf"),
              let fontDataProvider = CGDataProvider(url: fontURL as CFURL),
              let font = CGFont(fontDataProvider) else {
            print("⚠️ Failed to load font: \(name)")
            return
        }
        
        var error: Unmanaged<CFError>?
        if !CTFontManagerRegisterGraphicsFont(font, &error) {
            print("⚠️ Failed to register font: \(name)")
        }
    }
}
