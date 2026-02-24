import SwiftUI

// MARK: - Bead Collection View
struct BeadCollectionView: View {
    @StateObject private var viewModel = BeadViewModel()
    @State private var showFilterSheet = false
    @State private var showSortMenu = false
    @State private var selectedBead: Bead?
    @State private var showBeadDetail = false
    
    private let columns = [
        GridItem(.adaptive(minimum: 100, maximum: 120), spacing: 16)
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header Stats
                statsHeader
                
                // Progress Bar
                progressSection
                
                // Filters
                filterSection
                
                // Bead Grid
                beadGrid
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 20)
        }
        .background(DesignSystem.Colors.background)
        .navigationTitle("My Beads")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                syncButton
            }
        }
        .sheet(isPresented: $showFilterSheet) {
            BeadFilterSheet(viewModel: viewModel)
        }
        .sheet(item: $selectedBead) { bead in
            BeadDetailView(bead: bead, viewModel: viewModel)
        }
        .overlay {
            if viewModel.showEarnedAnimation, let bead = viewModel.newlyEarnedBead {
                BeadEarnedAnimation(bead: bead, isShowing: $viewModel.showEarnedAnimation)
            }
        }
        .task {
            await viewModel.loadBeads()
        }
        .refreshable {
            await viewModel.loadBeads()
        }
    }
    
    // MARK: - Stats Header
    private var statsHeader: some View {
        HStack(spacing: 16) {
            StatCard(
                title: "Total Beads",
                value: "\(viewModel.totalBeads)",
                icon: "circle.hexagongrid.fill",
                color: DesignSystem.Colors.primary
            )
            
            StatCard(
                title: "Unique Types",
                value: "\(viewModel.uniqueBeadTypes)",
                icon: "star.fill",
                color: DesignSystem.Colors.success
            )
            
            StatCard(
                title: "To Sync",
                value: "\(viewModel.unsyncedCount)",
                icon: "arrow.up.arrow.down",
                color: viewModel.unsyncedCount > 0 ? DesignSystem.Colors.warning : DesignSystem.Colors.success
            )
        }
    }
    
    // MARK: - Progress Section
    private var progressSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Collection Progress")
                    .font(DesignSystem.Typography.h3)
                
                Spacer()
                
                Text("\(Int(viewModel.completionPercentage))%")
                    .font(DesignSystem.Typography.captionMedium)
                    .foregroundColor(DesignSystem.Colors.primary)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(DesignSystem.Colors.backgroundCard)
                        .frame(height: 16)
                    
                    RoundedRectangle(cornerRadius: 8)
                        .fill(
                            LinearGradient(
                                colors: [DesignSystem.Colors.primary, DesignSystem.Colors.primary.opacity(0.7)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * CGFloat(viewModel.completionPercentage / 100), height: 16)
                        .animation(.easeInOut(duration: 0.5), value: viewModel.completionPercentage)
                }
            }
            .frame(height: 16)
            
            Text("\(viewModel.uniqueBeadTypes) of \(BeadType.allCases.count) bead types collected")
                .font(DesignSystem.Typography.caption)
                .foregroundColor(DesignSystem.Colors.textSecondary)
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
    
    // MARK: - Filter Section
    private var filterSection: some View {
        HStack(spacing: 12) {
            // Filter Button
            Button(action: { showFilterSheet = true }) {
                HStack(spacing: 6) {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                    Text("Filter")
                }
                .font(DesignSystem.Typography.bodyMedium)
                .foregroundColor(DesignSystem.Colors.primary)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(DesignSystem.Colors.primary.opacity(0.1))
                .cornerRadius(100)
            }
            
            // Sort Menu
            Menu {
                ForEach(BeadViewModel.SortOption.allCases, id: \.self) { option in
                    Button(action: { viewModel.setSortOption(option) }) {
                        Label(option.rawValue, systemImage: option.icon)
                    }
                }
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "arrow.up.arrow.down.circle")
                    Text(viewModel.sortOption.rawValue)
                }
                .font(DesignSystem.Typography.bodyMedium)
                .foregroundColor(DesignSystem.Colors.textPrimary)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(DesignSystem.Colors.backgroundCard)
                .cornerRadius(100)
            }
            
            Spacer()
            
            // Clear Filters
            if viewModel.selectedRarity != nil || viewModel.selectedType != nil {
                Button(action: { viewModel.clearFilters() }) {
                    Text("Clear")
                        .font(DesignSystem.Typography.captionMedium)
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                }
            }
        }
    }
    
    // MARK: - Bead Grid
    private var beadGrid: some View {
        LazyVGrid(columns: columns, spacing: 16) {
            ForEach(viewModel.filteredBeads) { bead in
                BeadCard(bead: bead)
                    .onTapGesture {
                        selectedBead = bead
                    }
            }
        }
    }
    
    // MARK: - Sync Button
    private var syncButton: some View {
        Button(action: {
            Task {
                await viewModel.syncBeads()
            }
        }) {
            HStack(spacing: 4) {
                Image(systemName: "arrow.clockwise")
                if viewModel.unsyncedCount > 0 {
                    Text("\(viewModel.unsyncedCount)")
                        .font(.caption2.bold())
                        .padding(.horizontal, 4)
                        .padding(.vertical, 2)
                        .background(Color.red)
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                }
            }
        }
        .disabled(viewModel.unsyncedCount == 0 || viewModel.state == .syncing)
    }
}

