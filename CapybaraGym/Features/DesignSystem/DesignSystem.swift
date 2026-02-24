//
//  DesignSystem.swift
//  CapybaraGym
//
//  Design System for Capybara Gym App
//  Based on Figma specifications
//

import SwiftUI

// MARK: - Colors
extension Color {
    // Primary Colors
    static let primaryBrown = Color(hex: "#7d3e3a")
    static let primaryBrownLight = Color(hex: "#9a5a56")
    static let primaryBrownDark = Color(hex: "#5e2e2b")
    
    // Background Colors
    static let appBackground = Color(hex: "#ffffff")
    static let cardBackground = Color(hex: "#f4f4f9")
    static let inputBackground = Color(hex: "#e8eaf3")
    static let tabBarBackground = Color(hex: "#e8e9f2")
    
    // Text Colors
    static let primaryText = Color(hex: "#1a1a1a")
    static let secondaryText = Color(hex: "#666666")
    static let tertiaryText = Color(hex: "#999999")
    
    // Status Colors
    static let successGreen = Color(hex: "#4CAF50")
    static let warningOrange = Color(hex: "#FF9800")
    static let errorRed = Color(hex: "#F44336")
    
    // Occupancy Colors
    static let occupancyLow = Color(hex: "#4CAF50")
    static let occupancyMedium = Color(hex: "#FF9800")
    static let occupancyHigh = Color(hex: "#F44336")
    
    // Social Colors
    static let googleRed = Color(hex: "#DB4437")
    static let facebookBlue = Color(hex: "#4267B2")
    static let appleBlack = Color(hex: "#000000")
    
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
}

// MARK: - Typography
struct OutfitFont {
    static let light = "Outfit-Light"
    static let regular = "Outfit-Regular"
    static let medium = "Outfit-Medium"
    static let semiBold = "Outfit-SemiBold"
    static let bold = "Outfit-Bold"
}

extension Font {
    // Large Titles
    static let largeTitle = Font.custom(OutfitFont.medium, size: 34)
    static let largeTitleLight = Font.custom(OutfitFont.light, size: 34)
    
    // Titles
    static let title1 = Font.custom(OutfitFont.medium, size: 28)
    static let title2 = Font.custom(OutfitFont.medium, size: 22)
    static let title3 = Font.custom(OutfitFont.regular, size: 20)
    
    // Headlines
    static let headline = Font.custom(OutfitFont.medium, size: 17)
    static let subheadline = Font.custom(OutfitFont.regular, size: 15)
    
    // Body
    static let bodyLarge = Font.custom(OutfitFont.regular, size: 17)
    static let bodyMedium = Font.custom(OutfitFont.regular, size: 15)
    static let bodySmall = Font.custom(OutfitFont.regular, size: 13)
    
    // Captions
    static let caption = Font.custom(OutfitFont.regular, size: 12)
    static let captionMedium = Font.custom(OutfitFont.medium, size: 12)
    
    // Buttons
    static let button = Font.custom(OutfitFont.medium, size: 16)
    static let buttonSmall = Font.custom(OutfitFont.medium, size: 14)
}

// MARK: - Layout Constants
struct Layout {
    // Screen
    static let screenWidth: CGFloat = 375
    static let screenHeight: CGFloat = 812
    
    // Spacing
    static let spacingXS: CGFloat = 4
    static let spacingS: CGFloat = 8
    static let spacingM: CGFloat = 16
    static let spacingL: CGFloat = 24
    static let spacingXL: CGFloat = 32
    
    // Component Sizes
    static let primaryButtonWidth: CGFloat = 342
    static let primaryButtonHeight: CGFloat = 48
    static let inputFieldWidth: CGFloat = 342
    static let inputFieldHeight: CGFloat = 50
    static let gymCardWidth: CGFloat = 343
    static let gymCardHeight: CGFloat = 432
    static let tabBarHeight: CGFloat = 64
    
    // Corner Radii
    static let radiusSmall: CGFloat = 8
    static let radiusMedium: CGFloat = 12
    static let radiusLarge: CGFloat = 16
    static let radiusFull: CGFloat = 100
    
