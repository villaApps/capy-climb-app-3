import Foundation

// MARK: - Bead Model
/// Represents a collectible bead earned through gym activities
struct Bead: Identifiable, Codable, Equatable {
    let id: String
    let userId: String
    let type: BeadType
    let name: String
    let description: String
    let imageUrl: String?
    let colorHex: String
    let earnedAt: Date
    let checkInId: String?
    let gymId: String?
    let rarity: BeadRarity
    var isSynced: Bool
    var syncAttemptCount: Int
    var lastSyncAttempt: Date?
    
    init(
        id: String = UUID().uuidString,
        userId: String,
        type: BeadType,
        name: String,
        description: String,
        imageUrl: String? = nil,
        colorHex: String,
        earnedAt: Date = Date(),
        checkInId: String? = nil,
        gymId: String? = nil,
        rarity: BeadRarity = .common,
        isSynced: Bool = false,
        syncAttemptCount: Int = 0,
        lastSyncAttempt: Date? = nil
    ) {
        self.id = id
        self.userId = userId
        self.type = type
        self.name = name
        self.description = description
        self.imageUrl = imageUrl
        self.colorHex = colorHex
        self.earnedAt = earnedAt
        self.checkInId = checkInId
        self.gymId = gymId
        self.rarity = rarity
        self.isSynced = isSynced
        self.syncAttemptCount = syncAttemptCount
        self.lastSyncAttempt = lastSyncAttempt
    }
}

// MARK: - Bead Type
enum BeadType: String, Codable, CaseIterable {
    case firstCheckIn = "FIRST_CHECKIN"
    case streak3 = "STREAK_3"
    case streak7 = "STREAK_7"
    case streak30 = "STREAK_30"
    case streak100 = "STREAK_100"
    case earlyBird = "EARLY_BIRD"
    case nightOwl = "NIGHT_OWL"
    case weekendWarrior = "WEEKEND_WARRIOR"
    case gymExplorer = "GYM_EXPLORER"
    case socialButterfly = "SOCIAL_BUTTERFLY"
    case passCollector = "PASS_COLLECTOR"
    case fitnessMaster = "FITNESS_MASTER"
    case specialEvent = "SPECIAL_EVENT"
    case limitedEdition = "LIMITED_EDITION"
    
    var displayName: String {
        switch self {
        case .firstCheckIn: return "First Steps"
        case .streak3: return "3-Day Streak"
        case .streak7: return "Week Warrior"
        case .streak30: return "Monthly Master"
        case .streak100: return "Century Club"
        case .earlyBird: return "Early Bird"
        case .nightOwl: return "Night Owl"
        case .weekendWarrior: return "Weekend Warrior"
        case .gymExplorer: return "Gym Explorer"
        case .socialButterfly: return "Social Butterfly"
        case .passCollector: return "Pass Collector"
        case .fitnessMaster: return "Fitness Master"
        case .specialEvent: return "Special Event"
        case .limitedEdition: return "Limited Edition"
        }
    }
    
    var description: String {
        switch self {
        case .firstCheckIn: return "Complete your first gym check-in"
        case .streak3: return "Check in 3 days in a row"
        case .streak7: return "Maintain a 7-day streak"
        case .streak30: return "Incredible! 30 days straight"
        case .streak100: return "Legendary! 100 days of dedication"
        case .earlyBird: return "Check in before 7 AM"
        case .nightOwl: return "Check in after 9 PM"
        case .weekendWarrior: return "Check in on both Saturday and Sunday"
        case .gymExplorer: return "Visit 5 different gyms"
        case .socialButterfly: return "Attend 3 community events"
        case .passCollector: return "Purchase 5 different pass types"
        case .fitnessMaster: return "Complete 50 workouts"
        case .specialEvent: return "Participate in a special gym event"
        case .limitedEdition: return "Rare limited edition bead"
        }
    }
    
    var defaultColorHex: String {
        switch self {
        case .firstCheckIn: return "#7d3e3a"
        case .streak3: return "#618e22"
        case .streak7: return "#f3c700"
        case .streak30: return "#f97c16"
        case .streak100: return "#bf1b16"
        case .earlyBird: return "#4a90d9"
        case .nightOwl: return "#6b5b95"
        case .weekendWarrior: return "#88b04b"
        case .gymExplorer: return "#d65076"
        case .socialButterfly: return "#45b8ac"
        case .passCollector: return "#e15d44"
        case .fitnessMaster: return "#5b5ea6"
        case .specialEvent: return "#9b2335"
        case .limitedEdition: return "#dfcfbe"
        }
    }
    
