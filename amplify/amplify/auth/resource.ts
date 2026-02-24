import { defineAuth } from '@aws-amplify/backend';

/**
 * Authentication Configuration for Capybara Wellness App
 * 
 * Features:
 * - Email-based signup/signin
 * - Social login (Apple, Google)
 * - Multi-Factor Authentication (MFA)
 * - Password recovery
 * - User profile attributes
 */
export const auth = defineAuth({
  loginWith: {
    email: {
      verificationEmailStyle: 'CODE',
      verificationEmailSubject: 'Welcome to Capybara Wellness - Verify your email',
      verificationEmailBody: (createCode) => 
        `Welcome to Capybara Wellness! Your verification code is: ${createCode()}`,
    },
    // Social providers configuration
    externalProviders: {
      google: {
        clientId: process.env.GOOGLE_CLIENT_ID!,
        clientSecret: process.env.GOOGLE_CLIENT_SECRET!,
        scopes: ['openid', 'email', 'profile'],
        attributeMapping: {
          email: 'email',
          givenName: 'given_name',
          familyName: 'family_name',
          picture: 'picture',
        },
      },
      signInWithApple: {
        clientId: process.env.APPLE_CLIENT_ID!,
        keyId: process.env.APPLE_KEY_ID!,
        privateKey: process.env.APPLE_PRIVATE_KEY!,
        teamId: process.env.APPLE_TEAM_ID!,
        scopes: ['email', 'name'],
        attributeMapping: {
          email: 'email',
          givenName: 'firstName',
          familyName: 'lastName',
        },
      },
      callbackUrls: [
        'capybarawellness://callback',
        'http://localhost:3000/auth/callback',
      ],
      logoutUrls: [
        'capybarawellness://logout',
        'http://localhost:3000/auth/logout',
      ],
    },
  },
  
  // Multi-Factor Authentication
  multifactor: {
    mode: 'OPTIONAL',
    sms: true,
    totp: true,
  },
  
  // User attributes
  userAttributes: {
    // Profile information
    givenName: {
      mutable: true,
      required: false,
    },
    familyName: {
      mutable: true,
      required: false,
    },
    nickname: {
      mutable: true,
      required: false,
    },
    birthdate: {
      mutable: true,
      required: false,
    },
    gender: {
      mutable: true,
      required: false,
    },
    phoneNumber: {
      mutable: true,
      required: false,
    },
    // Profile picture
    picture: {
      mutable: true,
      required: false,
    },
    // Preferred language
    preferredUsername: {
      mutable: true,
      required: false,
    },
    // Custom attributes for wellness app
    profile: {
      mutable: true,
      required: false,
    },
  },
  
  // Password policy
  passwordPolicy: {
    minimumLength: 8,
    requireLowercase: true,
    requireUppercase: true,
    requireNumbers: true,
    requireSpecialCharacters: true,
  },
  
  // Account recovery
  accountRecovery: 'EMAIL_ONLY',
  
  // Device tracking
  deviceTracking: {
    challengeRequiredOnNewDevice: true,
    deviceOnlyRememberedOnUserPrompt: true,
  },
  
  // Email sending configuration
  senders: {
    fromEmail: 'noreply@capybarawellness.app',
    fromName: 'Capybara Wellness',
    replyTo: 'support@capybarawellness.app',
  },
});
