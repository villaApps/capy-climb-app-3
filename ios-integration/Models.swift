import Foundation

/**
 * GymPass App - Data Models
 * 
 * Swift models corresponding to the GraphQL schema
 */

// MARK: - Enums

public enum PassStatus: String, Codable, CaseIterable {
    case active = "ACTIVE"
    case used = "USED"
    case expired = "EXPIRED"
    case cancelled = "CANCELLED"
    case pending = "PENDING"
}

public enum PassType: String, Codable, CaseIterable {
    case day = "DAY"
    case week = "WEEK"
    case month = "MONTH"
    case quarter = "QUARTER"
    case year = "YEAR"
    case punchCard = "PUNCH_CARD"
    case guest = "GUEST"
    
    public var displayName: String {
        switch self {
        case .day: return "Day Pass"
        case .week: return "Week Pass"
        case .month: return "Month Pass"
        case .quarter: return "Quarterly Pass"
        case .year: return "Year Pass"
        case .punchCard: return "Punch Card"
        case .guest: return "Guest Pass"
        }
    }
}

public enum MembershipTier: String, Codable, CaseIterable {
    case free = "FREE"
    case basic = "BASIC"
    case premium = "PREMIUM"
    case elite = "ELITE"
    case corporate = "CORPORATE"
    
    public var displayName: String {
        switch self {
        case .free: return "Free"
        case .basic: return "Basic"
        case .premium: return "Premium"
        case .elite: return "Elite"
        case .corporate: return "Corporate"
        }
    }
}

public enum CheckInStatus: String, Codable {
    case checkedIn = "CHECKED_IN"
    case checkedOut = "CHECKED_OUT"
    case noShow = "NO_SHOW"
}

public enum GymStatus: String, Codable {
    case active = "ACTIVE"
    case inactive = "INACTIVE"
    case maintenance = "MAINTENANCE"
    case closed = "CLOSED"
}

public enum FacilityType: String, Codable {
    case cardio = "CARDIO"
    case strength = "STRENGTH"
    case pool = "POOL"
    case studio = "STUDIO"
    case court = "COURT"
    case spa = "SPA"
    case locker = "LOCKER"
    case parking = "PARKING"
}

public enum ShopItemType: String, Codable {
    case pass = "PASS"
    case merchandise = "MERCHANDISE"
    case supplement = "SUPPLEMENT"
    case service = "SERVICE"
    case giftCard = "GIFT_CARD"
}

public enum PostType: String, Codable {
    case general = "GENERAL"
    case event = "EVENT"
    case announcement = "ANNOUNCEMENT"
    case tip = "TIP"
    case challenge = "CHALLENGE"
}

// MARK: - Gym Model

public struct Gym: Identifiable, Codable {
    public let id: String
    public let name: String
    public let slug: String
    public let description: String?
    public let shortDescription: String?
    public let address: String
    public let city: String
    public let state: String
    public let zipCode: String
    public let country: String?
    public let latitude: Double?
    public let longitude: Double?
    public let phoneNumber: String?
    public let email: String?
    public let website: String?
    public let logoUrl: String?
    public let coverImageUrl: String?
    public let galleryImages: [String]?
    public let hours: GymHours?
    public let amenities: [String]?
    public let equipment: [String]?
    public let status: GymStatus?
    public let isFeatured: Bool?
    public let maxCapacity: Int?
    public let currentOccupancy: Int?
    public let averageRating: Double?
    public let totalReviews: Int?
    public let facilities: FacilityConnection?
    public let passes: PassConnection?
    public let createdAt: String
    public let updatedAt: String
    
    // Computed properties
    public var fullAddress: String {
        "\(address), \(city), \(state) \(zipCode)"
    }
    
    public var isOpen: Bool {
        status == .active
    }
    
    public var occupancyPercentage: Double {
        guard let max = maxCapacity, let current = currentOccupancy, max > 0 else { return 0 }
        return Double(current) / Double(max) * 100
    }
}

public struct GymHours: Codable {
    public let monday: DayHours?
    public let tuesday: DayHours?
    public let wednesday: DayHours?
    public let thursday: DayHours?
    public let friday: DayHours?
    public let saturday: DayHours?
    public let sunday: DayHours?
}

public struct DayHours: Codable {
    public let open: String?
    public let close: String?
    public let isClosed: Bool?
}

public struct FacilityConnection: Codable {
    public let items: [Facility]?
}

