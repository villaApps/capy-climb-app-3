import type { Schema } from '../../data/resource';
import { SESClient, SendEmailCommand } from '@aws-sdk/client-ses';
import { SNSClient, PublishCommand } from '@aws-sdk/client-sns';

const sesClient = new SESClient({ region: process.env.SES_REGION || 'us-east-1' });
const snsClient = new SNSClient({ region: process.env.AWS_REGION || 'us-east-1' });

interface NotificationPayload {
  userId: string;
  type: 'PUSH' | 'EMAIL' | 'BOTH';
  title: string;
  body: string;
  data?: Record<string, unknown>;
  emailTemplate?: string;
  deviceTokens?: string[];
}

/**
 * Send email notification via SES
 */
async function sendEmailNotification(
  toEmail: string,
  subject: string,
  body: string,
  htmlBody?: string
): Promise<void> {
  const command = new SendEmailCommand({
    Source: process.env.SES_FROM_EMAIL,
    Destination: {
      ToAddresses: [toEmail],
    },
    Message: {
      Subject: {
        Data: subject,
        Charset: 'UTF-8',
      },
      Body: {
        Text: {
          Data: body,
          Charset: 'UTF-8',
        },
        ...(htmlBody && {
          Html: {
            Data: htmlBody,
            Charset: 'UTF-8',
          },
        }),
      },
    },
  });

  await sesClient.send(command);
}

/**
 * Send push notification via SNS
 */
async function sendPushNotification(
  deviceToken: string,
  title: string,
  body: string,
  data?: Record<string, unknown>
): Promise<void> {
  const platformApplicationArn = process.env.SNS_PLATFORM_APPLICATION_ARN;
  
  if (!platformApplicationArn) {
    console.warn('SNS Platform Application ARN not configured');
    return;
  }

  const message = JSON.stringify({
    APNS: JSON.stringify({
      aps: {
        alert: {
          title,
          body,
        },
        badge: 1,
        sound: 'default',
      },
      data,
    }),
    GCM: JSON.stringify({
      notification: {
        title,
        body,
      },
      data,
    }),
  });

  const command = new PublishCommand({
    Message: message,
    MessageStructure: 'json',
    TargetArn: deviceToken,
  });

  await snsClient.send(command);
}

/**
 * Main handler for notification function
 */
export const handler: Schema['notificationFunction']['functionHandler'] = async (event) => {
  console.log('Notification function invoked:', JSON.stringify(event, null, 2));

  try {
    const payload = event.arguments as unknown as NotificationPayload;
    
    if (!payload) {
      return {
        statusCode: 400,
        body: JSON.stringify({ error: 'Missing notification payload' }),
      };
    }

    const { userId, type, title, body, data, deviceTokens } = payload;

    // Send push notifications
    if ((type === 'PUSH' || type === 'BOTH') && deviceTokens && deviceTokens.length > 0) {
      const pushPromises = deviceTokens.map((token) =>
        sendPushNotification(token, title, body, data).catch((error) => {
          console.error(`Failed to send push to token ${token}:`, error);
        })
      );
      await Promise.all(pushPromises);
    }

    // Send email notification
    if (type === 'EMAIL' || type === 'BOTH') {
      // In production, fetch user's email from Cognito or database
      const userEmail = `${userId}@example.com`; // Placeholder
      await sendEmailNotification(
        userEmail,
        title,
        body,
        `<h1>${title}</h1><p>${body}</p>`
      );
    }

    return {
      statusCode: 200,
      body: JSON.stringify({
        success: true,
        message: 'Notification sent successfully',
        sentTo: {
          push: deviceTokens?.length || 0,
          email: type === 'EMAIL' || type === 'BOTH' ? 1 : 0,
        },
      }),
    };
  } catch (error) {
    console.error('Notification function error:', error);
    return {
      statusCode: 500,
      body: JSON.stringify({
        error: 'Failed to send notification',
        message: error instanceof Error ? error.message : 'Unknown error',
      }),
    };
  }
};

/**
 * Scheduled reminder handler
 * Triggered by EventBridge for daily reminders
 */
export const scheduledReminderHandler = async (): Promise<void> => {
  console.log('Processing scheduled reminders...');
  
  // In production:
  // 1. Query users with reminders enabled for current time
  // 2. Fetch their device tokens
  // 3. Send personalized reminders based on their preferences
  
  // Example reminder types:
  const reminderTypes = [
    { type: 'DAILY_REMINDER', title: 'How are you feeling?', body: 'Take a moment to check in with your mood.' },
    { type: 'MEDITATION_REMINDER', title: 'Time to meditate', body: 'Your daily meditation session is waiting for you.' },
    { type: 'JOURNAL_REMINDER', title: 'Journal time', body: 'Reflect on your day with a journal entry.' },
    { type: 'STREAK_REMINDER', title: 'Keep your streak alive!', body: 'Don\'t break your wellness streak!' },
  ];

  console.log('Reminder types configured:', reminderTypes);
};
