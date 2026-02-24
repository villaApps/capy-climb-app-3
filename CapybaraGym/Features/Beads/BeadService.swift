import Foundation
import Combine
import Amplify

// MARK: - Bead Service Protocol
protocol BeadServiceProtocol {
    func earnBead(_ type: BeadType, checkInId: String?, gymId: String?) async throws -> Bead
    func getUserBeads() async throws -> [Bead]
    func syncBeads() async throws -> BeadSyncResult
    func uploadBead(_ bead: Bead) async throws -> BeadUploadResponse
    func getUnsyncedBeads() async throws -> [Bead]
    func markBeadAsSynced(_ beadId: String) async throws
    func deleteBead(_ beadId: String) async throws
    func getBeadCollection() async throws -> BeadCollection
    func checkForNewBeads(checkIn: CheckIn) async throws -> [BeadType]
}

// MARK: - Bead Sync Result
struct BeadSyncResult {
    let successCount: Int
    let failedCount: Int
    let failedBeadIds: [String]
    let timestamp: Date
}

// MARK: - Bead Service Implementation
@Observable
final class BeadService: BeadServiceProtocol {
    
    // MARK: - Properties
    private let networkManager: NetworkManager
    private let localStorage: BeadLocalStorage
    private let authService: AuthServiceProtocol
    private let syncQueue: OperationQueue
    
    var syncStatus: BeadSyncStatus = .idle
    var lastSyncDate: Date?
    var pendingUploadCount: Int = 0
    
    private var cancellables = Set<AnyCancellable>()
    private let maxRetryAttempts = 3
    private let syncInterval: TimeInterval = 300 // 5 minutes
    
    // MARK: - Initialization
    init(
        networkManager: NetworkManager = NetworkManager.shared,
        localStorage: BeadLocalStorage = BeadLocalStorage.shared,
        authService: AuthServiceProtocol = AmplifyAuthService()
    ) {
        self.networkManager = networkManager
        self.localStorage = localStorage
        self.authService = authService
        
        self.syncQueue = OperationQueue()
        self.syncQueue.name = "com.capybaragym.beadsync"
        self.syncQueue.maxConcurrentOperationCount = 1
        
        setupPeriodicSync()
    }
    