    // Padding
    static let horizontalPadding: CGFloat = 16
}

// MARK: - Shadow Styles
struct ShadowStyle {
    static let card = ShadowConfiguration(
        color: Color.black.opacity(0.08),
        radius: 12,
        x: 0,
        y: 4
    )
    
    static let button = ShadowConfiguration(
        color: Color.primaryBrown.opacity(0.25),
        radius: 8,
        x: 0,
        y: 4
    )
    
    static let elevated = ShadowConfiguration(
        color: Color.black.opacity(0.12),
        radius: 16,
        x: 0,
        y: 8
    )
}

struct ShadowConfiguration {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
}

extension View {
    func customShadow(_ config: ShadowConfiguration) -> some View {
        self.shadow(color: config.color, radius: config.radius, x: config.x, y: config.y)
    }
}

// MARK: - Button Styles
struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.button)
            .foregroundColor(.white)
            .frame(width: Layout.primaryButtonWidth, height: Layout.primaryButtonHeight)
            .background(Color.primaryBrown)
            .cornerRadius(Layout.radiusFull)
            .customShadow(ShadowStyle.button)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.button)
            .foregroundColor(.primaryBrown)
            .frame(width: Layout.primaryButtonWidth, height: Layout.primaryButtonHeight)
            .background(Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: Layout.radiusFull)
                    .stroke(Color.primaryBrown, lineWidth: 1.5)
            )
            .cornerRadius(Layout.radiusFull)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct SocialButtonStyle: ButtonStyle {
    let backgroundColor: Color
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.buttonSmall)
            .foregroundColor(backgroundColor == .white ? .primaryText : .white)
            .frame(height: 48)
            .frame(maxWidth: .infinity)
            .background(backgroundColor)
            .overlay(
                RoundedRectangle(cornerRadius: Layout.radiusMedium)
                    .stroke(Color.gray.opacity(0.2), lineWidth: backgroundColor == .white ? 1 : 0)
            )
            .cornerRadius(Layout.radiusMedium)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Text Field Styles
struct InputFieldStyle: ViewModifier {
    @Binding var isFocused: Bool
    
    func body(content: Content) -> some View {
        content
            .font(.bodyMedium)
            .padding(.horizontal, Layout.spacingM)
            .frame(height: Layout.inputFieldHeight)
            .background(Color.inputBackground)
            .cornerRadius(Layout.radiusMedium)
            .overlay(
                RoundedRectangle(cornerRadius: Layout.radiusMedium)
                    .stroke(isFocused ? Color.primaryBrown : Color.clear, lineWidth: 1.5)
            )
    }
}

extension View {
    func inputFieldStyle(isFocused: Binding<Bool>) -> some View {
        modifier(InputFieldStyle(isFocused: isFocused))
    }
}

// MARK: - Card Styles
struct GymCardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(Color.cardBackground)
            .cornerRadius(Layout.radiusLarge)
            .customShadow(ShadowStyle.card)
    }
}

struct PassCardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color.primaryBrown, Color.primaryBrownLight]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(Layout.radiusLarge)
            .customShadow(ShadowStyle.elevated)
    }
}

extension View {
    func gymCardStyle() -> some View {
        modifier(GymCardStyle())
    }
    
    func passCardStyle() -> some View {
        modifier(PassCardStyle())
    }
}

// MARK: - Tab Bar Item
struct TabBarItem: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 22, weight: isSelected ? .semibold : .regular))
                Text(title)
                    .font(.captionMedium)
            }
            .foregroundColor(isSelected ? .primaryBrown : .tertiaryText)
            .frame(maxWidth: .infinity)
        }
    }
}

// MARK: - Loading View
struct LoadingView: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                ProgressView()
                    .scaleEffect(1.5)
                    .tint(.primaryBrown)
                Text("Loading...")
                    .font(.bodyMedium)
                    .foregroundColor(.primaryText)
            }
            .padding(24)
            .background(Color.white)
            .cornerRadius(Layout.radiusLarge)
            .customShadow(ShadowStyle.elevated)
        }
    }
}

