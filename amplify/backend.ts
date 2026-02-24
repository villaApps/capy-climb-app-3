import { defineBackend } from '@aws-amplify/backend';
import { auth } from './auth/resource';
import { data } from './data/resource';
import {
  gymImagesStorage,
  userAvatarsStorage,
  passQRCodesStorage,
  shopItemsStorage,
  communityContentStorage,
  documentsStorage,
} from './storage/resource';

/**
 * Gym Membership App - Amplify Gen 2 Backend Configuration
 * 
 * This is the main backend configuration file that ties together:
 * - Authentication (Cognito)
 * - Data/GraphQL API (AppSync)
 * - Storage (S3)
 * - Functions (Lambda)
 * 
 * Deploy with: npx amplify deploy
 */

const backend = defineBackend({
  // Authentication
  auth,
  
  // GraphQL API with all data models
  data,
  
  // Storage buckets
  gymImagesStorage,
  userAvatarsStorage,
  passQRCodesStorage,
  shopItemsStorage,
  communityContentStorage,
  documentsStorage,
});

// ============================================
// CUSTOM CONFIGURATIONS
// ============================================

// Get references to resources for additional configuration
const { cfnUserPool, cfnUserPoolClient } = backend.auth.resources;
const { cfnGraphQLApi, cfnGraphQLSchema } = backend.data.resources;

// ============================================
// COGNITO USER POOL CUSTOMIZATIONS
// ============================================

// Enable advanced security features
cfnUserPool.userPoolAddOns = {
  advancedSecurityMode: 'ENFORCED',
};

// Configure email settings
cfnUserPool.emailConfiguration = {
  emailSendingAccount: 'DEVELOPER',
  from: 'noreply@gympass-app.com',
  replyToEmailAddress: 'support@gympass-app.com',
  sourceArn: process.env.SES_EMAIL_ARN,
};

// Configure SMS settings
cfnUserPool.smsConfiguration = {
  snsCallerArn: process.env.SNS_SMS_ARN!,
  externalId: process.env.SNS_EXTERNAL_ID,
  snsRegion: process.env.AWS_REGION || 'us-east-1',
};

// User pool client OAuth settings
cfnUserPoolClient.supportedIdentityProviders = [
  'COGNITO',
  'Google',
  'SignInWithApple',
];

cfnUserPoolClient.allowedOAuthFlows = ['code', 'implicit'];
cfnUserPoolClient.allowedOAuthScopes = [
  'openid',
  'email',
  'profile',
  'aws.cognito.signin.user.admin',
];

// ============================================
// APPSYNC GRAPHQL API CUSTOMIZATIONS
// ============================================

// Enable logging
cfnGraphQLApi.logConfig = {
  cloudWatchLogsRoleArn: process.env.APPSYNC_LOGS_ROLE_ARN,
  excludeVerboseContent: false,
  fieldLogLevel: 'ERROR',
};

// Enable X-Ray tracing
cfnGraphQLApi.xrayEnabled = true;

// ============================================
// OUTPUTS
// ============================================

// Export backend outputs for frontend configuration
export const outputs = {
  Auth: {
    region: process.env.AWS_REGION || 'us-east-1',
    userPoolId: cfnUserPool.ref,
    userPoolClientId: cfnUserPoolClient.ref,
    identityPoolId: backend.auth.resources.cfnIdentityPool?.ref,
    oauth: {
      domain: `${cfnUserPool.ref}.auth.${process.env.AWS_REGION || 'us-east-1'}.amazoncognito.com`,
      scope: ['openid', 'email', 'profile'],
      redirectSignIn: ['gympass://callback'],
      redirectSignOut: ['gympass://logout'],
      responseType: 'code',
    },
  },
  API: {
    GraphQL: {
      endpoint: backend.data.graphqlUrl,
      region: process.env.AWS_REGION || 'us-east-1',
      defaultAuthMode: 'userPool',
      apiKey: backend.data.apiKey,
    },
  },
  Storage: {
    gymImages: {
      bucket: gymImagesStorage.bucketName,
      region: process.env.AWS_REGION || 'us-east-1',
    },
    userAvatars: {
      bucket: userAvatarsStorage.bucketName,
      region: process.env.AWS_REGION || 'us-east-1',
    },
    passQRCodes: {
      bucket: passQRCodesStorage.bucketName,
      region: process.env.AWS_REGION || 'us-east-1',
    },
    shopItems: {
      bucket: shopItemsStorage.bucketName,
      region: process.env.AWS_REGION || 'us-east-1',
    },
    communityContent: {
      bucket: communityContentStorage.bucketName,
      region: process.env.AWS_REGION || 'us-east-1',
    },
    documents: {
      bucket: documentsStorage.bucketName,
      region: process.env.AWS_REGION || 'us-east-1',
    },
  },
};

export default backend;
