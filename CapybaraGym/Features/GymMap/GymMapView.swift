//
//  GymMapView.swift
//  CapybaraGym
//
//  Gym map and discovery screen
//

import SwiftUI
import MapKit

public struct GymMapView: View {
    
    @StateObject private var viewModel = GymMapViewModel()
    @State private var selectedGym: GymLocation?
    @State private var showGymDetail = false
    @State private var searchText = ""
    
    public init() {}
    
    public var body: some View {
        ZStack {
            // Map
            Map(coordinateRegion: $viewModel.region,
                showsUserLocation: true,
                annotationItems: viewModel.gyms) { gym in
                MapAnnotation(coordinate: gym.coordinate) {
                    GymAnnotationView(gym: gym, isSelected: selectedGym?.id == gym.id) {
                        selectedGym = gym
                        showGymDetail = true
                    }
                }
            }
            .ignoresSafeArea()
            
            // Overlay UI
            VStack(spacing: 0) {
                // Search Bar
                searchBar
                    .padding()
                
                Spacer()
                
                // Bottom Sheet
                if showGymDetail, let gym = selectedGym {
                    GymDetailSheet(gym: gym) {
                        showGymDetail = false
                        selectedGym = nil
                    }
                    .transition(.move(edge: .bottom))
                } else {
                    // Gym List Preview
                    gymListPreview
                }
            }
        }
        .sheet(item: $selectedGym) { gym in
            GymDetailView(gym: gym)
        }
        .alert("Location Access Required", isPresented: $viewModel.showLocationAlert) {
            Button("Open Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Please enable location access in Settings to find gyms near you.")
        }
        .onAppear {
            viewModel.requestLocationPermission()
        }
    }
    
    // MARK: - Search Bar
    private var searchBar: some View {
        HStack(spacing: CapySpacing.small) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(CapyColors.textTertiary)
            
            TextField("Search gyms...", text: $searchText)
                .font(CapyTypography.bodyMedium)
            
            if !searchText.isEmpty {
                Button(action: { searchText = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(CapyColors.textTertiary)
                }
            }
        }
        .padding(.horizontal, CapySpacing.medium)
        .frame(height: 48)
        .background(CapyColors.cardElevated)
        .cornerRadius(CapyRadius.xLarge)
        .shadow(color: CapyColors.shadow, radius: 8, x: 0, y: 4)
    }
    
    // MARK: - Gym List Preview
    private var gymListPreview: some View {
        VStack(spacing: 0) {
            // Handle bar
            RoundedRectangle(cornerRadius: 2)
                .fill(CapyColors.divider)
                .frame(width: 40, height: 4)
                .padding(.top, CapySpacing.small)
                .padding(.bottom, CapySpacing.medium)
            
            // Header
            HStack {
                Text("Nearby Gyms")
                    .font(CapyTypography.heading4)
                    .foregroundColor(CapyColors.textPrimary)
                
                Spacer()
                
                Text("\(viewModel.gyms.count) found")
                    .font(CapyTypography.bodySmall)
                    .foregroundColor(CapyColors.textSecondary)
            }
            .padding(.horizontal, CapySpacing.large)
            
            // List
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: CapySpacing.medium) {
                    ForEach(viewModel.gyms) { gym in
                        GymPreviewCard(gym: gym) {
                            selectedGym = gym
                            viewModel.centerOnGym(gym)
                        }
                    }
                }
                .padding(.horizontal, CapySpacing.large)
                .padding(.vertical, CapySpacing.medium)
            }
            .frame(height: 180)
        }
        .background(CapyColors.cardElevated)
        .cornerRadius(CapyRadius.xLarge, corners: [.topLeft, .topRight])
        .shadow(color: CapyColors.shadow, radius: 10, x: 0, y: -5)
    }
}

// MARK: - Gym Annotation View
struct GymAnnotationView: View {
    let gym: GymLocation
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                // Outer circle (selected state)
                if isSelected {
                    Circle()
                        .fill(CapyColors.primary.opacity(0.2))
                        .frame(width: 48, height: 48)
                }
                
                // Main circle
                Circle()
                    .fill(isSelected ? CapyColors.primary : CapyColors.cardElevated)
                    .frame(width: 36, height: 36)
                    .shadow(color: CapyColors.shadow, radius: 4, x: 0, y: 2)
                
                // Icon
                Image(systemName: "dumbbell.fill")
                    .font(.system(size: 14))
                    .foregroundColor(isSelected ? .white : CapyColors.primary)
            }
        }
        .scaleEffect(isSelected ? 1.1 : 1.0)
        .animation(.spring(), value: isSelected)
    }
}

