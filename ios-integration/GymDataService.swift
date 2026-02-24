import Foundation
import Amplify
import AWSAPIPlugin

/**
 * GymPass App - Gym Data Service
 * 
 * Handles all GraphQL operations for gym data:
 * - Gym browsing and search
 * - Pass management
 * - Check-ins
 * - User profile
 * - Community features
 */

@MainActor
public final class GymDataService: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published public var gyms: [Gym] = []
    @Published public var featuredGyms: [Gym] = []
    @Published public var userPasses: [UserPass] = []
    @Published public var activePasses: [UserPass] = []
    @Published public var checkInHistory: [CheckIn] = []
    @Published public var shopItems: [ShopItem] = []
    @Published public var communityPosts: [CommunityPost] = []
    @Published public var isLoading: Bool = false
    @Published public var error: Error?
    
    // MARK: - Singleton
    
    public static let shared = GymDataService()
    
    private init() {}
    
    // MARK: - Gym Operations
    
    /// List all gyms with pagination
    public func listGyms(limit: Int = 20, nextToken: String? = nil) async {
        isLoading = true
        defer { isLoading = false }
        
        let query = """
        query ListGyms($limit: Int, $nextToken: String) {
            listGyms(limit: $limit, nextToken: $nextToken) {
                items {
                    id
                    name
                    slug
                    description
                    shortDescription
                    address
                    city
                    state
                    zipCode
                    country
                    latitude
                    longitude
                    phoneNumber
                    email
                    website
                    logoUrl
                    coverImageUrl
                    galleryImages
                    hours
                    amenities
                    equipment
                    status
                    isFeatured
                    maxCapacity
                    currentOccupancy
                    averageRating
                    totalReviews
                    createdAt
                    updatedAt
                }
                nextToken
            }
        }
        """
        
        do {
            let result = try await Amplify.API.query(
                request: GraphQLRequest<
            String: any,
                responseType: ListGymsResponse.self,
                variables: ["limit": limit, "nextToken": nextToken as Any]
            ))
            
            switch result {
            case .success(let response):
                self.gyms = response.listGyms.items
            case .failure(let error):
                self.error = error
            }
        } catch {
            self.error = error
        }
    }
    
    /// Get gym by ID
    public func getGym(id: String) async -> Gym? {
        let query = """
        query GetGym($id: ID!) {
            getGym(id: $id) {
                id
                name
                slug
                description
                shortDescription
                address
                city
                state
                zipCode
                country
                latitude
                longitude
                phoneNumber
                email
                website
                logoUrl
                coverImageUrl
                galleryImages
                hours
                amenities
                equipment
                status
                isFeatured
                maxCapacity
                currentOccupancy
                averageRating
                totalReviews
                facilities {
                    items {
                        id
                        name
                        facilityType
                        description
                        imageUrl
                        capacity
                        currentUsers
                        isOpen
                    }
                }
                passes {
                    items {
                        id
                        name
                        description
                        passType
                        durationDays
                        price
                        originalPrice
                        features
                        includesClasses
                        includesPool
                        includesSpa
                        guestPassesIncluded
                        maxVisits
                        maxCheckInsPerDay
                        isActive
                    }
                }
                createdAt
                updatedAt
            }
        }
        """
        
        do {
            let result = try await Amplify.API.query(
                request: GraphQLRequest<
            String: any,
                responseType: GetGymResponse.self,
                variables: ["id": id]
            ))
            
            switch result {
            case .success(let response):
                return response.getGym
            case .failure(let error):
                self.error = error
                return nil
            }
        } catch {
            self.error = error
            return nil
        }
    }
    
    /// Search gyms by location
    public func searchGymsByLocation(
        latitude: Double,
        longitude: Double,
        radiusKm: Double = 10,
        limit: Int = 20
    ) async {
        isLoading = true
        defer { isLoading = false }
        
        let query = """
        query SearchGymsByLocation($latitude: Float!, $longitude: Float!, $radiusKm: Float, $limit: Int) {
            searchGymsByLocation(latitude: $latitude, longitude: $longitude, radiusKm: $radiusKm, limit: $limit) {
                id
                name
                slug
                description
                address
                city
                state
                latitude
                longitude
                phoneNumber
                logoUrl
                coverImageUrl
                amenities
                averageRating
                distance
            }
        }
        """
        
        do {
            let result = try await Amplify.API.query(
                request: GraphQLRequest<
            String: any,
                responseType: SearchGymsResponse.self,
                variables: [
                    "latitude": latitude,
                    "longitude": longitude,
                    "radiusKm": radiusKm,
                    "limit": limit
                ]
            ))
            
            switch result {
            case .success(let response):
                self.gyms = response.searchGymsByLocation
            case .failure(let error):
                self.error = error
            }
        } catch {
            self.error = error
        }
    }
    
    /// Get featured gyms
    public func getFeaturedGyms(limit: Int = 10) async {
        isLoading = true
        defer { isLoading = false }
        
        let query = """
        query GetFeaturedGyms($limit: Int) {
            getFeaturedGyms(limit: $limit) {
                id
                name
                slug
                description
                shortDescription
                address
                city
                state
                logoUrl
                coverImageUrl
                amenities
                averageRating
                totalReviews
            }
        }
        """
        
        do {
            let result = try await Amplify.API.query(
                request: GraphQLRequest<
            String: any,
                responseType: FeaturedGymsResponse.self,
                variables: ["limit": limit]
            ))
            
            switch result {
            case .success(let response):
                self.featuredGyms = response.getFeaturedGyms
            case .failure(let error):
                self.error = error
            }
        } catch {
            self.error = error
        }
    }
    
    // MARK: - Pass Operations
    
    /// Get available passes for a gym
    public func getGymPasses(gymId: String) async -> [Pass] {
        let query = """
        query GetGymPasses($gymId: ID!) {
            listPasses(filter: { gymId: { eq: $gymId }, isActive: { eq: true } }) {
                items {
                    id
                    name
                    description
                    passType
                    durationDays
                    price
                    originalPrice
                    currency
                    features
                    includesClasses
                    includesPool
                    includesSpa
                    guestPassesIncluded
                    maxVisits
                    maxCheckInsPerDay
                    validFrom
                    validUntil
                }
            }
        }
        """
        
        do {
            let result = try await Amplify.API.query(
                request: GraphQLRequest<
            String: any,
                responseType: GymPassesResponse.self,
                variables: ["gymId": gymId]
            ))
            
            switch result {
            case .success(let response):
                return response.listPasses.items
            case .failure(let error):
                self.error = error
                return []
            }
        } catch {
            self.error = error
            return []
        }
    }
    
    /// Purchase a pass
    public func purchasePass(
        passId: String,
        paymentMethodId: String,
        discountCode: String? = nil
    ) async -> UserPass? {
        isLoading = true
        defer { isLoading = false }
        
        guard let userId = AuthService.shared.currentUserId else {
            self.error = NSError(domain: "GymDataService", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])
            return nil
        }
        
        let mutation = """
        mutation PurchasePass($passId: ID!, $userId: ID!, $paymentMethodId: String!, $discountCode: String) {
            purchasePass(
                passId: $passId,
                userId: $userId,
                paymentMethodId: $paymentMethodId,
                discountCode: $discountCode
            ) {
                id
                qrCodeData
                qrCodeImageUrl
                status
                totalVisitsAllowed
                visitsUsed
                visitsRemaining
                purchaseDate
                activationDate
                expirationDate
                pass {
                    id
                    name
                    passType
                    gym {
                        id
                        name
                        logoUrl
                    }
                }
            }
        }
        """
        
        do {
            let result = try await Amplify.API.mutate(
                request: GraphQLRequest<
            String: any,
                responseType: PurchasePassResponse.self,
                variables: [
                    "passId": passId,
                    "userId": userId,
                    "paymentMethodId": paymentMethodId,
                    "discountCode": discountCode as Any
                ]
            ))
            
            switch result {
            case .success(let response):
                await fetchUserPasses()
                return response.purchasePass
            case .failure(let error):
                self.error = error
                return nil
            }
        } catch {
            self.error = error
            return nil
        }
    }
    
    /// Get user's passes
    public func fetchUserPasses() async {
        guard let userId = AuthService.shared.currentUserId else { return }
        
        let query = """
        query GetUserPasses($userId: ID!) {
            listUserPasses(filter: { userId: { eq: $userId } }) {
                items {
                    id
                    qrCodeData
                    qrCodeImageUrl
                    status
                    totalVisitsAllowed
                    visitsUsed
                    visitsRemaining
                    purchaseDate
                    activationDate
                    expirationDate
                    pass {
                        id
                        name
                        passType
                        durationDays
                        features
                    }
                    gym {
                        id
                        name
                        logoUrl
                        address
                    }
                }
            }
        }
        """
        
        do {
            let result = try await Amplify.API.query(
                request: GraphQLRequest<
            String: any,
                responseType: UserPassesResponse.self,
                variables: ["userId": userId]
            ))
            
            switch result {
            case .success(let response):
                self.userPasses = response.listUserPasses.items
                self.activePasses = response.listUserPasses.items.filter { $0.status == .active }
            case .failure(let error):
                self.error = error
            }
        } catch {
            self.error = error
        }
    }
    
    /// Get active passes
    public func fetchActivePasses() async {
        guard let userId = AuthService.shared.currentUserId else { return }
        
        let query = """
        query GetActivePasses($userId: ID!) {
            getActivePasses(userId: $userId) {
                id
                qrCodeData
                qrCodeImageUrl
                status
                visitsUsed
                visitsRemaining
                expirationDate
                pass {
                    id
                    name
                    passType
                }
                gym {
                    id
                    name
                    logoUrl
                }
            }
        }
        """
        
        do {
            let result = try await Amplify.API.query(
                request: GraphQLRequest<
            String: any,
                responseType: ActivePassesResponse.self,
                variables: ["userId": userId]
            ))
            
            switch result {
            case .success(let response):
                self.activePasses = response.getActivePasses
            case .failure(let error):
                self.error = error
            }
        } catch {
            self.error = error
        }
    }
    
    // MARK: - Check-in Operations
    
    /// Get check-in history
    public func fetchCheckInHistory(
        gymId: String? = nil,
        startDate: Date? = nil,
        endDate: Date? = nil
    ) async {
        guard let userId = AuthService.shared.currentUserId else { return }
        
        let query = """
        query GetCheckInHistory($userId: ID!, $gymId: ID, $startDate: AWSDate, $endDate: AWSDate) {
            getCheckInHistory(userId: $userId, gymId: $gymId, startDate: $startDate, endDate: $endDate) {
                id
                checkInTime
                checkOutTime
                status
                durationMinutes
                gym {
                    id
                    name
                    logoUrl
                    address
                }
                userPass {
                    pass {
                        name
                        passType
                    }
                }
            }
        }
        """
        
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withFullDate]
        
        do {
            let result = try await Amplify.API.query(
                request: GraphQLRequest<
            String: any,
                responseType: CheckInHistoryResponse.self,
                variables: [
                    "userId": userId,
                    "gymId": gymId as Any,
                    "startDate": startDate.map { dateFormatter.string(from: $0) } as Any,
                    "endDate": endDate.map { dateFormatter.string(from: $0) } as Any
                ]
            ))
            
            switch result {
            case .success(let response):
                self.checkInHistory = response.getCheckInHistory
            case .failure(let error):
                self.error = error
            }
        } catch {
            self.error = error
        }
    }
    
    // MARK: - Shop Operations
    
    /// Get shop items
    public func fetchShopItems(itemType: ShopItemType? = nil, limit: Int = 20) async {
        isLoading = true
        defer { isLoading = false }
        
        let query: String
        let variables: [String: Any]
        
        if let type = itemType {
            query = """
            query GetShopItemsByType($itemType: ShopItemType!, $limit: Int) {
                getShopItemsByType(itemType: $itemType, limit: $limit) {
                    id
                    name
                    itemType
                    description
                    shortDescription
                    imageUrl
                    price
                    originalPrice
                    currency
                    inStock
                    stockQuantity
                    tags
                    isFeatured
                    isNew
                    averageRating
                    totalReviews
                }
            }
            """
            variables = ["itemType": type.rawValue, "limit": limit]
        } else {
            query = """
            query ListShopItems($limit: Int) {
                listShopItems(limit: $limit) {
                    items {
                        id
                        name
                        itemType
                        description
                        shortDescription
                        imageUrl
                        price
                        originalPrice
                        currency
                        inStock
                        stockQuantity
                        tags
                        isFeatured
                        isNew
                        averageRating
                        totalReviews
                    }
                }
            }
            """
            variables = ["limit": limit]
        }
        
        do {
            let result = try await Amplify.API.query(
                request: GraphQLRequest<
            String: any,
                responseType: ShopItemsResponse.self,
                variables: variables
            ))
            
            switch result {
            case .success(let response):
                self.shopItems = response.listShopItems?.items ?? response.getShopItemsByType ?? []
            case .failure(let error):
                self.error = error
            }
        } catch {
            self.error = error
        }
    }
    
    // MARK: - Community Operations
    
    /// Get community posts
    public func fetchCommunityPosts(postType: PostType? = nil, limit: Int = 20) async {
        isLoading = true
        defer { isLoading = false }
        
        let filter = postType != nil ? "filter: { postType: { eq: \(postType!.rawValue) } }" : ""
        
        let query = """
        query ListCommunityPosts($limit: Int) {
            listCommunityPosts(limit: $limit, \(filter)) {
                items {
                    id
                    title
                    content
                    postType
                    imageUrl
                    videoUrl
                    likes
                    comments
                    shares
                    views
                    eventDate
                    eventLocation
                    maxAttendees
                    currentAttendees
                    isPinned
                    isActive
                    author {
                        id
                        firstName
                        lastName
                        displayName
                        avatarUrl
                    }
                    createdAt
                    updatedAt
                }
            }
        }
        """
        
        do {
            let result = try await Amplify.API.query(
                request: GraphQLRequest<
            String: any,
                responseType: CommunityPostsResponse.self,
                variables: ["limit": limit]
            ))
            
            switch result {
            case .success(let response):
                self.communityPosts = response.listCommunityPosts.items
            case .failure(let error):
                self.error = error
            }
        } catch {
            self.error = error
        }
    }
    
    /// Create community post
    public func createCommunityPost(
        title: String,
        content: String,
        postType: PostType = .general,
        imageUrl: String? = nil
    ) async -> CommunityPost? {
        guard let authorId = AuthService.shared.currentUserId else { return nil }
        
        let mutation = """
        mutation CreateCommunityPost($input: CreateCommunityPostInput!) {
            createCommunityPost(input: $input) {
                id
                title
                content
                postType
                imageUrl
                likes
                comments
                author {
                    id
                    firstName
                    lastName
                    displayName
                    avatarUrl
                }
                createdAt
            }
        }
        """
        
        let input: [String: Any] = [
            "title": title,
            "content": content,
            "postType": postType.rawValue,
            "authorId": authorId,
            "imageUrl": imageUrl as Any,
            "createdAt": ISO8601DateFormatter().string(from: Date()),
            "updatedAt": ISO8601DateFormatter().string(from: Date())
        ]
        
        do {
            let result = try await Amplify.API.mutate(
                request: GraphQLRequest<
            String: any,
                responseType: CreatePostResponse.self,
                variables: ["input": input]
            ))
            
            switch result {
            case .success(let response):
                await fetchCommunityPosts()
                return response.createCommunityPost
            case .failure(let error):
                self.error = error
                return nil
            }
        } catch {
            self.error = error
            return nil
        }
    }
    
    /// Join event
    public func joinEvent(eventId: String) async -> Bool {
        guard let userId = AuthService.shared.currentUserId else { return false }
        
        let mutation = """
        mutation JoinEvent($eventId: ID!, $userId: ID!) {
            joinEvent(eventId: $eventId, userId: $userId) {
                id
                status
            }
        }
        """
        
        do {
            let result = try await Amplify.API.mutate(
                request: GraphQLRequest<
            String: any,
                responseType: JoinEventResponse.self,
                variables: ["eventId": eventId, "userId": userId]
            ))
            
            switch result {
            case .success:
                return true
            case .failure(let error):
                self.error = error
                return false
            }
        } catch {
            self.error = error
            return false
        }
    }
}

