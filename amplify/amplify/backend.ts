import { defineBackend } from '@aws-amplify/backend';
import { auth } from './auth/resource.js';
import { data } from './data/resource.js';
import { storage } from './storage/resource.js';
import { notificationFunction } from './functions/notification/resource.js';
import { streakAggregationFunction } from './functions/streak-aggregation/resource.js';

/**
 * Capybara Wellness App - Amplify Gen 2 Backend
 * 
 * This backend provides:
 * - Authentication via Amazon Cognito
 * - GraphQL API for data operations
 * - S3 Storage for user media
 * - Lambda functions for notifications and data processing
 */
export const backend = defineBackend({
  auth,
  data,
  storage,
  notificationFunction,
  streakAggregationFunction,
});

// Add additional backend configurations
const { cfnUserPool } = backend.auth.resources.cfnResources;

// Enable advanced security features
if (cfnUserPool) {
  cfnUserPool.userPoolAddOns = {
    advancedSecurityMode: 'ENFORCED',
  };
}
