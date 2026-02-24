//
//  ShopViewModel.swift
//  CapybaraGym
//
//  Shop ViewModel
//

import SwiftUI

@MainActor
public final class ShopViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published public var dayPasses: [Product] = []
    @Published public var memberships: [Product] = []
    @Published public var promotions: [Promotion] = []
    @Published public var isLoading = false
    @Published public var error: Error?
    
    // MARK: - Initialization
    public init() {
        loadProducts()
    }
    
    // MARK: - Public Methods
    
    public func refresh() async {
        // Load from API
    }
    
    public func purchaseProduct(_ product: Product, quantity: Int) async throws {
        // Implement purchase logic
    }
    
    public func applyPromoCode(_ code: String) async throws -> Decimal {
        // Validate and apply promo code
        return 0
    }
    
    // MARK: - Private Methods
    
    private func loadProducts() {
        // Day Passes
        dayPasses = [
            Product(
                id: "day_1",
                name: "Single Day",
                description: "24-hour gym access",
                price: 15.00,
                originalPrice: nil,
                icon: "ticket",
                color: CapyColors.info,
                features: ["Full gym access", "All amenities included", "Valid for 24 hours"],
                type: .dayPass
            ),
            Product(
                id: "day_3",
                name: "3-Day Pack",
                description: "Three day passes",
                price: 39.00,
                originalPrice: "$45",
                icon: "ticket.fill",
                color: CapyColors.success,
                features: ["3 separate day passes", "Shareable", "No expiration"],
                type: .dayPass
            ),
            Product(
                id: "day_7",
                name: "7-Day Pass",
                description: "One week access",
                price: 79.00,
                originalPrice: "$105",
                icon: "calendar.badge.clock",
                color: CapyColors.warning,
                features: ["7 consecutive days", "Full gym access", "All amenities included"],
                type: .dayPass
            )
        ]
        
        // Memberships
        memberships = [
            Product(
                id: "monthly_basic",
                name: "Basic Monthly",
                description: "Unlimited gym access",
                price: 49.00,
                originalPrice: nil,
                icon: "star",
                color: CapyColors.primary,
                features: ["Unlimited gym access", "Locker room access", "Free WiFi"],
                type: .membership
            ),
            Product(
                id: "monthly_premium",
                name: "Premium Monthly",
                description: "All-inclusive membership",
                price: 99.00,
                originalPrice: nil,
                icon: "crown",
                color: CapyColors.warning,
                features: [
                    "Unlimited gym access",
                    "Group fitness classes",
                    "Sauna & steam room",
                    "Guest passes (2/month)",
                    "Personal training discount"
                ],
                type: .membership
            ),
            Product(
                id: "yearly",
                name: "Annual Membership",
                description: "Best value - save 30%",
                price: 699.00,
                originalPrice: "$1,188",
                icon: "crown.fill",
                color: CapyColors.success,
                features: [
                    "All Premium benefits",
                    "2 months free",
                    "Priority class booking",
                    "Free fitness assessment",
                    "Nutrition consultation"
                ],
                type: .membership
            )
        ]
        
        // Promotions
        promotions = [
            Promotion(
                id: "promo_1",
                title: "Student Discount",
                description: "20% off all memberships with valid student ID",
                code: "STUDENT20",
                discount: 0.20,
                expiryDate: Date().adding(months: 3),
                icon: "graduationcap.fill",
                color: CapyColors.info
            ),
            Promotion(
                id: "promo_2",
                title: "Refer a Friend",
                description: "Get $20 credit when your friend signs up",
                code: nil,
                discount: nil,
                expiryDate: nil,
                icon: "person.2.fill",
                color: CapyColors.success
            ),
            Promotion(
                id: "promo_3",
                title: "First Timer Special",
                description: "50% off your first month",
                code: "FIRST50",
                discount: 0.50,
                expiryDate: Date().adding(days: 30),
                icon: "sparkles",
                color: CapyColors.warning
            )
        ]
    }
}
