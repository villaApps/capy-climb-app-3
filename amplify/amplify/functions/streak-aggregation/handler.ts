import type { Schema } from '../../data/resource';

interface MoodStats {
  totalEntries: number;
  moodDistribution: Record<string, number>;
  averageIntensity: number;
  mostCommonMood: string;
  streakDays: number;
  weeklyTrend: Array<{
    date: string;
    mood: string;
    intensity: number;
  }>;
}

interface WellnessSummary {
  userProfileId: string;
  period: string;
  moodStats: MoodStats;
  meditationStats: {
    totalSessions: number;
    totalMinutes: number;
    averageSessionLength: number;
    completionRate: number;
  };
  journalStats: {
    totalEntries: number;
    totalWords: number;
    favoriteEntries: number;
  };
  streakInfo: {
    currentStreak: number;
    longestStreak: number;
    streakType: string;
  };
  goalsProgress: Array<{
    goalId: string;
    title: string;
    progress: number;
    achieved: boolean;
  }>;
}

/**
 * Calculate streak based on activity dates
 */
function calculateStreak(activityDates: string[]): {
  currentStreak: number;
  longestStreak: number;
  isActive: boolean;
} {
  if (!activityDates || activityDates.length === 0) {
    return { currentStreak: 0, longestStreak: 0, isActive: false };
  }

  // Sort dates in descending order
  const sortedDates = [...activityDates]
    .map((d) => new Date(d))
    .sort((a, b) => b.getTime() - a.getTime());

  const today = new Date();
  today.setHours(0, 0, 0, 0);

  const yesterday = new Date(today);
  yesterday.setDate(yesterday.getDate() - 1);

  let currentStreak = 0;
  let longestStreak = 0;
  let tempStreak = 0;
  let isActive = false;

  // Check if streak is active (activity today or yesterday)
  const lastActivity = sortedDates[0];
  lastActivity.setHours(0, 0, 0, 0);
  
  if (lastActivity.getTime() === today.getTime() || 
      lastActivity.getTime() === yesterday.getTime()) {
    isActive = true;
  }

  // Calculate current streak
  let checkDate = new Date(today);
  for (const date of sortedDates) {
    const activityDate = new Date(date);
    activityDate.setHours(0, 0, 0, 0);

    if (activityDate.getTime() === checkDate.getTime()) {
      currentStreak++;
      checkDate.setDate(checkDate.getDate() - 1);
    } else if (activityDate.getTime() < checkDate.getTime()) {
      break;
    }
  }

  // Calculate longest streak
  let prevDate: Date | null = null;
  for (const date of sortedDates) {
    const activityDate = new Date(date);
    activityDate.setHours(0, 0, 0, 0);

    if (!prevDate) {
      tempStreak = 1;
    } else {
      const diffDays = Math.floor(
        (prevDate.getTime() - activityDate.getTime()) / (1000 * 60 * 60 * 24)
      );
      if (diffDays === 1) {
        tempStreak++;
      } else if (diffDays > 1) {
        longestStreak = Math.max(longestStreak, tempStreak);
        tempStreak = 1;
      }
    }
    prevDate = activityDate;
  }
  longestStreak = Math.max(longestStreak, tempStreak, currentStreak);

  return { currentStreak, longestStreak, isActive };
}

/**
 * Aggregate mood statistics
 */
function aggregateMoodStats(moodEntries: Array<{
  mood: string;
  intensity: number;
  entryDate: string;
}>): MoodStats {
  if (!moodEntries || moodEntries.length === 0) {
    return {
      totalEntries: 0,
      moodDistribution: {},
      averageIntensity: 0,
      mostCommonMood: '',
      streakDays: 0,
      weeklyTrend: [],
    };
  }

  const moodDistribution: Record<string, number> = {};
  let totalIntensity = 0;
  let maxMoodCount = 0;
  let mostCommonMood = '';

  for (const entry of moodEntries) {
    // Count mood distribution
    moodDistribution[entry.mood] = (moodDistribution[entry.mood] || 0) + 1;
    
    // Track most common mood
    if (moodDistribution[entry.mood] > maxMoodCount) {
      maxMoodCount = moodDistribution[entry.mood];
      mostCommonMood = entry.mood;
    }

    // Sum intensity
    totalIntensity += entry.intensity || 0;
  }

  // Calculate weekly trend (last 7 days)
  const last7Days = moodEntries
    .slice(0, 7)
    .map((entry) => ({
      date: entry.entryDate,
      mood: entry.mood,
      intensity: entry.intensity || 0,
    }));

  // Calculate mood streak (consecutive days with mood entries)
  const uniqueDates = [...new Set(moodEntries.map((e) => e.entryDate))];
  const { currentStreak: streakDays } = calculateStreak(uniqueDates);

  return {
    totalEntries: moodEntries.length,
    moodDistribution,
    averageIntensity: Math.round((totalIntensity / moodEntries.length) * 10) / 10,
    mostCommonMood,
    streakDays,
    weeklyTrend: last7Days,
  };
}