// MARK: - Empty State View
struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    let buttonTitle: String?
    let buttonAction: (() -> Void)?
    
    init(
        icon: String,
        title: String,
        message: String,
        buttonTitle: String? = nil,
        buttonAction: (() -> Void)? = nil
    ) {
        self.icon = icon
        self.title = title
        self.message = message
        self.buttonTitle = buttonTitle
        self.buttonAction = buttonAction
    }
    
    var body: some View {
        VStack(spacing: Layout.spacingL) {
            Image(systemName: icon)
                .font(.system(size: 64))
                .foregroundColor(.tertiaryText)
            
            VStack(spacing: Layout.spacingS) {
                Text(title)
                    .font(.title3)
                    .foregroundColor(.primaryText)
                
                Text(message)
                    .font(.bodyMedium)
                    .foregroundColor(.secondaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Layout.spacingXL)
            }
            
            if let buttonTitle = buttonTitle, let buttonAction = buttonAction {
                Button(action: buttonAction) {
                    Text(buttonTitle)
                        .font(.button)
                        .foregroundColor(.white)
                        .frame(width: 200, height: Layout.primaryButtonHeight)
                        .background(Color.primaryBrown)
                        .cornerRadius(Layout.radiusFull)
                }
            }
        }
        .padding()
    }
}

// MARK: - Navigation Bar Modifier
struct NavigationBarModifier: ViewModifier {
    var title: String
    var showBackButton: Bool = true
    var backAction: (() -> Void)?
    
    func body(content: Content) -> some View {
        content
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if showBackButton {
                        Button(action: { backAction?() }) {
                            Image(systemName: "chevron.left")
                                .font(.headline)
                                .foregroundColor(.primaryBrown)
                        }
                    }
                }
                ToolbarItem(placement: .principal) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.primaryText)
                }
            }
    }
}

extension View {
    func customNavigationBar(
        title: String,
        showBackButton: Bool = true,
        backAction: (() -> Void)? = nil
    ) -> some View {
        modifier(NavigationBarModifier(
            title: title,
            showBackButton: showBackButton,
            backAction: backAction
        ))
    }
}

// MARK: - Preview Helpers
#Preview("Design System") {
    ScrollView {
        VStack(spacing: 32) {
            // Colors
            VStack(alignment: .leading, spacing: 16) {
                Text("Colors")
                    .font(.title2)
                
                HStack(spacing: 12) {
                    Color.primaryBrown
                        .frame(width: 60, height: 60)
                        .cornerRadius(8)
                    Color.cardBackground
                        .frame(width: 60, height: 60)
                        .cornerRadius(8)
                    Color.inputBackground
                        .frame(width: 60, height: 60)
                        .cornerRadius(8)
                }
            }
            
            // Typography
            VStack(alignment: .leading, spacing: 8) {
                Text("Typography")
                    .font(.title2)
                
                Text("Large Title").font(.largeTitle)
                Text("Title 1").font(.title1)
                Text("Title 2").font(.title2)
                Text("Headline").font(.headline)
                Text("Body Large").font(.bodyLarge)
                Text("Body Medium").font(.bodyMedium)
                Text("Caption").font(.caption)
            }
            
            // Buttons
            VStack(spacing: 16) {
                Text("Buttons")
                    .font(.title2)
                
                Button("Primary Button") {}
                    .buttonStyle(PrimaryButtonStyle())
                
                Button("Secondary Button") {}
                    .buttonStyle(SecondaryButtonStyle())
            }
            
            // Cards
            VStack(spacing: 16) {
                Text("Cards")
                    .font(.title2)
                
                Text("Gym Card")
                    .frame(width: Layout.gymCardWidth, height: 100)
                    .gymCardStyle()
                
                Text("Pass Card")
                    .frame(width: Layout.gymCardWidth, height: 100)
                    .foregroundColor(.white)
                    .passCardStyle()
            }
        }
        .padding()
    }
}
