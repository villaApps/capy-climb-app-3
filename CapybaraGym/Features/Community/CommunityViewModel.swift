//
//  CommunityViewModel.swift
//  CapybaraGym
//
//  Community ViewModel
//

import SwiftUI

@MainActor
public final class CommunityViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published public var posts: [Post] = []
    @Published public var challenges: [Challenge] = []
    @Published public var leaderboard: [LeaderboardUser] = []
    @Published public var isLoading = false
    
    // MARK: - Initialization
    public init() {
        loadMockData()
    }
    
    // MARK: - Public Methods
    
    public func refresh() async {
        // Load from API
    }
    
    public func likePost(_ postId: String) async {
        // Implement like functionality
    }
    
    public func joinChallenge(_ challengeId: String) async {
        // Implement join challenge
    }
    
    // MARK: - Private Methods
    
    private func loadMockData() {
        // Posts
        posts = [
            Post(
                id: "1",
                userId: "user1",
                userName: "Sarah Johnson",
                userInitials: "SJ",
                userColor: CapyColors.primary,
                content: "Just crushed my workout! 5 miles and feeling great! 🏃‍♀️💪",
                imageURL: nil,
                timestamp: Date().adding(hours: -2),
                likes: 24,
                comments: 5
            ),
            Post(
                id: "2",
                userId: "user2",
                userName: "Mike Chen",
                userInitials: "MC",
                userColor: CapyColors.info,
                content: "New PR on bench press today! 225lbs x 5 reps. Hard work pays off! 🏋️‍♂️",
                imageURL: nil,
                timestamp: Date().adding(hours: -5),
                likes: 56,
                comments: 12
            ),
            Post(
                id: "3",
                userId: "user3",
                userName: "Emily Davis",
                userInitials: "ED",
                userColor: CapyColors.success,
                content: "Morning yoga session was exactly what I needed. Namaste 🧘‍♀️",
                imageURL: nil,
                timestamp: Date().adding(hours: -8),
                likes: 32,
                comments: 3
            )
        ]
        
        // Challenges
        challenges = [
            Challenge(
                id: "1",
                title: "30-Day Cardio Challenge",
                description: "Complete 30 minutes of cardio every day for 30 days",
                difficulty: "Medium",
                target: 30,
                currentProgress: 12,
                participants: 245,
                daysRemaining: 18
            ),
            Challenge(
                id: "2",
                title: "10K Steps Daily",
                description: "Walk 10,000 steps every day this week",
                difficulty: "Easy",
                target: 7,
                currentProgress: 3,
                participants: 512,
                daysRemaining: 4
            ),
            Challenge(
                id: "3",
                title: "Strength Master",
                description: "Complete 20 strength training sessions this month",
                difficulty: "Hard",
                target: 20,
                currentProgress: 8,
                participants: 89,
                daysRemaining: 15
            )
        ]
        
        // Leaderboard
        leaderboard = [
            LeaderboardUser(
                id: "1",
                name: "Alex Thompson",
                initials: "AT",
                color: CapyColors.warning,
                points: 2450,
                workouts: 45,
                calories: 12500
            ),
            LeaderboardUser(
                id: "2",
                name: "Maria Garcia",
                initials: "MG",
                color: CapyColors.success,
                points: 2320,
                workouts: 42,
                calories: 11800
            ),
            LeaderboardUser(
                id: "3",
                name: "James Wilson",
                initials: "JW",
                color: CapyColors.info,
                points: 2180,
                workouts: 38,
                calories: 11200
            ),
            LeaderboardUser(
                id: "4",
                name: "Lisa Anderson",
                initials: "LA",
                color: CapyColors.primary,
                points: 1950,
                workouts: 35,
                calories: 9800
            ),
            LeaderboardUser(
                id: "5",
                name: "David Lee",
                initials: "DL",
                color: CapyColors.accentSecondary,
                points: 1820,
                workouts: 32,
                calories: 9200
            ),
            LeaderboardUser(
                id: "6",
                name: "Jennifer Brown",
                initials: "JB",
                color: CapyColors.accentTertiary,
                points: 1750,
                workouts: 30,
                calories: 8800
            ),
            LeaderboardUser(
                id: "7",
                name: "Robert Taylor",
                initials: "RT",
                color: CapyColors.error,
                points: 1680,
                workouts: 28,
                calories: 8500
            ),
            LeaderboardUser(
                id: "8",
                name: "Amanda Martinez",
                initials: "AM",
                color: CapyColors.warning,
                points: 1540,
                workouts: 26,
                calories: 7800
            )
        ]
    }
}
