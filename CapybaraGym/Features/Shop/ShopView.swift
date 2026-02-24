//
//  ShopView.swift
//  CapybaraGym
//
//  Shop screen for purchasing passes
//

import SwiftUI

public struct ShopView: View {
    
    @StateObject private var viewModel = ShopViewModel()
    @State private var selectedProduct: Product?
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: CapySpacing.large) {
                    // Hero Banner
                    heroBanner
                    
                    // Passes Section
                    passesSection
                    
                    // Memberships Section
                    membershipsSection
                    
                    // Promotions Section
                    promotionsSection
                }
                .padding(.vertical, CapySpacing.medium)
            }
            .background(CapyColors.background)
            .navigationTitle("Shop")
            .navigationBarTitleDisplayMode(.large)
            .sheet(item: $selectedProduct) { product in
                ProductDetailView(product: product)
            }
        }
    }
    
    // MARK: - Hero Banner
    private var heroBanner: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [CapyColors.primary, CapyColors.primaryDark],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            VStack(spacing: CapySpacing.medium) {
                Text("Special Offer")
                    .font(CapyTypography.overline)
                    .foregroundColor(.white.opacity(0.8))
                
                Text("20% Off\nMonthly Passes")
                    .font(CapyTypography.displaySmall)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text("Limited time offer. Use code CAPY20")
                    .font(CapyTypography.bodyMedium)
                    .foregroundColor(.white.opacity(0.9))
                
                CapyButton(
                    title: "Get Offer",
                    style: .secondary,
                    size: .small,
                    isFullWidth: false
                ) {
                    // Apply promo code
                }
                .padding(.top, CapySpacing.small)
            }
            .padding(CapySpacing.large)
        }
        .frame(height: 280)
        .cornerRadius(CapyRadius.xLarge)
        .padding(.horizontal, CapySpacing.large)
    }
    
    // MARK: - Passes Section
    private var passesSection: some View {
        VStack(alignment: .leading, spacing: CapySpacing.medium) {
            Text("Day Passes")
                .font(CapyTypography.heading4)
                .foregroundColor(CapyColors.textPrimary)
                .padding(.horizontal, CapySpacing.large)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: CapySpacing.medium) {
                    ForEach(viewModel.dayPasses) { product in
                        ProductCard(product: product) {
                            selectedProduct = product
                        }
                    }
                }
                .padding(.horizontal, CapySpacing.large)
            }
        }
    }
    
    // MARK: - Memberships Section
    private var membershipsSection: some View {
        VStack(alignment: .leading, spacing: CapySpacing.medium) {
            Text("Memberships")
                .font(CapyTypography.heading4)
                .foregroundColor(CapyColors.textPrimary)
                .padding(.horizontal, CapySpacing.large)
            
            VStack(spacing: CapySpacing.small) {
                ForEach(viewModel.memberships) { product in
                    MembershipRow(product: product) {
                        selectedProduct = product
                    }
                }
            }
            .padding(.horizontal, CapySpacing.large)
        }
    }
    
    // MARK: - Promotions Section
    private var promotionsSection: some View {
        VStack(alignment: .leading, spacing: CapySpacing.medium) {
            Text("Current Promotions")
                .font(CapyTypography.heading4)
                .foregroundColor(CapyColors.textPrimary)
                .padding(.horizontal, CapySpacing.large)
            
            VStack(spacing: CapySpacing.small) {
                ForEach(viewModel.promotions) { promotion in
                    PromotionCard(promotion: promotion)
                }
            }
            .padding(.horizontal, CapySpacing.large)
        }
    }
}

// MARK: - Product Card
struct ProductCard: View {
    let product: Product
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            CapyCard(style: .elevated, padding: 0) {
                VStack(alignment: .leading, spacing: CapySpacing.small) {
                    // Image
                    ZStack {
                        Rectangle()
                            .fill(product.color.opacity(0.1))
                            .frame(width: 160, height: 120)
                        
                        Image(systemName: product.icon)
                            .font(.system(size: 48))
                            .foregroundColor(product.color)
                    }
                    
                    // Info
                    VStack(alignment: .leading, spacing: CapySpacing.xxSmall) {
                        Text(product.name)
                            .font(CapyTypography.labelLarge)
                            .foregroundColor(CapyColors.textPrimary)
                        
                        Text(product.description)
                            .font(CapyTypography.caption)
                            .foregroundColor(CapyColors.textSecondary)
                            .lineLimit(2)
                        
                        HStack {
                            Text(product.displayPrice)
                                .font(CapyTypography.heading4)
                                .foregroundColor(CapyColors.primary)
                            
                            if let originalPrice = product.originalPrice {
                                Text(originalPrice)
                                    .font(CapyTypography.bodySmall)
                                    .foregroundColor(CapyColors.textTertiary)
                                    .strikethrough()
                            }
                        }
                    }
                    .padding(CapySpacing.small)
                }
            }
            .frame(width: 160)
        }
    }
}

// MARK: - Membership Row
struct MembershipRow: View {
    let product: Product
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            CapyCard(style: .elevated, padding: CapySpacing.medium) {
                HStack(spacing: CapySpacing.medium) {
                    // Icon
                    ZStack {
                        Circle()
                            .fill(product.color.opacity(0.1))
                            .frame(width: 56, height: 56)
                        
                        Image(systemName: product.icon)
                            .font(.system(size: 28))
                            .foregroundColor(product.color)
                    }
                    
                    // Info
                    VStack(alignment: .leading, spacing: CapySpacing.xxSmall) {
                        Text(product.name)
                            .font(CapyTypography.heading5)
                            .foregroundColor(CapyColors.textPrimary)
                        
                        Text(product.description)
                            .font(CapyTypography.bodySmall)
                            .foregroundColor(CapyColors.textSecondary)
                        
                        HStack {
                            Text(product.displayPrice)
                                .font(CapyTypography.labelLarge)
                                .foregroundColor(CapyColors.primary)
                            
                            Text("/month")
                                .font(CapyTypography.caption)
                                .foregroundColor(CapyColors.textTertiary)
                        }
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(CapyColors.textTertiary)
                }
            }
        }
    }
}

