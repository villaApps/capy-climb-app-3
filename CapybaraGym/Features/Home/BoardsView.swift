//
//  BoardsView.swift
//  CapybaraGym
//
//  Community boards and discussion categories
//

import SwiftUI

struct BoardsView: View {
    @StateObject private var viewModel = BoardsViewModel()
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                // Featured Board
                featuredBoardSection
                
                // Popular Boards
                popularBoardsSection
                
                // My Boards
                myBoardsSection
                
                // Recent Discussions
                recentDiscussionsSection
            }
            .padding()
            .padding(.bottom, 32)
        }
        .background(Color.appBackground)
    }
    
    // MARK: - Featured Board Section
    private var featuredBoardSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Featured Board")
                .font(.headline)
                .foregroundColor(.primaryText)
            
            if let featured = viewModel.featuredBoard {
                FeaturedBoardCard(board: featured)
            }
        }
    }
    
    // MARK: - Popular Boards Section
    private var popularBoardsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Popular Boards")
                    .font(.headline)
                    .foregroundColor(.primaryText)
                
                Spacer()
                
                Button(action: {}) {
                    Text("See All")
                        .font(.bodySmall)
                        .foregroundColor(.primaryBrown)
                }
            }
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(viewModel.popularBoards) { board in
                    BoardGridItem(board: board)
                }
            }
        }
    }
    
    // MARK: - My Boards Section
    private var myBoardsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("My Boards")
                    .font(.headline)
                    .foregroundColor(.primaryText)
                
                Spacer()
                
                Button(action: {}) {
                    HStack(spacing: 4) {
                        Image(systemName: "plus")
                            .font(.caption)
                        Text("Join")
                            .font(.bodySmall)
                    }
                    .foregroundColor(.primaryBrown)
                }
            }
            
            if viewModel.myBoards.isEmpty {
                EmptyStateView(
                    icon: "person.3",
                    title: "No Boards Yet",
                    message: "Join boards to connect with like-minded fitness enthusiasts"
                )
                .padding(.vertical, 20)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(viewModel.myBoards) { board in
                            MyBoardItem(board: board)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Recent Discussions Section
    private var recentDiscussionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Recent Discussions")
                    .font(.headline)
                    .foregroundColor(.primaryText)
                
                Spacer()
                
                Button(action: {}) {
                    Text("View All")
                        .font(.bodySmall)
                        .foregroundColor(.primaryBrown)
                }
            }
            
            VStack(spacing: 12) {
                ForEach(viewModel.recentDiscussions) { discussion in
                    DiscussionRow(discussion: discussion)
                }
            }
        }
    }
}

// MARK: - Featured Board Card
struct FeaturedBoardCard: View {
    let board: Board
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Banner Image
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [Color.primaryBrown, Color.primaryBrownLight]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .frame(height: 120)
                
                VStack(spacing: 8) {
                    Image(systemName: board.icon)
                        .font(.system(size: 40))
                        .foregroundColor(.white)
                    
                    Text(board.name)
                        .font(.title3)
                        .foregroundColor(.white)
                }
            }
            
            // Info
            VStack(alignment: .leading, spacing: 12) {
                Text(board.description)
                    .font(.bodySmall)
                    .foregroundColor(.secondaryText)
                    .lineLimit(2)
                
                HStack(spacing: 16) {
                    StatBadge(icon: "person.2", value: "\(board.memberCount)", label: "Members")
                    StatBadge(icon: "bubble.left", value: "\(board.postCount)", label: "Posts")
                }
                
                Button(action: {}) {
                    Text("Join Board")
                        .font(.buttonSmall)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 40)
                        .background(Color.primaryBrown)
                        .cornerRadius(Layout.radiusFull)
                }
            }
            .padding(16)
        }
        .background(Color.cardBackground)
        .cornerRadius(Layout.radiusLarge)
        .customShadow(ShadowStyle.card)
    }
}

// MARK: - Board Grid Item
struct BoardGridItem: View {
    let board: Board
    
    var body: some View {
        Button(action: {}) {
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(board.color.opacity(0.15))
                        .frame(width: 56, height: 56)
                    
                    Image(systemName: board.icon)
                        .font(.system(size: 24))
                        .foregroundColor(board.color)
                }
                
                VStack(spacing: 4) {
                    Text(board.name)
                        .font(.bodyMedium)
                        .foregroundColor(.primaryText)
                        .lineLimit(1)
                    
                    Text("\(board.memberCount) members")
                        .font(.caption)
                        .foregroundColor(.secondaryText)
                }
            }
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity)
            .background(Color.cardBackground)
            .cornerRadius(Layout.radiusMedium)
        }
    }
}

// MARK: - My Board Item
struct MyBoardItem: View {
    let board: Board
    
    var body: some View {
        Button(action: {}) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(board.color.opacity(0.15))
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: board.icon)
                        .font(.system(size: 20))
                        .foregroundColor(board.color)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(board.name)
                        .font(.bodyMedium)
                        .foregroundColor(.primaryText)
                    
                    if let lastActivity = board.lastActivity {
                        Text(lastActivity)
                            .font(.caption)
                            .foregroundColor(.secondaryText)
                    }
                }
                
                Spacer()
                
                if board.unreadCount > 0 {
                    Text("\(board.unreadCount)")
                        .font(.captionMedium)
                        .foregroundColor(.white)
                        .frame(width: 24, height: 24)
                        .background(Color.primaryBrown)
                        .clipShape(Circle())
                }
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.tertiaryText)
            }
            .padding(12)
            .frame(width: 280)
            .background(Color.cardBackground)
            .cornerRadius(Layout.radiusMedium)
        }
    }
}

