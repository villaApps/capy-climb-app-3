//
//  PassManagementViewModel.swift
//  CapybaraGym
//
//  Pass management ViewModel
//

import SwiftUI

@MainActor
public final class PassManagementViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published public var activePass: Pass?
    @Published public var passHistory: [Pass] = []
    @Published public var isLoading = false
    @Published public var error: Error?
    
    // MARK: - Private Properties
    private let authService = AuthService.shared
    
    // MARK: - Initialization
    public init() {
        loadPasses()
    }
    
    // MARK: - Public Methods
    
    public func refresh() async {
        await loadPassesAsync()
    }
    
    public func purchasePass(type: Pass.PassType) async {
        // Implement purchase logic
    }
    
    // MARK: - Private Methods
    
    private func loadPasses() {
        // Mock data for preview
        activePass = Pass(
            id: "pass_active",
            name: "Premium Monthly",
            type: .monthly,
            remainingVisits: 999,
            totalVisits: 999,
            expiryDate: Date().adding(months: 1),
            purchaseDate: Date(),
            isActive: true
        )
        
        passHistory = [
            Pass(
                id: "pass_1",
                name: "Day Pass",
                type: .day,
                remainingVisits: 0,
                totalVisits: 1,
                expiryDate: Date().adding(days: -5),
                purchaseDate: Date().adding(days: -6),
                isActive: false
            ),
            Pass(
                id: "pass_2",
                name: "Weekly Pass",
                type: .weekly,
                remainingVisits: 0,
                totalVisits: 7,
                expiryDate: Date().adding(days: -15),
                purchaseDate: Date().adding(days: -22),
                isActive: false
            ),
            Pass(
                id: "pass_3",
                name: "Monthly Pass",
                type: .monthly,
                remainingVisits: 0,
                totalVisits: 30,
                expiryDate: Date().adding(months: -2),
                purchaseDate: Date().adding(months: -3),
                isActive: false
            )
        ]
    }
    
    private func loadPassesAsync() async {
        isLoading = true
        defer { isLoading = false }
        
        // Implement API call to fetch passes
        // This would call your backend API
    }
}
