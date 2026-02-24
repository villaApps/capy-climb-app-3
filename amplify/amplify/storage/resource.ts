import { defineStorage } from '@aws-amplify/backend';

/**
 * S3 Storage Configuration for Capybara Wellness App
 * 
 * Buckets:
 * - user-avatars: User profile pictures
 * - journal-media: Journal entry attachments (images, audio)
 * - meditation-audio: Meditation audio files
 * - app-assets: Static app assets (icons, badges, etc.)
 */
export const storage = defineStorage({
  name: 'capybaraWellnessStorage',
  
  // Access rules for different paths
  access: (allow) => ({
    // User avatars - owner only
    'avatars/{entity_id}/*': [
      allow.entity('identity').to(['read', 'write', 'delete']),
      allow.authenticated().to(['read']),
    ],
    
    // Journal media attachments - owner only
    'journal-media/{entity_id}/*': [
      allow.entity('identity').to(['read', 'write', 'delete']),
    ],
    
    // Meditation audio files - owner can upload, all authenticated can read
    'meditation-audio/{entity_id}/*': [
      allow.entity('identity').to(['read', 'write', 'delete']),
      allow.authenticated().to(['read']),
    ],
    
    // App assets - public read, admin write
    'app-assets/*': [
      allow.guest().to(['read']),
      allow.authenticated().to(['read']),
      allow.groups(['admin']).to(['read', 'write', 'delete']),
    ],
    
    // User exports - owner only
    'exports/{entity_id}/*': [
      allow.entity('identity').to(['read', 'write', 'delete']),
    ],
  }),
  
  // CORS configuration
  cors: [
    {
      maxAge: 300,
      allowedOrigins: ['*'],
      allowedHeaders: ['*'],
      allowedMethods: ['GET', 'PUT', 'POST', 'DELETE', 'HEAD'],
    },
  ],
  
  // Trigger functions for file processing
  triggers: {
    // onUpload: defineFunction({
    //   entry: './triggers/on-upload.ts',
    // }),
  },
});
