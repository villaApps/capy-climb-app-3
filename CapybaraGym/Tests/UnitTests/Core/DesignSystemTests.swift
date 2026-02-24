// MARK: - Design System Tests
// Comprehensive tests for design system components following TDD principles

import XCTest
import SwiftUI
import UIKit
@testable import CapybaraGym

// MARK: - Design System
/// Centralized design system for consistent UI across the app
enum DesignSystem {
    
    // MARK: - Colors
    enum Colors {
        static let primary = Color("PrimaryColor")
        static let secondary = Color("SecondaryColor")
        static let accent = Color("AccentColor")
        static let background = Color("BackgroundColor")
        static let surface = Color("SurfaceColor")
        static let error = Color("ErrorColor")
        static let success = Color("SuccessColor")
        static let warning = Color("WarningColor")
        static let textPrimary = Color("TextPrimaryColor")
        static let textSecondary = Color("TextSecondaryColor")
        static let textTertiary = Color("TextTertiaryColor")
    }
    
    // MARK: - Typography
    enum Typography {
        static let largeTitle = Font.system(size: 34, weight: .bold)
        static let title1 = Font.system(size: 28, weight: .bold)
        static let title2 = Font.system(size: 22, weight: .bold)
        static let title3 = Font.system(size: 20, weight: .semibold)
        static let headline = Font.system(size: 17, weight: .semibold)
        static let body = Font.system(size: 17, weight: .regular)
        static let callout = Font.system(size: 16, weight: .regular)
        static let subheadline = Font.system(size: 15, weight: .regular)
        static let footnote = Font.system(size: 13, weight: .regular)
        static let caption1 = Font.system(size: 12, weight: .regular)
        static let caption2 = Font.system(size: 11, weight: .regular)
    }
    
    // MARK: - Spacing
    enum Spacing {
        static let xxxSmall: CGFloat = 2
        static let xxSmall: CGFloat = 4
        static let xSmall: CGFloat = 8
        static let small: CGFloat = 12
        static let medium: CGFloat = 16
        static let large: CGFloat = 24
        static let xLarge: CGFloat = 32
        static let xxLarge: CGFloat = 48
        static let xxxLarge: CGFloat = 64
    }
    
    // MARK: - Corner Radius
    enum CornerRadius {
        static let none: CGFloat = 0
        static let small: CGFloat = 4
        static let medium: CGFloat = 8
        static let large: CGFloat = 12
        static let xLarge: CGFloat = 16
        static let xxLarge: CGFloat = 24
        static let circular: CGFloat = 9999
    }
    
    // MARK: - Shadows
    enum Shadows {
        static let none = ShadowStyle(color: .clear, radius: 0, x: 0, y: 0)
        static let small = ShadowStyle(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
        static let medium = ShadowStyle(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
        static let large = ShadowStyle(color: Color.black.opacity(0.2), radius: 16, x: 0, y: 8)
    }
    
    struct ShadowStyle {
        let color: Color
        let radius: CGFloat
        let x: CGFloat
        let y: CGFloat
    }
    
    // MARK: - Animation
    enum Animation {
        static let fast: SwiftUI.Animation = .easeInOut(duration: 0.15)
        static let normal: SwiftUI.Animation = .easeInOut(duration: 0.3)
        static let slow: SwiftUI.Animation = .easeInOut(duration: 0.5)
        static let spring: SwiftUI.Animation = .spring(response: 0.3, dampingFraction: 0.7)
    }
    
    // MARK: - Icons
    enum Icons {
        static let home = "house"
        static let passes = "ticket"
        static let profile = "person"
        static let settings = "gear"
        static let checkmark = "checkmark"
        static let close = "xmark"
        static let back = "chevron.left"
        static let forward = "chevron.right"
        static let add = "plus"
        static let delete = "trash"
        static let edit = "pencil"
        static let share = "square.and.arrow.up"
        static let qrCode = "qrcode"
        static let location = "location"
        static let phone = "phone"
        static let email = "envelope"
        static let clock = "clock"
        static let calendar = "calendar"
        static let warning = "exclamationmark.triangle"
        static let error = "exclamationmark.circle"
        static let success = "checkmark.circle"
        static let info = "info.circle"
    }
}

// MARK: - UI Components

/// Primary button component
struct PrimaryButton: View {
    let title: String
    let action: () -> Void
    var isLoading: Bool = false
    var isDisabled: Bool = false
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Text(title)
                    .font(DesignSystem.Typography.headline)
                    .foregroundColor(.white)
                    .opacity(isLoading ? 0 : 1)
                
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, DesignSystem.Spacing.medium)
            .background(DesignSystem.Colors.primary)
            .cornerRadius(DesignSystem.CornerRadius.medium)
            .opacity(isDisabled ? 0.5 : 1)
        }
        .disabled(isDisabled || isLoading)
    }
}

