//
//  LocationService.swift
//  CapybaraGym
//
//  Location tracking and gym discovery service
//

import Foundation
import CoreLocation
import MapKit

// MARK: - Location Errors
public enum LocationError: LocalizedError {
    case denied
    case restricted
    case notDetermined
    case unavailable
    case unknown(Error)
    
    public var errorDescription: String? {
        switch self {
        case .denied:
            return "Location access denied. Please enable in Settings."
        case .restricted:
            return "Location access restricted."
        case .notDetermined:
            return "Location permission not determined."
        case .unavailable:
            return "Location services unavailable."
        case .unknown(let error):
            return error.localizedDescription
        }
    }
}

// MARK: - Gym Location Model
public struct GymLocation: Identifiable, Codable, Equatable {
    public let id: String
    public let name: String
    public let address: String
    public let latitude: Double
    public let longitude: Double
    public let phoneNumber: String?
    public let openingHours: [OpeningHours]?
    public let amenities: [String]?
    public let rating: Double?
    public let reviewCount: Int?
    public let imageURLs: [String]?
    public let isOpen: Bool?
    
    public var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    public var mapItem: MKMapItem {
        let placemark = MKPlacemark(coordinate: coordinate)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = name
        mapItem.phoneNumber = phoneNumber
        return mapItem
    }
    
    public static func == (lhs: GymLocation, rhs: GymLocation) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Opening Hours
public struct OpeningHours: Codable {
    public let dayOfWeek: Int // 1 = Sunday, 7 = Saturday
    public let openTime: String // "06:00"
    public let closeTime: String // "22:00"
    public let isOpen24Hours: Bool
    public let isClosed: Bool
}

// MARK: - Location Service Protocol
public protocol LocationServiceProtocol {
    var currentLocation: CLLocation? { get }
    var authorizationStatus: CLAuthorizationStatus { get }
    var isTracking: Bool { get }
    
    func requestAuthorization() async throws
    func startTracking() async throws
    func stopTracking()
    func getNearbyGyms(radius: Double) async throws -> [GymLocation]
    func getDirections(to gym: GymLocation) async throws -> MKRoute
    func calculateDistance(to coordinate: CLLocationCoordinate2D) -> CLLocationDistance?
    func searchGyms(query: String) async throws -> [GymLocation]
}

// MARK: - Location Service Implementation
public final class LocationService: NSObject, ObservableObject {
    
    // MARK: - Singleton
    public static let shared = LocationService()
    
    // MARK: - Published Properties
    @Published public private(set) var currentLocation: CLLocation?
    @Published public private(set) var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published public private(set) var isTracking = false
    @Published public private(set) var nearbyGyms: [GymLocation] = []
    
    // MARK: - Private Properties
    private let locationManager = CLLocationManager()
    private var locationContinuation: CheckedContinuation<CLLocation, Error>?
    private var authorizationContinuation: CheckedContinuation<Void, Error>?
    
    // MARK: - Initialization
    private override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 100 // Update every 100 meters
        authorizationStatus = locationManager.authorizationStatus
    }
    
    // MARK: - Public Methods
    
