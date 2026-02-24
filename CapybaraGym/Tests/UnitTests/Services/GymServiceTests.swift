// MARK: - Gym Service Tests
// Comprehensive unit tests for GymService following TDD principles

import XCTest
import Combine
import CoreLocation
@testable import CapybaraGym

// MARK: - GymService
/// Production implementation of gym service
@MainActor
final class GymService: GymServiceProtocol {
    
    // MARK: - Properties
    @Published private var gyms: [Gym] = []
    var gymsPublisher: AnyPublisher<[Gym], Never> {
        $gyms.eraseToAnyPublisher()
    }
    
    @Published private var nearbyGyms: [Gym] = []
    var nearbyGymsPublisher: AnyPublisher<[Gym], Never> {
        $nearbyGyms.eraseToAnyPublisher()
    }
    
    // MARK: - Dependencies
    private let networkClient: NetworkClientProtocol
    private let cacheManager: CacheManagerProtocol
    
    // MARK: - Initialization
    init(networkClient: NetworkClientProtocol, cacheManager: CacheManagerProtocol) {
        self.networkClient = networkClient
        self.cacheManager = cacheManager
    }
    
    // MARK: - GymServiceProtocol Implementation
    
    func fetchAllGyms() async throws -> [Gym] {
        // Try cache first
        if let cachedGyms: [Gym] = try? cacheManager.get(key: "allGyms"),
           !cachedGyms.isEmpty {
            gyms = cachedGyms
            return cachedGyms
        }
        
        do {
            let fetchedGyms: [Gym] = try await networkClient.get(
                endpoint: "/gyms",
                headers: nil
            )
            
            // Cache the results
            try? cacheManager.set(fetchedGyms, key: "allGyms", expiration: 300)
            
            gyms = fetchedGyms
            return fetchedGyms
        } catch let error as NetworkError {
            throw mapNetworkError(error)
        }
    }
    
    func fetchNearbyGyms(latitude: Double, longitude: Double, radius: Double) async throws -> [Gym] {
        // Validate coordinates
        guard latitude >= -90 && latitude <= 90 else {
            throw GymError.invalidLocation
        }
        guard longitude >= -180 && longitude <= 180 else {
            throw GymError.invalidLocation
        }
        guard radius > 0 && radius <= 100 else {
            throw GymError.invalidLocation
        }
        
        let request = NearbyGymsRequest(
            latitude: latitude,
            longitude: longitude,
            radius: radius
        )
        
        do {
            let fetchedGyms: [Gym] = try await networkClient.post(
                endpoint: "/gyms/nearby",
                body: request
            )
            
            nearbyGyms = fetchedGyms
            return fetchedGyms
        } catch let error as NetworkError {
            throw mapNetworkError(error)
        }
    }
    
    func fetchGym(byId id: String) async throws -> Gym {
        guard !id.isEmpty else {
            throw GymError.gymNotFound
        }
        
        // Try cache first
        if let cachedGym: Gym = try? cacheManager.get(key: "gym_\(id)") {
            return cachedGym
        }
        
        do {
            let gym: Gym = try await networkClient.get(
                endpoint: "/gyms/\(id)",
                headers: nil
            )
            
            // Cache the result
            try? cacheManager.set(gym, key: "gym_\(id)", expiration: 600)
            
            return gym
        } catch let error as NetworkError {
            throw mapNetworkError(error)
        }
    }
    
    func searchGyms(query: String) async throws -> [Gym] {
        guard !query.isEmpty else {
            return try await fetchAllGyms()
        }
        
        let request = SearchGymsRequest(query: query)
        
        do {
            let results: [Gym] = try await networkClient.post(
                endpoint: "/gyms/search",
                body: request
            )
            
            return results
        } catch let error as NetworkError {
            throw mapNetworkError(error)
        }
    }
    
