import XCTest
@testable import CapybaraGym

// MARK: - Bead View Model Tests
@MainActor
final class BeadViewModelTests: XCTestCase {
    
    // MARK: - Properties
    var sut: BeadViewModel!
    var mockBeadService: MockBeadService!
    var mockAuthService: MockAuthService!
    
    // MARK: - Setup
    override func setUp() {
        super.setUp()
        mockBeadService = MockBeadService()
        mockAuthService = MockAuthService()
        sut = BeadViewModel(
            beadService: mockBeadService,
            authService: mockAuthService
        )
    }
    
    override func tearDown() {
        sut = nil
        mockBeadService = nil
        mockAuthService = nil
        super.tearDown()
    }
    
    // MARK: - Initial State Tests
    
    func testInitialState() {
        XCTAssertEqual(sut.state, .idle)
        XCTAssertTrue(sut.beads.isEmpty)
        XCTAssertNil(sut.collection)
        XCTAssertNil(sut.selectedBead)
        XCTAssertFalse(sut.showEarnedAnimation)
        XCTAssertNil(sut.newlyEarnedBead)
        XCTAssertEqual(sut.syncProgress, 0.0)
        XCTAssertEqual(sut.pendingUploadCount, 0)
        XCTAssertNil(sut.selectedRarity)
        XCTAssertNil(sut.selectedType)
        XCTAssertEqual(sut.sortOption, .newest)
    }
    
    // MARK: - Load Beads Tests
    
    func testLoadBeadsSuccess() async {
        // Given
        let expectedBeads = [
            createBead(type: .firstCheckIn),
            createBead(type: .streak3)
        ]
        mockBeadService.mockBeads = expectedBeads
        mockBeadService.mockCollection = BeadCollection(userId: "user1", beads: expectedBeads)
        
        // When
        await sut.loadBeads()
        
        // Then
        XCTAssertEqual(sut.state, .loaded)
        XCTAssertEqual(sut.beads.count, 2)
        XCTAssertNotNil(sut.collection)
        XCTAssertTrue(mockBeadService.getUserBeadsCalled)
    }
    
    func testLoadBeadsFailure() async {
        // Given
        mockBeadService.shouldThrowError = true
        mockBeadService.error = BeadError.networkError
        
        // When
        await sut.loadBeads()
        
        // Then
        XCTAssertEqual(sut.state, .error("Network connection failed"))
        XCTAssertTrue(sut.beads.isEmpty)
    }
    
    func testLoadBeadsUnauthorized() async {
        // Given
        mockBeadService.shouldThrowError = true
        mockBeadService.error = BeadError.unauthorized
        
        // When
        await sut.loadBeads()
        
        // Then
        XCTAssertEqual(sut.state, .error("Please sign in to sync beads"))
    }
    
    // MARK: - Earn Bead Tests
    
    func testEarnBeadSuccess() async {
        // Given
        let expectedBead = createBead(type: .firstCheckIn)
        mockBeadService.mockEarnedBead = expectedBead
        
        // When
        await sut.earnBead(.firstCheckIn, checkInId: "check1", gymId: "gym1")
        
        // Then
        XCTAssertEqual(sut.state, .beadEarned(expectedBead))
        XCTAssertEqual(sut.beads.count, 1)
        XCTAssertEqual(sut.beads.first?.type, .firstCheckIn)
        XCTAssertTrue(sut.showEarnedAnimation)
        XCTAssertEqual(sut.newlyEarnedBead, expectedBead)
        XCTAssertTrue(mockBeadService.earnBeadCalled)
    }
    
    func testEarnBeadAlreadyExists() async {
        // Given
        mockBeadService.shouldThrowError = true
        mockBeadService.error = BeadError.beadAlreadyExists
        
        // When
        await sut.earnBead(.firstCheckIn)
        
        // Then
        XCTAssertEqual(sut.state, .error("You already have this bead!"))
    }
    
    func testEarnBeadFailure() async {
        // Given
        mockBeadService.shouldThrowError = true
        mockBeadService.error = BeadError.networkError
        
        // When
        await sut.earnBead(.firstCheckIn)
        
        // Then
        XCTAssertEqual(sut.state, .error("Network connection failed"))
    }
    
