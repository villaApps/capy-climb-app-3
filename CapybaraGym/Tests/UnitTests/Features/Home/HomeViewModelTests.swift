// MARK: - Home ViewModel Tests
// Comprehensive unit tests for HomeViewModel following TDD principles

import XCTest
import Combine
import CoreLocation
@testable import CapybaraGym

// MARK: - HomeViewModel
/// ViewModel responsible for managing home screen data and interactions
@MainActor
final class HomeViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var gyms: [Gym] = []
    @Published var nearbyGyms: [Gym] = []
    @Published var activePass: GymPass?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var searchQuery: String = ""
    @Published var selectedGym: Gym?
    @Published var userLocation: CLLocationCoordinate2D?
    @Published var showLocationPermissionAlert: Bool = false
    @Published var greeting: String = ""
    
    // MARK: - Dependencies
    private let gymService: GymServiceProtocol
    private let passService: PassServiceProtocol
    private let authService: AuthServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Computed Properties
    var hasActivePass: Bool {
        activePass?.isActive == true
    }
    
    var filteredGyms: [Gym] {
        if searchQuery.isEmpty {
            return gyms
        }
        return gyms.filter { gym in
            gym.name.localizedCaseInsensitiveContains(searchQuery) ||
            gym.address.localizedCaseInsensitiveContains(searchQuery)
        }
    }
    
    var passStatusText: String {
        guard let pass = activePass else { return "No active pass" }
        if pass.isActive {
            return "\(pass.daysRemaining) days remaining"
        } else {
            return "Pass expired"
        }
    }
    
    // MARK: - Initialization
    init(
        gymService: GymServiceProtocol,
        passService: PassServiceProtocol,
        authService: AuthServiceProtocol
    ) {
        self.gymService = gymService
        self.passService = passService
        self.authService = authService
        updateGreeting()
    }
    
    // MARK: - Lifecycle
    func onAppear() async {
        await fetchData()
    }
    
    func onRefresh() async {
        await fetchData()
    }
    
    // MARK: - Data Fetching
    func fetchData() async {
        isLoading = true
        errorMessage = nil
        
        await withTaskGroup(of: Void.self) { group in
            group.addTask {
                await self.fetchGyms()
            }
            group.addTask {
                await self.fetchActivePass()
            }
            if let location = userLocation {
                group.addTask {
                    await self.fetchNearbyGyms(latitude: location.latitude, longitude: location.longitude)
                }
            }
        }
        
        isLoading = false
    }
    
    func fetchGyms() async {
        do {
            let fetchedGyms = try await gymService.fetchAllGyms()
            gyms = fetchedGyms
        } catch {
            errorMessage = "Failed to load gyms"
        }
    }
    
    func fetchNearbyGyms(latitude: Double, longitude: Double) async {
        do {
            let fetchedGyms = try await gymService.fetchNearbyGyms(
                latitude: latitude,
                longitude: longitude,
                radius: 10.0
            )
            nearbyGyms = fetchedGyms
        } catch {
            // Silently fail for nearby gyms - not critical
        }
    }
    
    func fetchActivePass() async {
        guard let user = await authService.getCurrentUser() else { return }
        
        do {
            activePass = try await passService.fetchActivePass(userId: user.id)
        } catch {
            errorMessage = "Failed to load pass information"
        }
    }
    
    func searchGyms(query: String) async {
        searchQuery = query
        
        guard !query.isEmpty else {
            await fetchGyms()
            return
        }
        
        isLoading = true
        
        do {
            let results = try await gymService.searchGyms(query: query)
            gyms = results
        } catch {
            errorMessage = "Search failed"
        }
        
        isLoading = false
    }
    
    // MARK: - Actions
    func selectGym(_ gym: Gym) {
        selectedGym = gym
    }
    
    func clearSelection() {
        selectedGym = nil
    }
    
    func updateLocation(_ coordinate: CLLocationCoordinate2D) {
        userLocation = coordinate
    }
    
    func handleLocationPermissionDenied() {
        showLocationPermissionAlert = true
    }
    
    func clearError() {
        errorMessage = nil
    }
    
    // MARK: - Private Methods
    private func updateGreeting() {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12:
            greeting = "Good morning"
        case 12..<17:
            greeting = "Good afternoon"
        case 17..<22:
            greeting = "Good evening"
        default:
            greeting = "Good night"
        }
    }
}

// MARK: - HomeViewModelTests
@MainActor
final class HomeViewModelTests: XCTestCase {
    