    func fetchGymAmenities(gymId: String) async throws -> [Amenity] {
        guard !gymId.isEmpty else {
            throw GymError.gymNotFound
        }
        
        // Try cache first
        if let cachedAmenities: [Amenity] = try? cacheManager.get(key: "amenities_\(gymId)") {
            return cachedAmenities
        }
        
        do {
            let amenities: [Amenity] = try await networkClient.get(
                endpoint: "/gyms/\(gymId)/amenities",
                headers: nil
            )
            
            // Cache the results
            try? cacheManager.set(amenities, key: "amenities_\(gymId)", expiration: 3600)
            
            return amenities
        } catch let error as NetworkError {
            throw mapNetworkError(error)
        }
    }
    
    func fetchGymHours(gymId: String) async throws -> GymHours {
        guard !gymId.isEmpty else {
            throw GymError.gymNotFound
        }
        
        // Try cache first
        if let cachedHours: GymHours = try? cacheManager.get(key: "hours_\(gymId)") {
            return cachedHours
        }
        
        do {
            let hours: GymHours = try await networkClient.get(
                endpoint: "/gyms/\(gymId)/hours",
                headers: nil
            )
            
            // Cache the result
            try? cacheManager.set(hours, key: "hours_\(gymId)", expiration: 3600)
            
            return hours
        } catch let error as NetworkError {
            throw mapNetworkError(error)
        }
    }
    
    func fetchGymCapacity(gymId: String) async throws -> GymCapacity {
        guard !gymId.isEmpty else {
            throw GymError.gymNotFound
        }
        
        // Don't cache capacity - it changes frequently
        do {
            let capacity: GymCapacity = try await networkClient.get(
                endpoint: "/gyms/\(gymId)/capacity",
                headers: nil
            )
            
            return capacity
        } catch let error as NetworkError {
            throw mapNetworkError(error)
        }
    }
    
    // MARK: - Private Methods
    
    private func mapNetworkError(_ error: NetworkError) -> GymError {
        switch error {
        case .notFound:
            return .gymNotFound
        case .serverError:
            return .serverError
        case .networkError:
            return .networkError
        default:
            return .unknown(error.localizedDescription)
        }
    }
}

// MARK: - Supporting Types

struct NearbyGymsRequest: Codable {
    let latitude: Double
    let longitude: Double
    let radius: Double
}

struct SearchGymsRequest: Codable {
    let query: String
}

// MARK: - Protocols

protocol CacheManagerProtocol {
    func get<T: Decodable>(key: String) throws -> T?
    func set<T: Encodable>(_ value: T, key: String, expiration: TimeInterval) throws
    func delete(key: String) throws
    func clear() throws
}

// MARK: - GymServiceTests

@MainActor
final class GymServiceTests: XCTestCase {
    
    // MARK: - Properties
    private var sut: GymService!
    private var mockNetworkClient: MockNetworkClient!
    private var mockCacheManager: MockCacheManager!
    
    // MARK: - Setup & Teardown
    override func setUp() {
        super.setUp()
        mockNetworkClient = MockNetworkClient()
        mockCacheManager = MockCacheManager()
        sut = GymService(
            networkClient: mockNetworkClient,
            cacheManager: mockCacheManager
        )
    }
    
    override func tearDown() {
        sut = nil
        mockNetworkClient.reset()
        mockCacheManager.reset()
        mockNetworkClient = nil
        mockCacheManager = nil
        super.tearDown()
    }
    
    // MARK: - Fetch All Gyms Tests
    
    func test_fetchAllGyms_success_returnsGyms() async throws {
        // Given
        let expectedGyms = [
            Gym(
                id: "gym-1",
                name: "Downtown Fitness",
                address: "123 Main St",
                latitude: 37.7749,
                longitude: -122.4194,
                phone: "+1-555-0101",
                email: "downtown@example.com",
                imageUrls: [],
                amenities: [],
                rating: 4.5,
                reviewCount: 100,
                isOpen24Hours: false,
                openingTime: "06:00",
                closingTime: "22:00"
            )
        ]
        mockNetworkClient.mockGyms = expectedGyms
        
        // When
        let gyms = try await sut.fetchAllGyms()
        
        // Then
        XCTAssertEqual(gyms.count, 1)
        XCTAssertEqual(gyms.first?.id, "gym-1")
    }
    