    func testEarnMultipleBeads() async {
        // Given
        let bead1 = createBead(type: .firstCheckIn, id: "1")
        let bead2 = createBead(type: .streak3, id: "2")
        mockBeadService.mockEarnedBead = bead1
        
        // When
        await sut.earnBead(.firstCheckIn)
        mockBeadService.mockEarnedBead = bead2
        await sut.earnBead(.streak3)
        
        // Then
        XCTAssertEqual(sut.beads.count, 2)
        XCTAssertEqual(sut.beads[0].type, .streak3) // Newest first
        XCTAssertEqual(sut.beads[1].type, .firstCheckIn)
    }
    
    // MARK: - Sync Tests
    
    func testSyncBeadsSuccess() async {
        // Given
        let unsyncedBeads = [
            createBead(type: .firstCheckIn, isSynced: false),
            createBead(type: .streak3, isSynced: false)
        ]
        mockBeadService.mockBeads = unsyncedBeads
        mockBeadService.mockSyncResult = BeadSyncResult(
            successCount: 2,
            failedCount: 0,
            failedBeadIds: [],
            timestamp: Date()
        )
        
        // When
        await sut.syncBeads()
        
        // Then
        XCTAssertEqual(sut.state, .syncComplete(2, 0))
        XCTAssertEqual(sut.syncProgress, 1.0)
        XCTAssertTrue(mockBeadService.syncBeadsCalled)
    }
    
    func testSyncBeadsPartialSuccess() async {
        // Given
        mockBeadService.mockSyncResult = BeadSyncResult(
            successCount: 1,
            failedCount: 1,
            failedBeadIds: ["bead2"],
            timestamp: Date()
        )
        
        // When
        await sut.syncBeads()
        
        // Then
        XCTAssertEqual(sut.state, .syncComplete(1, 1))
        XCTAssertEqual(sut.pendingUploadCount, 1)
    }
    
    func testSyncBeadsFailure() async {
        // Given
        mockBeadService.shouldThrowError = true
        mockBeadService.error = BeadError.networkError
        
        // When
        await sut.syncBeads()
        
        // Then
        XCTAssertEqual(sut.state, .error("Sync failed: Network connection failed"))
        XCTAssertEqual(sut.syncProgress, 0.0)
    }
    
    func testSyncBeadsNoUnsynced() async {
        // Given
        let syncedBeads = [createBead(type: .firstCheckIn, isSynced: true)]
        mockBeadService.mockBeads = syncedBeads
        
        // When
        await sut.syncBeads()
        
        // Then - Should not attempt sync if no unsynced beads
        XCTAssertFalse(mockBeadService.syncBeadsCalled)
    }
    
    // MARK: - Filter Tests
    
    func testFilterByRarity() {
        // Given
        let commonBead = createBead(type: .firstCheckIn, rarity: .common)
        let rareBead = createBead(type: .streak30, rarity: .rare)
        sut.beads = [commonBead, rareBead]
        
        // When
        sut.filterByRarity(.rare)
        
        // Then
        XCTAssertEqual(sut.filteredBeads.count, 1)
        XCTAssertEqual(sut.filteredBeads.first?.rarity, .rare)
    }
    
    func testFilterByType() {
        // Given
        let streakBead = createBead(type: .streak3)
        let earlyBirdBead = createBead(type: .earlyBird)
        sut.beads = [streakBead, earlyBirdBead]
        
        // When
        sut.filterByType(.streak3)
        
        // Then
        XCTAssertEqual(sut.filteredBeads.count, 1)
        XCTAssertEqual(sut.filteredBeads.first?.type, .streak3)
    }
    
    func testClearFilters() {
        // Given
        sut.selectedRarity = .rare
        sut.selectedType = .streak3
        sut.sortOption = .oldest
        
        // When
        sut.clearFilters()
        
        // Then
        XCTAssertNil(sut.selectedRarity)
        XCTAssertNil(sut.selectedType)
        XCTAssertEqual(sut.sortOption, .newest)
    }
    
    func testMultipleFilters() {
        // Given
        let commonStreak = createBead(type: .streak3, rarity: .common)
        let rareStreak = createBead(type: .streak7, rarity: .rare)
        let rareEarlyBird = createBead(type: .earlyBird, rarity: .rare)
        sut.beads = [commonStreak, rareStreak, rareEarlyBird]
        
        // When
        sut.filterByRarity(.rare)
        sut.filterByType(.streak7)
        
        // Then
        XCTAssertEqual(sut.filteredBeads.count, 1)
        XCTAssertEqual(sut.filteredBeads.first?.type, .streak7)
        XCTAssertEqual(sut.filteredBeads.first?.rarity, .rare)
    }
    
