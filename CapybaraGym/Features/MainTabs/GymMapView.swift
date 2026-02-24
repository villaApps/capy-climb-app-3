//
//  GymMapView.swift
//  CapybaraGym
//
//  Map view with gym locations
//

import SwiftUI
import MapKit

struct GymMapView: View {
    @StateObject private var viewModel = GymMapViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Map
                Map(position: $viewModel.mapPosition) {
                    ForEach(viewModel.gyms) { gym in
                        Marker(gym.name, systemImage: "dumbbell.fill", coordinate: gym.coordinate)
                            .tint(gym.markerColor)
                    }
                    
                    UserAnnotation()
                }
                .mapStyle(.standard)
                .mapControls {
                    MapUserLocationButton()
                    MapCompass()
                    MapScaleView()
                }
                
                // Overlay Content
                VStack(spacing: 0) {
                    // Search Header
                    searchHeader
                        .padding()
                    
                    Spacer()
                    
                    // Bottom Sheet
                    if let selectedGym = viewModel.selectedGym {
                        GymDetailCard(gym: selectedGym) {
                            viewModel.selectedGym = nil
                        } onNavigate: {
                            viewModel.navigateToGym(selectedGym)
                        }
                        .transition(.move(edge: .bottom))
                    } else {
                        // Gym List Preview
                        gymListPreview
                            .padding(.horizontal)
                            .padding(.bottom, 16)
                    }
                }
            }
            .navigationTitle("Find Gyms")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { viewModel.showFilterOptions() }) {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                            .font(.headline)
                            .foregroundColor(.primaryBrown)
                    }
                }
            }
            .sheet(isPresented: $viewModel.showFilters) {
                MapFilterSheet(viewModel: viewModel)
            }
        }
    }
    
    // MARK: - Search Header
    private var searchHeader: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                HStack(spacing: 10) {
                    Image(systemName: "magnifyingglass")
                        .font(.bodyMedium)
                        .foregroundColor(.tertiaryText)
                    
                    TextField("Search gyms...", text: $viewModel.searchText)
                        .font(.bodyMedium)
                }
                .padding(.horizontal, Layout.spacingM)
                .frame(height: 48)
                .background(Color.white)
                .cornerRadius(Layout.radiusMedium)
                .customShadow(ShadowStyle.card)
                
                Button(action: { viewModel.centerOnUser() }) {
                    Image(systemName: "location.fill")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width: 48, height: 48)
                        .background(Color.primaryBrown)
                        .cornerRadius(Layout.radiusMedium)
                        .customShadow(ShadowStyle.button)
                }
            }
            
            // Quick Filters
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(viewModel.quickFilters) { filter in
                        FilterChip(
                            title: filter.name,
                            isSelected: viewModel.selectedFilter?.id == filter.id,
                            action: { viewModel.selectFilter(filter) }
                        )
                    }
                }
            }
        }
    }
    
    // MARK: - Gym List Preview
    private var gymListPreview: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Nearby Gyms (\(viewModel.gyms.count))")
                    .font(.headline)
                    .foregroundColor(.primaryText)
                
                Spacer()
                
                Menu {
                    Button("Distance") { viewModel.sortBy = .distance }
                    Button("Rating") { viewModel.sortBy = .rating }
                    Button("Occupancy") { viewModel.sortBy = .occupancy }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.up.arrow.down")
                            .font(.caption)
                        Text("Sort")
                            .font(.captionMedium)
                    }
                    .foregroundColor(.primaryBrown)
                }
            }
            .padding(.horizontal, 4)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(viewModel.gyms.prefix(5)) { gym in
                        CompactGymCard(gym: gym) {
                            viewModel.selectGym(gym)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(Layout.radiusLarge)
        .customShadow(ShadowStyle.elevated)
    }
}

// MARK: - Filter Chip
struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.captionMedium)
                .foregroundColor(isSelected ? .white : .primaryText)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(isSelected ? Color.primaryBrown : Color.white)
                .cornerRadius(Layout.radiusFull)
                .customShadow(ShadowStyle.card)
        }
    }
}