// MARK: - Gym Preview Card
struct GymPreviewCard: View {
    let gym: GymLocation
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: CapySpacing.medium) {
                // Image
                ZStack {
                    RoundedRectangle(cornerRadius: CapyRadius.large)
                        .fill(CapyColors.cardBackground)
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: "dumbbell.fill")
                        .font(.system(size: 30))
                        .foregroundColor(CapyColors.primary.opacity(0.5))
                }
                
                // Info
                VStack(alignment: .leading, spacing: CapySpacing.xxSmall) {
                    Text(gym.name)
                        .font(CapyTypography.labelLarge)
                        .foregroundColor(CapyColors.textPrimary)
                        .lineLimit(1)
                    
                    Text(gym.address)
                        .font(CapyTypography.bodySmall)
                        .foregroundColor(CapyColors.textSecondary)
                        .lineLimit(2)
                    
                    HStack(spacing: CapySpacing.small) {
                        Label("4.5", systemImage: "star.fill")
                            .font(CapyTypography.caption)
                            .foregroundColor(CapyColors.warning)
                        
                        Text("• 2.3 km")
                            .font(CapyTypography.caption)
                            .foregroundColor(CapyColors.textTertiary)
                    }
                }
                .frame(maxWidth: 180, alignment: .leading)
            }
            .padding(CapySpacing.medium)
            .background(CapyColors.backgroundSecondary)
            .cornerRadius(CapyRadius.xLarge)
            .overlay(
                RoundedRectangle(cornerRadius: CapyRadius.xLarge)
                    .stroke(CapyColors.divider, lineWidth: 1)
            )
        }
    }
}

