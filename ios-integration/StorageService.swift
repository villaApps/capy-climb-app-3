import Foundation
import Amplify
import AWSS3StoragePlugin
import UIKit

/**
 * GymPass App - Storage Service
 * 
 * Handles all file storage operations:
 * - Upload user avatars
 * - Upload gym images
 * - Upload community content
 * - Download and cache images
 * - Generate pre-signed URLs
 */

@MainActor
public final class StorageService: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published public var uploadProgress: Double = 0
    @Published public var isUploading: Bool = false
    @Published public var error: Error?
    
    // MARK: - Singleton
    
    public static let shared = StorageService()
    
    private init() {}
    
    // MARK: - Upload Operations
    
    /// Upload user avatar
    public func uploadAvatar(
        image: UIImage,
        compressionQuality: CGFloat = 0.8
    ) async -> Result<String, Error> {
        guard let userId = AuthService.shared.currentUserId else {
            return .failure(StorageError.notAuthenticated)
        }
        
        guard let imageData = image.jpegData(compressionQuality: compressionQuality) else {
            return .failure(StorageError.invalidImage)
        }
        
        let key = "avatars/\(userId)/avatar_\(UUID().uuidString).jpg"
        
        return await uploadData(imageData, key: key, bucket: .userAvatars)
    }
    
    /// Upload community post image
    public func uploadCommunityImage(
        image: UIImage,
        compressionQuality: CGFloat = 0.8
    ) async -> Result<String, Error> {
        guard let userId = AuthService.shared.currentUserId else {
            return .failure(StorageError.notAuthenticated)
        }
        
        guard let imageData = image.jpegData(compressionQuality: compressionQuality) else {
            return .failure(StorageError.invalidImage)
        }
        
        let key = "posts/\(userId)/image_\(UUID().uuidString).jpg"
        
        return await uploadData(imageData, key: key, bucket: .communityContent)
    }
    
    /// Upload gym image (admin only)
    public func uploadGymImage(
        image: UIImage,
        gymId: String,
        compressionQuality: CGFloat = 0.8
    ) async -> Result<String, Error> {
        guard let imageData = image.jpegData(compressionQuality: compressionQuality) else {
            return .failure(StorageError.invalidImage)
        }
        
        let key = "gyms/\(gymId)/image_\(UUID().uuidString).jpg"
        
        return await uploadData(imageData, key: key, bucket: .gymImages)
    }
    
    /// Upload generic data
    private func uploadData(
        _ data: Data,
        key: String,
        bucket: StorageBucket
    ) async -> Result<String, Error> {
        isUploading = true
        uploadProgress = 0
        defer {
            isUploading = false
            uploadProgress = 0
        }
        
        let options = StorageUploadDataRequest.Options(
            accessLevel: .protected,
            metadata: [
                "Content-Type": "image/jpeg",
                "x-amz-meta-uploaded-by": AuthService.shared.currentUserId ?? "unknown"
            ]
        )
        
        do {
            let uploadTask = Amplify.Storage.uploadData(
                key: key,
                data: data,
                options: options
            )
            
            // Track progress
            Task {
                for await progress in await uploadTask.progress {
                    self.uploadProgress = progress.fractionCompleted
                }
            }
            
            let result = try await uploadTask.value
            print("✅ Uploaded to: \(result)")
            
            // Get the URL
            let urlResult = try await Amplify.Storage.getURL(key: key, options: .init())
            return .success(urlResult.absoluteString)
            
        } catch {
            self.error = error
            return .failure(error)
        }
    }
    
    // MARK: - Download Operations
    
    /// Download image data
    public func downloadImage(key: String) async -> Result<Data, Error> {
        do {
            let result = try await Amplify.Storage.downloadData(key: key, options: .init())
            return .success(result)
        } catch {
            self.error = error
            return .failure(error)
        }
    }
    
    /// Get pre-signed URL for an image
    public func getImageURL(key: String, expiresIn: Int = 3600) async -> Result<URL, Error> {
        do {
            let options = StorageGetURLRequest.Options(
                accessLevel: .guest,
                expires: expiresIn
            )
            let url = try await Amplify.Storage.getURL(key: key, options: options)
            return .success(url)
        } catch {
            self.error = error
            return .failure(error)
        }
    }
    
    // MARK: - Delete Operations
    
    /// Delete a file
    public func deleteFile(key: String) async -> Result<Void, Error> {
        do {
            try await Amplify.Storage.remove(key: key, options: .init())
            return .success(())
        } catch {
            self.error = error
            return .failure(error)
        }
    }
    
    /// Delete user avatar
    public func deleteAvatar(key: String) async -> Result<Void, Error> {
        guard AuthService.shared.currentUserId != nil else {
            return .failure(StorageError.notAuthenticated)
        }
        
        return await deleteFile(key: key)
    }
    
    // MARK: - List Operations
    
    /// List files in a path
    public func listFiles(path: String) async -> Result<[StorageListResult.Item], Error> {
        do {
            let result = try await Amplify.Storage.list(options: .init(path: path))
            return .success(result.items)
        } catch {
            self.error = error
            return .failure(error)
        }
    }
    
    // MARK: - Image Processing
    
    /// Resize image to target size
    public func resizeImage(_ image: UIImage, targetSize: CGSize) -> UIImage? {
        let size = image.size
        
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        let ratio = min(widthRatio, heightRatio)
        let newSize = CGSize(width: size.width * ratio, height: size.height * ratio)
        
        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
    
    /// Compress image to target file size
    public func compressImage(_ image: UIImage, maxFileSize: Int = 1024 * 1024) -> Data? {
        var compression: CGFloat = 1.0
        var imageData = image.jpegData(compressionQuality: compression)
        
        guard var data = imageData else { return nil }
        
        while data.count > maxFileSize && compression > 0.1 {
            compression -= 0.1
            if let compressed = image.jpegData(compressionQuality: compression) {
                data = compressed
            }
        }
        
        return data
    }
}

// MARK: - Storage Bucket Enum

enum StorageBucket {
    case gymImages
    case userAvatars
    case passQRCodes
    case shopItems
    case communityContent
    case documents
    
    var name: String {
        switch self {
        case .gymImages: return "gym-images"
        case .userAvatars: return "user-avatars"
        case .passQRCodes: return "pass-qr-codes"
        case .shopItems: return "shop-items"
        case .communityContent: return "community-content"
        case .documents: return "documents"
        }
    }
}

// MARK: - Storage Errors

enum StorageError: LocalizedError {
    case notAuthenticated
    case invalidImage
    case uploadFailed
    case downloadFailed
    case fileNotFound
    
    var errorDescription: String? {
        switch self {
        case .notAuthenticated:
            return "User is not authenticated"
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

// MARK: - Image Cache

public actor ImageCache {
    public static let shared = ImageCache()
    
    private var cache: NSCache<NSString, UIImage> = {
        let cache = NSCache<NSString, UIImage>()
        cache.countLimit = 100
        cache.totalCostLimit = 50 * 1024 * 1024 // 50MB
        return cache
    }()
    
    public func getImage(forKey key: String) -> UIImage? {
        cache.object(forKey: key as NSString)
    }
    
    public func setImage(_ image: UIImage, forKey key: String) {
        cache.setObject(image, forKey: key as NSString)
    }
    
    public func removeImage(forKey key: String) {
        cache.removeObject(forKey: key as NSString)
    }
    
    public func clearCache() {
        cache.removeAllObjects()
    }
}