// MARK: - Compact Gym Card
struct CompactGymCard: View {
    let gym: GymMapLocation
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Image
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 60, height: 60)
                    .overlay(
                        Image(systemName: "photo")
                            .foregroundColor(.tertiaryText)
                    )
                
                // Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(gym.name)
                        .font(.bodyMedium)
                        .foregroundColor(.primaryText)
                        .lineLimit(1)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.caption2)
                            .foregroundColor(.warningOrange)
                        Text(String(format: "%.1f", gym.rating))
                            .font(.caption)
                            .foregroundColor(.secondaryText)
                    }
                    
                    OccupancyIndicator(
                        occupancy: gym.occupancy,
                        capacity: gym.capacity,
                        showLabel: false,
                        style: .compact
                    )
                    .frame(width: 80)
                }
                .frame(width: 120, alignment: .leading)
            }
            .padding(10)
            .background(Color.cardBackground)
            .cornerRadius(Layout.radiusMedium)
        }
    }
}

// MARK: - Gym Detail Card
struct GymDetailCard: View {
    let gym: GymMapLocation
    let onDismiss: () -> Void
    let onNavigate: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            // Handle
            RoundedRectangle(cornerRadius: 2.5)
                .fill(Color.gray.opacity(0.3))
                .frame(width: 40, height: 5)
                .padding(.top, 8)
            
            HStack(spacing: 16) {
                // Image
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 80, height: 80)
                    .overlay(
                        Image(systemName: "photo")
                            .font(.system(size: 28))
                            .foregroundColor(.tertiaryText)
                    )
                
                // Info
                VStack(alignment: .leading, spacing: 6) {
                    Text(gym.name)
                        .font(.headline)
                        .foregroundColor(.primaryText)
                    
                    Text(gym.address)
                        .font(.bodySmall)
                        .foregroundColor(.secondaryText)
                        .lineLimit(2)
                    
                    HStack(spacing: 12) {
                        LiveOccupancyBadge(occupancy: gym.occupancy, capacity: gym.capacity)
                        
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .font(.caption2)
                                .foregroundColor(.warningOrange)
                            Text(String(format: "%.1f", gym.rating))
                                .font(.caption)
                        }
                    }
                }
                
                Spacer()
            }
            
            // Action Buttons
            HStack(spacing: 12) {
                Button(action: onDismiss) {
                    Text("Close")
                        .font(.buttonSmall)
                        .foregroundColor(.primaryText)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(Color.inputBackground)
                        .cornerRadius(Layout.radiusFull)
                }
                
                Button(action: onNavigate) {
                    HStack(spacing: 6) {
                        Image(systemName: "location.fill")
                            .font(.caption)
                        Text("Navigate")
                            .font(.buttonSmall)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(Color.primaryBrown)
                    .cornerRadius(Layout.radiusFull)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(Layout.radiusLarge)
        .customShadow(ShadowStyle.elevated)
        .padding(.horizontal)
    }
}

// MARK: - Map Filter Sheet
struct MapFilterSheet: View {
    @ObservedObject var viewModel: GymMapViewModel
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
                                .foregroundColor(.secondaryText)
                            Spacer()
                            Text("\(Int(viewModel.maxDistance)) km")
                                .font(.captionMedium)
                                .foregroundColor(.primaryBrown)
                            Spacer()
                            Text("50 km")
                                .font(.caption)
                                .foregroundColor(.secondaryText)
                        }
                    }
                }
                
                Section("Amenities") {
                    ForEach(viewModel.amenities, id: \.self) { amenity in
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
                
                Section("Occupancy") {
                    Picker("Max Occupancy", selection: $viewModel.maxOccupancy) {
                        Text("Any").tag(100)
                        Text("< 50%").tag(50)
                        Text("< 70%").tag(70)
                    }
                    .pickerStyle(.segmented)
                }
            }
            .navigationTitle("Filter Gyms")
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

// MARK: - Gym Map Location Model
struct GymMapLocation: Identifiable {
    let id: String
    let name: String
    let address: String
    let coordinate: CLLocationCoordinate2D
    let rating: Double
    let occupancy: Int
    let capacity: Int
    let amenities: [String]
    
    var markerColor: Color {
        let percentage = Double(occupancy) / Double(capacity)
        switch percentage {
        case 0..<0.5: return .occupancyLow
        case 0.5..<0.8: return .occupancyMedium
        default: return .occupancyHigh
        }
    }
}

// MARK: - Quick Filter Model
struct QuickFilter: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
}