// MARK: - Stat Card
struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)
            
            Text(value)
                .font(DesignSystem.Typography.h2)
                .foregroundColor(DesignSystem.Colors.textPrimary)
            
            Text(title)
                .font(DesignSystem.Typography.caption)
                .foregroundColor(DesignSystem.Colors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
}

// MARK: - Bead Card
struct BeadCard: View {
    let bead: Bead
    @State private var isPressed = false
    
    var body: some View {
        VStack(spacing: 8) {
            // Bead Visual
            ZStack {
                Circle()
                    .fill(Color(hex: bead.colorHex).opacity(0.2))
                    .frame(width: 70, height: 70)
                
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(hex: bead.colorHex),
                                Color(hex: bead.colorHex).opacity(0.7)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 50, height: 50)
                    .shadow(
                        color: Color(hex: bead.colorHex).opacity(0.4),
                        radius: 8,
                        x: 0,
                        y: 4
                    )
                
                Image(systemName: beadIcon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
            }
            
            // Rarity Badge
            Text(bead.rarity.rawValue)
                .font(.system(size: 8, weight: .bold))
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(Color(hex: bead.rarity.colorHex).opacity(0.2))
                .foregroundColor(Color(hex: bead.rarity.colorHex))
                .cornerRadius(4)
            
            // Name
            Text(bead.name)
                .font(DesignSystem.Typography.captionMedium)
                .foregroundColor(DesignSystem.Colors.textPrimary)
                .lineLimit(1)
                .multilineTextAlignment(.center)
            
            // Date
            Text(formattedDate)
                .font(DesignSystem.Typography.small)
                .foregroundColor(DesignSystem.Colors.textSecondary)
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: isPressed)
        .onLongPressGesture(
            minimumDuration: 0.1,
            pressing: { pressing in
                isPressed = pressing
            },
            perform: {}
        )
        .overlay(
            // Sync indicator
            Group {
                if !bead.isSynced {
                    VStack {
                        HStack {
                            Spacer()
                            Image(systemName: "arrow.up.circle.fill")
                                .font(.system(size: 16))
                                .foregroundColor(DesignSystem.Colors.warning)
                                .background(Color.white)
                                .clipShape(Circle())
                        }
                        Spacer()
                    }
                    .padding(4)
                }
            }
        )
    }
    
    private var beadIcon: String {
        switch bead.type {
        case .firstCheckIn: return "figure.walk"
        case .streak3, .streak7, .streak30, .streak100: return "flame.fill"
        case .earlyBird: return "sunrise.fill"
        case .nightOwl: return "moon.fill"
        case .weekendWarrior: return "calendar.badge.clock"
        case .gymExplorer: return "mappin.and.ellipse"
        case .socialButterfly: return "person.3.fill"
        case .passCollector: return "ticket.fill"
        case .fitnessMaster: return "trophy.fill"
        case .specialEvent: return "sparkles"
        case .limitedEdition: return "crown.fill"
        }
    }
    
    private var formattedDate: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: bead.earnedAt, relativeTo: Date())
    }
}