public struct PassConnection: Codable {
    public let items: [Pass]?
}

// MARK: - Pass Model

public struct Pass: Identifiable, Codable {
    public let id: String
    public let name: String
    public let description: String?
    public let passType: PassType
    public let durationDays: Int
    public let price: Double
    public let originalPrice: Double?
    public let currency: String?
    public let features: [String]?
    public let includesClasses: Bool?
    public let includesPool: Bool?
    public let includesSpa: Bool?
    public let guestPassesIncluded: Int?
    public let maxVisits: Int?
    public let maxCheckInsPerDay: Int?
    public let isActive: Bool?
    public let validFrom: String?
    public let validUntil: String?
    public let gymId: String?
    public let gym: Gym?
    
    // Computed properties
    public var formattedPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency ?? "USD"
        return formatter.string(from: NSNumber(value: price)) ?? "\(price)"
    }
    
    public var discountPercentage: Int? {
        guard let original = originalPrice, original > price else { return nil }
        return Int((original - price) / original * 100)
    }
}

// MARK: - UserPass Model

public struct UserPass: Identifiable, Codable {
    public let id: String
    public let qrCodeData: String
    public let qrCodeImageUrl: String?
    public let status: PassStatus
    public let totalVisitsAllowed: Int?
    public let visitsUsed: Int?
    public let visitsRemaining: Int?
    public let purchaseDate: String
    public let activationDate: String?
    public let expirationDate: String
    public let paymentId: String?
    public let paymentStatus: String?
    public let amountPaid: Double?
    public let discountApplied: Double?
    public let userId: String?
    public let user: User?
    public let passId: String?
    public let pass: Pass?
    public let gymId: String?
    public let gym: Gym?
    public let checkIns: CheckInConnection?
    public let createdAt: String?
    public let updatedAt: String?
    
    // Computed properties
    public var isValid: Bool {
        status == .active && !isExpired
    }
    
    public var isExpired: Bool {
        guard let expiration = expirationDate.toDate() else { return false }
        return Date() > expiration
    }
    
    public var daysUntilExpiration: Int {
        guard let expiration = expirationDate.toDate() else { return 0 }
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: Date(), to: expiration)
        return components.day ?? 0
    }
    
    public var formattedExpirationDate: String {
        expirationDate.toFormattedDate() ?? expirationDate
    }
}

public struct CheckInConnection: Codable {
    public let items: [CheckIn]?
}

// MARK: - CheckIn Model

public struct CheckIn: Identifiable, Codable {
    public let id: String
    public let checkInTime: String
    public let checkOutTime: String?
    public let status: CheckInStatus
    public let qrCodeScanned: String?
    public let validatedBy: String?
    public let validationMethod: String?
    public let checkInLatitude: Double?
    public let checkInLongitude: Double?
    public let checkOutLatitude: Double?
    public let checkOutLongitude: Double?
    public let durationMinutes: Int?
    public let notes: String?
    public let userId: String?
    public let user: User?
    public let gymId: String?
    public let gym: Gym?
    public let userPassId: String?
    public let userPass: UserPass?
    public let createdAt: String?
    public let updatedAt: String?
    
    // Computed properties
    public var formattedCheckInTime: String {
        checkInTime.toFormattedDateTime() ?? checkInTime
    }
    
    public var formattedDuration: String {
        guard let minutes = durationMinutes else { return "--" }
        let hours = minutes / 60
        let mins = minutes % 60
        if hours > 0 {
            return "\(hours)h \(mins)m"
        } else {
            return "\(mins)m"
        }
    }
}

// MARK: - Facility Model

public struct Facility: Identifiable, Codable {
    public let id: String
    public let name: String
    public let facilityType: FacilityType
    public let description: String?
    public let rules: String?
    public let imageUrl: String?
    public let capacity: Int?
    public let currentUsers: Int?
    public let isOpen: Bool?
    public let hours: GymHours?
    public let requiresBooking: Bool?
    public let equipmentList: [Equipment]?
    public let gymId: String?
    public let gym: Gym?
    
    // Computed properties
    public var occupancyPercentage: Double {
        guard let cap = capacity, let current = currentUsers, cap > 0 else { return 0 }
        return Double(current) / Double(cap) * 100
    }
    
    public var isAtCapacity: Bool {
        guard let cap = capacity, let current = currentUsers else { return false }
        return current >= cap
    }
}