// MARK: - ViewModel
@MainActor
class GymMapViewModel: ObservableObject {
    @Published var mapPosition: MapCameraPosition = .userLocation(followsHeading: true, fallback: .automatic)
    @Published var searchText = ""
    @Published var selectedGym: GymMapLocation?
    @Published var showFilters = false
    @Published var selectedFilter: QuickFilter?
    @Published var sortBy: SortOption = .distance
    @Published var maxDistance: Double = 10
    @Published var selectedAmenities: Set<String> = []
    @Published var maxOccupancy = 100
    
    let quickFilters: [QuickFilter] = [
        QuickFilter(name: "All", icon: "list.bullet"),
        QuickFilter(name: "Open Now", icon: "clock"),
        QuickFilter(name: "24/7", icon: "24.circle"),
        QuickFilter(name: "Pool", icon: "figure.pool.swim"),
        QuickFilter(name: "Classes", icon: "person.2")
    ]
    
    let amenities = ["Pool", "Sauna", "Yoga Studio", "Cardio", "Weights", "CrossFit", "Parking"]
    
    var gyms: [GymMapLocation] = [
        GymMapLocation(
            id: "1",
            name: "Capybara Fitness Center",
            address: "123 Gym Street, Downtown",
            coordinate: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
            rating: 4.8,
            occupancy: 45,
            capacity: 100,
            amenities: ["Pool", "Sauna", "Yoga"]
        ),
        GymMapLocation(
            id: "2",
            name: "Iron Pump Gym",
            address: "456 Muscle Ave, Uptown",
            coordinate: CLLocationCoordinate2D(latitude: 37.7849, longitude: -122.4094),
            rating: 4.5,
            occupancy: 78,
            capacity: 80,
            amenities: ["Weights", "Cardio", "CrossFit"]
        ),
        GymMapLocation(
            id: "3",
            name: "Zen Wellness Studio",
            address: "789 Peace Blvd, Midtown",
            coordinate: CLLocationCoordinate2D(latitude: 37.7649, longitude: -122.4294),
            rating: 4.9,
            occupancy: 12,
            capacity: 30,
            amenities: ["Yoga", "Pilates", "Meditation"]
        )
    ]
    
    enum SortOption {
        case distance, rating, occupancy
    }
    
    func centerOnUser() {
        mapPosition = .userLocation(followsHeading: true, fallback: .automatic)
    }
    
    func selectGym(_ gym: GymMapLocation) {
        selectedGym = gym
        withAnimation {
            mapPosition = .region(MKCoordinateRegion(
                center: gym.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            ))
        }
    }
    
    func selectFilter(_ filter: QuickFilter) {
        selectedFilter = selectedFilter?.id == filter.id ? nil : filter
    }
    
    func showFilterOptions() {
        showFilters = true
    }
    
    func resetFilters() {
        maxDistance = 10
        selectedAmenities.removeAll()
        maxOccupancy = 100
        selectedFilter = nil
    }
    
    func navigateToGym(_ gym: GymMapLocation) {
        // Open Maps app for navigation
        let placemark = MKPlacemark(coordinate: gym.coordinate)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = gym.name
        mapItem.openInMaps()
    }
}

// MARK: - Preview
#Preview("Gym Map View") {
    GymMapView()
}