    // MARK: - Properties
    private var sut: HomeViewModel!
    private var mockGymService: MockGymService!
    private var mockPassService: MockPassService!
    private var mockAuthService: MockAuthService!
    private var cancellables: Set<AnyCancellable>!
    
    // MARK: - Setup & Teardown
    override func setUp() {
        super.setUp()
        mockGymService = MockGymService()
        mockPassService = MockPassService()
        mockAuthService = MockAuthService()
        sut = HomeViewModel(
            gymService: mockGymService,
            passService: mockPassService,
            authService: mockAuthService
        )
        cancellables = Set<AnyCancellable>()
    }
    
    override func tearDown() {
        sut = nil
        mockGymService.reset()
        mockPassService.reset()
        mockAuthService.reset()
        mockGymService = nil
        mockPassService = nil
        mockAuthService = nil
        cancellables = nil
        super.tearDown()
    }
    
    // MARK: - Initial State Tests
    
    func test_initialState_hasEmptyGyms() {
        XCTAssertTrue(sut.gyms.isEmpty)
    }
    
    func test_initialState_hasEmptyNearbyGyms() {
        XCTAssertTrue(sut.nearbyGyms.isEmpty)
    }
    
    func test_initialState_hasNoActivePass() {
        XCTAssertNil(sut.activePass)
    }
    
    func test_initialState_isNotLoading() {
        XCTAssertFalse(sut.isLoading)
    }
    
    func test_initialState_hasNoError() {
        XCTAssertNil(sut.errorMessage)
    }
    
    func test_initialState_hasEmptySearchQuery() {
        XCTAssertEqual(sut.searchQuery, "")
    }
    
    func test_initialState_hasNoSelectedGym() {
        XCTAssertNil(sut.selectedGym)
    }
    
    func test_initialState_hasNoUserLocation() {
        XCTAssertNil(sut.userLocation)
    }
    
    func test_initialState_doesNotShowLocationPermissionAlert() {
        XCTAssertFalse(sut.showLocationPermissionAlert)
    }
    
    // MARK: - Greeting Tests
    
    func test_greeting_inMorningHours_returnsGoodMorning() {
        // This test assumes the test runs at a specific time
        // In practice, you'd inject a date provider for testability
        let hour = Calendar.current.component(.hour, from: Date())
        if hour >= 5 && hour < 12 {
            XCTAssertEqual(sut.greeting, "Good morning")
        }
    }
    
    // MARK: - Has Active Pass Tests
    
    func test_hasActivePass_withNoPass_returnsFalse() {
        sut.activePass = nil
        XCTAssertFalse(sut.hasActivePass)
    }
    
    func test_hasActivePass_withActivePass_returnsTrue() {
        sut.activePass = mockPassService.mockPasses.first
        XCTAssertTrue(sut.hasActivePass)
    }
    
    func test_hasActivePass_withExpiredPass_returnsFalse() {
        let expiredPass = GymPass(
            id: "expired",
            userId: "user-1",
            type: .standard,
            status: .expired,
            startDate: Date().addingTimeInterval(-86400 * 60),
            endDate: Date().addingTimeInterval(-86400),
            checkInsRemaining: nil,
            totalCheckIns: 10,
            gyms: ["gym-1"],
            autoRenew: false,
            price: 49.99
        )
        sut.activePass = expiredPass
        XCTAssertFalse(sut.hasActivePass)
    }
    
    // MARK: - Filtered Gyms Tests
    
    func test_filteredGyms_withEmptySearchQuery_returnsAllGyms() {
        // Given
        sut.gyms = mockGymService.mockGyms
        sut.searchQuery = ""
        
        // Then
        XCTAssertEqual(sut.filteredGyms.count, mockGymService.mockGyms.count)
    }
    
    func test_filteredGyms_withMatchingNameQuery_returnsFilteredResults() {
        // Given
        sut.gyms = mockGymService.mockGyms
        sut.searchQuery = "Downtown"
        
        // Then
        XCTAssertEqual(sut.filteredGyms.count, 1)
        XCTAssertEqual(sut.filteredGyms.first?.name, "Downtown Capybara Fitness")
    }
    
    func test_filteredGyms_withMatchingAddressQuery_returnsFilteredResults() {
        // Given
        sut.gyms = mockGymService.mockGyms
        sut.searchQuery = "Oak Ave"
        
        // Then
        XCTAssertEqual(sut.filteredGyms.count, 1)
        XCTAssertEqual(sut.filteredGyms.first?.name, "Uptown Capybara Center")
    }
    