    func test_fetchAllGyms_cachesResults() async throws {
        // Given
        let expectedGyms = [
            Gym(
                id: "gym-1",
                name: "Downtown Fitness",
                address: "123 Main St",
                latitude: 37.7749,
                longitude: -122.4194,
                phone: "+1-555-0101",
                email: "downtown@example.com",
                imageUrls: [],
                amenities: [],
                rating: 4.5,
                reviewCount: 100,
                isOpen24Hours: false,
                openingTime: "06:00",
                closingTime: "22:00"
            )
        ]
        mockNetworkClient.mockGyms = expectedGyms
        
        // When
        _ = try await sut.fetchAllGyms()
        
        // Then
        XCTAssertNotNil(mockCacheManager.cache["allGyms"])
    }
    
    func test_fetchAllGyms_withCachedData_returnsCachedGyms() async throws {
        // Given
        let cachedGyms = [
            Gym(
                id: "cached-gym",
                name: "Cached Fitness",
                address: "Cached St",
                latitude: 37.0,
                longitude: -122.0,
                phone: "+1-555-0000",
                email: "cached@example.com",
                imageUrls: [],
                amenities: [],
                rating: 4.0,
                reviewCount: 50,
                isOpen24Hours: false,
                openingTime: "07:00",
                closingTime: "21:00"
            )
        ]
        mockCacheManager.cache["allGyms"] = cachedGyms
        
        // When
        let gyms = try await sut.fetchAllGyms()
        
        // Then
        XCTAssertEqual(gyms.first?.id, "cached-gym")
        XCTAssertEqual(mockNetworkClient.getCallCount, 0) // Should not call network
    }
    
    func test_fetchAllGyms_withNetworkError_throwsError() async {
        // Given
        mockNetworkClient.shouldThrowError = true
        mockNetworkClient.errorToThrow = .networkError
        
        // When/Then
        do {
            _ = try await sut.fetchAllGyms()
            XCTFail("Expected error to be thrown")
        } catch let error as GymError {
            XCTAssertEqual(error, .networkError)
        }
    }
    
    // MARK: - Fetch Nearby Gyms Tests
    
    func test_fetchNearbyGyms_withValidCoordinates_returnsGyms() async throws {
        // Given
        let expectedGyms = [
            Gym(
                id: "gym-1",
                name: "Nearby Fitness",
                address: "Nearby St",
                latitude: 37.7749,
                longitude: -122.4194,
                phone: "+1-555-0101",
                email: "nearby@example.com",
                imageUrls: [],
                amenities: [],
                rating: 4.5,
                reviewCount: 100,
                isOpen24Hours: false,
                openingTime: "06:00",
                closingTime: "22:00"
            )
        ]
        mockNetworkClient.mockGyms = expectedGyms
        
        // When
        let gyms = try await sut.fetchNearbyGyms(
            latitude: 37.7749,
            longitude: -122.4194,
            radius: 10.0
        )
        
        // Then
        XCTAssertEqual(gyms.count, 1)
    }
    
    func test_fetchNearbyGyms_withInvalidLatitude_throwsInvalidLocation() async {
        // When/Then
        do {
            _ = try await sut.fetchNearbyGyms(latitude: 91, longitude: -122, radius: 10)
            XCTFail("Expected error to be thrown")
        } catch let error as GymError {
            XCTAssertEqual(error, .invalidLocation)
        }
    }
    
    func test_fetchNearbyGyms_withInvalidLongitude_throwsInvalidLocation() async {
        // When/Then
        do {
            _ = try await sut.fetchNearbyGyms(latitude: 37, longitude: -181, radius: 10)
            XCTFail("Expected error to be thrown")
        } catch let error as GymError {
            XCTAssertEqual(error, .invalidLocation)
        }
    }
    
