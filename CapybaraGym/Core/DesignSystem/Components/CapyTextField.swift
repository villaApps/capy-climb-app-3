//
//  CapyTextField.swift
//  CapybaraGym
//
//  Text field component with various styles
//

import SwiftUI

// MARK: - Text Field Style Enum
public enum CapyTextFieldStyle {
    case `default`
    case outlined
    case filled
}

// MARK: - CapyTextField
public struct CapyTextField: View {
    
    // MARK: - Properties
    let title: String
    let placeholder: String
    let icon: String?
    let style: CapyTextFieldStyle
    let isSecure: Bool
    let keyboardType: UIKeyboardType
    let textContentType: UITextContentType?
    let autocapitalization: TextInputAutocapitalization
    
    @Binding var text: String
    @State private var isFocused: Bool = false
    @State private var isSecureVisible: Bool = false
    
    // MARK: - Initialization
    public init(
        title: String,
        placeholder: String,
        text: Binding<String>,
        icon: String? = nil,
        style: CapyTextFieldStyle = .default,
        isSecure: Bool = false,
        keyboardType: UIKeyboardType = .default,
        textContentType: UITextContentType? = nil,
        autocapitalization: TextInputAutocapitalization = .sentences
    ) {
        self.title = title
        self.placeholder = placeholder
        self._text = text
        self.icon = icon
        self.style = style
        self.isSecure = isSecure
        self.keyboardType = keyboardType
        self.textContentType = textContentType
        self.autocapitalization = autocapitalization
    }
    
    // MARK: - Body
    public var body: some View {
        VStack(alignment: .leading, spacing: CapySpacing.xSmall) {
            // Title label
            if !title.isEmpty {
                Text(title)
                    .font(CapyTypography.labelMedium)
                    .foregroundColor(CapyColors.textSecondary)
            }
            
            // Text field container
            HStack(spacing: CapySpacing.small) {
                // Leading icon
                if let icon = icon {
                    Image(systemName: icon)
                        .foregroundColor(iconColor)
                        .font(.system(size: 18))
                }
                
                // Text input
                if isSecure && !isSecureVisible {
                    SecureField(placeholder, text: $text)
                        .font(CapyTypography.bodyMedium)
                        .foregroundColor(CapyColors.textPrimary)
                        .keyboardType(keyboardType)
                        .textContentType(textContentType)
                        .textInputAutocapitalization(autocapitalization)
                } else {
                    TextField(placeholder, text: $text)
                        .font(CapyTypography.bodyMedium)
                        .foregroundColor(CapyColors.textPrimary)
                        .keyboardType(keyboardType)
                        .textContentType(textContentType)
                        .textInputAutocapitalization(autocapitalization)
                }
                
                // Clear button
                if !text.isEmpty {
                    Button(action: { text = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(CapyColors.textTertiary)
                            .font(.system(size: 18))
                    }
                }
                
                // Secure field toggle
                if isSecure {
                    Button(action: { isSecureVisible.toggle() }) {
                        Image(systemName: isSecureVisible ? "eye.slash" : "eye")
                            .foregroundColor(CapyColors.textTertiary)
                            .font(.system(size: 18))
                    }
                }
            }
            .frame(height: CapyLayout.textFieldHeight)
            .padding(.horizontal, CapySpacing.medium)
            .background(backgroundColor)
            .overlay(
                RoundedRectangle(cornerRadius: CapyRadius.xLarge)
                    .stroke(borderColor, lineWidth: borderWidth)
            )
            .cornerRadius(CapyRadius.xLarge)
        }
    }
    
    // MARK: - Computed Properties
    private var iconColor: Color {
        isFocused ? CapyColors.primary : CapyColors.textTertiary
    }
    
    private var backgroundColor: Color {
        switch style {
        case .default, .outlined:
            return CapyColors.backgroundSecondary
        case .filled:
            return CapyColors.cardBackground
        }
    }
    
    private var borderColor: Color {
        switch style {
        case .default:
            return Color.clear
        case .outlined:
            return isFocused ? CapyColors.primary : CapyColors.divider
        case .filled:
            return Color.clear
        }
    }
    
    private var borderWidth: CGFloat {
        switch style {
        case .outlined:
            return 1.5
        default:
            return 0
        }
    }
}

// MARK: - CapyTextArea
public struct CapyTextArea: View {
    
    // MARK: - Properties
    let title: String
    let placeholder: String
    let minHeight: CGFloat
    let maxHeight: CGFloat?
    
    @Binding var text: String
    
    // MARK: - Initialization
    public init(
        title: String,
        placeholder: String,
        text: Binding<String>,
        minHeight: CGFloat = 100,
        maxHeight: CGFloat? = nil
    ) {
        self.title = title
        self.placeholder = placeholder
        self._text = text
        self.minHeight = minHeight
        self.maxHeight = maxHeight
    }
    
    // MARK: - Body
    public var body: some View {
        VStack(alignment: .leading, spacing: CapySpacing.xSmall) {
            // Title label
            if !title.isEmpty {
                Text(title)
                    .font(CapyTypography.labelMedium)
                    .foregroundColor(CapyColors.textSecondary)
            }
            
            // Text editor
            ZStack(alignment: .topLeading) {
                if text.isEmpty {
                    Text(placeholder)
                        .font(CapyTypography.bodyMedium)
                        .foregroundColor(CapyColors.placeholder)
                        .padding(.top, 8)
                        .padding(.leading, 4)
                }
                
                TextEditor(text: $text)
                    .font(CapyTypography.bodyMedium)
                    .foregroundColor(CapyColors.textPrimary)
                    .scrollContentBackground(.hidden)
            }
            .frame(minHeight: minHeight, maxHeight: maxHeight)
            .padding(.horizontal, CapySpacing.small)
            .padding(.vertical, CapySpacing.xSmall)
            .background(CapyColors.backgroundSecondary)
            .overlay(
                RoundedRectangle(cornerRadius: CapyRadius.large)
                    .stroke(CapyColors.divider, lineWidth: 1)
            )
            .cornerRadius(CapyRadius.large)
        }
    }
}

// MARK: - Preview
struct CapyTextField_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: CapySpacing.large) {
            CapyTextField(
                title: "Email",
                placeholder: "Enter your email",
                text: .constant(""),
                icon: "envelope",
                keyboardType: .emailAddress,
                textContentType: .emailAddress
            )
            
            CapyTextField(
                title: "Password",
                placeholder: "Enter your password",
                text: .constant("password123"),
                icon: "lock",
                isSecure: true,
                textContentType: .password
            )
            
            CapyTextField(
                title: "Outlined Style",
                placeholder: "With outline",
                text: .constant(""),
                style: .outlined
            )
            
            CapyTextArea(
                title: "Description",
                placeholder: "Enter description...",
                text: .constant("")
            )
        }
        .padding()
        .background(CapyColors.background)
    }
}
