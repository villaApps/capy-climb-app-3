//
//  FacilitiesView.swift
//  CapybaraGym
//
//  Gym facilities listing and details
//

import SwiftUI

struct FacilitiesView: View {
    @StateObject private var viewModel = FacilitiesViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground.ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        // Search Bar
                        searchBar
                            .padding(.horizontal)
                            .padding(.top, 8)
                        
                        // Filter Chips
                        filterChips
                            .padding(.horizontal)
                            .padding(.top, 16)
                        
                        // Gyms List
                        gymsList
                            .padding(.horizontal)
                            .padding(.top, 20)
                            .padding(.bottom, 32)
                    }
                }
            }
            .navigationTitle("Gym Facilities")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { viewModel.showMapView() }) {
                        Image(systemName: "map")
                            .font(.headline)
                            .foregroundColor(.primaryBrown)
                    }
                }
            }
            .sheet(isPresented: $viewModel.showFilters) {
                FacilityFilterSheet(viewModel: viewModel)
            }
        }
    }
    
    // MARK: - Search Bar
    private var searchBar: some View {
        HStack(spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .font(.bodyMedium)
                    .foregroundColor(.tertiaryText)
                
                TextField("Search gyms, amenities...", text: $viewModel.searchText)
                    .font(.bodyMedium)
            }
            .padding(.horizontal, Layout.spacingM)
            .frame(height: 48)
            .background(Color.inputBackground)
            .cornerRadius(Layout.radiusMedium)
            
            Button(action: { viewModel.showFilters = true }) {
                Image(systemName: "slider.horizontal.3")
                    .font(.headline)
                    .foregroundColor(.primaryBrown)
                    .frame(width: 48, height: 48)
                    .background(Color.inputBackground)
                    .cornerRadius(Layout.radiusMedium)
            }
        }
    }
    
    // MARK: - Filter Chips
    private var filterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(viewModel.filters) { filter in
                    FilterChip(
                        title: filter.name,
                        isSelected: filter.isSelected,
                        action: { viewModel.toggleFilter(filter) }
                    )
                }
            }
        }
    }
    
    // MARK: - Gyms List
    private var gymsList: some View {
        LazyVStack(spacing: 16) {
            ForEach(viewModel.filteredGyms) { gym in
                FacilityCard(gym: gym) {
                    viewModel.selectGym(gym)
                }
            }
        }
    }
}

// MARK: - Facility Card
struct FacilityCard: View {
    let gym: Facility
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 0) {
                // Image Section
                ZStack(alignment: .topTrailing) {
                    // Gym Image
                    RoundedRectangle(cornerRadius: 0)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 180)
                        .overlay(
                            Image(systemName: "photo")
                                .font(.system(size: 40))
                                .foregroundColor(.tertiaryText)
                        )
                    
                    // Badges
                    VStack(alignment: .trailing, spacing: 8) {
                        // Open Badge
                        HStack(spacing: 4) {
                            Circle()
                                .fill(gym.isOpen ? Color.occupancyLow : Color.errorRed)
                                .frame(width: 6, height: 6)
                            Text(gym.isOpen ? "Open" : "Closed")
                                .font(.captionMedium)
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.black.opacity(0.6))
                        .cornerRadius(12)
                        
                        // Favorite Button
                        Button(action: {}) {
                            Image(systemName: gym.isFavorite ? "heart.fill" : "heart")
                                .font(.system(size: 18))
                                .foregroundColor(gym.isFavorite ? .errorRed : .white)
                                .padding(8)
                                .background(Color.black.opacity(0.4))
                                .clipShape(Circle())
                        }
                    }
                    .padding(12)
                }
                
                // Content Section
                VStack(alignment: .leading, spacing: 12) {
                    // Title and Rating
                    HStack {
                        Text(gym.name)
                            .font(.headline)
                            .foregroundColor(.primaryText)
                            .lineLimit(1)
                        
                        Spacer()
                        
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .font(.caption)
                                .foregroundColor(.warningOrange)
                            Text(String(format: "%.1f", gym.rating))
                                .font(.captionMedium)
                                .foregroundColor(.primaryText)
                        }
                    }
                    
                    // Location
                    HStack(spacing: 4) {
                        Image(systemName: "mappin.and.ellipse")
                            .font(.caption)
                            .foregroundColor(.secondaryText)
                        Text(gym.address)
                            .font(.bodySmall)
                            .foregroundColor(.secondaryText)
                            .lineLimit(1)
                    }
                    
                    // Occupancy
                    OccupancyIndicator(
                        occupancy: gym.occupancy,
                        capacity: gym.capacity,
                        showLabel: true,
                        style: .full
                    )
                    
                    // Amenities
                    FlowLayout(spacing: 8) {
                        ForEach(gym.amenities.prefix(4), id: \.self) { amenity in
                            AmenityBadge(name: amenity)
                        }
                    }
                    
                    // Hours and Distance
                    HStack {
                        HStack(spacing: 4) {
                            Image(systemName: "clock")
                                .font(.caption)
                                .foregroundColor(.tertiaryText)
                            Text(gym.hours)
                                .font(.caption)
                                .foregroundColor(.tertiaryText)
                        }
                        
                        Spacer()
                        
                        HStack(spacing: 4) {
                            Image(systemName: "location")
                                .font(.caption)
                                .foregroundColor(.primaryBrown)
                            Text("\(String(format: "%.1f", gym.distance)) km")
                                .font(.captionMedium)
                                .foregroundColor(.primaryBrown)
                        }
                    }
                    
                    // Action Buttons
                    HStack(spacing: 12) {
                        Button(action: {}) {
                            HStack(spacing: 6) {
                                Image(systemName: "location.fill")
                                    .font(.caption)
                                Text("Navigate")
                                    .font(.buttonSmall)
                            }
                            .foregroundColor(.primaryBrown)
                            .frame(maxWidth: .infinity)
                            .frame(height: 40)
                            .background(Color.primaryBrown.opacity(0.1))
                            .cornerRadius(Layout.radiusFull)
                        }
                        
                        Button(action: {}) {
                            HStack(spacing: 6) {
                                Image(systemName: "ticket.fill")
                                    .font(.caption)
                                Text("Buy Pass")
                                    .font(.buttonSmall)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 40)
                            .background(Color.primaryBrown)
                            .cornerRadius(Layout.radiusFull)
                        }
                    }
                }
                .padding(16)
            }
        }
        .background(Color.cardBackground)
        .cornerRadius(Layout.radiusLarge)
        .customShadow(ShadowStyle.card)
    }
}

