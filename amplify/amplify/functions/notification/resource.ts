import { defineFunction } from '@aws-amplify/backend';

/**
 * Notification Function
 * 
 * Handles:
 * - Push notification delivery
 * - Email notifications
 * - Scheduled reminders
 * - Notification aggregation
 */
export const notificationFunction = defineFunction({
  name: 'notificationFunction',
  entry: './handler.ts',
  environment: {
    // SES Configuration
    SES_FROM_EMAIL: 'noreply@capybarawellness.app',
    SES_REGION: 'us-east-1',
    
    // SNS Configuration for Push
    SNS_PLATFORM_APPLICATION_ARN: process.env.SNS_PLATFORM_APPLICATION_ARN || '',
    
    // App Configuration
    APP_NAME: 'Capybara Wellness',
    APP_URL: 'https://capybarawellness.app',
  },
  timeoutSeconds: 30,
  memoryMB: 512,
});