// MARK: - Bead Filter Sheet
struct BeadFilterSheet: View {
    @ObservedObject var viewModel: BeadViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List {
                // Rarity Filter
                Section("Rarity") {
                    ForEach(BeadRarity.allCases, id: \.self) { rarity in
                        Button(action: {
                            if viewModel.selectedRarity == rarity {
                                viewModel.filterByRarity(nil)
                            } else {
                                viewModel.filterByRarity(rarity)
                            }
                        }) {
                            HStack {
                                Circle()
                                    .fill(Color(hex: rarity.colorHex))
                                    .frame(width: 12, height: 12)
                                
                                Text(rarity.displayName)
                                
                                Spacer()
                                
                                if viewModel.selectedRarity == rarity {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(DesignSystem.Colors.primary)
                                }
                            }
                        }
                        .foregroundColor(DesignSystem.Colors.textPrimary)
                    }
                }
                
                // Type Filter
                Section("Type") {
                    ForEach(BeadType.allCases, id: \.self) { type in
                        Button(action: {
                            if viewModel.selectedType == type {
                                viewModel.filterByType(nil)
                            } else {
                                viewModel.filterByType(type)
                            }
                        }) {
                            HStack {
                                Text(type.displayName)
                                
                                Spacer()
                                
                                if viewModel.selectedType == type {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(DesignSystem.Colors.primary)
                                }
                            }
                        }
                        .foregroundColor(DesignSystem.Colors.textPrimary)
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Filter Beads")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Bead Detail View
struct BeadDetailView: View {
    let bead: Bead
    @ObservedObject var viewModel: BeadViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Bead Visual
                    ZStack {
                        Circle()
                            .fill(Color(hex: bead.colorHex).opacity(0.15))
                            .frame(width: 200, height: 200)
                        
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(hex: bead.colorHex),
                                        Color(hex: bead.colorHex).opacity(0.7)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 140, height: 140)
                            .shadow(
                                color: Color(hex: bead.colorHex).opacity(0.5),
                                radius: 20,
                                x: 0,
                                y: 10
                            )
                        
                        Image(systemName: beadIcon)
                            .font(.system(size: 60, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    .padding(.top, 20)
                    
                    // Info
                    VStack(spacing: 12) {
                        Text(bead.name)
                            .font(DesignSystem.Typography.h1)
                            .foregroundColor(DesignSystem.Colors.textPrimary)
                        
                        HStack(spacing: 8) {
                            Text(bead.rarity.displayName)
                                .font(DesignSystem.Typography.captionMedium)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 4)
                                .background(Color(hex: bead.rarity.colorHex).opacity(0.2))
                                .foregroundColor(Color(hex: bead.rarity.colorHex))
                                .cornerRadius(100)
                            
                            if !bead.isSynced {
                                HStack(spacing: 4) {
                                    Image(systemName: "arrow.up")
                                    Text("Not Synced")
                                }
                                .font(DesignSystem.Typography.caption)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 4)
                                .background(DesignSystem.Colors.warning.opacity(0.2))
                                .foregroundColor(DesignSystem.Colors.warning)
                                .cornerRadius(100)
                            }
                        }
                        
                        Text(bead.description)
                            .font(DesignSystem.Typography.body)
                            .foregroundColor(DesignSystem.Colors.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                    }
                    
                    // Details
                    VStack(spacing: 16) {
                        DetailRow(title: "Earned", value: formattedDate)
                        DetailRow(title: "Type", value: bead.type.displayName)
                        
                        if let gymId = bead.gymId {
                            DetailRow(title: "Gym ID", value: gymId)
                        }
                        
                        if let checkInId = bead.checkInId {
                            DetailRow(title: "Check-in ID", value: checkInId)
                        }
                    }
                    .padding(20)
                    .background(DesignSystem.Colors.backgroundCard)
                    .cornerRadius(16)
                    .padding(.horizontal, 16)
                    
                    // Share Button
                    CapyButton(
                        title: "Share Bead",
                        icon: "square.and.arrow.up",
                        action: {
                            shareBead()
                        }
                    )
                    .padding(.horizontal, 16)
                    
                    Spacer()
                }
            }
            .background(DesignSystem.Colors.background)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var beadIcon: String {
        switch bead.type {
        case .firstCheckIn: return "figure.walk"
        case .streak3, .streak7, .streak30, .streak100: return "flame.fill"
        case .earlyBird: return "sunrise.fill"
        case .nightOwl: return "moon.fill"
        case .weekendWarrior: return "calendar.badge.clock"
        case .gymExplorer: return "mappin.and.ellipse"
        case .socialButterfly: return "person.3.fill"
        case .passCollector: return "ticket.fill"
        case .fitnessMaster: return "trophy.fill"
        case .specialEvent: return "sparkles"
        case .limitedEdition: return "crown.fill"
        }
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: bead.earnedAt)
    }
    
    private func shareBead() {
        let text = viewModel.shareBead(bead)
        // Implement share sheet
    }
}

// MARK: - Detail Row
struct DetailRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(DesignSystem.Typography.body)
                .foregroundColor(DesignSystem.Colors.textSecondary)
            
            Spacer()
            
            Text(value)
                .font(DesignSystem.Typography.bodyMedium)
                .foregroundColor(DesignSystem.Colors.textPrimary)
        }
    }
}

