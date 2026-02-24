import { defineFunction } from '@aws-amplify/backend';

/**
 * Streak Aggregation Function
 * 
 * Handles:
 * - Streak calculation and updates
 * - Wellness summary generation
 * - Mood statistics aggregation
 * - Goal progress tracking
 */
export const streakAggregationFunction = defineFunction({
  name: 'streakAggregationFunction',
  entry: './handler.ts',
  environment: {
    // DynamoDB table names (set automatically by Amplify)
    DATA_GRAPHQL_ENDPOINT: process.env.DATA_GRAPHQL_ENDPOINT || '',
    
    // Streak configuration
    STREAK_BREAK_THRESHOLD_HOURS: '48', // Hours before streak breaks
    
    // Aggregation settings
    AGGREGATION_BATCH_SIZE: '100',
  },
  timeoutSeconds: 60,
  memoryMB: 1024,
});
