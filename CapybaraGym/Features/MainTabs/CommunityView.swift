//
//  CommunityView.swift
//  CapybaraGym
//
//  Community posts and discussions
//

import SwiftUI

struct CommunityView: View {
    @StateObject private var viewModel = CommunityViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Category Tabs
                    categoryTabs
                        .padding(.horizontal)
                        .padding(.top, 8)
                    
                    // Content
                    contentView
                }
            }
            .navigationTitle("Community")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { viewModel.showNewPost() }) {
                        Image(systemName: "square.and.pencil")
                            .font(.headline)
                            .foregroundColor(.primaryBrown)
                    }
                }
            }
            .sheet(isPresented: $viewModel.showCreatePost) {
                CreatePostView()
            }
        }
    }
    
    // MARK: - Category Tabs
    private var categoryTabs: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(viewModel.categories) { category in
                    CategoryTab(
                        title: category.name,
                        isSelected: viewModel.selectedCategory?.id == category.id,
                        action: { viewModel.selectCategory(category) }
                    )
                }
            }
        }
    }
    
    // MARK: - Content View
    @ViewBuilder
    private var contentView: some View {
        switch viewModel.selectedCategory?.type {
        case .overview:
            OverviewView()
        case .boards:
            BoardsView()
        case .facilities:
            FacilitiesView()
        case .none:
            postsListView
        }
    }
    
    // MARK: - Posts List View
    private var postsListView: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: 16) {
                ForEach(viewModel.posts) { post in
                    CommunityPostCard(post: post) {
                        viewModel.selectPost(post)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.top, 16)
            .padding(.bottom, 32)
        }
        .refreshable {
            await viewModel.refreshPosts()
        }
    }
}

// MARK: - Category Tab
struct CategoryTab: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(isSelected ? .bodyMedium : .bodySmall)
                .foregroundColor(isSelected ? .white : .secondaryText)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.primaryBrown : Color.inputBackground)
                .cornerRadius(Layout.radiusFull)
        }
    }
}

// MARK: - Community Post Card
struct CommunityPostCard: View {
    let post: CommunityPost
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                // Header
                HStack(spacing: 12) {
                    // Avatar
                    ZStack {
                        Circle()
                            .fill(Color.primaryBrown.opacity(0.2))
                            .frame(width: 44, height: 44)
                        
                        Image(systemName: "person.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.primaryBrown)
                    }
                    
                    // Author Info
                    VStack(alignment: .leading, spacing: 2) {
                        Text(post.authorName)
                            .font(.bodyMedium)
                            .foregroundColor(.primaryText)
                        
                        HStack(spacing: 6) {
                            Text(post.timeAgo)
                                .font(.caption)
                                .foregroundColor(.tertiaryText)
                            
                            Text("•")
                                .font(.caption)
                                .foregroundColor(.tertiaryText)
                            
                            Text(post.category)
                                .font(.caption)
                                .foregroundColor(.primaryBrown)
                        }
                    }
                    
                    Spacer()
                    
                    // More Options
                    Button(action: {}) {
                        Image(systemName: "ellipsis")
                            .font(.bodyMedium)
                            .foregroundColor(.tertiaryText)
                    }
                }
                
                // Content
                VStack(alignment: .leading, spacing: 8) {
                    Text(post.title)
                        .font(.headline)
                        .foregroundColor(.primaryText)
                        .lineLimit(2)
                    
                    Text(post.content)
                        .font(.bodySmall)
                        .foregroundColor(.secondaryText)
                        .lineLimit(3)
                        .multilineTextAlignment(.leading)
                }
                
                // Image (if any)
                if let imageURL = post.imageURL {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 180)
                        .overlay(
                            Image(systemName: "photo")
                                .font(.system(size: 32))
                                .foregroundColor(.tertiaryText)
                        )
                }
                
                // Actions
                HStack(spacing: 24) {
                    ActionButton(
                        icon: post.isLiked ? "heart.fill" : "heart",
                        count: post.likes,
                        color: post.isLiked ? .errorRed : .tertiaryText,
                        action: {}
                    )
                    
                    ActionButton(
                        icon: "bubble.left",
                        count: post.comments,
                        color: .tertiaryText,
                        action: {}
                    )
                    
                    ActionButton(
                        icon: "arrow.2.squarepath",
                        count: post.shares,
                        color: .tertiaryText,
                        action: {}
                    )
                    
                    Spacer()
                    
                    Button(action: {}) {
                        Image(systemName: "bookmark")
                            .font(.bodyMedium)
                            .foregroundColor(.tertiaryText)
                    }
                }
            }
            .padding(16)
            .background(Color.cardBackground)
            .cornerRadius(Layout.radiusLarge)
        }
    }
}

