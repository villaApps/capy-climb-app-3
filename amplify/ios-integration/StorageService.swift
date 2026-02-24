//
//  StorageService.swift
//  Capybara Wellness
//
//  Storage service for S3 operations
//

import Foundation
import Amplify
import AWSS3StoragePlugin
import UIKit

/// Storage service for file operations
@MainActor
class StorageService: ObservableObject {
    
    static let shared = StorageService()
    
    @Published var uploadProgress: Double = 0
    @Published var isUploading = false
    
    private init() {}
    
    // MARK: - Avatar Upload
    
    /// Upload user avatar
    func uploadAvatar(_ image: UIImage) async throws -> String {
        guard let userId = AuthService.shared.currentUser?.userId else {
            throw StorageError.notAuthenticated
        }
        
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw StorageError.invalidImage
        }
        
        let key = "avatars/\(userId)/avatar.jpg"
        
        isUploading = true
        uploadProgress = 0
        
        defer {
            isUploading = false
            uploadProgress = 0
        }
        
        let result = try await Amplify.Storage.uploadData(
            key: key,
            data: imageData,
            options: .init(
                accessLevel: .protected,
                metadata: [
                    "contentType": "image/jpeg",
                    "userId": userId
                ]
            )
        )
        
        // Track progress
        for await progress in result.progress {
            self.uploadProgress = progress.fractionCompleted
        }
        
        return key
    }
    
    /// Download user avatar
    func downloadAvatar(for userId: String? = nil) async throws -> UIImage? {
        let targetUserId = userId ?? AuthService.shared.currentUser?.userId
        
        guard let id = targetUserId else {
            throw StorageError.notAuthenticated
        }
        
        let key = "avatars/\(id)/avatar.jpg"
        
        let result = try await Amplify.Storage.downloadData(
            key: key,
            options: .init(accessLevel: .protected)
        )
        
        let data = try await result.value
        return UIImage(data: data)
    }
    
    /// Get avatar URL
    func getAvatarURL(for userId: String? = nil) async throws -> URL? {
        let targetUserId = userId ?? AuthService.shared.currentUser?.userId
        
        guard let id = targetUserId else {
            throw StorageError.notAuthenticated
        }
        
        let key = "avatars/\(id)/avatar.jpg"
        
        let result = try await Amplify.Storage.getURL(
            key: key,
            options: .init(
                accessLevel: .protected,
                expires: 3600 // 1 hour
            )
        )
        
        return try await result.value
    }
    
    // MARK: - Journal Media
    
    /// Upload journal media (image or audio)
    func uploadJournalMedia(
        _ data: Data,
        filename: String,
        contentType: String
    ) async throws -> String {
        guard let userId = AuthService.shared.currentUser?.userId else {
            throw StorageError.notAuthenticated
        }
        
        let key = "journal-media/\(userId)/\(filename)"
        
        let result = try await Amplify.Storage.uploadData(
            key: key,
            data: data,
            options: .init(
                accessLevel: .private,
                metadata: ["contentType": contentType]
            )
        )
        
        _ = try await result.value
        return key
    }
    
    /// Upload journal image
    func uploadJournalImage(_ image: UIImage, filename: String? = nil) async throws -> String {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw StorageError.invalidImage
        }
        
        let actualFilename = filename ?? "\(UUID().uuidString).jpg"
        return try await uploadJournalMedia(
            imageData,
            filename: actualFilename,
            contentType: "image/jpeg"
        )
    }
    
    /// Download journal media
    func downloadJournalMedia(key: String) async throws -> Data {
        let result = try await Amplify.Storage.downloadData(
            key: key,
            options: .init(accessLevel: .private)
        )
        
        return try await result.value
    }
    
    // MARK: - Meditation Audio
    
    /// Upload meditation audio
    func uploadMeditationAudio(
        _ data: Data,
        filename: String
    ) async throws -> String {
        guard let userId = AuthService.shared.currentUser?.userId else {
            throw StorageError.notAuthenticated
        }
        
        let key = "meditation-audio/\(userId)/\(filename)"
        
        let result = try await Amplify.Storage.uploadData(
            key: key,
            data: data,
            options: .init(
                accessLevel: .protected,
                metadata: ["contentType": "audio/m4a"]
            )
        )
        
        _ = try await result.value
        return key
    }
    
    /// Get meditation audio URL
    func getMeditationAudioURL(key: String) async throws -> URL? {
        let result = try await Amplify.Storage.getURL(
            key: key,
            options: .init(
                accessLevel: .protected,
                expires: 3600
            )
        )
        
        return try await result.value
    }
    
    // MARK: - File Management
    
    /// List user's files
    func listFiles(path: String) async throws -> [StorageListResultItem] {
        guard let userId = AuthService.shared.currentUser?.userId else {
            throw StorageError.notAuthenticated
        }
        
        let prefix = "\(path)/\(userId)/"
        
        let result = try await Amplify.Storage.list(
            options: .init(
                accessLevel: .private,
                path: prefix
            )
        )
        
        return try await result.value.items
    }
    
    /// Delete a file
    func deleteFile(key: String) async throws {
        _ = try await Amplify.Storage.remove(
            key: key,
            options: .init(accessLevel: .private)
        )
    }
    
    /// Cancel ongoing upload
    func cancelUpload() {
        // Implementation depends on Amplify version
        uploadProgress = 0
        isUploading = false
    }
}

// MARK: - Errors

enum StorageError: LocalizedError {
    case notAuthenticated
    case invalidImage
    case uploadFailed
    case downloadFailed
    case fileNotFound
    
    var errorDescription: String? {
        switch self {
        case .notAuthenticated:
            return "User not authenticated"
        case .invalidImage:
            return "Invalid image data"
        case .uploadFailed:
            return "Failed to upload file"
        case .downloadFailed:
            return "Failed to download file"
        case .fileNotFound:
            return "File not found"
        }
    }
}
