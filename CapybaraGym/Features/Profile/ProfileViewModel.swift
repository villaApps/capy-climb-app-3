//
//  ProfileViewModel.swift
//  CapybaraGym
//
//  Profile ViewModel
//

import SwiftUI

@MainActor
public final class ProfileViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published public var userName: String = "Guest User"
    @Published public var userEmail: String = ""
    @Published public var userInitials: String = "G"
    @Published public var memberSince: String = "January 2024"
    
    @Published public var totalWorkouts: Int = 0
    @Published public var totalCalories: Int = 0
    @Published public var streakDays: Int = 0
    
    @Published public var achievements: [Achievement] = []
    
    @Published public var isLoading = false
    @Published public var error: Error?
    
    // MARK: - Private Properties
    private let authService = AuthService.shared
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    public init() {
        setupBindings()
        loadMockData()
    }
    
    // MARK: - Public Methods
    
    public func refresh() async {
        // Load from API
    }
    
    public func updateProfile(firstName: String, lastName: String, phoneNumber: String) async {
        do {
            _ = try await authService.updateUserAttributes(attributes: [
                "given_name": firstName,
                "family_name": lastName,
                "phone_number": phoneNumber
            ])
        } catch {
            self.error = error
        }
    }
    
    public func signOut() async {
        do {
            try await authService.signOut()
        } catch {
            self.error = error
        }
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
            userName = user.displayName
            userEmail = user.email
            userInitials = user.displayName.initials
        }
    }
    
    private func loadMockData() {
        totalWorkouts = 156
        totalCalories = 78450
        streakDays = 12
        
        achievements = [
            Achievement(
                id: "1",
                name: "First Workout",
                icon: "flame.fill",
                color: CapyColors.primary,
                isUnlocked: true
            ),
            Achievement(
                id: "2",
                name: "7-Day Streak",
                icon: "calendar.badge.clock",
                color: CapyColors.warning,
                isUnlocked: true
            ),
            Achievement(
                id: "3",
                name: "100 Workouts",
                icon: "100.circle.fill",
                color: CapyColors.success,
                isUnlocked: true
            ),
            Achievement(
                id: "4",
                name: "Early Bird",
                icon: "sunrise.fill",
                color: CapyColors.info,
                isUnlocked: true
            ),
            Achievement(
                id: "5",
                name: "30-Day Streak",
                icon: "crown.fill",
                color: CapyColors.accentSecondary,
                isUnlocked: false
            ),
            Achievement(
                id: "6",
                name: "Marathon",
                icon: "figure.run",
                color: CapyColors.accentTertiary,
                isUnlocked: false
            )
        ]
    }
}