public struct Equipment: Codable {
    public let name: String
    public let count: Int
    public let brand: String?
}

// MARK: - ShopItem Model

public struct ShopItem: Identifiable, Codable {
    public let id: String
    public let name: String
    public let itemType: ShopItemType
    public let description: String?
    public let shortDescription: String?
    public let imageUrl: String?
    public let galleryImages: [String]?
    public let price: Double
    public let originalPrice: Double?
    public let currency: String?
    public let inStock: Bool?
    public let stockQuantity: Int?
    public let linkedPassId: String?
    public let sku: String?
    public let weight: String?
    public let dimensions: String?
    public let tags: [String]?
    public let isFeatured: Bool?
    public let isNew: Bool?
    public let averageRating: Double?
    public let totalReviews: Int?
    
    // Computed properties
    public var formattedPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency ?? "USD"
        return formatter.string(from: NSNumber(value: price)) ?? "\(price)"
    }
}

// MARK: - CommunityPost Model

public struct CommunityPost: Identifiable, Codable {
    public let id: String
    public let title: String
    public let content: String
    public let postType: PostType
    public let imageUrl: String?
    public let videoUrl: String?
    public let likes: Int?
    public let comments: Int?
    public let shares: Int?
    public let views: Int?
    public let eventDate: String?
    public let eventLocation: String?
    public let eventGymId: String?
    public let maxAttendees: Int?
    public let currentAttendees: Int?
    public let isPinned: Bool?
    public let isActive: Bool?
    public let authorId: String?
    public let author: User?
    public let commentsList: CommentConnection?
    public let attendees: AttendeeConnection?
    public let createdAt: String
    public let updatedAt: String?
    
    // Computed properties
    public var isEvent: Bool {
        postType == .event
    }
    
    public var isEventFull: Bool {
        guard let max = maxAttendees, let current = currentAttendees else { return false }
        return current >= max
    }
    
    public var formattedEventDate: String? {
        eventDate?.toFormattedDateTime()
    }
}

public struct CommentConnection: Codable {
    public let items: [CommunityComment]?
}

public struct AttendeeConnection: Codable {
    public let items: [EventAttendee]?
}

// MARK: - CommunityComment Model

public struct CommunityComment: Identifiable, Codable {
    public let id: String
    public let postId: String
    public let authorId: String
    public let content: String
    public let likes: Int?
    public let parentCommentId: String?
    public let createdAt: String
    public let updatedAt: String?
}

// MARK: - EventAttendee Model

public struct EventAttendee: Identifiable, Codable {
    public let id: String
    public let eventId: String
    public let userId: String
    public let status: String
    public let registeredAt: String
}

// MARK: - User Model

public struct User: Identifiable, Codable {
    public let id: String
    public let email: String
    public let firstName: String
    public let lastName: String
    public let displayName: String?
    public let bio: String?
    public let avatarUrl: String?
    public let phoneNumber: String?
    public let dateOfBirth: String?
    public let membershipTier: MembershipTier?
    public let membershipStartDate: String?
    public let membershipEndDate: String?
    public let autoRenew: Bool?
    public let fitnessGoals: [String]?
    public let preferredWorkoutTime: String?
    public let emergencyContactName: String?
    public let emergencyContactPhone: String?
    public let totalCheckIns: Int?
    public let totalPassesPurchased: Int?
    public let favoriteGymId: String?
    public let notificationsEnabled: Bool?
    public let marketingEmailsEnabled: Bool?
    public let locationSharingEnabled: Bool?
    public let createdAt: String?
    public let updatedAt: String?
    public let lastLoginAt: String?
    
    // Computed properties
    public var fullName: String {
        "\(firstName) \(lastName)"
    }
    
    public var displayNameOrFullName: String {
        displayName ?? fullName
    }
    
    public var initials: String {
        let first = String(firstName.prefix(1))
        let last = String(lastName.prefix(1))
        return "\(first)\(last)".uppercased()
    }
}

// MARK: - Helper Extensions

extension String {
    func toDate(format: String = "yyyy-MM-dd'T'HH:mm:ss.SSSZ") -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter.date(from: self)
    }
    
    func toFormattedDate(format: String = "MMM d, yyyy") -> String? {
        guard let date = toDate() else { return nil }
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: date)
    }
    
    func toFormattedDateTime(format: String = "MMM d, yyyy 'at' h:mm a") -> String? {
        guard let date = toDate() else { return nil }
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: date)
    }
}