// MARK: - Bead Earned Animation
struct BeadEarnedAnimation: View {
    let bead: Bead
    @Binding var isShowing: Bool
    @State private var scale: CGFloat = 0.1
    @State private var opacity: Double = 0
    @State private var rotation: Double = 0
    
    var body: some View {
        ZStack {
            // Background overlay
            Color.black.opacity(0.7)
                .ignoresSafeArea()
                .onTapGesture {
                    dismiss()
                }
            
            // Celebration content
            VStack(spacing: 24) {
                Spacer()
                
                Text("New Bead Earned!")
                    .font(DesignSystem.Typography.display)
                    .foregroundColor(.white)
                    .opacity(opacity)
                
                // Animated bead
                ZStack {
                    // Glow effect
                    Circle()
                        .fill(Color(hex: bead.colorHex).opacity(0.3))
                        .frame(width: 250, height: 250)
                        .blur(radius: 30)
                    
                    // Bead
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(hex: bead.colorHex),
                                    Color(hex: bead.colorHex).opacity(0.8)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 150, height: 150)
                        .shadow(
                            color: Color(hex: bead.colorHex).opacity(0.6),
                            radius: 30,
                            x: 0,
                            y: 10
                        )
                        .scaleEffect(scale)
                        .rotationEffect(.degrees(rotation))
                    
                    Image(systemName: beadIcon)
                        .font(.system(size: 70, weight: .bold))
                        .foregroundColor(.white)
                        .scaleEffect(scale)
                }
                
                Text(bead.name)
                    .font(DesignSystem.Typography.h1)
                    .foregroundColor(.white)
                    .opacity(opacity)
                
                Text(bead.rarity.displayName)
                    .font(DesignSystem.Typography.h3)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .background(Color(hex: bead.rarity.colorHex).opacity(0.3))
                    .foregroundColor(Color(hex: bead.rarity.colorHex))
                    .cornerRadius(100)
                    .opacity(opacity)
                
                Text(bead.description)
                    .font(DesignSystem.Typography.bodyLarge)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .opacity(opacity)
                
                Spacer()
                
                // Continue button
                Button(action: { dismiss() }) {
                    Text("Awesome!")
                        .font(DesignSystem.Typography.button)
                        .foregroundColor(DesignSystem.Colors.primary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.white)
                        .cornerRadius(100)
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            animateIn()
        }
    }
    
    private var beadIcon: String {
        switch bead.type {
        case .firstCheckIn: return "figure.walk"
        case .streak3, .streak7, .streak30, .streak100: return "flame.fill"
        case .earlyBird: return "sunrise.fill"
        case .nightOwl: return "moon.fill"
        case .weekendWarrior: return "calendar.badge.clock"
        case .gymExplorer: return "mappin.and.ellipse"
        case .socialButterfly: return "person.3.fill"
        case .passCollector: return "ticket.fill"
        case .fitnessMaster: return "trophy.fill"
        case .specialEvent: return "sparkles"
        case .limitedEdition: return "crown.fill"
        }
    }
    
    private func animateIn() {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.6)) {
            scale = 1.0
            opacity = 1.0
        }
        
        withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
            rotation = 360
        }
    }
    
    private func dismiss() {
        withAnimation(.easeOut(duration: 0.3)) {
            scale = 0.1
            opacity = 0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            isShowing = false
        }
    }
}

// MARK: - Preview
struct BeadCollectionView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            BeadCollectionView()
        }
    }
}
