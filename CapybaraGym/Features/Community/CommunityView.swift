//
//  CommunityView.swift
//  CapybaraGym
//
//  Community and social features screen
//

import SwiftUI

public struct CommunityView: View {
    
    @StateObject private var viewModel = CommunityViewModel()
    @State private var selectedTab = 0
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Segmented Control
                Picker("View", selection: $selectedTab) {
                    Text("Feed").tag(0)
                    Text("Challenges").tag(1)
                    Text("Leaderboard").tag(2)
                }
                .pickerStyle(.segmented)
                .padding()
                
                // Content
                TabView(selection: $selectedTab) {
                    FeedView(viewModel: viewModel)
                        .tag(0)
                    
                    ChallengesView(viewModel: viewModel)
                        .tag(1)
                    
                    LeaderboardView(viewModel: viewModel)
                        .tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
            .navigationTitle("Community")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

// MARK: - Feed View
struct FeedView: View {
    @ObservedObject var viewModel: CommunityViewModel
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: CapySpacing.medium) {
                // Create Post Button
                CreatePostButton()
                    .padding(.horizontal, CapySpacing.large)
                
                // Posts
                ForEach(viewModel.posts) { post in
                    PostCard(post: post)
                        .padding(.horizontal, CapySpacing.large)
                }
            }
            .padding(.vertical, CapySpacing.medium)
        }
        .background(CapyColors.background)
    }
}

// MARK: - Create Post Button
struct CreatePostButton: View {
    var body: some View {
        Button(action: {}) {
            CapyCard(style: .elevated, padding: CapySpacing.medium) {
                HStack(spacing: CapySpacing.medium) {
                    ZStack {
                        Circle()
                            .fill(CapyColors.primary.opacity(0.1))
                            .frame(width: 44, height: 44)
                        
                        Image(systemName: "person.circle")
                            .font(.system(size: 24))
                            .foregroundColor(CapyColors.primary)
                    }
                    
                    Text("Share your workout...")
                        .font(CapyTypography.bodyMedium)
                        .foregroundColor(CapyColors.textSecondary)
                    
                    Spacer()
                    
                    Image(systemName: "photo")
                        .foregroundColor(CapyColors.primary)
                }
            }
        }
    }
}

// MARK: - Post Card
struct PostCard: View {
    let post: Post
    @State private var isLiked = false
    @State private var likeCount: Int
    
    init(post: Post) {
        self.post = post
        _likeCount = State(initialValue: post.likes)
    }
    