    public func requestAuthorization() async throws {
        guard authorizationStatus == .notDetermined else {
            if authorizationStatus == .denied || authorizationStatus == .restricted {
                throw LocationError.denied
            }
            return
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            authorizationContinuation = continuation
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    public func startTracking() async throws {
        guard CLLocationManager.locationServicesEnabled() else {
            throw LocationError.unavailable
        }
        
        try await requestAuthorization()
        
        locationManager.startUpdatingLocation()
        isTracking = true
        
        Logger.info("Location tracking started")
    }
    
    public func stopTracking() {
        locationManager.stopUpdatingLocation()
        isTracking = false
        
        Logger.info("Location tracking stopped")
    }
    
    public func getCurrentLocation() async throws -> CLLocation {
        if let location = currentLocation {
            return location
        }
        
        try await requestAuthorization()
        
        return try await withCheckedThrowingContinuation { continuation in
            locationContinuation = continuation
            locationManager.requestLocation()
        }
    }
    
    public func getNearbyGyms(radius: Double = 10000) async throws -> [GymLocation] {
        let location = try await getCurrentLocation()
        
        // Create a search request
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = "gym fitness center"
        request.region = MKCoordinateRegion(
            center: location.coordinate,
            latitudinalMeters: radius,
            longitudinalMeters: radius
        )
        request.resultTypes = .pointOfInterest
        
        let search = MKLocalSearch(request: request)
        let response = try await search.start()
        
        let gyms = response.mapItems.map { mapItem -> GymLocation in
            GymLocation(
                id: mapItem.placemark.identifier ?? UUID().uuidString,
                name: mapItem.name ?? "Unknown Gym",
                address: mapItem.placemark.title ?? "",
                latitude: mapItem.placemark.coordinate.latitude,
                longitude: mapItem.placemark.coordinate.longitude,
                phoneNumber: mapItem.phoneNumber,
                openingHours: nil,
                amenities: nil,
                rating: mapItem.pointOfInterestCategory != nil ? 4.0 : nil,
                reviewCount: nil,
                imageURLs: nil,
                isOpen: nil
            )
        }
        
        await MainActor.run {
            self.nearbyGyms = gyms
        }
        
        return gyms
    }
    
    public func getDirections(to gym: GymLocation) async throws -> MKRoute {
        let location = try await getCurrentLocation()
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: location.coordinate))
        request.destination = gym.mapItem
        request.transportType = .automobile
        request.requestsAlternateRoutes = false
        
        let directions = MKDirections(request: request)
        let response = try await directions.calculate()
        
        guard let route = response.routes.first else {
            throw LocationError.unknown(NSError(domain: "Location", code: -1, userInfo: [NSLocalizedDescriptionKey: "No route found"]))
        }
        
        return route
    }
    
    public func calculateDistance(to coordinate: CLLocationCoordinate2D) -> CLLocationDistance? {
        guard let currentLocation = currentLocation else { return nil }
        let targetLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        return currentLocation.distance(from: targetLocation)
    }
    
    public func searchGyms(query: String) async throws -> [GymLocation] {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query + " gym fitness"
        request.resultTypes = .pointOfInterest
        
        let search = MKLocalSearch(request: request)
        let response = try await search.start()
        
        return response.mapItems.map { mapItem in
            GymLocation(
                id: mapItem.placemark.identifier ?? UUID().uuidString,
                name: mapItem.name ?? "Unknown Gym",
                address: mapItem.placemark.title ?? "",
                latitude: mapItem.placemark.coordinate.latitude,
                longitude: mapItem.placemark.coordinate.longitude,
                phoneNumber: mapItem.phoneNumber,
                openingHours: nil,
                amenities: nil,
                rating: nil,
                reviewCount: nil,
                imageURLs: nil,
                isOpen: nil
            )
        }
    }
    
    public func formatDistance(_ distance: CLLocationDistance) -> String {
        let formatter = LengthFormatter()
        formatter.unitStyle = .short
        
        if distance < 1000 {
            return formatter.string(fromMeters: distance)
        } else {
            return formatter.string(fromValue: distance / 1000, unit: .kilometer)
        }
    }
}

// MARK: - CLLocationManagerDelegate
extension LocationService: CLLocationManagerDelegate {
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        currentLocation = location
        
        // Resume continuation if waiting
        locationContinuation?.resume(returning: location)
        locationContinuation = nil
        
        // Post notification
        NotificationCenter.default.post(
            name: NotificationNames.locationDidUpdate,
            object: location
        )
        
        Logger.debug("Location updated: \(location.coordinate.latitude), \(location.coordinate.longitude)")
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationContinuation?.resume(throwing: LocationError.unknown(error))
        locationContinuation = nil
        
        Logger.error("Location error: \(error.localizedDescription)")
    }
    
    public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            authorizationContinuation?.resume()
            authorizationContinuation = nil
            
        case .denied:
            authorizationContinuation?.resume(throwing: LocationError.denied)
            authorizationContinuation = nil
            
            NotificationCenter.default.post(name: NotificationNames.locationAccessDenied, object: nil)
            
        case .restricted:
            authorizationContinuation?.resume(throwing: LocationError.restricted)
            authorizationContinuation = nil
            
        case .notDetermined:
            break
            
        @unknown default:
            break
        }
        
        Logger.debug("Location authorization status changed: \(manager.authorizationStatus)")
    }
}

// MARK: - CLLocationCoordinate2D Extensions
public extension CLLocationCoordinate2D {
    static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}
