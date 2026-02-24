//
//  CapyButton.swift
//  CapybaraGym
//
//  Primary button component
//

import SwiftUI

// MARK: - Button Style Enum
public enum CapyButtonStyle {
    case primary
    case secondary
    case outline
    case ghost
    case destructive
}

// MARK: - Button Size Enum
public enum CapyButtonSize {
    case small
    case medium
    case large
    
    var height: CGFloat {
        switch self {
        case .small: return CapyLayout.buttonHeightSmall
        case .medium: return CapyLayout.buttonHeight
        case .large: return 64
        }
    }
    
    var font: Font {
        switch self {
        case .small: return CapyTypography.buttonSecondary
        case .medium: return CapyTypography.buttonPrimary
        case .large: return CapyTypography.buttonPrimary
        }
    }
    
    var horizontalPadding: CGFloat {
        switch self {
        case .small: return CapySpacing.medium
        case .medium: return CapySpacing.large
        case .large: return CapySpacing.xLarge
        }
    }
}

// MARK: - CapyButton
public struct CapyButton: View {
    
    // MARK: - Properties
    let title: String
    let icon: String?
    let style: CapyButtonStyle
    let size: CapyButtonSize
    let isLoading: Bool
    let isFullWidth: Bool
    let action: () -> Void
    
    // MARK: - Initialization
    public init(
        title: String,
        icon: String? = nil,
        style: CapyButtonStyle = .primary,
        size: CapyButtonSize = .medium,
        isLoading: Bool = false,
        isFullWidth: Bool = true,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.style = style
        self.size = size
        self.isLoading = isLoading
        self.isFullWidth = isFullWidth
        self.action = action
    }
    
    // MARK: - Body
    public var body: some View {
        Button(action: action) {
            HStack(spacing: CapySpacing.xSmall) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: progressColor))
                        .scaleEffect(0.8)
                } else {
                    if let icon = icon {
                        Image(systemName: icon)
                            .font(.system(size: 16, weight: .semibold))
                    }
                    
                    Text(title)
                        .font(size.font)
                }
            }
            .frame(maxWidth: isFullWidth ? .infinity : nil)
            .frame(height: size.height)
            .padding(.horizontal, size.horizontalPadding)
        }
        .disabled(isLoading)
        .buttonStyle(CapyButtonStyleModifier(style: style))
    }
    
    // MARK: - Computed Properties
    private var progressColor: Color {
        switch style {
        case .primary, .destructive:
            return .white
        case .secondary, .outline, .ghost:
            return CapyColors.primary
        }
    }
}

// MARK: - Button Style Modifier
struct CapyButtonStyleModifier: ButtonStyle {
    let style: CapyButtonStyle
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(foregroundColor(isPressed: configuration.isPressed))
            .background(backgroundColor(isPressed: configuration.isPressed))
            .overlay(
                RoundedRectangle(cornerRadius: CapyRadius.fullyRounded)
                    .stroke(borderColor, lineWidth: borderWidth)
            )
            .cornerRadius(CapyRadius.fullyRounded)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
    
    private func foregroundColor(isPressed: Bool) -> Color {
        let opacity = isPressed ? 0.8 : 1.0
        switch style {
        case .primary, .destructive:
            return CapyColors.textInverse.opacity(opacity)
        case .secondary:
            return CapyColors.textPrimary.opacity(opacity)
        case .outline, .ghost:
            return CapyColors.primary.opacity(opacity)
        }
    }
    
    private func backgroundColor(isPressed: Bool) -> Color {
        let opacity = isPressed ? 0.8 : 1.0
        switch style {
        case .primary:
            return CapyColors.primary.opacity(opacity)
        case .secondary:
            return CapyColors.cardBackground.opacity(opacity)
        case .outline, .ghost:
            return Color.clear
        case .destructive:
            return CapyColors.error.opacity(opacity)
        }
    }
    
    private var borderColor: Color {
        switch style {
        case .outline:
            return CapyColors.primary
        default:
            return Color.clear
        }
    }
    
    private var borderWidth: CGFloat {
        switch style {
        case .outline:
            return 2
        default:
            return 0
        }
    }
}

// MARK: - Preview
struct CapyButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: CapySpacing.medium) {
            CapyButton(title: "Primary Button", action: {})
            
            CapyButton(
                title: "With Icon",
                icon: "arrow.right",
                action: {}
            )
            
            CapyButton(
                title: "Secondary",
                style: .secondary,
                action: {}
            )
            
            CapyButton(
                title: "Outline",
                style: .outline,
                action: {}
            )
            
            CapyButton(
                title: "Ghost",
                style: .ghost,
                action: {}
            )
            
            CapyButton(
                title: "Destructive",
                style: .destructive,
                action: {}
            )
            
            CapyButton(
                title: "Loading",
                isLoading: true,
                action: {}
            )
            
            HStack {
                CapyButton(
                    title: "Small",
                    size: .small,
                    isFullWidth: false,
                    action: {}
                )
                
                CapyButton(
                    title: "Large",
                    size: .large,
                    isFullWidth: false,
                    action: {}
                )
            }
        }
        .padding()
        .background(CapyColors.background)
    }
}