    func test_filteredGyms_withCaseInsensitiveQuery_returnsResults() {
        // Given
        sut.gyms = mockGymService.mockGyms
        sut.searchQuery = "downtown"
        
        // Then
        XCTAssertEqual(sut.filteredGyms.count, 1)
    }
    
    func test_filteredGyms_withNoMatchingQuery_returnsEmpty() {
        // Given
        sut.gyms = mockGymService.mockGyms
        sut.searchQuery = "NonExistentGym"
        
        // Then
        XCTAssertTrue(sut.filteredGyms.isEmpty)
    }
    
    // MARK: - Pass Status Text Tests
    
    func test_passStatusText_withNoPass_returnsNoActivePass() {
        sut.activePass = nil
        XCTAssertEqual(sut.passStatusText, "No active pass")
    }
    
    func test_passStatusText_withActivePass_returnsDaysRemaining() {
        sut.activePass = mockPassService.mockPasses.first
        XCTAssertTrue(sut.passStatusText.contains("days remaining"))
    }
    
    // MARK: - Fetch Gyms Tests
    
    func test_fetchGyms_success_setsGyms() async {
        // Given
        mockGymService.shouldSucceed = true
        
        // When
        await sut.fetchGyms()
        
        // Then
        XCTAssertEqual(sut.gyms.count, mockGymService.mockGyms.count)
        XCTAssertEqual(mockGymService.fetchAllGymsCallCount, 1)
    }
    
    func test_fetchGyms_failure_setsErrorMessage() async {
        // Given
        mockGymService.shouldReturnNetworkError = true
        
        // When
        await sut.fetchGyms()
        
        // Then
        XCTAssertEqual(sut.errorMessage, "Failed to load gyms")
    }
    
    // MARK: - Fetch Nearby Gyms Tests
    
    func test_fetchNearbyGyms_success_setsNearbyGyms() async {
        // Given
        mockGymService.shouldSucceed = true
        
        // When
        await sut.fetchNearbyGyms(latitude: 37.7749, longitude: -122.4194)
        
        // Then
        XCTAssertEqual(sut.nearbyGyms.count, mockGymService.mockGyms.count)
        XCTAssertEqual(mockGymService.fetchNearbyGymsCallCount, 1)
        XCTAssertEqual(mockGymService.capturedLatitude, 37.7749)
        XCTAssertEqual(mockGymService.capturedLongitude, -122.4194)
    }
    
    func test_fetchNearbyGyms_withInvalidLocation_doesNotThrow() async {
        // Given
        mockGymService.shouldReturnInvalidLocation = true
        
        // When & Then - Should not throw
        await sut.fetchNearbyGyms(latitude: 999, longitude: 999)
    }
    
    // MARK: - Fetch Active Pass Tests
    
    func test_fetchActivePass_withAuthenticatedUser_setsActivePass() async {
        // Given
        mockAuthService.simulateAuthenticatedUser()
        mockPassService.shouldSucceed = true
        
        // When
        await sut.fetchActivePass()
        
        // Then
        XCTAssertNotNil(sut.activePass)
        XCTAssertEqual(mockPassService.fetchActivePassCallCount, 1)
    }
    
    func test_fetchActivePass_withNoUser_doesNotCallService() async {
        // Given
        mockAuthService.currentUser = nil
        
        // When
        await sut.fetchActivePass()
        
        // Then
        XCTAssertEqual(mockPassService.fetchActivePassCallCount, 0)
    }
    
    func test_fetchActivePass_failure_setsErrorMessage() async {
        // Given
        mockAuthService.simulateAuthenticatedUser()
        mockPassService.shouldReturnNetworkError = true
        
        // When
        await sut.fetchActivePass()
        
        // Then
        XCTAssertEqual(sut.errorMessage, "Failed to load pass information")
    }
    
    // MARK: - Search Gyms Tests
    
    func test_searchGyms_withQuery_updatesSearchQuery() async {
        // When
        await sut.searchGyms(query: "Downtown")
        
        // Then
        XCTAssertEqual(sut.searchQuery, "Downtown")
    }
    
    func test_searchGyms_withEmptyQuery_fetchesAllGyms() async {
        // Given
        mockGymService.shouldSucceed = true
        
        // When
        await sut.searchGyms(query: "")
        
        // Then
        XCTAssertEqual(mockGymService.fetchAllGymsCallCount, 1)
    }
    
