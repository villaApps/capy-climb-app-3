import { type ClientSchema, a, defineData } from '@aws-amplify/backend';

/**
 * Gym Membership App - Data Schema
 * 
 * Models:
 * 1. User - Extended user profile with membership info
 * 2. Gym - Gym locations with details, amenities, images
 * 3. Pass - Different pass types (day, week, month, etc.)
 * 4. UserPass - User's purchased passes with status
 * 5. CheckIn - QR code check-in records
 * 6. Facility - Gym facilities/equipment
 * 7. ShopItem - Items available in shop
 * 8. Community - Community posts/events
 */

const schema = a.schema({
  
  // ============================================
  // ENUMS
  // ============================================
  
  PassStatus: a.enum(['ACTIVE', 'USED', 'EXPIRED', 'CANCELLED', 'PENDING']),
  PassType: a.enum(['DAY', 'WEEK', 'MONTH', 'QUARTER', 'YEAR', 'PUNCH_CARD', 'GUEST']),
  MembershipTier: a.enum(['FREE', 'BASIC', 'PREMIUM', 'ELITE', 'CORPORATE']),
  CheckInStatus: a.enum(['CHECKED_IN', 'CHECKED_OUT', 'NO_SHOW']),
  GymStatus: a.enum(['ACTIVE', 'INACTIVE', 'MAINTENANCE', 'CLOSED']),
  FacilityType: a.enum(['CARDIO', 'STRENGTH', 'POOL', 'STUDIO', 'COURT', 'SPA', 'LOCKER', 'PARKING']),
  ShopItemType: a.enum(['PASS', 'MERCHANDISE', 'SUPPLEMENT', 'SERVICE', 'GIFT_CARD']),
  PostType: a.enum(['GENERAL', 'EVENT', 'ANNOUNCEMENT', 'TIP', 'CHALLENGE']),
  
  // ============================================
  // MODEL 1: USER - Extended profile with membership info
  // ============================================
  User: a.model({
    // Identity
    id: a.id().required(),
    email: a.email().required(),
    
    // Profile
    firstName: a.string().required(),
    lastName: a.string().required(),
    displayName: a.string(),
    bio: a.string(),
    avatarUrl: a.url(),
    phoneNumber: a.phone(),
    dateOfBirth: a.date(),
    
    // Membership
    membershipTier: a.ref('MembershipTier').default('FREE'),
    membershipStartDate: a.date(),
    membershipEndDate: a.date(),
    autoRenew: a.boolean().default(false),
    
    // Fitness Profile
    fitnessGoals: a.string().array(),
    preferredWorkoutTime: a.time(),
    emergencyContactName: a.string(),
    emergencyContactPhone: a.phone(),
    
    // Stats
    totalCheckIns: a.integer().default(0),
    totalPassesPurchased: a.integer().default(0),
    favoriteGymId: a.string(),
    
    // Preferences
    notificationsEnabled: a.boolean().default(true),
    marketingEmailsEnabled: a.boolean().default(true),
    locationSharingEnabled: a.boolean().default(false),
    
    // Relations
    userPasses: a.hasMany('UserPass', 'userId'),
    checkIns: a.hasMany('CheckIn', 'userId'),
    communityPosts: a.hasMany('CommunityPost', 'authorId'),
    favorites: a.hasMany('UserFavorite', 'userId'),
    
    // Timestamps
    createdAt: a.datetime().required(),
    updatedAt: a.datetime().required(),
    lastLoginAt: a.datetime(),
  })
  .authorization((allow) => [
    allow.owner().to(['read', 'update', 'delete']),
    allow.groups(['SUPER_ADMIN']).to(['read', 'update', 'delete']),
    allow.authenticated().to(['read']),
  ]),
  
  // ============================================
  // MODEL 2: GYM - Gym locations with details, amenities, images
  // ============================================
  Gym: a.model({
    // Identity
    id: a.id().required(),
    name: a.string().required(),
    slug: a.string().required(),
    
    // Description
    description: a.string(),
    shortDescription: a.string(),
    
    // Location
    address: a.string().required(),
    city: a.string().required(),
    state: a.string().required(),
    zipCode: a.string().required(),
    country: a.string().default('US'),
    latitude: a.float(),
    longitude: a.float(),
    
    // Contact
    phoneNumber: a.phone(),
    email: a.email(),
    website: a.url(),
    
    // Media
    logoUrl: a.url(),
    coverImageUrl: a.url(),
    galleryImages: a.url().array(),
    
    // Details
    hours: a.json(), // { monday: { open: "06:00", close: "22:00" }, ... }
    amenities: a.string().array(),
    equipment: a.string().array(),
    
    // Status
    status: a.ref('GymStatus').default('ACTIVE'),
    isFeatured: a.boolean().default(false),
    
    // Capacity
    maxCapacity: a.integer(),
    currentOccupancy: a.integer().default(0),
    
    // Ratings
    averageRating: a.float().default(0),
    totalReviews: a.integer().default(0),
    
    // Relations
    passes: a.hasMany('Pass', 'gymId'),
    facilities: a.hasMany('Facility', 'gymId'),
    checkIns: a.hasMany('CheckIn', 'gymId'),
    reviews: a.hasMany('GymReview', 'gymId'),
    staff: a.hasMany('GymStaff', 'gymId'),
    
    // Timestamps
    createdAt: a.datetime().required(),
    updatedAt: a.datetime().required(),
  })
  .authorization((allow) => [
    allow.groups(['GYM_ADMIN', 'SUPER_ADMIN']).to(['read', 'update', 'delete']),
    allow.authenticated().to(['read']),
    allow.guest().to(['read']),
  ]),
  
  // ============================================
  // MODEL 3: PASS - Different pass types (day, week, month, etc.)
  // ============================================
  Pass: a.model({
    // Identity
    id: a.id().required(),
    name: a.string().required(),
    description: a.string(),
    
    // Type & Duration
    passType: a.ref('PassType').required(),
    durationDays: a.integer().required(),
    
    // Pricing
    price: a.float().required(),
    originalPrice: a.float(),
    currency: a.string().default('USD'),
    
    // Features
    features: a.string().array(),
    includesClasses: a.boolean().default(false),
    includesPool: a.boolean().default(false),
    includesSpa: a.boolean().default(false),
    guestPassesIncluded: a.integer().default(0),
    
    // Usage
    maxVisits: a.integer(), // null = unlimited
    maxCheckInsPerDay: a.integer().default(1),
    
    // Availability
    isActive: a.boolean().default(true),
    validFrom: a.date(),
    validUntil: a.date(),
    
    // Relations
    gymId: a.string().required(),
    gym: a.belongsTo('Gym', 'gymId'),
    userPasses: a.hasMany('UserPass', 'passId'),
    
    // Timestamps
    createdAt: a.datetime().required(),
    updatedAt: a.datetime().required(),
  })
  .authorization((allow) => [
    allow.groups(['GYM_ADMIN', 'SUPER_ADMIN']).to(['read', 'create', 'update', 'delete']),
    allow.authenticated().to(['read']),
    allow.guest().to(['read']),
  ]),
  
  // ============================================
  // MODEL 4: USERPASS - User's purchased passes with status
  // ============================================
  UserPass: a.model({
    // Identity
    id: a.id().required(),
    
    // QR Code for check-in
    qrCodeData: a.string().required(),
    qrCodeImageUrl: a.url(),
    
    // Status
    status: a.ref('PassStatus').default('PENDING'),
    
    // Usage tracking
    totalVisitsAllowed: a.integer(),
    visitsUsed: a.integer().default(0),
    visitsRemaining: a.integer(),
    
    // Validity
    purchaseDate: a.datetime().required(),
    activationDate: a.datetime(),
    expirationDate: a.datetime().required(),
    
    // Payment
    paymentId: a.string(),
    paymentStatus: a.string(),
    amountPaid: a.float(),
    discountApplied: a.float().default(0),
    
    // Relations
    userId: a.string().required(),
    user: a.belongsTo('User', 'userId'),
    passId: a.string().required(),
    pass: a.belongsTo('Pass', 'passId'),
    gymId: a.string().required(),
    checkIns: a.hasMany('CheckIn', 'userPassId'),
    
    // Timestamps
    createdAt: a.datetime().required(),
    updatedAt: a.datetime().required(),
  })
  .authorization((allow) => [
    allow.owner().to(['read', 'update']),
    allow.groups(['GYM_ADMIN', 'GYM_STAFF', 'SUPER_ADMIN']).to(['read', 'update']),
  ]),
  
  // ============================================
  // MODEL 5: CHECKIN - QR code check-in records
  // ============================================
  CheckIn: a.model({
    // Identity
    id: a.id().required(),
    
    // Check-in details
    checkInTime: a.datetime().required(),
    checkOutTime: a.datetime(),
    status: a.ref('CheckInStatus').default('CHECKED_IN'),
    
    // QR validation
    qrCodeScanned: a.string().required(),
    validatedBy: a.string(), // Staff member ID who validated
    validationMethod: a.enum(['QR_SCAN', 'MANUAL', 'NFC', 'BIOMETRIC']),
    
    // Location
    checkInLatitude: a.float(),
    checkInLongitude: a.float(),
    checkOutLatitude: a.float(),
    checkOutLongitude: a.float(),
    
    // Session
    durationMinutes: a.integer(),
    notes: a.string(),
    
    // Relations
    userId: a.string().required(),
    user: a.belongsTo('User', 'userId'),
    gymId: a.string().required(),
    gym: a.belongsTo('Gym', 'gymId'),
    userPassId: a.string().required(),
    userPass: a.belongsTo('UserPass', 'userPassId'),
    
    // Timestamps
    createdAt: a.datetime().required(),
    updatedAt: a.datetime().required(),
  })
  .authorization((allow) => [
    allow.owner().to(['read']),
    allow.groups(['GYM_ADMIN', 'GYM_STAFF', 'SUPER_ADMIN']).to(['read', 'create', 'update']),
  ]),
  
  // ============================================
  // MODEL 6: FACILITY - Gym facilities/equipment
  // ============================================
  Facility: a.model({
    // Identity
    id: a.id().required(),
    name: a.string().required(),
    
    // Type
    facilityType: a.ref('FacilityType').required(),
    
    // Description
    description: a.string(),
    rules: a.string(),
    
    // Media
    imageUrl: a.url(),
    
    // Capacity
    capacity: a.integer(),
    currentUsers: a.integer().default(0),
    
    // Availability
    isOpen: a.boolean().default(true),
    hours: a.json(),
    requiresBooking: a.boolean().default(false),
    
    // Equipment (for strength/cardio areas)
    equipmentList: a.json(), // [{ name: "Treadmill", count: 10, brand: "Life Fitness" }]
    
    // Relations
    gymId: a.string().required(),
    gym: a.belongsTo('Gym', 'gymId'),
    bookings: a.hasMany('FacilityBooking', 'facilityId'),
    
    // Timestamps
    createdAt: a.datetime().required(),
    updatedAt: a.datetime().required(),
  })
  .authorization((allow) => [
    allow.groups(['GYM_ADMIN', 'GYM_STAFF', 'SUPER_ADMIN']).to(['read', 'create', 'update', 'delete']),
    allow.authenticated().to(['read']),
  ]),
  
  // ============================================
  // MODEL 7: SHOPITEM - Items available in shop
  // ============================================
  ShopItem: a.model({
    // Identity
    id: a.id().required(),
    name: a.string().required(),
    
    // Type
    itemType: a.ref('ShopItemType').required(),
    
    // Description
    description: a.string(),
    shortDescription: a.string(),
    
    // Media
    imageUrl: a.url(),
    galleryImages: a.url().array(),
    
    // Pricing
    price: a.float().required(),
    originalPrice: a.float(),
    currency: a.string().default('USD'),
    
    // Inventory
    inStock: a.boolean().default(true),
    stockQuantity: a.integer(),
    
    // For passes
    linkedPassId: a.string(),
    
    // For merchandise/supplements
    sku: a.string(),
    weight: a.string(),
    dimensions: a.string(),
    
    // Features
    tags: a.string().array(),
    isFeatured: a.boolean().default(false),
    isNew: a.boolean().default(false),
    
    // Ratings
    averageRating: a.float().default(0),
    totalReviews: a.integer().default(0),
    
    // Relations
    reviews: a.hasMany('ShopItemReview', 'shopItemId'),
    
    // Timestamps
    createdAt: a.datetime().required(),
    updatedAt: a.datetime().required(),
  })
  .authorization((allow) => [
    allow.groups(['SUPER_ADMIN']).to(['read', 'create', 'update', 'delete']),
    allow.authenticated().to(['read']),
  ]),
  
  // ============================================
  // MODEL 8: COMMUNITY - Community posts/events
  // ============================================
  CommunityPost: a.model({
    // Identity
    id: a.id().required(),
    
    // Content
    title: a.string().required(),
    content: a.string().required(),
    postType: a.ref('PostType').default('GENERAL'),
    
    // Media
    imageUrl: a.url(),
    videoUrl: a.url(),
    
    // Engagement
    likes: a.integer().default(0),
    comments: a.integer().default(0),
    shares: a.integer().default(0),
    views: a.integer().default(0),
    
    // For events
    eventDate: a.datetime(),
    eventLocation: a.string(),
    eventGymId: a.string(),
    maxAttendees: a.integer(),
    currentAttendees: a.integer().default(0),
    
    // Status
    isPinned: a.boolean().default(false),
    isActive: a.boolean().default(true),
    
    // Relations
    authorId: a.string().required(),
    author: a.belongsTo('User', 'authorId'),
    commentsList: a.hasMany('CommunityComment', 'postId'),
    attendees: a.hasMany('EventAttendee', 'eventId'),
    
    // Timestamps
    createdAt: a.datetime().required(),
    updatedAt: a.datetime().required(),
  })
  .authorization((allow) => [
    allow.owner().to(['read', 'create', 'update', 'delete']),
    allow.groups(['SUPER_ADMIN']).to(['read', 'update', 'delete']),
    allow.authenticated().to(['read', 'create']),
  ]),
  
  // ============================================
  // SUPPORTING MODELS
  // ============================================
  
  // User Favorites (Gyms)
  UserFavorite: a.model({
    id: a.id().required(),
    userId: a.string().required(),
    gymId: a.string().required(),
    createdAt: a.datetime().required(),
  })
  .authorization((allow) => [
    allow.owner().to(['read', 'create', 'delete']),
  ]),
  
  // Gym Reviews
  GymReview: a.model({
    id: a.id().required(),
    gymId: a.string().required(),
    userId: a.string().required(),
    rating: a.integer().required(),
    title: a.string(),
    content: a.string(),
    images: a.url().array(),
    isVerified: a.boolean().default(false),
    helpfulCount: a.integer().default(0),
    createdAt: a.datetime().required(),
    updatedAt: a.datetime().required(),
  })
  .authorization((allow) => [
    allow.owner().to(['read', 'create', 'update', 'delete']),
    allow.authenticated().to(['read']),
    allow.groups(['SUPER_ADMIN']).to(['read', 'update', 'delete']),
  ]),
  
  // Gym Staff
  GymStaff: a.model({
    id: a.id().required(),
    gymId: a.string().required(),
    userId: a.string().required(),
    role: a.enum(['OWNER', 'MANAGER', 'TRAINER', 'RECEPTIONIST', 'MAINTENANCE']),
    isActive: a.boolean().default(true),
    joinedAt: a.datetime().required(),
    createdAt: a.datetime().required(),
  })
  .authorization((allow) => [
    allow.groups(['GYM_ADMIN', 'SUPER_ADMIN']).to(['read', 'create', 'update', 'delete']),
  ]),
  
  // Facility Booking
  FacilityBooking: a.model({
    id: a.id().required(),
    facilityId: a.string().required(),
    userId: a.string().required(),
    startTime: a.datetime().required(),
    endTime: a.datetime().required(),
    status: a.enum(['PENDING', 'CONFIRMED', 'CANCELLED', 'COMPLETED']),
    notes: a.string(),
    createdAt: a.datetime().required(),
  })
  .authorization((allow) => [
    allow.owner().to(['read', 'create', 'update', 'delete']),
    allow.groups(['GYM_ADMIN', 'GYM_STAFF']).to(['read', 'update']),
  ]),
  
  // Community Comments
  CommunityComment: a.model({
    id: a.id().required(),
    postId: a.string().required(),
    authorId: a.string().required(),
    content: a.string().required(),
    likes: a.integer().default(0),
    parentCommentId: a.string(), // For nested comments
    createdAt: a.datetime().required(),
    updatedAt: a.datetime().required(),
  })
  .authorization((allow) => [
    allow.owner().to(['read', 'create', 'update', 'delete']),
    allow.authenticated().to(['read']),
  ]),
  
  // Event Attendees
  EventAttendee: a.model({
    id: a.id().required(),
    eventId: a.string().required(),
    userId: a.string().required(),
    status: a.enum(['REGISTERED', 'ATTENDED', 'NO_SHOW', 'CANCELLED']),
    registeredAt: a.datetime().required(),
  })
  .authorization((allow) => [
    allow.owner().to(['read', 'create', 'update', 'delete']),
    allow.groups(['SUPER_ADMIN']).to(['read', 'update']),
  ]),
  
  // Shop Item Reviews
  ShopItemReview: a.model({
    id: a.id().required(),
    shopItemId: a.string().required(),
    userId: a.string().required(),
    rating: a.integer().required(),
    title: a.string(),
    content: a.string(),
    isVerifiedPurchase: a.boolean().default(false),
    createdAt: a.datetime().required(),
    updatedAt: a.datetime().required(),
  })
  .authorization((allow) => [
    allow.owner().to(['read', 'create', 'update', 'delete']),
    allow.authenticated().to(['read']),
  ]),
  
  // ============================================
  // QUERIES
  // ============================================
  
  // Search gyms by location
  searchGymsByLocation: a.query()
    .arguments({
      latitude: a.float().required(),
      longitude: a.float().required(),
      radiusKm: a.float().default(10),
      limit: a.integer().default(20),
    })
    .returns(a.ref('Gym').array())
    .authorization((allow) => [allow.authenticated(), allow.guest()]),
  
  // Get active passes for user
  getActivePasses: a.query()
    .arguments({
      userId: a.string().required(),
    })
    .returns(a.ref('UserPass').array())
    .authorization((allow) => [allow.authenticated()]),
  
  // Get pass history
  getPassHistory: a.query()
    .arguments({
      userId: a.string().required(),
      startDate: a.date(),
      endDate: a.date(),
    })
    .returns(a.ref('UserPass').array())
    .authorization((allow) => [allow.authenticated()]),
  
  // Get check-in history
  getCheckInHistory: a.query()
    .arguments({
      userId: a.string().required(),
      gymId: a.string(),
      startDate: a.date(),
      endDate: a.date(),
    })
    .returns(a.ref('CheckIn').array())
    .authorization((allow) => [allow.authenticated()]),
  
  // Validate QR code
  validateQRCode: a.query()
    .arguments({
      qrCode: a.string().required(),
      gymId: a.string().required(),
    })
    .returns(a.ref('UserPass'))
    .authorization((allow) => [allow.groups(['GYM_ADMIN', 'GYM_STAFF'])]),
  
  // Get featured gyms
  getFeaturedGyms: a.query()
    .arguments({
      limit: a.integer().default(10),
    })
    .returns(a.ref('Gym').array())
    .authorization((allow) => [allow.authenticated(), allow.guest()]),
  
  // Get shop items by type
  getShopItemsByType: a.query()
    .arguments({
      itemType: a.ref('ShopItemType').required(),
      limit: a.integer().default(20),
    })
    .returns(a.ref('ShopItem').array())
    .authorization((allow) => [allow.authenticated(), allow.guest()]),
  
  // ============================================
  // MUTATIONS
  // ============================================
  
  // Purchase pass
  purchasePass: a.mutation()
    .arguments({
      passId: a.string().required(),
      userId: a.string().required(),
      paymentMethodId: a.string().required(),
      discountCode: a.string(),
    })
    .returns(a.ref('UserPass'))
    .authorization((allow) => [allow.authenticated()]),
  
  // Process check-in
  processCheckIn: a.mutation()
    .arguments({
      qrCode: a.string().required(),
      gymId: a.string().required(),
      latitude: a.float(),
      longitude: a.float(),
    })
    .returns(a.ref('CheckIn'))
    .authorization((allow) => [allow.groups(['GYM_ADMIN', 'GYM_STAFF'])]),
  
  // Process check-out
  processCheckOut: a.mutation()
    .arguments({
      checkInId: a.string().required(),
      latitude: a.float(),
      longitude: a.float(),
    })
    .returns(a.ref('CheckIn'))
    .authorization((allow) => [allow.groups(['GYM_ADMIN', 'GYM_STAFF'])]),
  
  // Join event
  joinEvent: a.mutation()
    .arguments({
      eventId: a.string().required(),
      userId: a.string().required(),
    })
    .returns(a.ref('EventAttendee'))
    .authorization((allow) => [allow.authenticated()]),
  
  // Cancel event registration
  cancelEventRegistration: a.mutation()
    .arguments({
      eventId: a.string().required(),
      userId: a.string().required(),
    })
    .returns(a.boolean())
    .authorization((allow) => [allow.authenticated()]),
  
});

// Export type for frontend usage
export type Schema = ClientSchema<typeof schema>;

// Define data configuration
export const data = defineData({
  schema,
  authorizationModes: {
    defaultAuthorizationMode: 'userPool',
    apiKeyAuthorizationMode: {
      expiresInDays: 30,
    },
  },
});