    var body: some View {
        CapyCard(style: .elevated, padding: CapySpacing.medium) {
            VStack(alignment: .leading, spacing: CapySpacing.medium) {
                // Header
                HStack(spacing: CapySpacing.medium) {
                    // Avatar
                    ZStack {
                        Circle()
                            .fill(post.userColor.opacity(0.2))
                            .frame(width: 44, height: 44)
                        
                        Text(post.userInitials)
                            .font(CapyTypography.labelMedium)
                            .foregroundColor(post.userColor)
                    }
                    
                    VStack(alignment: .leading, spacing: CapySpacing.xxSmall) {
                        Text(post.userName)
                            .font(CapyTypography.labelLarge)
                            .foregroundColor(CapyColors.textPrimary)
                        
                        Text(post.timestamp.timeAgo)
                            .font(CapyTypography.caption)
                            .foregroundColor(CapyColors.textTertiary)
                    }
                    
                    Spacer()
                    
                    Button(action: {}) {
                        Image(systemName: "ellipsis")
                            .foregroundColor(CapyColors.textTertiary)
                    }
                }
                
                // Content
                Text(post.content)
                    .font(CapyTypography.bodyMedium)
                    .foregroundColor(CapyColors.textPrimary)
                
                // Image (if any)
                if let imageURL = post.imageURL {
                    RoundedRectangle(cornerRadius: CapyRadius.large)
                        .fill(CapyColors.cardBackground)
                        .frame(height: 200)
                        .overlay(
                            Image(systemName: "photo")
                                .font(.system(size: 40))
                                .foregroundColor(CapyColors.textTertiary)
                        )
                }
                
                // Stats
                HStack(spacing: CapySpacing.small) {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 12))
                        .foregroundColor(CapyColors.error)
                    
                    Text("\(likeCount) likes")
                        .font(CapyTypography.caption)
                        .foregroundColor(CapyColors.textSecondary)
                    
                    Spacer()
                    
                    Text("\(post.comments) comments")
                        .font(CapyTypography.caption)
                        .foregroundColor(CapyColors.textSecondary)
                }
                
                Divider()
                
                // Actions
                HStack(spacing: 0) {
                    Button(action: {
                        isLiked.toggle()
                        likeCount += isLiked ? 1 : -1
                    }) {
                        HStack(spacing: CapySpacing.xxSmall) {
                            Image(systemName: isLiked ? "heart.fill" : "heart")
                                .foregroundColor(isLiked ? CapyColors.error : CapyColors.textSecondary)
                            
                            Text("Like")
                                .font(CapyTypography.bodySmall)
                                .foregroundColor(isLiked ? CapyColors.error : CapyColors.textSecondary)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    
                    Button(action: {}) {
                        HStack(spacing: CapySpacing.xxSmall) {
                            Image(systemName: "bubble.right")
                                .foregroundColor(CapyColors.textSecondary)
                            
                            Text("Comment")
                                .font(CapyTypography.bodySmall)
                                .foregroundColor(CapyColors.textSecondary)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    
                    Button(action: {}) {
                        HStack(spacing: CapySpacing.xxSmall) {
                            Image(systemName: "square.and.arrow.up")
                                .foregroundColor(CapyColors.textSecondary)
                            
                            Text("Share")
                                .font(CapyTypography.bodySmall)
                                .foregroundColor(CapyColors.textSecondary)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
            }
        }
    }
}

// MARK: - Challenges View
struct ChallengesView: View {
    @ObservedObject var viewModel: CommunityViewModel
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: CapySpacing.medium) {
                ForEach(viewModel.challenges) { challenge in
                    ChallengeCard(challenge: challenge)
                        .padding(.horizontal, CapySpacing.large)
                }
            }
            .padding(.vertical, CapySpacing.medium)
        }
        .background(CapyColors.background)
    }
}

// MARK: - Challenge Card
struct ChallengeCard: View {
    let challenge: Challenge
    
    var body: some View {
        CapyCard(style: .elevated, padding: 0) {
            VStack(alignment: .leading, spacing: 0) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: CapySpacing.xxSmall) {
                        Text(challenge.title)
                            .font(CapyTypography.heading4)
                            .foregroundColor(CapyColors.textPrimary)
                        
                        Text(challenge.description)
                            .font(CapyTypography.bodySmall)
                            .foregroundColor(CapyColors.textSecondary)
                    }
                    
                    Spacer()
                    
                    // Badge
                    Text(challenge.difficulty)
                        .font(CapyTypography.caption)
                        .foregroundColor(.white)
                        .padding(.horizontal, CapySpacing.small)
                        .padding(.vertical, CapySpacing.xxSmall)
                        .background(difficultyColor)
                        .cornerRadius(CapyRadius.small)
                }
                .padding(CapySpacing.medium)
                
                // Progress
                VStack(alignment: .leading, spacing: CapySpacing.small) {
                    HStack {
                        Text("Progress")
                            .font(CapyTypography.bodySmall)
                            .foregroundColor(CapyColors.textSecondary)
                        
                        Spacer()
                        
                        Text("\(challenge.currentProgress)/\(challenge.target)")
                            .font(CapyTypography.labelMedium)
                            .foregroundColor(CapyColors.primary)
                    }
                    
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(CapyColors.cardBackground)
                                .frame(height: 8)
                            
                            RoundedRectangle(cornerRadius: 4)
                                .fill(CapyGradients.primary)
                                .frame(width: progressWidth(in: geometry), height: 8)
                        }
                    }
                    .frame(height: 8)
                }
                .padding(.horizontal, CapySpacing.medium)
                .padding(.bottom, CapySpacing.medium)
                
                // Footer
                HStack {
                    HStack(spacing: -8) {
                        ForEach(0..<min(challenge.participants, 3), id: \.self) { _ in
                            Circle()
                                .fill(CapyColors.primary.opacity(0.3))
                                .frame(width: 28, height: 28)
                                .overlay(
                                    Circle()
                                        .stroke(CapyColors.cardElevated, lineWidth: 2)
                                )
                        }
                    }
                    
                    Text("\(challenge.participants) participants")
                        .font(CapyTypography.caption)
                        .foregroundColor(CapyColors.textSecondary)
                    
                    Spacer()
                    
                    Text("\(challenge.daysRemaining) days left")
                        .font(CapyTypography.caption)
                        .foregroundColor(CapyColors.warning)
                }
                .padding(CapySpacing.medium)
                .background(CapyColors.cardBackground)
            }
        }
    }
    
    private var difficultyColor: Color {
        switch challenge.difficulty {
        case "Easy":
            return CapyColors.success
        case "Medium":
            return CapyColors.warning
        case "Hard":
            return CapyColors.error
        default:
            return CapyColors.primary
        }
    }
    
    private func progressWidth(in geometry: GeometryProxy) -> CGFloat {
        let progress = CGFloat(challenge.currentProgress) / CGFloat(challenge.target)
        return geometry.size.width * min(progress, 1.0)
    }
}