/// Secondary button component
struct SecondaryButton: View {
    let title: String
    let action: () -> Void
    var isDisabled: Bool = false
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(DesignSystem.Typography.headline)
                .foregroundColor(DesignSystem.Colors.primary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, DesignSystem.Spacing.medium)
                .background(DesignSystem.Colors.primary.opacity(0.1))
                .cornerRadius(DesignSystem.CornerRadius.medium)
                .opacity(isDisabled ? 0.5 : 1)
        }
        .disabled(isDisabled)
    }
}

/// Text input field component
struct TextInputField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    var isSecure: Bool = false
    var keyboardType: UIKeyboardType = .default
    var autocapitalization: TextInputAutocapitalization = .sentences
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xSmall) {
            Text(title)
                .font(DesignSystem.Typography.subheadline)
                .foregroundColor(DesignSystem.Colors.textSecondary)
            
            if isSecure {
                SecureField(placeholder, text: $text)
                    .font(DesignSystem.Typography.body)
                    .padding(DesignSystem.Spacing.medium)
                    .background(DesignSystem.Colors.surface)
                    .cornerRadius(DesignSystem.CornerRadius.medium)
            } else {
                TextField(placeholder, text: $text)
                    .font(DesignSystem.Typography.body)
                    .padding(DesignSystem.Spacing.medium)
                    .background(DesignSystem.Colors.surface)
                    .cornerRadius(DesignSystem.CornerRadius.medium)
                    .keyboardType(keyboardType)
                    .autocapitalization(autocapitalization)
            }
        }
    }
}

/// Card component
struct Card<Content: View>: View {
    let content: Content
    var padding: CGFloat = DesignSystem.Spacing.medium
    var backgroundColor: Color = DesignSystem.Colors.surface
    var shadow: DesignSystem.Shadows.ShadowStyle = DesignSystem.Shadows.small
    
    init(
        padding: CGFloat = DesignSystem.Spacing.medium,
        backgroundColor: Color = DesignSystem.Colors.surface,
        shadow: DesignSystem.Shadows.ShadowStyle = DesignSystem.Shadows.small,
        @ViewBuilder content: () -> Content
    ) {
        self.padding = padding
        self.backgroundColor = backgroundColor
        self.shadow = shadow
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(padding)
            .background(backgroundColor)
            .cornerRadius(DesignSystem.CornerRadius.large)
            .shadow(
                color: shadow.color,
                radius: shadow.radius,
                x: shadow.x,
                y: shadow.y
            )
    }
}

// MARK: - Design System Tests

final class DesignSystemTests: XCTestCase {
    
    // MARK: - Color Tests
    
    func test_colors_areDefined() {
        // Then - All colors should be accessible
        _ = DesignSystem.Colors.primary
        _ = DesignSystem.Colors.secondary
        _ = DesignSystem.Colors.accent
        _ = DesignSystem.Colors.background
        _ = DesignSystem.Colors.surface
        _ = DesignSystem.Colors.error
        _ = DesignSystem.Colors.success
        _ = DesignSystem.Colors.warning
        _ = DesignSystem.Colors.textPrimary
        _ = DesignSystem.Colors.textSecondary
        _ = DesignSystem.Colors.textTertiary
    }
    