// MARK: - Amenity Badge
struct AmenityBadge: View {
    let name: String
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: iconForAmenity(name))
                .font(.caption2)
            Text(name)
                .font(.caption)
        }
        .foregroundColor(.primaryBrown)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Color.primaryBrown.opacity(0.1))
        .cornerRadius(8)
    }
    
    private func iconForAmenity(_ amenity: String) -> String {
        switch amenity.lowercased() {
        case "pool": return "figure.pool.swim"
        case "sauna": return "flame.fill"
        case "yoga": return "sparkles"
        case "pilates": return "figure.mind.and.body"
        case "cardio": return "heart.fill"
        case "weights": return "dumbbell.fill"
        case "crossfit": return "figure.strengthtraining.traditional"
        case "parking": return "car.fill"
        case "wifi": return "wifi"
        case "locker": return "lock.fill"
        default: return "checkmark"
        }
    }
}

// MARK: - Flow Layout
struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(in: proposal.width ?? 0, subviews: subviews, spacing: spacing)
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(in: bounds.width, subviews: subviews, spacing: spacing)
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x,
                                      y: bounds.minY + result.positions[index].y),
                         proposal: .unspecified)
        }
    }
    
    struct FlowResult {
        var size: CGSize = .zero
        var positions: [CGPoint] = []
        
        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var x: CGFloat = 0
            var y: CGFloat = 0
            var rowHeight: CGFloat = 0
            
            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                
                if x + size.width > maxWidth && x > 0 {
                    x = 0
                    y += rowHeight + spacing
                    rowHeight = 0
                }
                
                positions.append(CGPoint(x: x, y: y))
                rowHeight = max(rowHeight, size.height)
                x += size.width + spacing
                self.size.width = max(self.size.width, x)
            }
            
            self.size.height = y + rowHeight
        }
    }
}

// MARK: - Facility Filter Sheet
struct FacilityFilterSheet: View {
    @ObservedObject var viewModel: FacilitiesViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                Section("Distance") {
                    VStack {
                        Slider(
                            value: $viewModel.maxDistance,
                            in: 1...50,
                            step: 1
                        )
                        
                        HStack {
                            Text("1 km")
                                .font(.caption)
                            Spacer()
                            Text("\(Int(viewModel.maxDistance)) km")
                                .font(.captionMedium)
                                .foregroundColor(.primaryBrown)
                            Spacer()
                            Text("50 km")
                                .font(.caption)
                        }
                    }
                }
                
                Section("Amenities") {
                    ForEach(viewModel.allAmenities, id: \.self) { amenity in
                        Toggle(amenity, isOn: Binding(
                            get: { viewModel.selectedAmenities.contains(amenity) },
                            set: { isOn in
                                if isOn {
                                    viewModel.selectedAmenities.insert(amenity)
                                } else {
                                    viewModel.selectedAmenities.remove(amenity)
                                }
                            }
                        ))
                    }
                }
                
                Section("Hours") {
                    Toggle("Open Now", isOn: $viewModel.showOpenOnly)
                    Toggle("24/7 Access", isOn: $viewModel.show24Hour)
                }
            }
            .navigationTitle("Filter")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Reset") {
                        viewModel.resetFilters()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Facility Model
