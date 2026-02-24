import Foundation
import CoreData

// MARK: - Bead Local Storage Protocol
protocol BeadLocalStorageProtocol {
    func saveBead(_ bead: Bead) async throws
    func getAllBeads(userId: String) async throws -> [Bead]
    func getBeadsByType(_ type: BeadType, userId: String) async throws -> [Bead]
    func getUnsyncedBeads(userId: String) async throws -> [Bead]
    func markAsSynced(beadId: String) async throws
    func updateBead(_ bead: Bead) async throws
    func deleteBead(beadId: String) async throws
    func getBeadById(_ id: String) async throws -> Bead?
    func clearAllBeads(userId: String) async throws
}

// MARK: - Bead Local Storage Implementation
final class BeadLocalStorage: BeadLocalStorageProtocol {
    
    // MARK: - Singleton
    static let shared = BeadLocalStorage()
    
    // MARK: - Properties
    private let userDefaults: UserDefaults
    private let beadsKey = "com.capybaragym.beads"
    private let queue = DispatchQueue(label: "com.capybaragym.beadstorage", qos: .userInitiated)
    
    // MARK: - Initialization
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }
    
    // MARK: - Save Bead
    func saveBead(_ bead: Bead) async throws {
        try await queue.async {
            var beads = try self.loadBeads()
            
            // Remove existing bead with same ID if exists
            beads.removeAll { $0.id == bead.id }
            
            // Add new bead
            beads.append(bead)
            
            // Save to UserDefaults
            try self.saveBeads(beads)
        }.value
    }
    
    // MARK: - Get All Beads
    func getAllBeads(userId: String) async throws -> [Bead] {
        try await queue.async {
            let beads = try self.loadBeads()
            return beads.filter { $0.userId == userId }
        }.value
    }
    
    // MARK: - Get Beads by Type
    func getBeadsByType(_ type: BeadType, userId: String) async throws -> [Bead] {
        try await queue.async {
            let beads = try self.loadBeads()
            return beads.filter { $0.userId == userId && $0.type == type }
        }.value
    }
    
    // MARK: - Get Unsynced Beads
    func getUnsyncedBeads(userId: String) async throws -> [Bead] {
        try await queue.async {
            let beads = try self.loadBeads()
            return beads.filter { $0.userId == userId && !$0.isSynced }
        }.value
    }
    
    // MARK: - Mark as Synced
    func markAsSynced(beadId: String) async throws {
        try await queue.async {
            var beads = try self.loadBeads()
            
            if let index = beads.firstIndex(where: { $0.id == beadId }) {
                beads[index].isSynced = true
                try self.saveBeads(beads)
            }
        }.value
    }
    
    // MARK: - Update Bead
    func updateBead(_ bead: Bead) async throws {
        try await queue.async {
            var beads = try self.loadBeads()
            
            if let index = beads.firstIndex(where: { $0.id == bead.id }) {
                beads[index] = bead
                try self.saveBeads(beads)
            }
        }.value
    }
    
    // MARK: - Delete Bead
    func deleteBead(beadId: String) async throws {
        try await queue.async {
            var beads = try self.loadBeads()
            beads.removeAll { $0.id == beadId }
            try self.saveBeads(beads)
        }.value
    }
    
    // MARK: - Get Bead by ID
    func getBeadById(_ id: String) async throws -> Bead? {
        try await queue.async {
            let beads = try self.loadBeads()
            return beads.first { $0.id == id }
        }.value
    }
    
    // MARK: - Clear All Beads
    func clearAllBeads(userId: String) async throws {
        try await queue.async {
            var beads = try self.loadBeads()
            beads.removeAll { $0.userId == userId }
            try self.saveBeads(beads)
        }.value
    }
    
    // MARK: - Private Helpers
    private func loadBeads() throws -> [Bead] {
        guard let data = userDefaults.data(forKey: beadsKey) else {
            return []
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode([Bead].self, from: data)
    }
    
    private func saveBeads(_ beads: [Bead]) throws {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(beads)
        userDefaults.set(data, forKey: beadsKey)
    }
}

// MARK: - File-Based Storage (Alternative for larger datasets)
final class BeadFileStorage: BeadLocalStorageProtocol {
    
    static let shared = BeadFileStorage()
    
    private let fileManager: FileManager
    private let documentsDirectory: URL
    private let beadsDirectory: URL
    
    init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
        self.documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        self.beadsDirectory = documentsDirectory.appendingPathComponent("Beads", isDirectory: true)
        
        // Create directory if needed
        try? fileManager.createDirectory(at: beadsDirectory, withIntermediateDirectories: true)
    }
    
    func saveBead(_ bead: Bead) async throws {
        let fileURL = beadsDirectory.appendingPathComponent("\(bead.id).json")
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(bead)
        try data.write(to: fileURL)
    }
    
    func getAllBeads(userId: String) async throws -> [Bead] {
        let files = try fileManager.contentsOfDirectory(at: beadsDirectory, includingPropertiesForKeys: nil)
        
        var beads: [Bead] = []
        for fileURL in files where fileURL.pathExtension == "json" {
            let data = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            if let bead = try? decoder.decode(Bead.self, from: data),
               bead.userId == userId {
                beads.append(bead)
            }
        }
        
        return beads
    }
    
    func getBeadsByType(_ type: BeadType, userId: String) async throws -> [Bead] {
        let allBeads = try await getAllBeads(userId: userId)
        return allBeads.filter { $0.type == type }
    }
    
    func getUnsyncedBeads(userId: String) async throws -> [Bead] {
        let allBeads = try await getAllBeads(userId: userId)
        return allBeads.filter { !$0.isSynced }
    }
    
    func markAsSynced(beadId: String) async throws {
        if let bead = try await getBeadById(beadId) {
            var updatedBead = bead
            updatedBead.isSynced = true
            try await saveBead(updatedBead)
        }
    }
    
    func updateBead(_ bead: Bead) async throws {
        try await saveBead(bead)
    }
    
    func deleteBead(beadId: String) async throws {
        let fileURL = beadsDirectory.appendingPathComponent("\(beadId).json")
        try? fileManager.removeItem(at: fileURL)
    }
    
    func getBeadById(_ id: String) async throws -> Bead? {
        let fileURL = beadsDirectory.appendingPathComponent("\(id).json")
        guard fileManager.fileExists(atPath: fileURL.path) else { return nil }
        
        let data = try Data(contentsOf: fileURL)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(Bead.self, from: data)
    }
    
    func clearAllBeads(userId: String) async throws {
        let beads = try await getAllBeads(userId: userId)
        for bead in beads {
            try await deleteBead(beadId: bead.id)
        }
    }
}