    // MARK: - Sort Tests
    
    func testSortByNewest() {
        // Given
        let oldBead = createBead(type: .firstCheckIn, earnedAt: Date().addingTimeInterval(-86400))
        let newBead = createBead(type: .streak3, earnedAt: Date())
        sut.beads = [oldBead, newBead]
        
        // When
        sut.setSortOption(.newest)
        
        // Then
        XCTAssertEqual(sut.filteredBeads.first?.type, .streak3)
    }
    
    func testSortByOldest() {
        // Given
        let oldBead = createBead(type: .firstCheckIn, earnedAt: Date().addingTimeInterval(-86400))
        let newBead = createBead(type: .streak3, earnedAt: Date())
        sut.beads = [newBead, oldBead]
        
        // When
        sut.setSortOption(.oldest)
        
        // Then
        XCTAssertEqual(sut.filteredBeads.first?.type, .firstCheckIn)
    }
    
    func testSortByRarity() {
        // Given
        let commonBead = createBead(type: .firstCheckIn, rarity: .common)
        let legendaryBead = createBead(type: .streak100, rarity: .legendary)
        let rareBead = createBead(type: .streak30, rarity: .rare)
        sut.beads = [commonBead, legendaryBead, rareBead]
        
        // When
        sut.setSortOption(.rarity)
        
        // Then - Legendary should be first (lowest drop rate)
        XCTAssertEqual(sut.filteredBeads.first?.rarity, .legendary)
        XCTAssertEqual(sut.filteredBeads.last?.rarity, .common)
    }
    
    // MARK: - Delete Tests
    
    func testDeleteBeadSuccess() async {
        // Given
        let bead = createBead(type: .firstCheckIn)
        sut.beads = [bead]
        
        // When
        await sut.deleteBead(bead.id)
        
        // Then
        XCTAssertTrue(sut.beads.isEmpty)
        XCTAssertTrue(mockBeadService.deleteBeadCalled)
    }
    
    func testDeleteBeadFailure() async {
        // Given
        let bead = createBead(type: .firstCheckIn)
        sut.beads = [bead]
        mockBeadService.shouldThrowError = true
        mockBeadService.error = BeadError.networkError
        
        // When
        await sut.deleteBead(bead.id)
        
        // Then
        XCTAssertEqual(sut.state, .error("Failed to delete bead: Network connection failed"))
        XCTAssertEqual(sut.beads.count, 1) // Should still have the bead
    }
    
    // MARK: - Check for New Beads Tests
    
    func testCheckForNewBeads() async {
        // Given
        let checkIn = CheckIn(id: "check1", userId: "user1", gymId: "gym1", checkInTime: Date())
        mockBeadService.mockNewBeadTypes = [.firstCheckIn, .streak3]
        
        // When
        let newTypes = await sut.checkForNewBeads(checkIn: checkIn)
        
        // Then
        XCTAssertEqual(newTypes.count, 2)
        XCTAssertTrue(newTypes.contains(.firstCheckIn))
        XCTAssertTrue(newTypes.contains(.streak3))
    }
    
    // MARK: - Computed Properties Tests
    
    func testTotalBeads() {
        // Given
        sut.beads = [createBead(type: .firstCheckIn), createBead(type: .streak3)]
        
        // Then
        XCTAssertEqual(sut.totalBeads, 2)
    }
    
    func testUniqueBeadTypes() {
        // Given
        let bead1 = createBead(type: .firstCheckIn, id: "1")
        let bead2 = createBead(type: .firstCheckIn, id: "2") // Same type
        let bead3 = createBead(type: .streak3, id: "3")
        sut.beads = [bead1, bead2, bead3]
        
        // Then
        XCTAssertEqual(sut.uniqueBeadTypes, 2)
    }
    
    func testCompletionPercentage() {
        // Given
        let totalTypes = BeadType.allCases.count
        let bead1 = createBead(type: .firstCheckIn)
        let bead2 = createBead(type: .streak3)
        sut.beads = [bead1, bead2]
        
        // Then
        let expectedPercentage = Double(2) / Double(totalTypes) * 100
        XCTAssertEqual(sut.completionPercentage, expectedPercentage)
    }
    
