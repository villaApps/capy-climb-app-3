// MARK: - Mock Gym Service
// Comprehensive mock for GymService to enable isolated unit testing

import Foundation
import Combine
@testable import CapybaraGym

// MARK: - Gym Service Protocol
public protocol GymServiceProtocol {
    var gymsPublisher: AnyPublisher<[Gym], Never> { get }
    var nearbyGymsPublisher: AnyPublisher<[Gym], Never> { get }
    
    func fetchAllGyms() async throws -> [Gym]
    func fetchNearbyGyms(latitude: Double, longitude: Double, radius: Double) async throws -> [Gym]
    func fetchGym(byId id: String) async throws -> Gym
    func searchGyms(query: String) async throws -> [Gym]
    func fetchGymAmenities(gymId: String) async throws -> [Amenity]
    func fetchGymHours(gymId: String) async throws -> GymHours
    func fetchGymCapacity(gymId: String) async throws -> GymCapacity
}

// MARK: - Gym Error
public enum GymError: Error, Equatable {
    case gymNotFound
    case invalidLocation
    case networkError
    case serverError
    case unknown(String)
    
    public static func == (lhs: GymError, rhs: GymError) -> Bool {
        switch (lhs, rhs) {
        case (.gymNotFound, .gymNotFound),
             (.invalidLocation, .invalidLocation),
             (.networkError, .networkError),
             (.serverError, .serverError):
            return true
        case (.unknown(let lhsMsg), .unknown(let rhsMsg)):
            return lhsMsg == rhsMsg
        default:
            return false
        }
    }
}

// MARK: - Mock Gym Service
public final class MockGymService: GymServiceProtocol {
    
    // MARK: - Properties
    @Published private var gyms: [Gym] = []
    public var gymsPublisher: AnyPublisher<[Gym], Never> {
        $gyms.eraseToAnyPublisher()
    }
    
    @Published private var nearbyGyms: [Gym] = []
    public var nearbyGymsPublisher: AnyPublisher<[Gym], Never> {
        $nearbyGyms.eraseToAnyPublisher()
    }
    
    // MARK: - Configuration
    public var shouldSucceed = true
    public var shouldReturnGymNotFound = false
    public var shouldReturnInvalidLocation = false
    public var shouldReturnNetworkError = false
    public var shouldReturnServerError = false
    public var delay: TimeInterval = 0.1
    
    // MARK: - Call Tracking
    public var fetchAllGymsCallCount = 0
    public var fetchNearbyGymsCallCount = 0
    public var fetchGymByIdCallCount = 0
    public var searchGymsCallCount = 0
    public var fetchGymAmenitiesCallCount = 0
    public var fetchGymHoursCallCount = 0
    public var fetchGymCapacityCallCount = 0
    
    // MARK: - Captured Parameters
    public var capturedLatitude: Double?
    public var capturedLongitude: Double?
    public var capturedRadius: Double?
    public var capturedGymId: String?
    public var capturedSearchQuery: String?
    
    // MARK: - Test Data
    public var mockGyms: [Gym] = [
        Gym(
            id: "gym-1",
            name: "Downtown Capybara Fitness",
            address: "123 Main St, Downtown",
            latitude: 37.7749,
            longitude: -122.4194,
            phone: "+1-555-0101",
            email: "downtown@capybaragym.com",
            imageUrls: ["https://example.com/gym1.jpg"],
            amenities: ["pool", "sauna", "weights"],
            rating: 4.8,
            reviewCount: 128,
            isOpen24Hours: true,
            openingTime: "00:00",
            closingTime: "23:59"
        ),
        Gym(
            id: "gym-2",
            name: "Uptown Capybara Center",
            address: "456 Oak Ave, Uptown",
            latitude: 37.7849,
            longitude: -122.4094,
            phone: "+1-555-0102",
            email: "uptown@capybaragym.com",
            imageUrls: ["https://example.com/gym2.jpg"],
            amenities: ["yoga", "pilates", "cardio"],
            rating: 4.6,
            reviewCount: 95,
            isOpen24Hours: false,
            openingTime: "06:00",
            closingTime: "22:00"
        ),
        Gym(
            id: "gym-3",
            name: "Westside Capybara Studio",
            address: "789 Beach Blvd, Westside",
            latitude: 37.7649,
            longitude: -122.4294,
            phone: "+1-555-0103",
            email: "westside@capybaragym.com",
            imageUrls: ["https://example.com/gym3.jpg"],
            amenities: ["crossfit", "boxing", "mma"],
            rating: 4.9,
            reviewCount: 210,
            isOpen24Hours: false,
            openingTime: "05:00",
            closingTime: "23:00"
        )
    ]
    
    public var mockAmenities: [Amenity] = [
        Amenity(id: "amenity-1", name: "Swimming Pool", icon: "waveform", category: .wellness),
        Amenity(id: "amenity-2", name: "Sauna", icon: "flame", category: .wellness),
        Amenity(id: "amenity-3", name: "Free Weights", icon: "dumbbell", category: .strength),
        Amenity(id: "amenity-4", name: "Cardio Machines", icon: "heart", category: .cardio),
        Amenity(id: "amenity-5", name: "Yoga Studio", icon: "leaf", category: .classes)
    ]
    
