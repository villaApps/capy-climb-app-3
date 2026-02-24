//
//  CapyCard.swift
//  CapybaraGym
//
//  Card component with various styles
//

import SwiftUI

// MARK: - Card Style Enum
public enum CapyCardStyle {
    case `default`
    case elevated
    case outlined
    case filled
}

// MARK: - CapyCard
public struct CapyCard<Content: View>: View {
    
    // MARK: - Properties
    let style: CapyCardStyle
    let padding: CGFloat
    let cornerRadius: CGFloat
    let shadow: ShadowStyle?
    let content: Content
    
    // MARK: - Initialization
    public init(
        style: CapyCardStyle = .default,
        padding: CGFloat = CapySpacing.cardPadding,
        cornerRadius: CGFloat = CapyRadius.xLarge,
        shadow: ShadowStyle? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.style = style
        self.padding = padding
        self.cornerRadius = cornerRadius
        self.shadow = shadow
        self.content = content()
    }
    
    // MARK: - Body
    public var body: some View {
        content
            .padding(padding)
            .background(backgroundColor)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(borderColor, lineWidth: borderWidth)
            )
            .cornerRadius(cornerRadius)
            .shadow(
                color: effectiveShadow.color,
                radius: effectiveShadow.radius,
                x: effectiveShadow.x,
                y: effectiveShadow.y
            )
    }
    
    // MARK: - Computed Properties
    private var backgroundColor: Color {
        switch style {
        case .default, .elevated:
            return CapyColors.cardElevated
        case .outlined:
            return CapyColors.backgroundSecondary
        case .filled:
            return CapyColors.cardBackground
        }
    }
    
    private var borderColor: Color {
        switch style {
        case .outlined:
            return CapyColors.divider
        default:
            return Color.clear
        }
    }
    
    private var borderWidth: CGFloat {
        switch style {
        case .outlined:
            return 1
        default:
            return 0
        }
    }
    
    private var effectiveShadow: ShadowStyle {
        shadow ?? defaultShadow
    }
    
    private var defaultShadow: ShadowStyle {
        switch style {
        case .elevated:
            return CapyShadow.medium
        case .default:
            return CapyShadow.small
        case .outlined, .filled:
            return CapyShadow.none
        }
    }
}

// MARK: - CapyListCard
public struct CapyListCard<Leading: View, Trailing: View>: View {
    
    // MARK: - Properties
    let title: String
    let subtitle: String?
    let style: CapyCardStyle
    let leading: Leading?
    let trailing: Trailing?
    let onTap: (() -> Void)?
    
    // MARK: - Initialization
    public init(
        title: String,
        subtitle: String? = nil,
        style: CapyCardStyle = .default,
        @ViewBuilder leading: () -> Leading? = { nil },
        @ViewBuilder trailing: () -> Trailing? = { nil },
        onTap: (() -> Void)? = nil
    ) {
        self.title = title
        self.subtitle = subtitle
        self.style = style
        self.leading = leading()
        self.trailing = trailing()
        self.onTap = onTap
    }
    
    // MARK: - Body
    public var body: some View {
        CapyCard(style: style, padding: CapySpacing.medium) {
            HStack(spacing: CapySpacing.medium) {
                // Leading content
                if let leading = leading {
                    leading
                }
                
                // Text content
                VStack(alignment: .leading, spacing: CapySpacing.xxSmall) {
                    Text(title)
                        .font(CapyTypography.bodyMedium)
                        .foregroundColor(CapyColors.textPrimary)
                    
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(CapyTypography.bodySmall)
                            .foregroundColor(CapyColors.textSecondary)
                            .lineLimit(2)
                    }
                }
                
                Spacer()
                
                // Trailing content
                if let trailing = trailing {
                    trailing
                }
            }
        }
        .onTapGesture {
            onTap?()
        }
        .opacity(onTap != nil ? 1.0 : 1.0)
    }
}

// MARK: - CapyImageCard
public struct CapyImageCard: View {
    
    // MARK: - Properties
    let imageURL: URL?
    let title: String
    let subtitle: String?
    let badge: String?
    let onTap: (() -> Void)?
    
    // MARK: - Initialization
    public init(
        imageURL: URL?,
        title: String,
        subtitle: String? = nil,
        badge: String? = nil,
        onTap: (() -> Void)? = nil
    ) {
        self.imageURL = imageURL
        self.title = title
        self.subtitle = subtitle
        self.badge = badge
        self.onTap = onTap
    }
    