    var defaultRarity: BeadRarity {
        switch self {
        case .firstCheckIn: return .common
        case .streak3: return .common
        case .streak7: return .uncommon
        case .streak30: return .rare
        case .streak100: return .legendary
        case .earlyBird: return .uncommon
        case .nightOwl: return .uncommon
        case .weekendWarrior: return .uncommon
        case .gymExplorer: return .rare
        case .socialButterfly: return .rare
        case .passCollector: return .rare
        case .fitnessMaster: return .legendary
        case .specialEvent: return .epic
        case .limitedEdition: return .legendary
        }
    }
}

// MARK: - Bead Rarity
enum BeadRarity: String, Codable, CaseIterable {
    case common = "COMMON"
    case uncommon = "UNCOMMON"
    case rare = "RARE"
    case epic = "EPIC"
    case legendary = "LEGENDARY"
    
    var displayName: String {
        switch self {
        case .common: return "Common"
        case .uncommon: return "Uncommon"
        case .rare: return "Rare"
        case .epic: return "Epic"
        case .legendary: return "Legendary"
        }
    }
    
    var colorHex: String {
        switch self {
        case .common: return "#6d6f82"
        case .uncommon: return "#618e22"
        case .rare: return "#4a90d9"
        case .epic: return "#9b59b6"
        case .legendary: return "#f39c12"
        }
    }
    
    var dropRate: Double {
        switch self {
        case .common: return 0.60
        case .uncommon: return 0.25
        case .rare: return 0.10
        case .epic: return 0.04
        case .legendary: return 0.01
        }
    }
}

// MARK: - Bead Collection
struct BeadCollection: Codable {
    let userId: String
    var beads: [Bead]
    var totalBeads: Int {
        beads.count
    }
    var uniqueBeadTypes: Int {
        Set(beads.map { $0.type }).count
    }
    var lastUpdated: Date
    
    init(userId: String, beads: [Bead] = [], lastUpdated: Date = Date()) {
        self.userId = userId
        self.beads = beads
        self.lastUpdated = lastUpdated
    }
    
    func beadsByType(_ type: BeadType) -> [Bead] {
        beads.filter { $0.type == type }
    }
    
    func beadsByRarity(_ rarity: BeadRarity) -> [Bead] {
        beads.filter { $0.rarity == rarity }
    }
    
    func hasBeadType(_ type: BeadType) -> Bool {
        beads.contains { $0.type == type }
    }
    
    func countByType(_ type: BeadType) -> Int {
        beads.filter { $0.type == type }.count
    }
}

// MARK: - Bead Earn Event
struct BeadEarnEvent: Codable {
    let id: String
    let userId: String
    let beadType: BeadType
    let earnedAt: Date
    let checkInId: String?
    let gymId: String?
    let context: [String: String]?
}

// MARK: - Bead Sync Status
enum BeadSyncStatus: Equatable {
    case idle
    case syncing
    case synced
    case failed(Error)
    case partialSuccess(Int, Int) // successCount, failedCount
    
    static func == (lhs: BeadSyncStatus, rhs: BeadSyncStatus) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle), (.syncing, .syncing), (.synced, .synced):
            return true
        case (.failed, .failed):
            return true
        case (.partialSuccess(let l1, let l2), .partialSuccess(let r1, let r2)):
            return l1 == r1 && l2 == r2
        default:
            return false
        }
    }
}

// MARK: - Bead Upload Response
struct BeadUploadResponse: Codable {
    let success: Bool
    let beadId: String
    let serverBeadId: String?
    let errorMessage: String?
    let syncedAt: Date?
}

// MARK: - Bead Error
enum BeadError: Error, LocalizedError {
    case networkError
    case serverError(String)
    case decodingError
    case unauthorized
    case beadAlreadyExists
    case syncFailed(Int) // retry count
    case maxRetriesExceeded
    
    var errorDescription: String? {
        switch self {
        case .networkError:
            return "Network connection failed"
        case .serverError(let message):
            return "Server error: \(message)"
        case .decodingError:
            return "Failed to process server response"
        case .unauthorized:
            return "Please sign in to sync beads"
        case .beadAlreadyExists:
            return "Bead already exists in your collection"
        case .syncFailed(let count):
            return "Sync failed after \(count) attempts"
        case .maxRetriesExceeded:
            return "Maximum retry attempts exceeded"
        }
    }
}