// MARK: - Action Button
struct ActionButton: View {
    let icon: String
    let count: Int
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.bodySmall)
                Text("\(count)")
                    .font(.captionMedium)
            }
            .foregroundColor(color)
        }
    }
}

// MARK: - Create Post View
struct CreatePostView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var content = ""
    @State private var selectedCategory = "General"
    
    let categories = ["General", "Workout Tips", "Nutrition", "Progress", "Q&A"]
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Post Details") {
                    TextField("Title", text: $title)
                    
                    ZStack(alignment: .topLeading) {
                        if content.isEmpty {
                            Text("What's on your mind?")
                                .foregroundColor(.tertiaryText)
                                .padding(.top, 8)
                                .padding(.leading, 4)
                        }
                        TextEditor(text: $content)
                            .frame(minHeight: 120)
                    }
                }
                
                Section("Category") {
                    Picker("Category", selection: $selectedCategory) {
                        ForEach(categories, id: \.self) { category in
                            Text(category).tag(category)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                Section {
                    Button(action: {}) {
                        HStack {
                            Image(systemName: "photo")
                            Text("Add Photo")
                        }
                    }
                }
            }
            .navigationTitle("New Post")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Post") {
                        dismiss()
                    }
                    .disabled(title.isEmpty || content.isEmpty)
                }
            }
        }
    }
}

// MARK: - Community Category Model
struct CommunityCategory: Identifiable {
    let id = UUID()
    let name: String
    let type: CategoryType
    
    enum CategoryType {
        case overview, boards, facilities
    }
}

// MARK: - Community Post Model
struct CommunityPost: Identifiable {
    let id: String
    let authorName: String
    let authorAvatar: String?
    let timeAgo: String
    let category: String
    let title: String
    let content: String
    let imageURL: String?
    let likes: Int
    let comments: Int
    let shares: Int
    let isLiked: Bool
    
    static let samples = [
        CommunityPost(
            id: "1",
            authorName: "Sarah Johnson",
            authorAvatar: nil,
            timeAgo: "2 hours ago",
            category: "Workout Tips",
            title: "My 30-day transformation journey!",
            content: "Started working out at Capybara Fitness a month ago and the results have been amazing. Here's what I learned...",
            imageURL: nil,
            likes: 128,
            comments: 24,
            shares: 8,
            isLiked: true
        ),
        CommunityPost(
            id: "2",
            authorName: "Mike Chen",
            authorAvatar: nil,
            timeAgo: "4 hours ago",
            category: "Q&A",
            title: "Best time to visit for less crowd?",
            content: "I've been trying to find the best time to hit the gym when it's less crowded. Any recommendations?",
            imageURL: nil,
            likes: 45,
            comments: 18,
            shares: 2,
            isLiked: false
        ),
        CommunityPost(
            id: "3",
            authorName: "Emma Wilson",
            authorAvatar: nil,
            timeAgo: "Yesterday",
            category: "Nutrition",
            title: "Post-workout meal ideas",
            content: "Sharing some of my favorite high-protein meals that help with recovery after intense workouts...",
            imageURL: nil,
            likes: 256,
            comments: 42,
            shares: 31,
            isLiked: false
        )
    ]
}

// MARK: - ViewModel
@MainActor
class CommunityViewModel: ObservableObject {
    @Published var selectedCategory: CommunityCategory?
    @Published var showCreatePost = false
    @Published var posts: [CommunityPost] = CommunityPost.samples
    
    let categories: [CommunityCategory] = [
        CommunityCategory(name: "Overview", type: .overview),
        CommunityCategory(name: "Boards", type: .boards),
        CommunityCategory(name: "Facilities", type: .facilities)
    ]
    
    func selectCategory(_ category: CommunityCategory) {
        selectedCategory = selectedCategory?.id == category.id ? nil : category
    }
    
    func showNewPost() {
        showCreatePost = true
    }
    
    func selectPost(_ post: CommunityPost) {
        // Navigate to post detail
    }
    
    func refreshPosts() async {
        // Simulate API call
        try? await Task.sleep(nanoseconds: 1_000_000_000)
    }
}

// MARK: - Preview
#Preview("Community View") {
    CommunityView()
}