    func test_fetchNearbyGyms_withZeroRadius_throwsInvalidLocation() async {
        // When/Then
        do {
            _ = try await sut.fetchNearbyGyms(latitude: 37, longitude: -122, radius: 0)
            XCTFail("Expected error to be thrown")
        } catch let error as GymError {
            XCTAssertEqual(error, .invalidLocation)
        }
    }
    
    func test_fetchNearbyGyms_withTooLargeRadius_throwsInvalidLocation() async {
        // When/Then
        do {
            _ = try await sut.fetchNearbyGyms(latitude: 37, longitude: -122, radius: 101)
            XCTFail("Expected error to be thrown")
        } catch let error as GymError {
            XCTAssertEqual(error, .invalidLocation)
        }
    }
    
    // MARK: - Fetch Gym By ID Tests
    
    func test_fetchGymById_withValidId_returnsGym() async throws {
        // Given
        let expectedGym = Gym(
            id: "gym-1",
            name: "Specific Fitness",
            address: "123 Main St",
            latitude: 37.7749,
            longitude: -122.4194,
            phone: "+1-555-0101",
            email: "specific@example.com",
            imageUrls: [],
            amenities: [],
            rating: 4.5,
            reviewCount: 100,
            isOpen24Hours: false,
            openingTime: "06:00",
            closingTime: "22:00"
        )
        mockNetworkClient.mockGym = expectedGym
        
        // When
        let gym = try await sut.fetchGym(byId: "gym-1")
        
        // Then
        XCTAssertEqual(gym.id, "gym-1")
        XCTAssertEqual(gym.name, "Specific Fitness")
    }
    
    func test_fetchGymById_withEmptyId_throwsGymNotFound() async {
        // When/Then
        do {
            _ = try await sut.fetchGym(byId: "")
            XCTFail("Expected error to be thrown")
        } catch let error as GymError {
            XCTAssertEqual(error, .gymNotFound)
        }
    }
    
    func test_fetchGymById_withCachedData_returnsCachedGym() async throws {
        // Given
        let cachedGym = Gym(
            id: "cached-gym",
            name: "Cached Fitness",
            address: "Cached St",
            latitude: 37.0,
            longitude: -122.0,
            phone: "+1-555-0000",
            email: "cached@example.com",
            imageUrls: [],
            amenities: [],
            rating: 4.0,
            reviewCount: 50,
            isOpen24Hours: false,
            openingTime: "07:00",
            closingTime: "21:00"
        )
        mockCacheManager.cache["gym_cached-gym"] = cachedGym
        
        // When
        let gym = try await sut.fetchGym(byId: "cached-gym")
        
        // Then
        XCTAssertEqual(gym.id, "cached-gym")
        XCTAssertEqual(mockNetworkClient.getCallCount, 0)
    }
    
    func test_fetchGymById_withNotFoundError_throwsGymNotFound() async {
        // Given
        mockNetworkClient.shouldThrowError = true
        mockNetworkClient.errorToThrow = .notFound
        
        // When/Then
        do {
            _ = try await sut.fetchGym(byId: "nonexistent")
            XCTFail("Expected error to be thrown")
        } catch let error as GymError {
            XCTAssertEqual(error, .gymNotFound)
        }
    }
    
    // MARK: - Search Gyms Tests
    
    func test_searchGyms_withQuery_returnsResults() async throws {
        // Given
        let expectedGyms = [
            Gym(
                id: "gym-1",
                name: "Search Result Fitness",
                address: "Search St",
                latitude: 37.7749,
                longitude: -122.4194,
                phone: "+1-555-0101",
                email: "search@example.com",
                imageUrls: [],
                amenities: [],
                rating: 4.5,
                reviewCount: 100,
                isOpen24Hours: false,
                openingTime: "06:00",
                closingTime: "22:00"
            )
        ]
        mockNetworkClient.mockGyms = expectedGyms
        
        // When
        let gyms = try await sut.searchGyms(query: "fitness")
        
        // Then
        XCTAssertEqual(gyms.count, 1)
    }
    
