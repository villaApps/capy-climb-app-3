import Foundation
import Combine

// MARK: - Bead View Model
@Observable
final class BeadViewModel {
    
    // MARK: - State
    enum State: Equatable {
        case idle
        case loading
        case loaded
        case error(String)
        case earningBead
        case beadEarned(Bead)
        case syncing
        case syncComplete(Int, Int) // success, failed
        
        static func == (lhs: State, rhs: State) -> Bool {
            switch (lhs, rhs) {
            case (.idle, .idle), (.loading, .loading), (.loaded, .loaded),
                 (.earningBead, .earningBead), (.syncing, .syncing):
                return true
            case (.error(let l), .error(let r)):
                return l == r
            case (.beadEarned, .beadEarned):
                return true
            case (.syncComplete(let l1, let l2), .syncComplete(let r1, let r2)):
                return l1 == r1 && l2 == r2
            default:
                return false
            }
        }
    }
    
    // MARK: - Properties
    private let beadService: BeadServiceProtocol
    private let authService: AuthServiceProtocol
    
    var state: State = .idle
    var beads: [Bead] = []
    var collection: BeadCollection?
    var selectedBead: Bead?
    var showEarnedAnimation: Bool = false
    var newlyEarnedBead: Bead?
    var syncProgress: Double = 0.0
    var pendingUploadCount: Int = 0
    
    // Filter and sort
    var selectedRarity: BeadRarity?
    var selectedType: BeadType?
    var sortOption: SortOption = .newest
    
    enum SortOption: String, CaseIterable {
        case newest = "Newest"
        case oldest = "Oldest"
        case rarity = "Rarity"
        case type = "Type"
        
        var icon: String {
            switch self {
            case .newest: return "arrow.down.circle"
            case .oldest: return "arrow.up.circle"
            case .rarity: return "star.circle"
            case .type: return "tag.circle"
            }
        }
    }
    
    // MARK: - Computed Properties
    var filteredBeads: [Bead] {
        var result = beads
        
        // Apply rarity filter
        if let rarity = selectedRarity {
            result = result.filter { $0.rarity == rarity }
        }
        
        // Apply type filter
        if let type = selectedType {
            result = result.filter { $0.type == type }
        }
        
        // Apply sorting
        switch sortOption {
        case .newest:
            result.sort { $0.earnedAt > $1.earnedAt }
        case .oldest:
            result.sort { $0.earnedAt < $1.earnedAt }
        case .rarity:
            result.sort { $0.rarity.dropRate < $1.rarity.dropRate }
        case .type:
            result.sort { $0.type.displayName < $1.type.displayName }
        }
        
        return result
    }
    
    var beadsByRarity: [BeadRarity: [Bead]] {
        Dictionary(grouping: beads, by: { $0.rarity })
    }
    
    var totalBeads: Int {
        collection?.totalBeads ?? 0
    }
    
    var uniqueBeadTypes: Int {
        collection?.uniqueBeadTypes ?? 0
    }
    
    var completionPercentage: Double {
        let totalPossible = BeadType.allCases.count
        guard totalPossible > 0 else { return 0 }
        return Double(uniqueBeadTypes) / Double(totalPossible) * 100
    }
    
    var unsyncedCount: Int {
        beads.filter { !$0.isSynced }.count
    }
    
    // MARK: - Initialization
    init(
        beadService: BeadServiceProtocol = BeadService(),
        authService: AuthServiceProtocol = AmplifyAuthService()
    ) {
        self.beadService = beadService
        self.authService = authService
    }
    
    // MARK: - Load Beads
    @MainActor
    func loadBeads() async {
        state = .loading
        
        do {
            beads = try await beadService.getUserBeads()
            collection = try await beadService.getBeadCollection()
            state = .loaded
        } catch {
            state = .error(error.localizedDescription)
        }
    }
    
    // MARK: - Earn Bead
    @MainActor
    func earnBead(_ type: BeadType, checkInId: String? = nil, gymId: String? = nil) async {
        state = .earningBead
        
        do {
            let bead = try await beadService.earnBead(type, checkInId: checkInId, gymId: gymId)
            beads.insert(bead, at: 0)
            newlyEarnedBead = bead
            showEarnedAnimation = true
            state = .beadEarned(bead)
            
            // Update collection
            collection = try? await beadService.getBeadCollection()
        } catch BeadError.beadAlreadyExists {
            state = .error("You already have this bead!")
        } catch {
            state = .error(error.localizedDescription)
        }
    }
    
    // MARK: - Sync Beads
    @MainActor
    func syncBeads() async {
        guard unsyncedCount > 0 else { return }
        
        state = .syncing
        syncProgress = 0.0
        
        do {
            let result = try await beadService.syncBeads()
            
            // Update local beads
            beads = try await beadService.getUserBeads()
            pendingUploadCount = result.failedCount
            
            state = .syncComplete(result.successCount, result.failedCount)
            syncProgress = 1.0
        } catch {
            state = .error("Sync failed: \(error.localizedDescription)")
            syncProgress = 0.0
        }
    }
    
    // MARK: - Check for New Beads
    @MainActor
    func checkForNewBeads(checkIn: CheckIn) async -> [BeadType] {
        do {
            let newTypes = try await beadService.checkForNewBeads(checkIn: checkIn)
            
            // Auto-earn any new beads
            for type in newTypes {
                await earnBead(type, checkInId: checkIn.id, gymId: checkIn.gymId)
            }
            
            return newTypes
        } catch {
            return []
        }
    }
    
    // MARK: - Delete Bead
    @MainActor
    func deleteBead(_ beadId: String) async {
        do {
            try await beadService.deleteBead(beadId)
            beads.removeAll { $0.id == beadId }
            collection = try? await beadService.getBeadCollection()
        } catch {
            state = .error("Failed to delete bead: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Filter Methods
    func filterByRarity(_ rarity: BeadRarity?) {
        selectedRarity = rarity
    }
    
    func filterByType(_ type: BeadType?) {
        selectedType = type
    }
    
    func setSortOption(_ option: SortOption) {
        sortOption = option
    }
    
    func clearFilters() {
        selectedRarity = nil
        selectedType = nil
        sortOption = .newest
    }
    
    // MARK: - Share Bead
    func shareBead(_ bead: Bead) -> String {
        return "I earned the \(bead.name) bead in Capybara Gym! 🏋️‍♂️✨ #CapybaraGym #\(bead.type.rawValue)"
    }
    
    // MARK: - Get Rarity Color
    func colorForRarity(_ rarity: BeadRarity) -> String {
        return rarity.colorHex
    }
    
    // MARK: - Get Progress for Bead Type
    func progressForType(_ type: BeadType) -> (current: Int, target: Int) {
        let count = beads.filter { $0.type == type }.count
        return (count, 1)
    }
}
