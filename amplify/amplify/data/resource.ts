import { type ClientSchema, a, defineData } from '@aws-amplify/backend';

/**
 * Data Schema for Capybara Wellness App
 * 
 * Models:
 * - UserProfile: Extended user information
 * - MoodEntry: Daily mood tracking
 * - JournalEntry: Personal journal entries
 * - MeditationSession: Meditation practice tracking
 * - Goal: User goals and achievements
 * - Streak: Streak tracking for habits
 * - Tag: Categorization tags
 * - Notification: User notifications
 */
const schema = a.schema({
  
  // ==================== ENUMS ====================
  
  MoodType: a.enum([
    'AMAZING',      // 😄
    'GOOD',         // 🙂
    'NEUTRAL',      // 😐
    'BAD',          // 😕
    'TERRIBLE',     // 😢
    'ANXIOUS',      // 😰
    'STRESSED',     // 😫
    'CALM',         // 😌
    'ENERGETIC',    // ⚡
    'TIRED',        // 😴
  ]),
  
  MeditationType: a.enum([
    'BREATHING',
    'BODY_SCAN',
    'LOVING_KINDNESS',
    'MINDFULNESS',
    'GUIDED',
    'SILENT',
    'SLEEP',
    'FOCUS',
  ]),
  
  GoalType: a.enum([
    'DAILY_MOOD',
    'DAILY_JOURNAL',
    'DAILY_MEDITATION',
    'WEEKLY_MEDITATION',
    'STREAK_GOAL',
    'CUSTOM',
  ]),
  
  GoalStatus: a.enum([
    'ACTIVE',
    'COMPLETED',
    'ARCHIVED',
  ]),
  
  NotificationType: a.enum([
    'DAILY_REMINDER',
    'STREAK_REMINDER',
    'GOAL_ACHIEVED',
    'WEEKLY_SUMMARY',
    'MEDITATION_REMINDER',
    'JOURNAL_REMINDER',
    'SYSTEM',
  ]),
  
  // ==================== MODELS ====================
  
  /**
   * User Profile - Extended user information
   * Links to Cognito user via owner field
   */
  UserProfile: a
    .model({
      // Identity
      id: a.id().required(),
      owner: a.string().required(),
      
      // Basic Info
      displayName: a.string(),
      bio: a.string(),
      avatarUrl: a.string(),
      
      // Preferences
      preferredLanguage: a.string().default('en'),
      timezone: a.string().default('UTC'),
      theme: a.enum(['LIGHT', 'DARK', 'AUTO']).default('AUTO'),
      
      // Notification preferences
      dailyReminderTime: a.time(),
      meditationReminderTime: a.time(),
      journalReminderTime: a.time(),
      enablePushNotifications: a.boolean().default(true),
      enableEmailNotifications: a.boolean().default(true),
      
      // Wellness preferences
      meditationGoalMinutes: a.integer().default(10),
      dailyJournalGoal: a.boolean().default(true),
      dailyMoodCheckGoal: a.boolean().default(true),
      
      // Stats (computed via functions)
      currentStreak: a.integer().default(0),
      longestStreak: a.integer().default(0),
      totalMeditationMinutes: a.integer().default(0),
      totalJournalEntries: a.integer().default(0),
      totalMoodEntries: a.integer().default(0),
      
      // Relationships
      moodEntries: a.hasMany('MoodEntry', 'userProfileId'),
      journalEntries: a.hasMany('JournalEntry', 'userProfileId'),
      meditationSessions: a.hasMany('MeditationSession', 'userProfileId'),
      goals: a.hasMany('Goal', 'userProfileId'),
      streaks: a.hasMany('Streak', 'userProfileId'),
      notifications: a.hasMany('Notification', 'userProfileId'),
      
      // Metadata
      createdAt: a.datetime().required(),
      updatedAt: a.datetime().required(),
      lastActiveAt: a.datetime(),
    })
    .authorization((allow) => [
      allow.owner().to(['read', 'create', 'update', 'delete']),
      allow.authenticated().to(['read']),
    ]),
  
  /**
   * Mood Entry - Daily mood tracking
   */
  MoodEntry: a
    .model({
      id: a.id().required(),
      owner: a.string().required(),
      
      // Mood data
      mood: a.ref('MoodType').required(),
      intensity: a.integer().validate((v) => v.min(1).max(10)),
      notes: a.string(),
      
      // Context
      tags: a.string().array(),
      triggers: a.string().array(),
      activities: a.string().array(),
      
      // Location (optional, for insights)
      location: a.string(),
      weather: a.string(),
      
      // Relationships
      userProfileId: a.id().required(),
      userProfile: a.belongsTo('UserProfile', 'userProfileId'),
      
      // Timestamp (user-selected, not auto)
      entryDate: a.date().required(),
      entryTime: a.time(),
      
      createdAt: a.datetime().required(),
      updatedAt: a.datetime().required(),
    })
    .authorization((allow) => [
      allow.owner().to(['read', 'create', 'update', 'delete']),
    ]),
  
  /**
   * Journal Entry - Personal journal entries
   */
  JournalEntry: a
    .model({
      id: a.id().required(),
      owner: a.string().required(),
      
      // Content
      title: a.string(),
      content: a.string().required(),
      
      // Mood at time of writing
      mood: a.ref('MoodType'),
      moodIntensity: a.integer().validate((v) => v.min(1).max(10)),
      
      // Categorization
      tags: a.string().array(),
      category: a.enum(['GRATITUDE', 'REFLECTION', 'GOALS', 'DREAMS', 'DAILY', 'VENTING', 'OTHER']),
      
      // Media attachments
      mediaUrls: a.string().array(),
      
      // Relationships
      userProfileId: a.id().required(),
      userProfile: a.belongsTo('UserProfile', 'userProfileId'),
      
      // Timestamp
      entryDate: a.date().required(),
      
      // Metadata
      isFavorite: a.boolean().default(false),
      wordCount: a.integer(),
      
      createdAt: a.datetime().required(),
      updatedAt: a.datetime().required(),
    })
    .authorization((allow) => [
      allow.owner().to(['read', 'create', 'update', 'delete']),
    ]),
  
  /**
   * Meditation Session - Track meditation practice
   */
  MeditationSession: a
    .model({
      id: a.id().required(),
      owner: a.string().required(),
      
      // Session details
      type: a.ref('MeditationType').required(),
      title: a.string(),
      description: a.string(),
      
      // Duration
      plannedDuration: a.integer().required(), // in minutes
      actualDuration: a.integer(), // in minutes (may differ from planned)
      
      // Status
      completed: a.boolean().default(false),
      completionPercentage: a.integer().validate((v) => v.min(0).max(100)),
      
      // Experience
      moodBefore: a.ref('MoodType'),
      moodAfter: a.ref('MoodType'),
      notes: a.string(),
      
      // Audio/Guided content
      audioUrl: a.string(),
      guideName: a.string(),
      
      // Relationships
      userProfileId: a.id().required(),
      userProfile: a.belongsTo('UserProfile', 'userProfileId'),
      
      // Timestamp
      sessionDate: a.date().required(),
      startedAt: a.datetime(),
      endedAt: a.datetime(),
      
      createdAt: a.datetime().required(),
      updatedAt: a.datetime().required(),
    })
    .authorization((allow) => [
      allow.owner().to(['read', 'create', 'update', 'delete']),
    ]),
  
  /**
   * Goal - User goals and achievements
   */
  Goal: a
    .model({
      id: a.id().required(),
      owner: a.string().required(),
      
      // Goal details
      title: a.string().required(),
      description: a.string(),
      type: a.ref('GoalType').required(),
      status: a.ref('GoalStatus').default('ACTIVE'),
      
      // Target
      targetValue: a.integer(), // e.g., 7 days, 30 minutes
      currentValue: a.integer().default(0),
      unit: a.string(), // 'days', 'minutes', 'entries', etc.
      
      // Timeframe
      startDate: a.date().required(),
      endDate: a.date(),
      
      // Progress tracking
      progressPercentage: a.integer().default(0),
      lastUpdatedAt: a.datetime(),
      
      // Achievement
      achievedAt: a.datetime(),
      achievementBadge: a.string(),
      
      // Relationships
      userProfileId: a.id().required(),
      userProfile: a.belongsTo('UserProfile', 'userProfileId'),
      
      createdAt: a.datetime().required(),
      updatedAt: a.datetime().required(),
    })
    .authorization((allow) => [
      allow.owner().to(['read', 'create', 'update', 'delete']),
    ]),
  
  /**
   * Streak - Track consecutive activity streaks
   */
  Streak: a
    .model({
      id: a.id().required(),
      owner: a.string().required(),
      
      // Streak type
      type: a.enum(['MOOD', 'JOURNAL', 'MEDITATION', 'OVERALL']).required(),
      
      // Current streak
      currentCount: a.integer().default(0),
      longestCount: a.integer().default(0),
      
      // Dates
      startedAt: a.date().required(),
      lastActivityAt: a.date().required(),
      longestStreakStartedAt: a.date(),
      longestStreakEndedAt: a.date(),
      
      // Status
      isActive: a.boolean().default(true),
      
      // History (simplified - could be separate model)
      activityDates: a.string().array(), // Array of dates in YYYY-MM-DD format
      
      // Relationships
      userProfileId: a.id().required(),
      userProfile: a.belongsTo('UserProfile', 'userProfileId'),
      
      createdAt: a.datetime().required(),
      updatedAt: a.datetime().required(),
    })
    .authorization((allow) => [
      allow.owner().to(['read', 'create', 'update', 'delete']),
    ]),
  
  /**
   * Notification - User notifications
   */
  Notification: a
    .model({
      id: a.id().required(),
      owner: a.string().required(),
      
      // Content
      type: a.ref('NotificationType').required(),
      title: a.string().required(),
      body: a.string().required(),
      
      // Data payload
      data: a.json(),
      actionUrl: a.string(),
      
      // Status
      isRead: a.boolean().default(false),
      isDelivered: a.boolean().default(false),
      
      // Timing
      scheduledFor: a.datetime(),
      deliveredAt: a.datetime(),
      readAt: a.datetime(),
      
      // Relationships
      userProfileId: a.id().required(),
      userProfile: a.belongsTo('UserProfile', 'userProfileId'),
      
      createdAt: a.datetime().required(),
      updatedAt: a.datetime().required(),
    })
    .authorization((allow) => [
      allow.owner().to(['read', 'create', 'update', 'delete']),
    ]),
  
  // ==================== QUERIES ====================
  
  /**
   * Get user wellness summary
   */
  getWellnessSummary: a
    .query()
    .arguments({
      userProfileId: a.id().required(),
      startDate: a.date(),
      endDate: a.date(),
    })
    .returns(a.json())
    .authorization((allow) => [allow.owner()])
    .handler(a.handler.function('streakAggregationFunction')),
  
  /**
   * Get mood statistics
   */
  getMoodStats: a
    .query()
    .arguments({
      userProfileId: a.id().required(),
      period: a.enum(['DAY', 'WEEK', 'MONTH', 'YEAR']).required(),
    })
    .returns(a.json())
    .authorization((allow) => [allow.owner()])
    .handler(a.handler.function('streakAggregationFunction')),
  
  // ==================== SUBSCRIPTIONS ====================
  
  /**
   * Subscribe to mood entry changes
   */
  onMoodEntryCreated: a
    .subscription()
    .for(a.ref('MoodEntry').mutations(['create']))
    .authorization((allow) => [allow.owner()]),
    
});

export type Schema = ClientSchema<typeof schema>;

export const data = defineData({
  schema,
  authorizationModes: {
    defaultAuthorizationMode: 'userPool',
    apiKeyAuthorizationMode: {
      expiresInDays: 30,
    },
  },
});
