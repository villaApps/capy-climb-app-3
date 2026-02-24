//
//  GymMapViewModel.swift
//  CapybaraGym
//
//  Gym map ViewModel
//

import SwiftUI
import MapKit

@MainActor
public final class GymMapViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published public var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    @Published public var gyms: [GymLocation] = []
    @Published public var isLoading = false
    @Published public var showLocationAlert = false
    @Published public var searchQuery = ""
    
    // MARK: - Private Properties
    private let locationService = LocationService.shared
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    public init() {
        setupBindings()
        loadMockGyms()
    }
    
    // MARK: - Public Methods
    
    public func requestLocationPermission() {
        Task {
            do {
                try await locationService.requestAuthorization()
                try await locationService.startTracking()
                await loadNearbyGyms()
            } catch LocationError.denied, LocationError.restricted {
                showLocationAlert = true
            } catch {
                Logger.error("Location error: \(error)")
            }
        }
    }
    
    public func loadNearbyGyms() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let nearbyGyms = try await locationService.getNearbyGyms(radius: 10000)
            self.gyms = nearbyGyms
            
            // Center map on first gym if available
            if let firstGym = nearbyGyms.first {
                centerOnGym(firstGym)
            }
        } catch {
            Logger.error("Failed to load gyms: \(error)")
        }
    }
    
    public func centerOnGym(_ gym: GymLocation) {
        withAnimation(.spring()) {
            region.center = gym.coordinate
            region.span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        }
    }
    
    public func centerOnUser() {
        guard let location = locationService.currentLocation else { return }
        
        withAnimation(.spring()) {
            region.center = location.coordinate
            region.span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        }
    }
    
    public func searchGyms() async {
        guard !searchQuery.isEmpty else { return }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            let results = try await locationService.searchGyms(query: searchQuery)
            self.gyms = results
        } catch {
            Logger.error("Search failed: \(error)")
        }
    }
    
    // MARK: - Private Methods
    
    private func setupBindings() {
        locationService.$currentLocation
            .receive(on: DispatchQueue.main)
            .sink { [weak self] location in
                if let location = location {
                    self?.region.center = location.coordinate
                }
            }
            .store(in: &cancellables)
    }
    
    private func loadMockGyms() {
        gyms = [
            GymLocation(
                id: "1",
                name: "Capybara Fitness Center",
                address: "123 Main St, San Francisco, CA",
                latitude: 37.7749,
                longitude: -122.4194,
                phoneNumber: "+1 (555) 123-4567",
                openingHours: [
                    OpeningHours(dayOfWeek: 1, openTime: "06:00", closeTime: "22:00", isOpen24Hours: false, isClosed: false),
                    OpeningHours(dayOfWeek: 2, openTime: "06:00", closeTime: "22:00", isOpen24Hours: false, isClosed: false),
                    OpeningHours(dayOfWeek: 3, openTime: "06:00", closeTime: "22:00", isOpen24Hours: false, isClosed: false),
                    OpeningHours(dayOfWeek: 4, openTime: "06:00", closeTime: "22:00", isOpen24Hours: false, isClosed: false),
                    OpeningHours(dayOfWeek: 5, openTime: "06:00", closeTime: "22:00", isOpen24Hours: false, isClosed: false),
                    OpeningHours(dayOfWeek: 6, openTime: "08:00", closeTime: "20:00", isOpen24Hours: false, isClosed: false),
                    OpeningHours(dayOfWeek: 7, openTime: "08:00", closeTime: "20:00", isOpen24Hours: false, isClosed: false)
                ],
                amenities: ["Cardio", "Weights", "Pool", "Sauna", "Classes"],
                rating: 4.5,
                reviewCount: 234,
                imageURLs: nil,
                isOpen: true
            ),
            GymLocation(
                id: "2",
                name: "Downtown Gym",
                address: "456 Market St, San Francisco, CA",
                latitude: 37.7858,
                longitude: -122.4064,
                phoneNumber: "+1 (555) 234-5678",
                openingHours: nil,
                amenities: ["Cardio", "Weights", "Yoga"],
                rating: 4.2,
                reviewCount: 156,
                imageURLs: nil,
                isOpen: true
            ),
            GymLocation(
                id: "3",
                name: "Sunset Fitness",
                address: "789 Sunset Blvd, San Francisco, CA",
                latitude: 37.7500,
                longitude: -122.4900,
                phoneNumber: "+1 (555) 345-6789",
                openingHours: nil,
                amenities: ["24/7", "Cardio", "Weights"],
                rating: 4.7,
                reviewCount: 312,
                imageURLs: nil,
                isOpen: true
            )
        ]
    }
}