    func test_searchGyms_withEmptyQuery_fetchesAllGyms() async throws {
        // Given
        let expectedGyms = [
            Gym(
                id: "gym-1",
                name: "All Fitness",
                address: "All St",
                latitude: 37.7749,
                longitude: -122.4194,
                phone: "+1-555-0101",
                email: "all@example.com",
                imageUrls: [],
                amenities: [],
                rating: 4.5,
                reviewCount: 100,
                isOpen24Hours: false,
                openingTime: "06:00",
                closingTime: "22:00"
            )
        ]
        mockNetworkClient.mockGyms = expectedGyms
        
        // When
        let gyms = try await sut.searchGyms(query: "")
        
        // Then
        XCTAssertEqual(gyms.count, 1)
    }
    
    // MARK: - Fetch Gym Amenities Tests
    
    func test_fetchGymAmenities_withValidId_returnsAmenities() async throws {
        // Given
        let expectedAmenities = [
            Amenity(id: "amenity-1", name: "Pool", icon: "waveform", category: .wellness),
            Amenity(id: "amenity-2", name: "Sauna", icon: "flame", category: .wellness)
        ]
        mockNetworkClient.mockAmenities = expectedAmenities
        
        // When
        let amenities = try await sut.fetchGymAmenities(gymId: "gym-1")
        
        // Then
        XCTAssertEqual(amenities.count, 2)
        XCTAssertEqual(amenities.first?.name, "Pool")
    }
    
    func test_fetchGymAmenities_withEmptyId_throwsGymNotFound() async {
        // When/Then
        do {
            _ = try await sut.fetchGymAmenities(gymId: "")
            XCTFail("Expected error to be thrown")
        } catch let error as GymError {
            XCTAssertEqual(error, .gymNotFound)
        }
    }
    
    func test_fetchGymAmenities_cachesResults() async throws {
        // Given
        let expectedAmenities = [
            Amenity(id: "amenity-1", name: "Pool", icon: "waveform", category: .wellness)
        ]
        mockNetworkClient.mockAmenities = expectedAmenities
        
        // When
        _ = try await sut.fetchGymAmenities(gymId: "gym-1")
        
        // Then
        XCTAssertNotNil(mockCacheManager.cache["amenities_gym-1"])
    }
    
    // MARK: - Fetch Gym Hours Tests
    
    func test_fetchGymHours_withValidId_returnsHours() async throws {
        // Given
        let expectedHours = GymHours(
            monday: DayHours(open: "06:00", close: "22:00", isClosed: false),
            tuesday: DayHours(open: "06:00", close: "22:00", isClosed: false),
            wednesday: DayHours(open: "06:00", close: "22:00", isClosed: false),
            thursday: DayHours(open: "06:00", close: "22:00", isClosed: false),
            friday: DayHours(open: "06:00", close: "22:00", isClosed: false),
            saturday: DayHours(open: "08:00", close: "20:00", isClosed: false),
            sunday: DayHours(open: "08:00", close: "20:00", isClosed: false)
        )
        mockNetworkClient.mockGymHours = expectedHours
        
        // When
        let hours = try await sut.fetchGymHours(gymId: "gym-1")
        
        // Then
        XCTAssertEqual(hours.monday.open, "06:00")
        XCTAssertEqual(hours.monday.close, "22:00")
    }
    
    func test_fetchGymHours_cachesResults() async throws {
        // Given
        let expectedHours = GymHours(
            monday: DayHours(open: "06:00", close: "22:00", isClosed: false),
            tuesday: DayHours(open: "06:00", close: "22:00", isClosed: false),
            wednesday: DayHours(open: "06:00", close: "22:00", isClosed: false),
            thursday: DayHours(open: "06:00", close: "22:00", isClosed: false),
            friday: DayHours(open: "06:00", close: "22:00", isClosed: false),
            saturday: DayHours(open: "08:00", close: "20:00", isClosed: false),
            sunday: DayHours(open: "08:00", close: "20:00", isClosed: false)
        )
        mockNetworkClient.mockGymHours = expectedHours
        
        // When
        _ = try await sut.fetchGymHours(gymId: "gym-1")
        
        // Then
        XCTAssertNotNil(mockCacheManager.cache["hours_gym-1"])
    }
    
