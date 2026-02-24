import Foundation
@testable import CapybaraGym

// MARK: - Mock Bead Service
@Observable
final class MockBeadService: BeadServiceProtocol {
    
    // MARK: - Mock Data
    var mockBeads: [Bead] = []
    var mockCollection: BeadCollection?
    var mockEarnedBead: Bead?
    var mockSyncResult: BeadSyncResult?
    var mockNewBeadTypes: [BeadType] = []
    
    // MARK: - Error Control
    var shouldThrowError = false
    var error: Error?
    var delay: TimeInterval = 0
    
    // MARK: - Call Tracking
    var getUserBeadsCallCount = 0
    var earnBeadCallCount = 0
    var syncBeadsCallCount = 0
    var uploadBeadCallCount = 0
    var getUnsyncedBeadsCallCount = 0
    var markBeadAsSyncedCallCount = 0
    var deleteBeadCallCount = 0
    var getBeadCollectionCallCount = 0
    var checkForNewBeadsCallCount = 0
    
    var lastEarnedType: BeadType?
    var lastCheckInId: String?
    var lastGymId: String?
    var lastUploadedBead: Bead?
    var lastDeletedBeadId: String?
    var lastCheckIn: CheckIn?
    
    // MARK: - BeadServiceProtocol
    
    func getUserBeads() async throws -> [Bead] {
        getUserBeadsCallCount += 1
        try await simulateDelay()
        if shouldThrowError { throw error ?? BeadError.networkError }
        return mockBeads
    }
    
    func earnBead(_ type: BeadType, checkInId: String?, gymId: String?) async throws -> Bead {
        earnBeadCallCount += 1
        lastEarnedType = type
        lastCheckInId = checkInId
        lastGymId = gymId
        
        try await simulateDelay()
        if shouldThrowError { throw error ?? BeadError.networkError }
        
        return mockEarnedBead ?? Bead(
            userId: "mock-user-id",
            type: type,
            name: type.displayName,
            description: type.description,
            colorHex: type.defaultColorHex,
            earnedAt: Date(),
            checkInId: checkInId,
            gymId: gymId,
            rarity: type.defaultRarity,
            isSynced: false
        )
    }
    
    func syncBeads() async throws -> BeadSyncResult {
        syncBeadsCallCount += 1
        try await simulateDelay()
        if shouldThrowError { throw error ?? BeadError.networkError }
        
        return mockSyncResult ?? BeadSyncResult(
            successCount: mockBeads.filter { !$0.isSynced }.count,
            failedCount: 0,
            failedBeadIds: [],
            timestamp: Date()
        )
    }
    
    func uploadBead(_ bead: Bead) async throws -> BeadUploadResponse {
        uploadBeadCallCount += 1
        lastUploadedBead = bead
        try await simulateDelay()
        if shouldThrowError { throw error ?? BeadError.networkError }
        
        return BeadUploadResponse(
            success: true,
            beadId: bead.id,
            serverBeadId: "server-\(bead.id)",
            errorMessage: nil,
            syncedAt: Date()
        )
    }
    
    func getUnsyncedBeads() async throws -> [Bead] {
        getUnsyncedBeadsCallCount += 1
        try await simulateDelay()
        if shouldThrowError { throw error ?? BeadError.networkError }
        return mockBeads.filter { !$0.isSynced }
    }
    
    func markBeadAsSynced(_ beadId: String) async throws {
        markBeadAsSyncedCallCount += 1
        try await simulateDelay()
        if shouldThrowError { throw error ?? BeadError.networkError }
        
        if let index = mockBeads.firstIndex(where: { $0.id == beadId }) {
            mockBeads[index].isSynced = true
        }
    }
    
    func deleteBead(_ beadId: String) async throws {
        deleteBeadCallCount += 1
        lastDeletedBeadId = beadId
        try await simulateDelay()
        if shouldThrowError { throw error ?? BeadError.networkError }
        mockBeads.removeAll { $0.id == beadId }
    }
    
    func getBeadCollection() async throws -> BeadCollection {
        getBeadCollectionCallCount += 1
        try await simulateDelay()
        if shouldThrowError { throw error ?? BeadError.networkError }
        
        return mockCollection ?? BeadCollection(
            userId: "mock-user-id",
            beads: mockBeads,
            lastUpdated: Date()
        )
    }
    
    func checkForNewBeads(checkIn: CheckIn) async throws -> [BeadType] {
        checkForNewBeadsCallCount += 1
        lastCheckIn = checkIn
        try await simulateDelay()
        if shouldThrowError { throw error ?? BeadError.networkError }
        return mockNewBeadTypes
    }
    
    // MARK: - Helper Methods
    
    private func simulateDelay() async throws {
        guard delay > 0 else { return }
        try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
    }
    
    func reset() {
        mockBeads = []
        mockCollection = nil
        mockEarnedBead = nil
        mockSyncResult = nil
        mockNewBeadTypes = []
        shouldThrowError = false
        error = nil
        delay = 0
        
        getUserBeadsCallCount = 0
        earnBeadCallCount = 0
        syncBeadsCallCount = 0
        uploadBeadCallCount = 0
        getUnsyncedBeadsCallCount = 0
        markBeadAsSyncedCallCount = 0
        deleteBeadCallCount = 0
        getBeadCollectionCallCount = 0
        checkForNewBeadsCallCount = 0
        
        lastEarnedType = nil
        lastCheckInId = nil
        lastGymId = nil
        lastUploadedBead = nil
        lastDeletedBeadId = nil
        lastCheckIn = nil
    }
    
    // MARK: - Test Data Helpers
    
    func addMockBead(
        type: BeadType = .firstCheckIn,
        isSynced: Bool = true,
        rarity: BeadRarity? = nil,
        earnedAt: Date = Date()
    ) -> Bead {
        let bead = Bead(
            userId: "mock-user-id",
            type: type,
            name: type.displayName,
            description: type.description,
            colorHex: type.defaultColorHex,
            earnedAt: earnedAt,
            rarity: rarity ?? type.defaultRarity,
            isSynced: isSynced
        )
        mockBeads.append(bead)
        return bead
    }
    
    func addMockBeads(count: Int, types: [BeadType]? = nil) {
        let beadTypes = types ?? BeadType.allCases
        for i in 0..<count {
            let type = beadTypes[i % beadTypes.count]
            addMockBead(type: type)
        }
    }
}
