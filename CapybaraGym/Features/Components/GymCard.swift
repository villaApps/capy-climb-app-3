//
//  GymCard.swift
//  CapybaraGym
//
//  Gym display card component
//

import SwiftUI

struct GymCard: View {
    let gym: Gym
    let onTap: () -> Void
    let onFavoriteTap: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 0) {
                // Image Section
                ZStack(alignment: .topTrailing) {
                    // Gym Image
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .overlay(
                            Image(systemName: "photo")
                                .font(.system(size: 40))
                                .foregroundColor(.tertiaryText)
                        )
                    
                    // Favorite Button
                    Button(action: onFavoriteTap) {
                        Image(systemName: gym.isFavorite ? "heart.fill" : "heart")
                            .font(.system(size: 20))
                            .foregroundColor(gym.isFavorite ? .errorRed : .white)
                            .padding(8)
                            .background(Color.black.opacity(0.3))
                            .clipShape(Circle())
                    }
                    .padding(12)
                }
                .frame(height: 200)
                
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
                        Text(gym.location)
                            .font(.bodySmall)
                            .foregroundColor(.secondaryText)
                            .lineLimit(1)
                    }
                    
                    // Occupancy Indicator
                    OccupancyIndicator(occupancy: gym.occupancy, capacity: gym.capacity)
                    
                    // Amenities
                    HStack(spacing: 8) {
                        ForEach(gym.amenities.prefix(3), id: \.self) { amenity in
                            AmenityTag(name: amenity)
                        }
                    }
                    
                    // Distance and Price
                    HStack {
                        HStack(spacing: 4) {
                            Image(systemName: "location")
                                .font(.caption)
                                .foregroundColor(.primaryBrown)
                            Text("\(String(format: "%.1f", gym.distance)) km")
                                .font(.captionMedium)
                                .foregroundColor(.primaryBrown)
                        }
                        
                        Spacer()
                        
                        Text("From $")(gym.pricePerVisit)/visit")
                            .font(.bodySmall)
                            .foregroundColor(.secondaryText)
                    }
                }
                .padding(16)
            }
        }
        .frame(width: Layout.gymCardWidth)
        .background(Color.cardBackground)
        .cornerRadius(Layout.radiusLarge)
        .customShadow(ShadowStyle.card)
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: isPressed)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
}

// MARK: - Amenity Tag
struct AmenityTag: View {
    let name: String
    
    var body: some View {
        Text(name)
            .font(.caption)
            .foregroundColor(.primaryBrown)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(Color.primaryBrown.opacity(0.1))
            .cornerRadius(6)
    }
}

// MARK: - Gym Model
struct Gym: Identifiable {
    let id: String
    let name: String
    let location: String
    let rating: Double
    let occupancy: Int
    let capacity: Int
    let amenities: [String]
    let distance: Double
    let pricePerVisit: Double
    let isFavorite: Bool
    let imageURL: String?
    
    static let sample = Gym(
        id: "1",
        name: "Capybara Fitness Center",
        location: "123 Gym Street, Downtown",
        rating: 4.8,
        occupancy: 45,
        capacity: 100,
        amenities: ["Pool", "Sauna", "Yoga"],
        distance: 2.5,
        pricePerVisit: 15.99,
        isFavorite: true,
        imageURL: nil
    )
    
    static let samples = [
        sample,
        Gym(
            id: "2",
            name: "Iron Pump Gym",
            location: "456 Muscle Ave, Uptown",
            rating: 4.5,
            occupancy: 78,
            capacity: 80,
            amenities: ["Weights", "Cardio", "CrossFit"],
            distance: 4.2,
            pricePerVisit: 12.99,
            isFavorite: false,
            imageURL: nil
        ),
        Gym(
            id: "3",
            name: "Zen Wellness Studio",
            location: "789 Peace Blvd, Midtown",
            rating: 4.9,
            occupancy: 12,
            capacity: 30,
            amenities: ["Yoga", "Pilates", "Meditation"],
            distance: 1.8,
            pricePerVisit: 20.00,
            isFavorite: true,
            imageURL: nil
        )
    ]
}

// MARK: - Preview
#Preview("Gym Card") {
    ScrollView {
        VStack(spacing: 20) {
            GymCard(
                gym: .sample,
                onTap: {},
                onFavoriteTap: {}
            )
            
            GymCard(
                gym: Gym.samples[1],
                onTap: {},
                onFavoriteTap: {}
            )
        }
        .padding()
    }
    .background(Color.gray.opacity(0.1))
}