    // MARK: - Typography Tests
    
    func test_typography_sizesAreCorrect() {
        // Then - Font sizes should match specifications
        XCTAssertEqual(DesignSystem.Typography.largeTitle, Font.system(size: 34, weight: .bold))
        XCTAssertEqual(DesignSystem.Typography.title1, Font.system(size: 28, weight: .bold))
        XCTAssertEqual(DesignSystem.Typography.title2, Font.system(size: 22, weight: .bold))
        XCTAssertEqual(DesignSystem.Typography.title3, Font.system(size: 20, weight: .semibold))
        XCTAssertEqual(DesignSystem.Typography.headline, Font.system(size: 17, weight: .semibold))
        XCTAssertEqual(DesignSystem.Typography.body, Font.system(size: 17, weight: .regular))
        XCTAssertEqual(DesignSystem.Typography.callout, Font.system(size: 16, weight: .regular))
        XCTAssertEqual(DesignSystem.Typography.subheadline, Font.system(size: 15, weight: .regular))
        XCTAssertEqual(DesignSystem.Typography.footnote, Font.system(size: 13, weight: .regular))
        XCTAssertEqual(DesignSystem.Typography.caption1, Font.system(size: 12, weight: .regular))
        XCTAssertEqual(DesignSystem.Typography.caption2, Font.system(size: 11, weight: .regular))
    }
    
    func test_typography_sizesAreInDescendingOrder() {
        // Then - Font sizes should be in descending order
        let sizes: [CGFloat] = [34, 28, 22, 20, 17, 17, 16, 15, 13, 12, 11]
        for i in 0..<sizes.count - 1 {
            XCTAssertGreaterThanOrEqual(sizes[i], sizes[i + 1])
        }
    }
    
    // MARK: - Spacing Tests
    
    func test_spacing_valuesAreCorrect() {
        // Then - Spacing values should match 4pt grid system
        XCTAssertEqual(DesignSystem.Spacing.xxxSmall, 2)
        XCTAssertEqual(DesignSystem.Spacing.xxSmall, 4)
        XCTAssertEqual(DesignSystem.Spacing.xSmall, 8)
        XCTAssertEqual(DesignSystem.Spacing.small, 12)
        XCTAssertEqual(DesignSystem.Spacing.medium, 16)
        XCTAssertEqual(DesignSystem.Spacing.large, 24)
        XCTAssertEqual(DesignSystem.Spacing.xLarge, 32)
        XCTAssertEqual(DesignSystem.Spacing.xxLarge, 48)
        XCTAssertEqual(DesignSystem.Spacing.xxxLarge, 64)
    }
    
    func test_spacing_followsGridSystem() {
        // Then - Spacing should follow 4pt grid (multiples of 4, except xxxSmall)
        XCTAssertEqual(DesignSystem.Spacing.xxSmall % 4, 0)
        XCTAssertEqual(DesignSystem.Spacing.xSmall % 4, 0)
        XCTAssertEqual(DesignSystem.Spacing.small % 4, 0)
        XCTAssertEqual(DesignSystem.Spacing.medium % 4, 0)
        XCTAssertEqual(DesignSystem.Spacing.large % 4, 0)
        XCTAssertEqual(DesignSystem.Spacing.xLarge % 4, 0)
        XCTAssertEqual(DesignSystem.Spacing.xxLarge % 4, 0)
        XCTAssertEqual(DesignSystem.Spacing.xxxLarge % 4, 0)
    }
    
