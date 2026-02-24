import { defineAuth } from '@aws-amplify/backend';

/**
 * Gym Membership App Authentication Configuration
 * 
 * Features:
 * - Email/password with verification
 * - Apple Sign In (OAuth)
 * - Google Sign In (OAuth)
 * - Optional MFA (SMS/TOTP)
 * - Custom attributes for gym membership data
 */
export const auth = defineAuth({
  loginWith: {
    email: {
      verificationEmailStyle: 'CODE',
      verificationEmailSubject: 'Verify your GymPass account',
      verificationEmailBody: (code: string) => 
        `Welcome to GymPass! Your verification code is: ${code}. This code expires in 30 minutes.`,
    },
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
      apple: {
        clientId: process.env.APPLE_CLIENT_ID!,
        teamId: process.env.APPLE_TEAM_ID!,
        keyId: process.env.APPLE_KEY_ID!,
        privateKey: process.env.APPLE_PRIVATE_KEY!,
        scopes: ['name', 'email'],
        attributeMapping: {
          email: 'email',
          givenName: 'firstName',
          familyName: 'lastName',
        },
      },
      callbackUrls: [
        'gympass://callback',
        'https://your-domain.com/auth/callback',
      ],
      logoutUrls: [
        'gympass://logout',
        'https://your-domain.com/auth/logout',
      ],
    },
  },
  
  // Multi-Factor Authentication (Optional)
  multifactor: {
    mode: 'OPTIONAL',
    sms: true,
    totp: true,
  },
  
  // User attributes
  userAttributes: {
    // Standard attributes
    email: {
      required: true,
      mutable: true,
    },
    givenName: {
      required: true,
      mutable: true,
    },
    familyName: {
      required: true,
      mutable: true,
    },
    phoneNumber: {
      required: false,
      mutable: true,
    },
    birthdate: {
      required: false,
      mutable: true,
    },
    picture: {
      required: false,
      mutable: true,
    },
    
    // Custom attributes for gym app
    'custom:membership_tier': {
      dataType: 'String',
      mutable: true,
      maxLen: 20,
    },
    'custom:total_checkins': {
      dataType: 'Number',
      mutable: true,
    },
    'custom:preferred_gym_id': {
      dataType: 'String',
      mutable: true,
      maxLen: 50,
    },
    'custom:fitness_goals': {
      dataType: 'String',
      mutable: true,
      maxLen: 500,
    },
    'custom:emergency_contact': {
      dataType: 'String',
      mutable: true,
      maxLen: 100,
    },
  },
  
  // Password policy
  passwordPolicy: {
    minLength: 8,
    requireLowercase: true,
    requireUppercase: true,
    requireDigits: true,
    requireSymbols: true,
  },
  
  // Account recovery
  accountRecovery: 'EMAIL_ONLY',
  
  // Advanced security
  advancedSecurityMode: 'ENFORCED',
  
  // Device tracking
  deviceTracking: {
    challengeRequiredOnNewDevice: true,
    deviceOnlyRememberedOnUserPrompt: true,
  },
  
  // Groups for role-based access
  groups: [
    {
      name: 'GYM_ADMIN',
      description: 'Gym administrators who can manage their gym',
    },
    {
      name: 'GYM_STAFF',
      description: 'Gym staff who can validate passes and check-ins',
    },
    {
      name: 'MEMBER',
      description: 'Regular gym members',
    },
    {
      name: 'PREMIUM_MEMBER',
      description: 'Premium tier members with additional benefits',
    },
    {
      name: 'SUPER_ADMIN',
      description: 'Platform administrators',
    },
  ],
  
  // Triggers
  triggers: {
    preSignUp: undefined,
    postConfirmation: undefined,
    preAuthentication: undefined,
    postAuthentication: undefined,
    customMessage: undefined,
    defineAuthChallenge: undefined,
    createAuthChallenge: undefined,
    verifyAuthChallengeResponse: undefined,
    userMigration: undefined,
  },
});