    public var mockGymHours = GymHours(
        monday: DayHours(open: "05:00", close: "23:00", isClosed: false),
        tuesday: DayHours(open: "05:00", close: "23:00", isClosed: false),
        wednesday: DayHours(open: "05:00", close: "23:00", isClosed: false),
        thursday: DayHours(open: "05:00", close: "23:00", isClosed: false),
        friday: DayHours(open: "05:00", close: "23:00", isClosed: false),
        saturday: DayHours(open: "07:00", close: "21:00", isClosed: false),
        sunday: DayHours(open: "08:00", close: "20:00", isClosed: false)
    )
    
    public var mockGymCapacity = GymCapacity(
        gymId: "gym-1",
        currentCapacity: 45,
        maxCapacity: 100,
        percentage: 0.45,
        status: .moderate,
        lastUpdated: Date()
    )
    
    // MARK: - Initialization
    public init() {}
    
    // MARK: - GymServiceProtocol Implementation
    
    public func fetchAllGyms() async throws -> [Gym] {
        fetchAllGymsCallCount += 1
        
        try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
        
        if shouldReturnNetworkError {
            throw GymError.networkError
        }
        
        if shouldReturnServerError {
            throw GymError.serverError
        }
        
        if shouldSucceed {
            gyms = mockGyms
            return mockGyms
        }
        
        throw GymError.unknown("Failed to fetch gyms")
    }
    
    public func fetchNearbyGyms(latitude: Double, longitude: Double, radius: Double) async throws -> [Gym] {
        fetchNearbyGymsCallCount += 1
        capturedLatitude = latitude
        capturedLongitude = longitude
        capturedRadius = radius
        
        try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
        
        // Validate coordinates
        guard latitude >= -90 && latitude <= 90 else {
            throw GymError.invalidLocation
        }
        guard longitude >= -180 && longitude <= 180 else {
            throw GymError.invalidLocation
        }
        guard radius > 0 else {
            throw GymError.invalidLocation
        }
        
        if shouldReturnInvalidLocation {
            throw GymError.invalidLocation
        }
        
        if shouldReturnNetworkError {
            throw GymError.networkError
        }
        
        if shouldSucceed {
            // Simulate filtering by distance (simplified)
            nearbyGyms = mockGyms
            return mockGyms
        }
        
        throw GymError.unknown("Failed to fetch nearby gyms")
    }
    
    public func fetchGym(byId id: String) async throws -> Gym {
        fetchGymByIdCallCount += 1
        capturedGymId = id
        
        try await Task.sleep(nanoseconds: UInt64(delay * 500_000_000))
        
        guard !id.isEmpty else {
            throw GymError.gymNotFound
        }
        
        if shouldReturnGymNotFound {
            throw GymError.gymNotFound
        }
        
        if shouldReturnNetworkError {
            throw GymError.networkError
        }
        
        if shouldSucceed {
            if let gym = mockGyms.first(where: { $0.id == id }) {
                return gym
            }
            throw GymError.gymNotFound
        }
        
        throw GymError.unknown("Failed to fetch gym")
    }
    
    public func searchGyms(query: String) async throws -> [Gym] {
        searchGymsCallCount += 1
        capturedSearchQuery = query
        
        try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
        
        if shouldReturnNetworkError {
            throw GymError.networkError
        }
        
        if shouldSucceed {
            if query.isEmpty {
                return mockGyms
            }
            let filtered = mockGyms.filter { gym in
                gym.name.localizedCaseInsensitiveContains(query) ||
                gym.address.localizedCaseInsensitiveContains(query)
            }
            return filtered
        }
        
        throw GymError.unknown("Failed to search gyms")
    }
    
    public func fetchGymAmenities(gymId: String) async throws -> [Amenity] {
        fetchGymAmenitiesCallCount += 1
        capturedGymId = gymId
        
        try await Task.sleep(nanoseconds: UInt64(delay * 500_000_000))
        
        guard !gymId.isEmpty else {
            throw GymError.gymNotFound
        }
        
        if shouldReturnGymNotFound {
            throw GymError.gymNotFound
        }
        
        if shouldReturnNetworkError {
            throw GymError.networkError
        }
        
        if shouldSucceed {
            return mockAmenities
        }
        
        throw GymError.unknown("Failed to fetch amenities")
    }
    
    public func fetchGymHours(gymId: String) async throws -> GymHours {
        fetchGymHoursCallCount += 1
        capturedGymId = gymId
        
        try await Task.sleep(nanoseconds: UInt64(delay * 500_000_000))
        
        guard !gymId.isEmpty else {
            throw GymError.gymNotFound
        }
        
        if shouldReturnGymNotFound {
            throw GymError.gymNotFound
        }
        
        if shouldReturnNetworkError {
            throw GymError.networkError
        }
        
        if shouldSucceed {
            return mockGymHours
        }
        
        throw GymError.unknown("Failed to fetch gym hours")
    }
    