struct Facility: Identifiable {
    let id: String
    let name: String
    let address: String
    let rating: Double
    let occupancy: Int
    let capacity: Int
    let amenities: [String]
    let distance: Double
    let hours: String
    let isOpen: Bool
    let isFavorite: Bool
    let imageURL: String?
    
    static let samples = [
        Facility(
            id: "1",
            name: "Capybara Fitness Center",
            address: "123 Gym Street, Downtown, San Francisco",
            rating: 4.8,
            occupancy: 45,
            capacity: 100,
            amenities: ["Pool", "Sauna", "Yoga", "Cardio", "Weights", "Parking"],
            distance: 2.5,
            hours: "5:00 AM - 11:00 PM",
            isOpen: true,
            isFavorite: true,
            imageURL: nil
        ),
        Facility(
            id: "2",
            name: "Iron Pump Gym",
            address: "456 Muscle Ave, Uptown, San Francisco",
            rating: 4.5,
            occupancy: 78,
            capacity: 80,
            amenities: ["Weights", "Cardio", "CrossFit", "Locker", "Wifi"],
            distance: 4.2,
            hours: "24/7",
            isOpen: true,
            isFavorite: false,
            imageURL: nil
        ),
        Facility(
            id: "3",
            name: "Zen Wellness Studio",
            address: "789 Peace Blvd, Midtown, San Francisco",
            rating: 4.9,
            occupancy: 12,
            capacity: 30,
            amenities: ["Yoga", "Pilates", "Meditation", "Sauna"],
            distance: 1.8,
            hours: "6:00 AM - 9:00 PM",
            isOpen: true,
            isFavorite: true,
            imageURL: nil
        ),
        Facility(
            id: "4",
            name: "Powerhouse Gym",
            address: "321 Strength Rd, Eastside, San Francisco",
            rating: 4.3,
            occupancy: 92,
            capacity: 120,
            amenities: ["Weights", "Cardio", "Pool", "Parking"],
            distance: 5.5,
            hours: "5:00 AM - 10:00 PM",
            isOpen: true,
            isFavorite: false,
            imageURL: nil
        )
    ]
}

// MARK: - Filter Model
struct FilterChipModel: Identifiable {
    let id = UUID()
    let name: String
    var isSelected: Bool
}

// MARK: - ViewModel
@MainActor
class FacilitiesViewModel: ObservableObject {
    @Published var searchText = ""
    @Published var showFilters = false
    @Published var maxDistance: Double = 10
    @Published var selectedAmenities: Set<String> = []
    @Published var showOpenOnly = false
    @Published var show24Hour = false
    
    let allAmenities = ["Pool", "Sauna", "Yoga", "Pilates", "Cardio", "Weights", "CrossFit", "Parking", "Locker", "Wifi"]
    
    @Published var filters: [FilterChipModel] = [
        FilterChipModel(name: "All", isSelected: true),
        FilterChipModel(name: "Open Now", isSelected: false),
        FilterChipModel(name: "24/7", isSelected: false),
        FilterChipModel(name: "Pool", isSelected: false),
        FilterChipModel(name: "Yoga", isSelected: false),
        FilterChipModel(name: "Weights", isSelected: false)
    ]
    
    @Published var gyms: [Facility] = Facility.samples
    
    var filteredGyms: [Facility] {
        gyms.filter { gym in
            // Search filter
            if !searchText.isEmpty {
                let searchLower = searchText.lowercased()
                let matchesSearch = gym.name.lowercased().contains(searchLower) ||
                                   gym.amenities.contains { $0.lowercased().contains(searchLower) }
                if !matchesSearch { return false }
            }
            
            // Distance filter
            if gym.distance > maxDistance { return false }
            
            // Amenities filter
            if !selectedAmenities.isEmpty {
                let gymAmenities = Set(gym.amenities)
                if selectedAmenities.isDisjoint(with: gymAmenities) { return false }
            }
            
            // Open now filter
            if showOpenOnly && !gym.isOpen { return false }
            
            // 24/7 filter
            if show24Hour && gym.hours != "24/7" { return false }
            
            return true
        }
    }
    
    func toggleFilter(_ filter: FilterChipModel) {
        if let index = filters.firstIndex(where: { $0.id == filter.id }) {
            filters[index].isSelected.toggle()
            
            // Update filter states
            if filter.name == "Open Now" {
                showOpenOnly = filters[index].isSelected
            } else if filter.name == "24/7" {
                show24Hour = filters[index].isSelected
            }
        }
    }
    
    func resetFilters() {
        maxDistance = 10
        selectedAmenities.removeAll()
        showOpenOnly = false
        show24Hour = false
        filters = filters.map { FilterChipModel(name: $0.name, isSelected: $0.name == "All") }
    }
    
    func selectGym(_ gym: Facility) {
        // Navigate to gym detail
    }
    
    func showMapView() {
        // Show map view
    }
}

// MARK: - Preview
#Preview("Facilities View") {
    FacilitiesView()
}