/**
 * Main handler for streak aggregation function
 */
export const handler: Schema['streakAggregationFunction']['functionHandler'] = async (event) => {
  console.log('Streak aggregation function invoked:', JSON.stringify(event, null, 2));

  try {
    const { info, arguments: args } = event;
    const operation = info?.fieldName;

    switch (operation) {
      case 'getWellnessSummary': {
        return await getWellnessSummary(args);
      }
      case 'getMoodStats': {
        return await getMoodStats(args);
      }
      default: {
        return {
          statusCode: 400,
          body: JSON.stringify({ error: `Unknown operation: ${operation}` }),
        };
      }
    }
  } catch (error) {
    console.error('Streak aggregation error:', error);
    return {
      statusCode: 500,
      body: JSON.stringify({
        error: 'Aggregation failed',
        message: error instanceof Error ? error.message : 'Unknown error',
      }),
    };
  }
};

/**
 * Get comprehensive wellness summary
 */
async function getWellnessSummary(args: {
  userProfileId: string;
  startDate?: string;
  endDate?: string;
}): Promise<WellnessSummary> {
  const { userProfileId, startDate, endDate } = args;

  // In production, these would be actual database queries
  // For now, returning mock data structure
  
  const mockMoodEntries = [
    { mood: 'GOOD', intensity: 7, entryDate: '2024-01-15' },
    { mood: 'CALM', intensity: 8, entryDate: '2024-01-14' },
    { mood: 'AMAZING', intensity: 9, entryDate: '2024-01-13' },
    { mood: 'NEUTRAL', intensity: 5, entryDate: '2024-01-12' },
    { mood: 'GOOD', intensity: 6, entryDate: '2024-01-11' },
  ];

  const moodStats = aggregateMoodStats(mockMoodEntries);

  return {
    userProfileId,
    period: `${startDate || 'all'} to ${endDate || 'now'}`,
    moodStats,
    meditationStats: {
      totalSessions: 45,
      totalMinutes: 675,
      averageSessionLength: 15,
      completionRate: 92,
    },
    journalStats: {
      totalEntries: 32,
      totalWords: 15420,
      favoriteEntries: 5,
    },
    streakInfo: {
      currentStreak: 12,
      longestStreak: 28,
      streakType: 'OVERALL',
    },
    goalsProgress: [
      { goalId: '1', title: 'Daily Meditation', progress: 85, achieved: false },
      { goalId: '2', title: '7-Day Mood Streak', progress: 100, achieved: true },
      { goalId: '3', title: 'Journal 30 Days', progress: 60, achieved: false },
    ],
  };
}

/**
 * Get mood statistics for a specific period
 */
async function getMoodStats(args: {
  userProfileId: string;
  period: 'DAY' | 'WEEK' | 'MONTH' | 'YEAR';
}): Promise<MoodStats> {
  const { userProfileId, period } = args;

  // In production, query actual mood entries for the period
  console.log(`Getting mood stats for user ${userProfileId}, period: ${period}`);

  const mockEntries = [
    { mood: 'HAPPY', intensity: 8, entryDate: '2024-01-15' },
    { mood: 'CALM', intensity: 7, entryDate: '2024-01-14' },
    { mood: 'ENERGETIC', intensity: 9, entryDate: '2024-01-13' },
  ];

  return aggregateMoodStats(mockEntries);
}

/**
 * Update streaks for all users (scheduled task)
 */
export const updateAllStreaks = async (): Promise<void> => {
  console.log('Updating all user streaks...');
  
  // In production:
  // 1. Query all active users
  // 2. For each user, calculate streaks for each activity type
  // 3. Update streak records
  // 4. Send notifications for broken streaks
  
  const activityTypes = ['MOOD', 'JOURNAL', 'MEDITATION', 'OVERALL'];
  
  for (const type of activityTypes) {
    console.log(`Processing ${type} streaks...`);
    // Process streaks for this activity type
  }
};

/**
 * Check and break inactive streaks
 */
export const breakInactiveStreaks = async (): Promise<void> => {
  const thresholdHours = parseInt(process.env.STREAK_BREAK_THRESHOLD_HOURS || '48');
  const thresholdMs = thresholdHours * 60 * 60 * 1000;
  
  console.log(`Breaking streaks inactive for ${thresholdHours} hours...`);
  
  // In production:
  // 1. Find streaks where lastActivityAt is older than threshold
  // 2. Set isActive to false
  // 3. Reset currentCount to 0
  // 4. Optionally notify user
};