    // MARK: - Fetch Gym Capacity Tests
    
    func test_fetchGymCapacity_withValidId_returnsCapacity() async throws {
        // Given
        let expectedCapacity = GymCapacity(
            gymId: "gym-1",
            currentCapacity: 45,
            maxCapacity: 100,
            percentage: 0.45,
            status: .moderate,
            lastUpdated: Date()
        )
        mockNetworkClient.mockGymCapacity = expectedCapacity
        
        // When
        let capacity = try await sut.fetchGymCapacity(gymId: "gym-1")
        
        // Then
        XCTAssertEqual(capacity.gymId, "gym-1")
        XCTAssertEqual(capacity.currentCapacity, 45)
        XCTAssertEqual(capacity.status, .moderate)
    }
    
    func test_fetchGymCapacity_doesNotCacheResults() async throws {
        // Given
        let expectedCapacity = GymCapacity(
            gymId: "gym-1",
            currentCapacity: 45,
            maxCapacity: 100,
            percentage: 0.45,
            status: .moderate,
            lastUpdated: Date()
        )
        mockNetworkClient.mockGymCapacity = expectedCapacity
        
        // When
        _ = try await sut.fetchGymCapacity(gymId: "gym-1")
        
        // Then
        // Capacity should not be cached
        let capacityKey = "capacity_gym-1"
        XCTAssertNil(mockCacheManager.cache[capacityKey])
    }
    
    // MARK: - Publisher Tests
    
    func test_gymsPublisher_publishesChanges() async {
        // Given
        let expectedGyms = [
            Gym(
                id: "gym-1",
                name: "Test Fitness",
                address: "Test St",
                latitude: 37.7749,
                longitude: -122.4194,
                phone: "+1-555-0101",
                email: "test@example.com",
                imageUrls: [],
                amenities: [],
                rating: 4.5,
                reviewCount: 100,
                isOpen24Hours: false,
                openingTime: "06:00",
                closingTime: "22:00"
            )
        ]
        mockNetworkClient.mockGyms = expectedGyms
        
        let expectation = XCTestExpectation(description: "Gyms publisher emits")
        
        var receivedGyms: [Gym] = []
        let cancellable = sut.gymsPublisher
            .dropFirst()
            .first()
            .sink { gyms in
                receivedGyms = gyms
                expectation.fulfill()
            }
        
        // When
        _ = try? await sut.fetchAllGyms()
        
        // Then
        await fulfillment(of: [expectation], timeout: 2.0)
        XCTAssertEqual(receivedGyms.count, 1)
        
        cancellable.cancel()
    }
}

// MARK: - Mock Cache Manager

class MockCacheManager: CacheManagerProtocol {
    var cache: [String: Any] = [:]
    var shouldThrowError = false
    
    func get<T: Decodable>(key: String) throws -> T? {
        if shouldThrowError {
            throw CacheError.notFound
        }
        return cache[key] as? T
    }
    
    func set<T: Encodable>(_ value: T, key: String, expiration: TimeInterval) throws {
        if shouldThrowError {
            throw CacheError.saveFailed
        }
        cache[key] = value
    }
    
    func delete(key: String) throws {
        if shouldThrowError {
            throw CacheError.deleteFailed
        }
        cache.removeValue(forKey: key)
    }
    
    func clear() throws {
        if shouldThrowError {
            throw CacheError.clearFailed
        }
        cache.removeAll()
    }
    
    func reset() {
        cache.removeAll()
        shouldThrowError = false
    }
}

enum CacheError: Error {
    case notFound
    case saveFailed
    case deleteFailed
    case clearFailed
}