    public func fetchGymCapacity(gymId: String) async throws -> GymCapacity {
        fetchGymCapacityCallCount += 1
        capturedGymId = gymId
        
        try await Task.sleep(nanoseconds: UInt64(delay * 300_000_000))
        
        guard !gymId.isEmpty else {
            throw GymError.gymNotFound
        }
        
        if shouldReturnGymNotFound {
            throw GymError.gymNotFound
        }
        
        if shouldReturnNetworkError {
            throw GymError.networkError
        }
        
        if shouldSucceed {
            return mockGymCapacity
        }
        
        throw GymError.unknown("Failed to fetch gym capacity")
    }
    
    // MARK: - Helper Methods
    
    public func reset() {
        fetchAllGymsCallCount = 0
        fetchNearbyGymsCallCount = 0
        fetchGymByIdCallCount = 0
        searchGymsCallCount = 0
        fetchGymAmenitiesCallCount = 0
        fetchGymHoursCallCount = 0
        fetchGymCapacityCallCount = 0
        
        capturedLatitude = nil
        capturedLongitude = nil
        capturedRadius = nil
        capturedGymId = nil
        capturedSearchQuery = nil
        
        shouldSucceed = true
        shouldReturnGymNotFound = false
        shouldReturnInvalidLocation = false
        shouldReturnNetworkError = false
        shouldReturnServerError = false
        
        gyms = []
        nearbyGyms = []
    }
    
    public func addMockGym(_ gym: Gym) {
        mockGyms.append(gym)
    }
    
    public func removeMockGym(byId id: String) {
        mockGyms.removeAll { $0.id == id }
    }
}

// MARK: - Supporting Models

public struct Gym: Equatable, Identifiable {
    public let id: String
    public let name: String
    public let address: String
    public let latitude: Double
    public let longitude: Double
    public let phone: String
    public let email: String
    public let imageUrls: [String]
    public let amenities: [String]
    public let rating: Double
    public let reviewCount: Int
    public let isOpen24Hours: Bool
    public let openingTime: String
    public let closingTime: String
    
    public init(id: String, name: String, address: String, latitude: Double, longitude: Double,
                phone: String, email: String, imageUrls: [String], amenities: [String],
                rating: Double, reviewCount: Int, isOpen24Hours: Bool, openingTime: String, closingTime: String) {
        self.id = id
        self.name = name
        self.address = address
        self.latitude = latitude
        self.longitude = longitude
        self.phone = phone
        self.email = email
        self.imageUrls = imageUrls
        self.amenities = amenities
        self.rating = rating
        self.reviewCount = reviewCount
        self.isOpen24Hours = isOpen24Hours
        self.openingTime = openingTime
        self.closingTime = closingTime
    }
}

public struct Amenity: Equatable, Identifiable {
    public let id: String
    public let name: String
    public let icon: String
    public let category: AmenityCategory
    
    public init(id: String, name: String, icon: String, category: AmenityCategory) {
        self.id = id
        self.name = name
        self.icon = icon
        self.category = category
    }
}

public enum AmenityCategory: String, CaseIterable {
    case cardio = "cardio"
    case strength = "strength"
    case wellness = "wellness"
    case classes = "classes"
    case other = "other"
}

public struct GymHours: Equatable {
    public let monday: DayHours
    public let tuesday: DayHours
    public let wednesday: DayHours
    public let thursday: DayHours
    public let friday: DayHours
    public let saturday: DayHours
    public let sunday: DayHours
    
    public init(monday: DayHours, tuesday: DayHours, wednesday: DayHours, thursday: DayHours,
                friday: DayHours, saturday: DayHours, sunday: DayHours) {
        self.monday = monday
        self.tuesday = tuesday
        self.wednesday = wednesday
        self.thursday = thursday
        self.friday = friday
        self.saturday = saturday
        self.sunday = sunday
    }
}

public struct DayHours: Equatable {
    public let open: String
    public let close: String
    public let isClosed: Bool
    
    public init(open: String, close: String, isClosed: Bool) {
        self.open = open
        self.close = close
        self.isClosed = isClosed
    }
}

public struct GymCapacity: Equatable {
    public let gymId: String
    public let currentCapacity: Int
    public let maxCapacity: Int
    public let percentage: Double
    public let status: CapacityStatus
    public let lastUpdated: Date
    
    public init(gymId: String, currentCapacity: Int, maxCapacity: Int, percentage: Double,
                status: CapacityStatus, lastUpdated: Date) {
        self.gymId = gymId
        self.currentCapacity = currentCapacity
        self.maxCapacity = maxCapacity
        self.percentage = percentage
        self.status = status
        self.lastUpdated = lastUpdated
    }
}

public enum CapacityStatus: String, Equatable {
    case low = "low"
    case moderate = "moderate"
    case busy = "busy"
    case full = "full"
}