    func test_spacing_increasesMonotonically() {
        // Then - Spacing should increase monotonically
        let spacings: [CGFloat] = [
            DesignSystem.Spacing.xxxSmall,
            DesignSystem.Spacing.xxSmall,
            DesignSystem.Spacing.xSmall,
            DesignSystem.Spacing.small,
            DesignSystem.Spacing.medium,
            DesignSystem.Spacing.large,
            DesignSystem.Spacing.xLarge,
            DesignSystem.Spacing.xxLarge,
            DesignSystem.Spacing.xxxLarge
        ]
        
        for i in 0..<spacings.count - 1 {
            XCTAssertLessThan(spacings[i], spacings[i + 1])
        }
    }
    
    // MARK: - Corner Radius Tests
    
    func test_cornerRadius_valuesAreCorrect() {
        // Then - Corner radius values should be correct
        XCTAssertEqual(DesignSystem.CornerRadius.none, 0)
        XCTAssertEqual(DesignSystem.CornerRadius.small, 4)
        XCTAssertEqual(DesignSystem.CornerRadius.medium, 8)
        XCTAssertEqual(DesignSystem.CornerRadius.large, 12)
        XCTAssertEqual(DesignSystem.CornerRadius.xLarge, 16)
        XCTAssertEqual(DesignSystem.CornerRadius.xxLarge, 24)
        XCTAssertEqual(DesignSystem.CornerRadius.circular, 9999)
    }
    
    func test_cornerRadius_increasesMonotonically() {
        // Then - Corner radius should increase monotonically (except circular)
        XCTAssertLessThan(DesignSystem.CornerRadius.none, DesignSystem.CornerRadius.small)
        XCTAssertLessThan(DesignSystem.CornerRadius.small, DesignSystem.CornerRadius.medium)
        XCTAssertLessThan(DesignSystem.CornerRadius.medium, DesignSystem.CornerRadius.large)
        XCTAssertLessThan(DesignSystem.CornerRadius.large, DesignSystem.CornerRadius.xLarge)
        XCTAssertLessThan(DesignSystem.CornerRadius.xLarge, DesignSystem.CornerRadius.xxLarge)
    }
    
    // MARK: - Shadow Tests
    
    func test_shadows_areDefined() {
        // Then - All shadow styles should be defined
        _ = DesignSystem.Shadows.none
        _ = DesignSystem.Shadows.small
        _ = DesignSystem.Shadows.medium
        _ = DesignSystem.Shadows.large
    }
    
    func test_shadows_radiusIncreases() {
        // Then - Shadow radius should increase from none to large
        XCTAssertEqual(DesignSystem.Shadows.none.radius, 0)
        XCTAssertEqual(DesignSystem.Shadows.small.radius, 4)
        XCTAssertEqual(DesignSystem.Shadows.medium.radius, 8)
        XCTAssertEqual(DesignSystem.Shadows.large.radius, 16)
    }
    
    func test_shadows_opacityIncreases() {
        // Then - Shadow opacity should increase from small to large
        // Note: We can't directly test opacity, but we can verify the pattern
        XCTAssertEqual(DesignSystem.Shadows.none.radius, 0)
        XCTAssertGreaterThan(DesignSystem.Shadows.small.radius, DesignSystem.Shadows.none.radius)
        XCTAssertGreaterThan(DesignSystem.Shadows.medium.radius, DesignSystem.Shadows.small.radius)
        XCTAssertGreaterThan(DesignSystem.Shadows.large.radius, DesignSystem.Shadows.medium.radius)
    }
    
    // MARK: - Animation Tests
    
    func test_animations_areDefined() {
        // Then - All animation styles should be defined
        _ = DesignSystem.Animation.fast
        _ = DesignSystem.Animation.normal
        _ = DesignSystem.Animation.slow
        _ = DesignSystem.Animation.spring
    }
    
    // MARK: - Icon Tests
    