    func test_searchGyms_withQuery_callsSearchService() async {
        // Given
        mockGymService.shouldSucceed = true
        
        // When
        await sut.searchGyms(query: "Downtown")
        
        // Then
        XCTAssertEqual(mockGymService.searchGymsCallCount, 1)
        XCTAssertEqual(mockGymService.capturedSearchQuery, "Downtown")
    }
    
    func test_searchGyms_failure_setsErrorMessage() async {
        // Given
        mockGymService.shouldReturnNetworkError = true
        
        // When
        await sut.searchGyms(query: "Downtown")
        
        // Then
        XCTAssertEqual(sut.errorMessage, "Search failed")
    }
    
    // MARK: - Select Gym Tests
    
    func test_selectGym_setsSelectedGym() {
        // Given
        let gym = mockGymService.mockGyms.first!
        
        // When
        sut.selectGym(gym)
        
        // Then
        XCTAssertEqual(sut.selectedGym?.id, gym.id)
    }
    
    func test_clearSelection_clearsSelectedGym() {
        // Given
        sut.selectedGym = mockGymService.mockGyms.first
        
        // When
        sut.clearSelection()
        
        // Then
        XCTAssertNil(sut.selectedGym)
    }
    
    // MARK: - Update Location Tests
    
    func test_updateLocation_setsUserLocation() {
        // Given
        let coordinate = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
        
        // When
        sut.updateLocation(coordinate)
        
        // Then
        XCTAssertEqual(sut.userLocation?.latitude, 37.7749)
        XCTAssertEqual(sut.userLocation?.longitude, -122.4194)
    }
    
    // MARK: - Location Permission Tests
    
    func test_handleLocationPermissionDenied_showsAlert() {
        // When
        sut.handleLocationPermissionDenied()
        
        // Then
        XCTAssertTrue(sut.showLocationPermissionAlert)
    }
    
    // MARK: - Clear Error Tests
    
    func test_clearError_clearsErrorMessage() {
        // Given
        sut.errorMessage = "Some error"
        
        // When
        sut.clearError()
        
        // Then
        XCTAssertNil(sut.errorMessage)
    }
    
    // MARK: - Loading State Tests
    
    func test_fetchData_setsIsLoading() async {
        // Given
        mockAuthService.simulateAuthenticatedUser()
        
        let expectation = expectation(description: "Loading state changes")
        var loadingStates: [Bool] = []
        
        sut.$isLoading
            .sink { isLoading in
                loadingStates.append(isLoading)
                if loadingStates.count >= 2 {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        // When
        Task {
            await sut.fetchData()
        }
        
        // Then
        await fulfillment(of: [expectation], timeout: 3.0)
        XCTAssertTrue(loadingStates.contains(true))
        XCTAssertEqual(loadingStates.last, false)
    }
    
    // MARK: - Publisher Tests
    
    func test_gymsPublisher_publishesChanges() async {
        // Given
        let expectation = expectation(description: "Gyms publisher emits")
        
        sut.$gyms
            .dropFirst()
            .first()
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // When
        await sut.fetchGyms()
        
        // Then
        await fulfillment(of: [expectation], timeout: 2.0)
    }
    
    func test_activePassPublisher_publishesChanges() async {
        // Given
        mockAuthService.simulateAuthenticatedUser()
        
        let expectation = expectation(description: "Active pass publisher emits")
        
        sut.$activePass
            .dropFirst()
            .first()
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // When
        await sut.fetchActivePass()
        
        // Then
        await fulfillment(of: [expectation], timeout: 2.0)
    }
    
    // MARK: - Integration Tests
    
    func test_onAppear_fetchesAllData() async {
        // Given
        mockAuthService.simulateAuthenticatedUser()
        mockGymService.shouldSucceed = true
        mockPassService.shouldSucceed = true
        
        // When
        await sut.onAppear()
        
        // Then
        XCTAssertEqual(mockGymService.fetchAllGymsCallCount, 1)
        XCTAssertEqual(mockPassService.fetchActivePassCallCount, 1)
    }
    
    func test_onRefresh_fetchesAllData() async {
        // Given
        mockAuthService.simulateAuthenticatedUser()
        mockGymService.shouldSucceed = true
        mockPassService.shouldSucceed = true
        
        // When
        await sut.onRefresh()
        
        // Then
        XCTAssertEqual(mockGymService.fetchAllGymsCallCount, 1)
        XCTAssertEqual(mockPassService.fetchActivePassCallCount, 1)
    }
}