// MARK: - Leaderboard View
struct LeaderboardView: View {
    @ObservedObject var viewModel: CommunityViewModel
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: CapySpacing.small) {
                // Top 3 Podium
                if viewModel.leaderboard.count >= 3 {
                    PodiumView(topUsers: Array(viewModel.leaderboard.prefix(3)))
                        .padding(.vertical, CapySpacing.large)
                }
                
                // Rest of leaderboard
                ForEach(Array(viewModel.leaderboard.dropFirst(3).enumerated()), id: \.element.id) { index, user in
                    LeaderboardRow(
                        rank: index + 4,
                        user: user
                    )
                    .padding(.horizontal, CapySpacing.large)
                }
            }
            .padding(.vertical, CapySpacing.medium)
        }
        .background(CapyColors.background)
    }
}

// MARK: - Podium View
struct PodiumView: View {
    let topUsers: [LeaderboardUser]
    
    var body: some View {
        HStack(alignment: .bottom, spacing: CapySpacing.medium) {
            // 2nd Place
            if topUsers.count > 1 {
                PodiumItem(
                    user: topUsers[1],
                    rank: 2,
                    height: 100,
                    color: Color.gray.opacity(0.7)
                )
            }
            
            // 1st Place
            PodiumItem(
                user: topUsers[0],
                rank: 1,
                height: 130,
                color: Color.yellow
            )
            
            // 3rd Place
            if topUsers.count > 2 {
                PodiumItem(
                    user: topUsers[2],
                    rank: 3,
                    height: 80,
                    color: Color.orange.opacity(0.7)
                )
            }
        }
        .padding(.horizontal, CapySpacing.large)
    }
}

// MARK: - Podium Item
struct PodiumItem: View {
    let user: LeaderboardUser
    let rank: Int
    let height: CGFloat
    let color: Color
    
    var body: some View {
        VStack(spacing: CapySpacing.small) {
            // Avatar
            ZStack {
                Circle()
                    .fill(user.color.opacity(0.2))
                    .frame(width: 60, height: 60)
                
                Text(user.initials)
                    .font(CapyTypography.labelLarge)
                    .foregroundColor(user.color)
                
                // Rank badge
                ZStack {
                    Circle()
                        .fill(color)
                        .frame(width: 24, height: 24)
                    
                    Text("\(rank)")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                }
                .offset(x: 20, y: 20)
            }
            
            Text(user.name)
                .font(CapyTypography.labelMedium)
                .foregroundColor(CapyColors.textPrimary)
            
            Text("\(user.points) pts")
                .font(CapyTypography.caption)
                .foregroundColor(CapyColors.textSecondary)
            
            // Podium
            RoundedRectangle(cornerRadius: 8)
                .fill(color)
                .frame(width: 80, height: height)
        }
    }
}

// MARK: - Leaderboard Row
struct LeaderboardRow: View {
    let rank: Int
    let user: LeaderboardUser
    
    var body: some View {
        CapyListCard(
            title: user.name,
            subtitle: "\(user.workouts) workouts • \(user.calories) kcal",
            leading: {
                HStack(spacing: CapySpacing.medium) {
                    Text("\(rank)")
                        .font(CapyTypography.heading4)
                        .foregroundColor(rank <= 10 ? CapyColors.primary : CapyColors.textTertiary)
                        .frame(width: 30)
                    
                    ZStack {
                        Circle()
                            .fill(user.color.opacity(0.2))
                            .frame(width: 44, height: 44)
                        
                        Text(user.initials)
                            .font(CapyTypography.labelMedium)
                            .foregroundColor(user.color)
                    }
                }
            },
            trailing: {
                Text("\(user.points)")
                    .font(CapyTypography.labelLarge)
                    .foregroundColor(CapyColors.primary)
            }
        )
    }
}

// MARK: - Models
struct Post: Identifiable {
    let id: String
    let userId: String
    let userName: String
    let userInitials: String
    let userColor: Color
    let content: String
    let imageURL: String?
    let timestamp: Date
    var likes: Int
    var comments: Int
}

struct Challenge: Identifiable {
    let id: String
    let title: String
    let description: String
    let difficulty: String
    let target: Int
    let currentProgress: Int
    let participants: Int
    let daysRemaining: Int
}

struct LeaderboardUser: Identifiable {
    let id: String
    let name: String
    let initials: String
    let color: Color
    let points: Int
    let workouts: Int
    let calories: Int
}

// MARK: - Preview
struct CommunityView_Previews: PreviewProvider {
    static var previews: some View {
        CommunityView()
    }
}