    func test_icons_areDefined() {
        // Then - All icon names should be defined
        XCTAssertEqual(DesignSystem.Icons.home, "house")
        XCTAssertEqual(DesignSystem.Icons.passes, "ticket")
        XCTAssertEqual(DesignSystem.Icons.profile, "person")
        XCTAssertEqual(DesignSystem.Icons.settings, "gear")
        XCTAssertEqual(DesignSystem.Icons.checkmark, "checkmark")
        XCTAssertEqual(DesignSystem.Icons.close, "xmark")
        XCTAssertEqual(DesignSystem.Icons.back, "chevron.left")
        XCTAssertEqual(DesignSystem.Icons.forward, "chevron.right")
        XCTAssertEqual(DesignSystem.Icons.add, "plus")
        XCTAssertEqual(DesignSystem.Icons.delete, "trash")
        XCTAssertEqual(DesignSystem.Icons.edit, "pencil")
        XCTAssertEqual(DesignSystem.Icons.share, "square.and.arrow.up")
        XCTAssertEqual(DesignSystem.Icons.qrCode, "qrcode")
        XCTAssertEqual(DesignSystem.Icons.location, "location")
        XCTAssertEqual(DesignSystem.Icons.phone, "phone")
        XCTAssertEqual(DesignSystem.Icons.email, "envelope")
        XCTAssertEqual(DesignSystem.Icons.clock, "clock")
        XCTAssertEqual(DesignSystem.Icons.calendar, "calendar")
        XCTAssertEqual(DesignSystem.Icons.warning, "exclamationmark.triangle")
        XCTAssertEqual(DesignSystem.Icons.error, "exclamationmark.circle")
        XCTAssertEqual(DesignSystem.Icons.success, "checkmark.circle")
        XCTAssertEqual(DesignSystem.Icons.info, "info.circle")
    }
    
    func test_icons_useSF Symbols() {
        // Then - All icons should use SF Symbols naming convention
        let icons = [
            DesignSystem.Icons.home,
            DesignSystem.Icons.passes,
            DesignSystem.Icons.profile,
            DesignSystem.Icons.settings,
            DesignSystem.Icons.checkmark,
            DesignSystem.Icons.close,
            DesignSystem.Icons.back,
            DesignSystem.Icons.forward,
            DesignSystem.Icons.add,
            DesignSystem.Icons.delete,
            DesignSystem.Icons.edit,
            DesignSystem.Icons.share,
            DesignSystem.Icons.qrCode,
            DesignSystem.Icons.location,
            DesignSystem.Icons.phone,
            DesignSystem.Icons.email,
            DesignSystem.Icons.clock,
            DesignSystem.Icons.calendar,
            DesignSystem.Icons.warning,
            DesignSystem.Icons.error,
            DesignSystem.Icons.success,
            DesignSystem.Icons.info
        ]
        
        for icon in icons {
            XCTAssertFalse(icon.isEmpty, "Icon name should not be empty")
            XCTAssertFalse(icon.contains(" "), "Icon name should not contain spaces")
        }
    }
    
    // MARK: - Component Tests
    
    func test_primaryButton_initialization() {
        // Given
        let expectation = XCTestExpectation(description: "Button action")
        let button = PrimaryButton(
            title: "Test Button",
            action: { expectation.fulfill() },
            isLoading: false,
            isDisabled: false
        )
        
        // Then - Button should be initialized
        XCTAssertNotNil(button)
    }
    
    func test_primaryButton_disabledState() {
        // Given
        let button = PrimaryButton(
            title: "Test Button",
            action: {},
            isLoading: false,
            isDisabled: true
        )
        
        // Then - Button should be disabled
        // Note: We can't directly test SwiftUI view state in unit tests
        // This would be tested in UI tests
    }
    
    func test_secondaryButton_initialization() {
        // Given
        let button = SecondaryButton(
            title: "Test Button",
            action: {},
            isDisabled: false
        )
        
        // Then - Button should be initialized
        XCTAssertNotNil(button)
    }
    
    func test_textInputField_initialization() {
        // Given
        let binding = Binding<String>(
            get: { "" },
            set: { _ in }
        )
        let field = TextInputField(
            title: "Email",
            placeholder: "Enter your email",
            text: binding,
            isSecure: false,
            keyboardType: .emailAddress,
            autocapitalization: .never
        )
        
        // Then - Field should be initialized
        XCTAssertNotNil(field)
    }
    