// MARK: - Promotion Card
struct PromotionCard: View {
    let promotion: Promotion
    
    var body: some View {
        CapyCard(style: .outlined, padding: CapySpacing.medium) {
            HStack(spacing: CapySpacing.medium) {
                // Icon
                ZStack {
                    Circle()
                        .fill(promotion.color.opacity(0.1))
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: promotion.icon)
                        .font(.system(size: 24))
                        .foregroundColor(promotion.color)
                }
                
                // Info
                VStack(alignment: .leading, spacing: CapySpacing.xxSmall) {
                    Text(promotion.title)
                        .font(CapyTypography.labelLarge)
                        .foregroundColor(CapyColors.textPrimary)
                    
                    Text(promotion.description)
                        .font(CapyTypography.bodySmall)
                        .foregroundColor(CapyColors.textSecondary)
                    
                    if let expiryDate = promotion.expiryDate {
                        Text("Expires \(expiryDate.shortDate)")
                            .font(CapyTypography.caption)
                            .foregroundColor(CapyColors.warning)
                    }
                }
                
                Spacer()
                
                // Code
                if let code = promotion.code {
                    Text(code)
                        .font(CapyTypography.labelMedium)
                        .foregroundColor(CapyColors.primary)
                        .padding(.horizontal, CapySpacing.small)
                        .padding(.vertical, CapySpacing.xxSmall)
                        .background(CapyColors.primary.opacity(0.1))
                        .cornerRadius(CapyRadius.small)
                }
            }
        }
    }
}

// MARK: - Product Detail View
struct ProductDetailView: View {
    let product: Product
    @State private var quantity = 1
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: CapySpacing.large) {
                    // Hero
                    ZStack {
                        Rectangle()
                            .fill(product.color.opacity(0.1))
                            .frame(height: 200)
                        
                        Image(systemName: product.icon)
                            .font(.system(size: 100))
                            .foregroundColor(product.color)
                    }
                    
                    // Details
                    VStack(alignment: .leading, spacing: CapySpacing.medium) {
                        Text(product.name)
                            .font(CapyTypography.heading1)
                            .foregroundColor(CapyColors.textPrimary)
                        
                        Text(product.description)
                            .font(CapyTypography.bodyLarge)
                            .foregroundColor(CapyColors.textSecondary)
                        
                        // Features
                        if !product.features.isEmpty {
                            VStack(alignment: .leading, spacing: CapySpacing.small) {
                                Text("What's Included")
                                    .font(CapyTypography.heading5)
                                    .foregroundColor(CapyColors.textPrimary)
                                
                                ForEach(product.features, id: \.self) { feature in
                                    HStack(spacing: CapySpacing.small) {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(CapyColors.success)
                                        
                                        Text(feature)
                                            .font(CapyTypography.bodyMedium)
                                            .foregroundColor(CapyColors.textPrimary)
                                    }
                                }
                            }
                        }
                        
                        // Quantity
                        HStack {
                            Text("Quantity")
                                .font(CapyTypography.bodyMedium)
                                .foregroundColor(CapyColors.textPrimary)
                            
                            Spacer()
                            
                            HStack(spacing: CapySpacing.medium) {
                                Button(action: {
                                    if quantity > 1 { quantity -= 1 }
                                }) {
                                    Image(systemName: "minus.circle.fill")
                                        .font(.system(size: 28))
                                        .foregroundColor(CapyColors.primary)
                                }
                                
                                Text("\(quantity)")
                                    .font(CapyTypography.heading4)
                                    .foregroundColor(CapyColors.textPrimary)
                                    .frame(width: 40)
                                
                                Button(action: {
                                    quantity += 1
                                }) {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.system(size: 28))
                                        .foregroundColor(CapyColors.primary)
                                }
                            }
                        }
                        
                        Divider()
                        
                        // Total
                        HStack {
                            Text("Total")
                                .font(CapyTypography.heading4)
                                .foregroundColor(CapyColors.textPrimary)
                            
                            Spacer()
                            
                            Text(product.totalPrice(quantity: quantity))
                                .font(CapyTypography.heading2)
                                .foregroundColor(CapyColors.primary)
                        }
                    }
                    .padding(.horizontal, CapySpacing.large)
                    
                    Spacer()
                    
                    // Purchase Button
                    CapyButton(
                        title: "Purchase",
                        action: {
                            // Handle purchase
                            dismiss()
                        }
                    )
                    .padding(.horizontal, CapySpacing.large)
                }
            }
            .background(CapyColors.background)
            .navigationTitle("Product Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Models
struct Product: Identifiable {
    let id: String
    let name: String
    let description: String
    let price: Decimal
    let originalPrice: String?
    let icon: String
    let color: Color
    let features: [String]
    let type: ProductType
    
    enum ProductType {
        case dayPass
        case membership
        case promotion
    }
    
    var displayPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: price as NSNumber) ?? "\(price)"
    }
    
    func totalPrice(quantity: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        let total = price * Decimal(quantity)
        return formatter.string(from: total as NSNumber) ?? "\(total)"
    }
}

struct Promotion: Identifiable {
    let id: String
    let title: String
    let description: String
    let code: String?
    let discount: Decimal?
    let expiryDate: Date?
    let icon: String
    let color: Color
}

// MARK: - Preview
struct ShopView_Previews: PreviewProvider {
    static var previews: some View {
        ShopView()
    }
}