    // MARK: - Bead Earning
    func earnBead(_ type: BeadType, checkInId: String? = nil, gymId: String? = nil) async throws -> Bead {
        guard let userId = authService.currentUser?.id else {
            throw BeadError.unauthorized
        }
        
        // Check if user already has this bead type (for unique beads)
        if shouldBeUnique(type) {
            let existingBeads = try await localStorage.getBeadsByType(type, userId: userId)
            if !existingBeads.isEmpty {
                throw BeadError.beadAlreadyExists
            }
        }
        
        let bead = Bead(
            userId: userId,
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
        
        // Save locally first
        try await localStorage.saveBead(bead)
        
        // Attempt to sync immediately
        Task {
            try? await uploadBead(bead)
        }
        
        return bead
    }
    
    // MARK: - Get User Beads
    func getUserBeads() async throws -> [Bead] {
        guard let userId = authService.currentUser?.id else {
            throw BeadError.unauthorized
        }
        
        // Get local beads
        var localBeads = try await localStorage.getAllBeads(userId: userId)
        
        // Try to fetch from server for latest
        do {
            let serverBeads = try await fetchBeadsFromServer(userId: userId)
            
            // Merge server beads with local
            for serverBead in serverBeads {
                if !localBeads.contains(where: { $0.id == serverBead.id }) {
                    var syncedBead = serverBead
                    syncedBead.isSynced = true
                    try? await localStorage.saveBead(syncedBead)
                    localBeads.append(syncedBead)
                }
            }
        } catch {
            Logger.warning("Failed to fetch beads from server, using local cache: \(error)")
        }
        
        return localBeads.sorted { $0.earnedAt > $1.earnedAt }
    }
    
    // MARK: - Sync Beads
    func syncBeads() async throws -> BeadSyncResult {
        guard syncStatus != .syncing else {
            return BeadSyncResult(successCount: 0, failedCount: 0, failedBeadIds: [], timestamp: Date())
        }
        
        syncStatus = .syncing
        defer { 
            if case .syncing = syncStatus {
                syncStatus = .idle
            }
        }
        
        let unsyncedBeads = try await getUnsyncedBeads()
        guard !unsyncedBeads.isEmpty else {
            syncStatus = .synced
            lastSyncDate = Date()
            return BeadSyncResult(successCount: 0, failedCount: 0, failedBeadIds: [], timestamp: Date())
        }
        
        var successCount = 0
        var failedCount = 0
        var failedBeadIds: [String] = []
        
        for bead in unsyncedBeads {
            do {
                _ = try await uploadBeadWithRetry(bead)
                successCount += 1
            } catch {
                failedCount += 1
                failedBeadIds.append(bead.id)
                
                // Increment retry count
                var updatedBead = bead
                updatedBead.syncAttemptCount += 1
                updatedBead.lastSyncAttempt = Date()
                try? await localStorage.updateBead(updatedBead)
            }
        }
        
        let result = BeadSyncResult(
            successCount: successCount,
            failedCount: failedCount,
            failedBeadIds: failedBeadIds,
            timestamp: Date()
        )
        
        if failedCount == 0 {
            syncStatus = .synced
            lastSyncDate = Date()
        } else if successCount > 0 {
            syncStatus = .partialSuccess(successCount, failedCount)
        } else {
            syncStatus = .failed(BeadError.syncFailed(maxRetryAttempts))
        }
        
        pendingUploadCount = failedCount
        
        return result
    }
    
    // MARK: - Upload Bead
    func uploadBead(_ bead: Bead) async throws -> BeadUploadResponse {
        return try await uploadBeadWithRetry(bead)
    }
    
    private func uploadBeadWithRetry(_ bead: Bead, attempt: Int = 1) async throws -> BeadUploadResponse {
        do {
            let response = try await performUpload(bead)
            
            if response.success {
                try await markBeadAsSynced(bead.id)
            }
            
            return response
        } catch {
            if attempt < maxRetryAttempts {
                let delay = pow(2.0, Double(attempt)) // Exponential backoff
                try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                return try await uploadBeadWithRetry(bead, attempt: attempt + 1)
            } else {
                throw BeadError.maxRetriesExceeded
            }
        }
    }
    
    private func performUpload(_ bead: Bead) async throws -> BeadUploadResponse {
        let mutation = """
        mutation CreateBead($input: CreateBeadInput!) {
            createBead(input: $input) {
                id
                userId
                type
                name
                description
                earnedAt
                rarity
                createdAt
            }
        }
        """
        
        let variables: [String: Any] = [
            "input": [
                "id": bead.id,
                "userId": bead.userId,
                "type": bead.type.rawValue,
                "name": bead.name,
                "description": bead.description,
                "colorHex": bead.colorHex,
                "earnedAt": ISO8601DateFormatter().string(from: bead.earnedAt),
                "checkInId": bead.checkInId as Any,
                "gymId": bead.gymId as Any,
                "rarity": bead.rarity.rawValue
            ]
        ]
        
        let request = GraphQLRequest<BeadUploadResponse>(
            document: mutation,
            variables: variables,
            responseType: BeadUploadResponse.self
        )
        
        let result = try await Amplify.API.mutate(request: request)
        
        switch result {
        case .success(let response):
            return response
        case .failure(let error):
            throw BeadError.serverError(error.errorDescription)
        }
    }
    
    // MARK: - Get Unsynced Beads
    func getUnsyncedBeads() async throws -> [Bead] {
        guard let userId = authService.currentUser?.id else {
            throw BeadError.unauthorized
        }
        
        return try await localStorage.getUnsyncedBeads(userId: userId)
    }
    
    // MARK: - Mark Bead as Synced
    func markBeadAsSynced(_ beadId: String) async throws {
        try await localStorage.markAsSynced(beadId: beadId)
    }
    
    // MARK: - Delete Bead
    func deleteBead(_ beadId: String) async throws {
        // Delete from server first
        let mutation = """
        mutation DeleteBead($id: ID!) {
            deleteBead(id: $id) {
                id
            }
        }
        """
        
        let request = GraphQLRequest<BeadDeleteResponse>(
            document: mutation,
            variables: ["id": beadId],
            responseType: BeadDeleteResponse.self
        )
        
        _ = try? await Amplify.API.mutate(request: request)
        
        // Delete from local storage
        try await localStorage.deleteBead(beadId: beadId)
    }
    
    // MARK: - Get Bead Collection
    func getBeadCollection() async throws -> BeadCollection {
        let beads = try await getUserBeads()
        guard let userId = authService.currentUser?.id else {
            throw BeadError.unauthorized
        }
        
        return BeadCollection(userId: userId, beads: beads)
    }
    
    // MARK: - Check for New Beads
    func checkForNewBeads(checkIn: CheckIn) async throws -> [BeadType] {
        guard let userId = authService.currentUser?.id else {
            throw BeadError.unauthorized
        }
        
        var newBeadTypes: [BeadType] = []
        let collection = try await getBeadCollection()
        
        // Check first check-in
        if collection.totalBeads == 0 {
            newBeadTypes.append(.firstCheckIn)
        }
        
        // Check streak
        let streak = try await getCurrentStreak(userId: userId)
        switch streak {
        case 3 where !collection.hasBeadType(.streak3):
            newBeadTypes.append(.streak3)
        case 7 where !collection.hasBeadType(.streak7):
            newBeadTypes.append(.streak7)
        case 30 where !collection.hasBeadType(.streak30):
            newBeadTypes.append(.streak30)
        case 100 where !collection.hasBeadType(.streak100):
            newBeadTypes.append(.streak100)
        default:
            break
        }
        
        // Check early bird / night owl
        let hour = Calendar.current.component(.hour, from: checkIn.checkInTime)
        if hour < 7 && !collection.hasBeadType(.earlyBird) {
            newBeadTypes.append(.earlyBird)
        } else if hour >= 21 && !collection.hasBeadType(.nightOwl) {
            newBeadTypes.append(.nightOwl)
        }
        
        // Check weekend warrior
        let weekday = Calendar.current.component(.weekday, from: checkIn.checkInTime)
        if (weekday == 7 || weekday == 1) && !collection.hasBeadType(.weekendWarrior) {
            // Check if already checked in this weekend
            let weekendCheckIns = try await getWeekendCheckIns(userId: userId)
            if weekendCheckIns.count >= 2 {
                newBeadTypes.append(.weekendWarrior)
            }
        }
        
        // Check gym explorer
        let uniqueGyms = Set(try await getUserCheckIns(userId: userId).map { $0.gymId })
        if uniqueGyms.count >= 5 && !collection.hasBeadType(.gymExplorer) {
            newBeadTypes.append(.gymExplorer)
        }
        
        return newBeadTypes
    }
    
    // MARK: - Private Helpers
    private func shouldBeUnique(_ type: BeadType) -> Bool {
        switch type {
        case .firstCheckIn, .streak3, .streak7, .streak30, .streak100,
             .earlyBird, .nightOwl, .weekendWarrior, .gymExplorer,
             .socialButterfly, .passCollector, .fitnessMaster:
            return true
        case .specialEvent, .limitedEdition:
            return false
        }
    }
    
    private func fetchBeadsFromServer(userId: String) async throws -> [Bead] {
        let query = """
        query ListBeads($userId: String!) {
            listBeads(filter: { userId: { eq: $userId } }) {
                items {
                    id
                    userId
                    type
                    name
                    description
                    imageUrl
                    colorHex
                    earnedAt
                    checkInId
                    gymId
                    rarity
                }
            }
        }
        """
        
        let request = GraphQLRequest<BeadListResponse>(
            document: query,
            variables: ["userId": userId],
            responseType: BeadListResponse.self
        )
        
        let result = try await Amplify.API.query(request: request)
        
        switch result {
        case .success(let response):
            return response.items
        case .failure(let error):
            throw BeadError.serverError(error.errorDescription)
        }
    }
    
    private func getCurrentStreak(userId: String) async throws -> Int {
        // This would be implemented using the streak service
        // Placeholder for now
        return 0
    }
    
    private func getWeekendCheckIns(userId: String) async throws -> [CheckIn] {
        // Placeholder
        return []
    }
    
    private func getUserCheckIns(userId: String) async throws -> [CheckIn] {
        // Placeholder
        return []
    }
    
    private func setupPeriodicSync() {
        Timer.scheduledTimer(withTimeInterval: syncInterval, repeats: true) { [weak self] _ in
            Task {
                try? await self?.syncBeads()
            }
        }
    }
}

// MARK: - Supporting Types
struct BeadDeleteResponse: Codable {
    let id: String
}

struct BeadListResponse: Codable {
    let items: [Bead]
}

// MARK: - Network Manager
class NetworkManager {
    static let shared = NetworkManager()
    
    func isReachable() -> Bool {
        // Implement network reachability check
        return true
    }
}

// MARK: - CheckIn Placeholder
struct CheckIn: Codable {
    let id: String
    let userId: String
    let gymId: String
    let checkInTime: Date
}