// MARK: - Gym Detail Sheet
struct GymDetailSheet: View {
    let gym: GymLocation
    let onClose: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Handle and close button
            HStack {
                RoundedRectangle(cornerRadius: 2)
                    .fill(CapyColors.divider)
                    .frame(width: 40, height: 4)
                
                Spacer()
                
                Button(action: onClose) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(CapyColors.textTertiary)
                }
            }
            .padding(.horizontal, CapySpacing.large)
            .padding(.top, CapySpacing.small)
            
            // Content
            ScrollView {
                VStack(alignment: .leading, spacing: CapySpacing.medium) {
                    // Header
                    HStack(spacing: CapySpacing.medium) {
                        // Image
                        ZStack {
                            RoundedRectangle(cornerRadius: CapyRadius.large)
                                .fill(CapyColors.cardBackground)
                                .frame(width: 80, height: 80)
                            
                            Image(systemName: "dumbbell.fill")
                                .font(.system(size: 32))
                                .foregroundColor(CapyColors.primary)
                        }
                        
                        VStack(alignment: .leading, spacing: CapySpacing.xxSmall) {
                            Text(gym.name)
                                .font(CapyTypography.heading3)
                                .foregroundColor(CapyColors.textPrimary)
                            
                            Label("4.5 (234 reviews)", systemImage: "star.fill")
                                .font(CapyTypography.bodySmall)
                                .foregroundColor(CapyColors.warning)
                            
                            if gym.isOpen == true {
                                Text("Open now")
                                    .font(CapyTypography.bodySmall)
                                    .foregroundColor(CapyColors.success)
                            }
                        }
                    }
                    
                    // Address
                    Label(gym.address, systemImage: "mappin.circle.fill")
                        .font(CapyTypography.bodyMedium)
                        .foregroundColor(CapyColors.textSecondary)
                    
                    // Amenities
                    if let amenities = gym.amenities, !amenities.isEmpty {
                        VStack(alignment: .leading, spacing: CapySpacing.small) {
                            Text("Amenities")
                                .font(CapyTypography.heading5)
                                .foregroundColor(CapyColors.textPrimary)
                            
                            FlowLayout(spacing: CapySpacing.small) {
                                ForEach(amenities, id: \.self) { amenity in
                                    AmenityTag(text: amenity)
                                }
                            }
                        }
                    }
                    
                    // Opening Hours
                    if let hours = gym.openingHours, !hours.isEmpty {
                        VStack(alignment: .leading, spacing: CapySpacing.small) {
                            Text("Opening Hours")
                                .font(CapyTypography.heading5)
                                .foregroundColor(CapyColors.textPrimary)
                            
                            VStack(alignment: .leading, spacing: CapySpacing.xxSmall) {
                                ForEach(hours, id: \.dayOfWeek) { hour in
                                    HStack {
                                        Text(weekdayName(hour.dayOfWeek))
                                            .font(CapyTypography.bodySmall)
                                            .foregroundColor(CapyColors.textSecondary)
                                            .frame(width: 80, alignment: .leading)
                                        
                                        if hour.isOpen24Hours {
                                            Text("Open 24 hours")
                                                .font(CapyTypography.bodySmall)
                                                .foregroundColor(CapyColors.success)
                                        } else if hour.isClosed {
                                            Text("Closed")
                                                .font(CapyTypography.bodySmall)
                                                .foregroundColor(CapyColors.textTertiary)
                                        } else {
                                            Text("\(hour.openTime) - \(hour.closeTime)")
                                                .font(CapyTypography.bodySmall)
                                                .foregroundColor(CapyColors.textPrimary)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                    // Action Buttons
                    HStack(spacing: CapySpacing.medium) {
                        CapyButton(
                            title: "Get Directions",
                            icon: "arrow.turn.up.right",
                            style: .primary,
                            isFullWidth: true
                        ) {
                            // Open Maps
                        }
                        
                        CapyButton(
                            title: "Call",
                            icon: "phone",
                            style: .secondary,
                            isFullWidth: false
                        ) {
                            if let phone = gym.phoneNumber,
                               let url = URL(string: "tel:\(phone)") {
                                UIApplication.shared.open(url)
                            }
                        }
                        .frame(width: 100)
                    }
                }
                .padding(CapySpacing.large)
            }
        }
        .background(CapyColors.cardElevated)
        .cornerRadius(CapyRadius.xLarge, corners: [.topLeft, .topRight])
        .shadow(color: CapyColors.shadow, radius: 10, x: 0, y: -5)
    }
    
    private func weekdayName(_ day: Int) -> String {
        let weekdays = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
        return weekdays[day - 1]
    }
}

// MARK: - Amenity Tag
struct AmenityTag: View {
    let text: String
    
    var body: some View {
        Text(text)
            .font(CapyTypography.caption)
            .foregroundColor(CapyColors.primary)
            .padding(.horizontal, CapySpacing.small)
            .padding(.vertical, CapySpacing.xxSmall)
            .background(CapyColors.primary.opacity(0.1))
            .cornerRadius(CapyRadius.small)
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
            var lineHeight: CGFloat = 0
            
            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                
                if x + size.width > maxWidth && x > 0 {
                    x = 0
                    y += lineHeight + spacing
                    lineHeight = 0
                }
                
                positions.append(CGPoint(x: x, y: y))
                lineHeight = max(lineHeight, size.height)
                x += size.width + spacing
            }
            
            self.size = CGSize(width: maxWidth, height: y + lineHeight)
        }
    }
}

// MARK: - Gym Detail View (Full Screen)
struct GymDetailView: View {
    let gym: GymLocation
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: CapySpacing.large) {
                    // Hero Image
                    ZStack {
                        Rectangle()
                            .fill(CapyColors.cardBackground)
                            .frame(height: 200)
                        
                        Image(systemName: "dumbbell.fill")
                            .font(.system(size: 80))
                            .foregroundColor(CapyColors.primary.opacity(0.3))
                    }
                    
                    // Content
                    VStack(alignment: .leading, spacing: CapySpacing.large) {
                        // Header
                        VStack(alignment: .leading, spacing: CapySpacing.small) {
                            Text(gym.name)
                                .font(CapyTypography.heading1)
                                .foregroundColor(CapyColors.textPrimary)
                            
                            HStack(spacing: CapySpacing.small) {
                                Label("4.5", systemImage: "star.fill")
                                    .font(CapyTypography.bodyMedium)
                                    .foregroundColor(CapyColors.warning)
                                
                                Text("(234 reviews)")
                                    .font(CapyTypography.bodySmall)
                                    .foregroundColor(CapyColors.textSecondary)
                            }
                        }
                        
                        // Info Section
                        VStack(alignment: .leading, spacing: CapySpacing.medium) {
                            InfoRow(icon: "mappin.circle.fill", title: "Address", value: gym.address)
                            
                            if let phone = gym.phoneNumber {
                                InfoRow(icon: "phone.fill", title: "Phone", value: phone)
                            }
                            
                            InfoRow(icon: "clock.fill", title: "Hours", value: "Open 24 hours")
                        }
                        
                        // Action Buttons
                        VStack(spacing: CapySpacing.medium) {
                            CapyButton(
                                title: "Check In",
                                icon: "qrcode",
                                style: .primary
                            ) {
                                // Show QR scanner
                            }
                            
                            CapyButton(
                                title: "Buy Pass",
                                icon: "ticket",
                                style: .secondary
                            ) {
                                // Navigate to shop
                            }
                        }
                    }
                    .padding(.horizontal, CapySpacing.large)
                }
            }
            .background(CapyColors.background)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Info Row
struct InfoRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack(spacing: CapySpacing.medium) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(CapyColors.primary)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: CapySpacing.xxSmall) {
                Text(title)
                    .font(CapyTypography.caption)
                    .foregroundColor(CapyColors.textSecondary)
                
                Text(value)
                    .font(CapyTypography.bodyMedium)
                    .foregroundColor(CapyColors.textPrimary)
            }
        }
    }
}

// MARK: - Preview
struct GymMapView_Previews: PreviewProvider {
    static var previews: some View {
        GymMapView()
    }
}