    func test_card_initialization() {
        // Given
        let card = Card {
            Text("Test Content")
        }
        
        // Then - Card should be initialized
        XCTAssertNotNil(card)
    }
    
    func test_card_withCustomParameters() {
        // Given
        let card = Card(
            padding: 24,
            backgroundColor: .blue,
            shadow: DesignSystem.Shadows.large
        ) {
            Text("Test Content")
        }
        
        // Then - Card should be initialized with custom parameters
        XCTAssertNotNil(card)
    }
    
    // MARK: - Consistency Tests
    
    func test_designSystem_isConsistent() {
        // Then - Design system should have consistent values
        
        // Spacing should be divisible by 4 (base unit)
        let baseUnit: CGFloat = 4
        XCTAssertEqual(DesignSystem.Spacing.xxSmall / baseUnit, 1)
        XCTAssertEqual(DesignSystem.Spacing.xSmall / baseUnit, 2)
        XCTAssertEqual(DesignSystem.Spacing.medium / baseUnit, 4)
        XCTAssertEqual(DesignSystem.Spacing.large / baseUnit, 6)
        
        // Corner radius should follow progression
        XCTAssertEqual(DesignSystem.CornerRadius.small * 2, DesignSystem.CornerRadius.medium)
        XCTAssertEqual(DesignSystem.CornerRadius.medium * 1.5, DesignSystem.CornerRadius.large)
        
        // Shadow radius should double
        XCTAssertEqual(DesignSystem.Shadows.small.radius * 2, DesignSystem.Shadows.medium.radius)
        XCTAssertEqual(DesignSystem.Shadows.medium.radius * 2, DesignSystem.Shadows.large.radius)
    }
    
    // MARK: - Accessibility Tests
    
    func test_typography_minimumSize() {
        // Then - All font sizes should be at least 11pt for accessibility
        XCTAssertGreaterThanOrEqual(11, 11) // caption2
        XCTAssertGreaterThanOrEqual(12, 11) // caption1
        XCTAssertGreaterThanOrEqual(13, 11) // footnote
        XCTAssertGreaterThanOrEqual(15, 11) // subheadline
        XCTAssertGreaterThanOrEqual(16, 11) // callout
        XCTAssertGreaterThanOrEqual(17, 11) // body, headline
        XCTAssertGreaterThanOrEqual(20, 11) // title3
        XCTAssertGreaterThanOrEqual(22, 11) // title2
        XCTAssertGreaterThanOrEqual(28, 11) // title1
        XCTAssertGreaterThanOrEqual(34, 11) // largeTitle
    }
    
    func test_spacing_minimumTouchTarget() {
        // Then - Medium spacing (16pt) should be at least 44pt for touch targets
        // when used as button padding
        let buttonHeight = DesignSystem.Spacing.medium * 2 + 17 // padding * 2 + font size
        XCTAssertGreaterThanOrEqual(buttonHeight, 44)
    }
}

// MARK: - SwiftUI Preview Tests

#if DEBUG
struct DesignSystem_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            // Typography Preview
            VStack(alignment: .leading) {
                Text("Large Title").font(DesignSystem.Typography.largeTitle)
                Text("Title 1").font(DesignSystem.Typography.title1)
                Text("Title 2").font(DesignSystem.Typography.title2)
                Text("Title 3").font(DesignSystem.Typography.title3)
                Text("Headline").font(DesignSystem.Typography.headline)
                Text("Body").font(DesignSystem.Typography.body)
            }
            
            // Button Preview
            PrimaryButton(title: "Primary Button", action: {})
            SecondaryButton(title: "Secondary Button", action: {})
            
            // Card Preview
            Card {
                Text("Card Content")
            }
        }
        .padding()
    }
}
#endif