// MARK: - Discussion Row
struct DiscussionRow: View {
    let discussion: Discussion
    
    var body: some View {
        Button(action: {}) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    // Board Tag
                    HStack(spacing: 4) {
                        Image(systemName: discussion.boardIcon)
                            .font(.caption2)
                        Text(discussion.boardName)
                            .font(.caption)
                    }
                    .foregroundColor(discussion.boardColor)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(discussion.boardColor.opacity(0.1))
                    .cornerRadius(6)
                    
                    Spacer()
                    
                    Text(discussion.timeAgo)
                        .font(.caption)
                        .foregroundColor(.tertiaryText)
                }
                
                Text(discussion.title)
                    .font(.bodyMedium)
                    .foregroundColor(.primaryText)
                    .lineLimit(2)
                
                HStack(spacing: 16) {
                    HStack(spacing: 4) {
                        Image(systemName: "person.circle")
                            .font(.caption)
                        Text(discussion.author)
                            .font(.caption)
                    }
                    .foregroundColor(.secondaryText)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "bubble.left")
                            .font(.caption)
                        Text("\(discussion.replies)")
                            .font(.caption)
                    }
                    .foregroundColor(.tertiaryText)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "eye")
                            .font(.caption)
                        Text("\(discussion.views)")
                            .font(.caption)
                    }
                    .foregroundColor(.tertiaryText)
                }
            }
            .padding(12)
            .background(Color.cardBackground)
            .cornerRadius(Layout.radiusMedium)
        }
    }
}

// MARK: - Stat Badge
struct StatBadge: View {
    let icon: String
    let value: String
    let label: String
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption)
            Text(value)
                .font(.captionMedium)
            Text(label)
                .font(.caption)
        }
        .foregroundColor(.secondaryText)
    }
}

// MARK: - Board Model
struct Board: Identifiable {
    let id: String
    let name: String
    let description: String
    let icon: String
    let color: Color
    let memberCount: Int
    let postCount: Int
    let unreadCount: Int
    let lastActivity: String?
    
    static let featured = Board(
        id: "1",
        name: "Transformation Stories",
        description: "Share your fitness journey and inspire others. Post before/after photos, progress updates, and tips that helped you along the way.",
        icon: "trophy.fill",
        color: .warningOrange,
        memberCount: 12543,
        postCount: 8932,
        unreadCount: 0,
        lastActivity: nil
    )
    
    static let popular = [
        Board(id: "2", name: "Workout Tips", description: "", icon: "dumbbell.fill", color: .primaryBrown, memberCount: 8934, postCount: 5621, unreadCount: 0, lastActivity: nil),
        Board(id: "3", name: "Nutrition", description: "", icon: "leaf.fill", color: .occupancyLow, memberCount: 7234, postCount: 4321, unreadCount: 0, lastActivity: nil),
        Board(id: "4", name: "Beginners", description: "", icon: "figure.walk", color: .occupancyMedium, memberCount: 15432, postCount: 9876, unreadCount: 0, lastActivity: nil),
        Board(id: "5", name: "Yoga & Mindfulness", description: "", icon: "sparkles", color: .primaryBrownLight, memberCount: 5432, postCount: 3210, unreadCount: 0, lastActivity: nil),
        Board(id: "6", name: "Running Club", description: "", icon: "figure.run", color: .occupancyLow, memberCount: 9876, postCount: 6543, unreadCount: 0, lastActivity: nil)
    ]
    
    static let myBoards = [
        Board(id: "7", name: "HIIT Enthusiasts", description: "", icon: "flame.fill", color: .errorRed, memberCount: 3456, postCount: 2100, unreadCount: 3, lastActivity: "2 new posts"),
        Board(id: "8", name: "Healthy Recipes", description: "", icon: "fork.knife", color: .occupancyLow, memberCount: 8765, postCount: 5432, unreadCount: 0, lastActivity: "Active 1h ago")
    ]
}

// MARK: - Discussion Model
struct Discussion: Identifiable {
    let id: String
    let boardName: String
    let boardIcon: String
    let boardColor: Color
    let title: String
    let author: String
    let timeAgo: String
    let replies: Int
    let views: Int
    
    static let samples = [
        Discussion(
            id: "1",
            boardName: "Workout Tips",
            boardIcon: "dumbbell.fill",
            boardColor: .primaryBrown,
            title: "Best exercises for building core strength?",
            author: "FitnessNewbie",
            timeAgo: "2h ago",
            replies: 24,
            views: 342
        ),
        Discussion(
            id: "2",
            boardName: "Nutrition",
            boardIcon: "leaf.fill",
            boardColor: .occupancyLow,
            title: "High protein meal prep ideas for the week",
            author: "HealthyEater",
            timeAgo: "4h ago",
            replies: 56,
            views: 892
        ),
        Discussion(
            id: "3",
            boardName: "Beginners",
            boardIcon: "figure.walk",
            boardColor: .occupancyMedium,
            title: "How do I overcome gym anxiety?",
            author: "FirstTimer",
            timeAgo: "6h ago",
            replies: 78,
            views: 1234
        )
    ]
}

// MARK: - ViewModel
@MainActor
class BoardsViewModel: ObservableObject {
    @Published var featuredBoard: Board? = .featured
    @Published var popularBoards: [Board] = Board.popular
    @Published var myBoards: [Board] = Board.myBoards
    @Published var recentDiscussions: [Discussion] = Discussion.samples
}

// MARK: - Preview
#Preview("Boards View") {
    BoardsView()
}