    // MARK: - Body
    public var body: some View {
        CapyCard(style: .elevated, padding: 0) {
            VStack(alignment: .leading, spacing: 0) {
                // Image
                ZStack(alignment: .topTrailing) {
                    Rectangle()
                        .fill(CapyColors.cardBackground)
                        .aspectRatio(16/9, contentMode: .fit)
                        .overlay(
                            Image(systemName: "photo")
                                .font(.system(size: 40))
                                .foregroundColor(CapyColors.textTertiary)
                        )
                    
                    if let badge = badge {
                        Text(badge)
                            .font(CapyTypography.labelSmall)
                            .foregroundColor(.white)
                            .padding(.horizontal, CapySpacing.small)
                            .padding(.vertical, CapySpacing.xxSmall)
                            .background(CapyColors.primary)
                            .cornerRadius(CapyRadius.small)
                            .padding(CapySpacing.small)
                    }
                }
                
                // Content
                VStack(alignment: .leading, spacing: CapySpacing.xxSmall) {
                    Text(title)
                        .font(CapyTypography.heading4)
                        .foregroundColor(CapyColors.textPrimary)
                        .lineLimit(2)
                    
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(CapyTypography.bodySmall)
                            .foregroundColor(CapyColors.textSecondary)
                            .lineLimit(2)
                    }
                }
                .padding(CapySpacing.medium)
            }
        }
        .onTapGesture {
            onTap?()
        }
    }
}

// MARK: - CapyStatCard
public struct CapyStatCard: View {
    
    // MARK: - Properties
    let title: String
    let value: String
    let subtitle: String?
    let icon: String
    let iconColor: Color
    let trend: Trend?
    
    public enum Trend {
        case up(String)
        case down(String)
        case neutral(String)
    }
    
    // MARK: - Initialization
    public init(
        title: String,
        value: String,
        subtitle: String? = nil,
        icon: String,
        iconColor: Color = CapyColors.primary,
        trend: Trend? = nil
    ) {
        self.title = title
        self.value = value
        self.subtitle = subtitle
        self.icon = icon
        self.iconColor = iconColor
        self.trend = trend
    }
    
    // MARK: - Body
    public var body: some View {
        CapyCard(style: .elevated, padding: CapySpacing.medium) {
            VStack(alignment: .leading, spacing: CapySpacing.small) {
                // Icon
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(iconColor)
                    .frame(width: 48, height: 48)
                    .background(iconColor.opacity(0.1))
                    .cornerRadius(CapyRadius.medium)
                
                // Value
                Text(value)
                    .font(CapyTypography.heading2)
                    .foregroundColor(CapyColors.textPrimary)
                
                // Title
                Text(title)
                    .font(CapyTypography.bodySmall)
                    .foregroundColor(CapyColors.textSecondary)
                
                // Trend
                if let trend = trend {
                    HStack(spacing: CapySpacing.xxSmall) {
                        Image(systemName: trendIcon(for: trend))
                            .font(.system(size: 12))
                            .foregroundColor(trendColor(for: trend))
                        
                        Text(trendText(for: trend))
                            .font(CapyTypography.caption)
                            .foregroundColor(trendColor(for: trend))
                    }
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    private func trendIcon(for trend: Trend) -> String {
        switch trend {
        case .up: return "arrow.up"
        case .down: return "arrow.down"
        case .neutral: return "minus"
        }
    }
    
    private func trendColor(for trend: Trend) -> Color {
        switch trend {
        case .up: return CapyColors.success
        case .down: return CapyColors.error
        case .neutral: return CapyColors.textTertiary
        }
    }
    
    private func trendText(for trend: Trend) -> String {
        switch trend {
        case .up(let text), .down(let text), .neutral(let text):
            return text
        }
    }
}

// MARK: - Preview
struct CapyCard_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            VStack(spacing: CapySpacing.medium) {
                // Basic card
                CapyCard {
                    Text("Basic Card Content")
                        .font(CapyTypography.bodyMedium)
                }
                
                // Elevated card
                CapyCard(style: .elevated) {
                    Text("Elevated Card")
                        .font(CapyTypography.bodyMedium)
                }
                
                // Outlined card
                CapyCard(style: .outlined) {
                    Text("Outlined Card")
                        .font(CapyTypography.bodyMedium)
                }
                
                // List card
                CapyListCard(
                    title: "Gym Name",
                    subtitle: "123 Main Street, City",
                    leading: {
                        Image(systemName: "mappin.circle.fill")
                            .font(.system(size: 32))
                            .foregroundColor(CapyColors.primary)
                    },
                    trailing: {
                        Image(systemName: "chevron.right")
                            .foregroundColor(CapyColors.textTertiary)
                    },
                    onTap: {}
                )
                
                // Stat card
                CapyStatCard(
                    title: "Workouts This Month",
                    value: "24",
                    subtitle: "Keep it up!",
                    icon: "flame.fill",
                    iconColor: CapyColors.primary,
                    trend: .up("+12% from last month")
                )
            }
            .padding()
        }
        .background(CapyColors.background)
    }
}
