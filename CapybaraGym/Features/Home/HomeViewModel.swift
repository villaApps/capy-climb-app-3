//
//  HomeViewModel.swift
//  CapybaraGym
//
//  Home screen ViewModel
//

import SwiftUI
import Combine

@MainActor
public final class HomeViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published public var userName: String = "Guest"
    @Published public var userInitials: String = "G"
    @Published public var greeting: String = "morning"
    
    @Published public var monthlyWorkouts: Int = 0
    @Published public var monthlyCalories: Int = 0
    @Published public var activeDays: Int = 0
    
    @Published public var activePass: Pass?
    @Published public var nearbyGyms: [GymLocation] = []
    @Published public var recentActivities: [Activity] = []
    
    @Published public var isLoadingGyms = false
    @Published public var error: Error?
    
    // MARK: - Private Properties
    private let authService = AuthService.shared
    private let locationService = LocationService.shared
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    public init() {
        setupBindings()
        updateGreeting()
        loadData()
    }
    
    // MARK: - Public Methods
    
    public func refresh() async {
        await loadNearbyGyms()
    }
    
    // MARK: - Private Methods
    
    private func setupBindings() {
        authService.$currentUser
            .receive(on: DispatchQueue.main)
            .sink { [weak self] user in
                self?.updateUserInfo(user)
            }
            .store(in: &cancellables)
    }
    
    private func updateUserInfo(_ user: AuthUser?) {
        if let user = user {
            userName = user.firstName ?? user.displayName
            userInitials = user.displayName.initials
        } else {
            userName = "Guest"
            userInitials = "G"
        }
    }
    
    private func updateGreeting() {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12:
            greeting = "morning"
        case 12..<17:
            greeting = "afternoon"
        case 17..<22:
            greeting = "evening"
        default:
            greeting = "night"
        }
    }
    
    private func loadData() {
        // Load mock data for preview
        loadMockData()
        
        // Load real data
        Task {
            await loadNearbyGyms()
        }
    }
    
    private func loadMockData() {
        // Mock active pass
        activePass = Pass(
            id: "pass_1",
            name: "Premium Monthly",
            type: .monthly,
            remainingVisits: 999,
            totalVisits: 999,
            expiryDate: Date().adding(months: 1),
            purchaseDate: Date(),
            isActive: true
        )
        
        // Mock stats
        monthlyWorkouts = 24
        monthlyCalories = 12500
        activeDays = 18
        
        // Mock activities
        recentActivities = [
            Activity(
                id: "1",
                title: "Workout at Capybara Fitness",
                subtitle: "Strength training • 45 min",
                icon: "dumbbell.fill",
                iconColor: CapyColors.primary,
                timestamp: Date().adding(hours: -2)
            ),
            Activity(
                id: "2",
                title: "Checked in at Downtown Gym",
                subtitle: "QR Code scan",
                icon: "qrcode",
                iconColor: CapyColors.success,
                timestamp: Date().adding(hours: -26)
            ),
            Activity(
                id: "3",
                title: "Purchased Day Pass",
                subtitle: "$15.00",
                icon: "bag.fill",
                iconColor: CapyColors.info,
                timestamp: Date().adding(days: -2)
            )
        ]
    }
    
    private func loadNearbyGyms() async {
        isLoadingGyms = true
        defer { isLoadingGyms = false }
        
        do {
            let gyms = try await locationService.getNearbyGyms(radius: 10000)
            self.nearbyGyms = gyms
        } catch {
            self.error = error
            Logger.error("Failed to load nearby gyms: \(error)")
        }
    }
}

// MARK: - Models

public struct Pass: Identifiable, Codable {
    public let id: String
    public let name: String
    public let type: PassType
    public let remainingVisits: Int
    public let totalVisits: Int
    public let expiryDate: Date?
    public let purchaseDate: Date
    public let isActive: Bool
    
    public enum PassType: String, Codable {
        case day = "day"
        case weekly = "weekly"
        case monthly = "monthly"
        case yearly = "yearly"
        class unlimited = "unlimited"
        
        public var displayName: String {
            switch self {
            case .day: return "Day Pass"
            case .weekly: return "Weekly Pass"
            case .monthly: return "Monthly Pass"
            case .yearly: return "Yearly Pass"
            case .unlimited: return "Unlimited Pass"
            }
        }
    }
}

public struct Activity: Identifiable, Codable {
    public let id: String
    public let title: String
    public let subtitle: String
    public let icon: String
    public let iconColor: Color
    public let timestamp: Date
    
    public var timeAgo: String {
        timestamp.timeAgo
    }
}