    func testUnsyncedCount() {
        // Given
        let syncedBead = createBead(type: .firstCheckIn, id: "1", isSynced: true)
        let unsyncedBead = createBead(type: .streak3, id: "2", isSynced: false)
        sut.beads = [syncedBead, unsyncedBead]
        
        // Then
        XCTAssertEqual(sut.unsyncedCount, 1)
    }
    
    func testBeadsByRarity() {
        // Given
        let commonBead = createBead(type: .firstCheckIn, rarity: .common)
        let rareBead = createBead(type: .streak30, rarity: .rare)
        sut.beads = [commonBead, rareBead]
        
        // Then
        XCTAssertEqual(sut.beadsByRarity[.common]?.count, 1)
        XCTAssertEqual(sut.beadsByRarity[.rare]?.count, 1)
    }
    
    func testProgressForType() {
        // Given
        let bead1 = createBead(type: .streak3)
        let bead2 = createBead(type: .streak3)
        sut.beads = [bead1, bead2]
        
        // When
        let progress = sut.progressForType(.streak3)
        
        // Then
        XCTAssertEqual(progress.current, 2)
        XCTAssertEqual(progress.target, 1)
    }
    
    func testShareBead() {
        // Given
        let bead = createBead(type: .firstCheckIn)
        
        // When
        let shareText = sut.shareBead(bead)
        
        // Then
        XCTAssertTrue(shareText.contains(bead.name))
        XCTAssertTrue(shareText.contains("Capybara Gym"))
        XCTAssertTrue(shareText.contains("#CapybaraGym"))
    }
    
    // MARK: - Helper Methods
    
    private func createBead(
        type: BeadType,
        id: String = UUID().uuidString,
        isSynced: Bool = false,
        rarity: BeadRarity? = nil,
        earnedAt: Date = Date()
    ) -> Bead {
        return Bead(
            id: id,
            userId: "user1",
            type: type,
            name: type.displayName,
            description: type.description,
            colorHex: type.defaultColorHex,
            earnedAt: earnedAt,
            rarity: rarity ?? type.defaultRarity,
            isSynced: isSynced
        )
    }
}

// MARK: - Mock Bead Service
class MockBeadService: BeadServiceProtocol {
    var mockBeads: [Bead] = []
    var mockCollection: BeadCollection?
    var mockEarnedBead: Bead?
    var mockSyncResult: BeadSyncResult?
    var mockNewBeadTypes: [BeadType] = []
    
    var shouldThrowError = false
    var error: Error?
    
    var getUserBeadsCalled = false
    var earnBeadCalled = false
    var syncBeadsCalled = false
    var deleteBeadCalled = false
    
    func getUserBeads() async throws -> [Bead] {
        getUserBeadsCalled = true
        if shouldThrowError { throw error ?? BeadError.networkError }
        return mockBeads
    }
    
    func earnBead(_ type: BeadType, checkInId: String?, gymId: String?) async throws -> Bead {
        earnBeadCalled = true
        if shouldThrowError { throw error ?? BeadError.networkError }
        return mockEarnedBead ?? Bead(
            userId: "user1",
            type: type,
            name: type.displayName,
            description: type.description,
            colorHex: type.defaultColorHex,
            rarity: type.defaultRarity
        )
    }
    
    func syncBeads() async throws -> BeadSyncResult {
        syncBeadsCalled = true
        if shouldThrowError { throw error ?? BeadError.networkError }
        return mockSyncResult ?? BeadSyncResult(successCount: 0, failedCount: 0, failedBeadIds: [], timestamp: Date())
    }
    
    func uploadBead(_ bead: Bead) async throws -> BeadUploadResponse {
        if shouldThrowError { throw error ?? BeadError.networkError }
        return BeadUploadResponse(success: true, beadId: bead.id, serverBeadId: bead.id, errorMessage: nil, syncedAt: Date())
    }
    
    func getUnsyncedBeads() async throws -> [Bead] {
        mockBeads.filter { !$0.isSynced }
    }
    
    func markBeadAsSynced(_ beadId: String) async throws {}
    
    func deleteBead(_ beadId: String) async throws {
        deleteBeadCalled = true
        if shouldThrowError { throw error ?? BeadError.networkError }
    }
    
    func getBeadCollection() async throws -> BeadCollection {
        mockCollection ?? BeadCollection(userId: "user1", beads: mockBeads)
    }
    
    func checkForNewBeads(checkIn: CheckIn) async throws -> [BeadType] {
        mockNewBeadTypes
    }
}