// MARK: - Response Types

struct ListGymsResponse: Codable {
    let listGyms: GymList
}

struct GymList: Codable {
    let items: [Gym]
    let nextToken: String?
}

struct GetGymResponse: Codable {
    let getGym: Gym
}

struct SearchGymsResponse: Codable {
    let searchGymsByLocation: [Gym]
}

struct FeaturedGymsResponse: Codable {
    let getFeaturedGyms: [Gym]
}

struct GymPassesResponse: Codable {
    let listPasses: PassList
}

struct PassList: Codable {
    let items: [Pass]
}

struct PurchasePassResponse: Codable {
    let purchasePass: UserPass
}

struct UserPassesResponse: Codable {
    let listUserPasses: UserPassList
}

struct UserPassList: Codable {
    let items: [UserPass]
}

struct ActivePassesResponse: Codable {
    let getActivePasses: [UserPass]
}

struct CheckInHistoryResponse: Codable {
    let getCheckInHistory: [CheckIn]
}

struct ShopItemsResponse: Codable {
    let listShopItems: ShopItemList?
    let getShopItemsByType: [ShopItem]?
}

struct ShopItemList: Codable {
    let items: [ShopItem]
}

struct CommunityPostsResponse: Codable {
    let listCommunityPosts: CommunityPostList
}

struct CommunityPostList: Codable {
    let items: [CommunityPost]
}

struct CreatePostResponse: Codable {
    let createCommunityPost: CommunityPost
}

struct JoinEventResponse: Codable {
    let joinEvent: EventAttendee
}
