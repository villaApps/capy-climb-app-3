import { defineStorage } from '@aws-amplify/backend';

/**
 * Gym Membership App - Storage Configuration
 * 
 * Buckets:
 * 1. gym-images - Gym photos, logos, cover images
 * 2. user-avatars - User profile pictures
 * 3. pass-qr-codes - Generated QR codes for passes
 * 4. shop-items - Shop item images
 * 5. community-content - Community post images/videos
 * 6. documents - Terms, policies, certificates
 */

// Main storage bucket for gym images
export const gymImagesStorage = defineStorage({
  name: 'gym-images',
  access: (allow) => ({
    // Gym admins can upload/manage their gym images
    'gyms/{entity_id}/*': [
      allow.groups(['GYM_ADMIN', 'SUPER_ADMIN']).to(['read', 'write', 'delete']),
      allow.authenticated().to(['read']),
      allow.guest().to(['read']),
    ],
    // Featured/promotional images managed by super admins
    'featured/*': [
      allow.groups(['SUPER_ADMIN']).to(['read', 'write', 'delete']),
      allow.authenticated().to(['read']),
      allow.guest().to(['read']),
    ],
    // Public gym gallery
    'public/*': [
      allow.authenticated().to(['read', 'write']),
      allow.guest().to(['read']),
    ],
  }),
});

// User avatars storage
export const userAvatarsStorage = defineStorage({
  name: 'user-avatars',
  access: (allow) => ({
    // Users can manage their own avatars
    'avatars/{entity_id}/*': [
      allow.entity('identity').to(['read', 'write', 'delete']),
      allow.authenticated().to(['read']),
    ],
    // Default avatars
    'defaults/*': [
      allow.authenticated().to(['read']),
      allow.guest().to(['read']),
    ],
  }),
});

// QR Codes storage for passes
export const passQRCodesStorage = defineStorage({
  name: 'pass-qr-codes',
  access: (allow) => ({
    // Users can view their own QR codes
    'codes/{entity_id}/*': [
      allow.entity('identity').to(['read']),
      allow.groups(['GYM_ADMIN', 'GYM_STAFF', 'SUPER_ADMIN']).to(['read']),
    ],
    // Staff can generate/validate QR codes
    'temp/*': [
      allow.groups(['GYM_ADMIN', 'GYM_STAFF', 'SUPER_ADMIN']).to(['read', 'write', 'delete']),
    ],
  }),
});

// Shop items storage
export const shopItemsStorage = defineStorage({
  name: 'shop-items',
  access: (allow) => ({
    // Super admins manage shop items
    'products/*': [
      allow.groups(['SUPER_ADMIN']).to(['read', 'write', 'delete']),
      allow.authenticated().to(['read']),
      allow.guest().to(['read']),
    ],
    // Categories
    'categories/*': [
      allow.groups(['SUPER_ADMIN']).to(['read', 'write', 'delete']),
      allow.authenticated().to(['read']),
      allow.guest().to(['read']),
    ],
  }),
});

// Community content storage
export const communityContentStorage = defineStorage({
  name: 'community-content',
  access: (allow) => ({
    // Users can manage their own community content
    'posts/{entity_id}/*': [
      allow.entity('identity').to(['read', 'write', 'delete']),
      allow.authenticated().to(['read']),
    ],
    // Events
    'events/*': [
      allow.groups(['SUPER_ADMIN']).to(['read', 'write', 'delete']),
      allow.authenticated().to(['read']),
    ],
    // Shared community assets
    'shared/*': [
      allow.authenticated().to(['read', 'write']),
    ],
  }),
});

// Documents storage
export const documentsStorage = defineStorage({
  name: 'documents',
  access: (allow) => ({
    // Terms and policies
    'legal/*': [
      allow.groups(['SUPER_ADMIN']).to(['read', 'write', 'delete']),
      allow.authenticated().to(['read']),
      allow.guest().to(['read']),
    ],
    // Gym certificates and licenses
    'certificates/{entity_id}/*': [
      allow.groups(['GYM_ADMIN', 'SUPER_ADMIN']).to(['read', 'write', 'delete']),
    ],
    // User documents (waivers, medical forms)
    'user-docs/{entity_id}/*': [
      allow.entity('identity').to(['read', 'write', 'delete']),
      allow.groups(['GYM_ADMIN', 'SUPER_ADMIN']).to(['read']),
    ],
  }),
});

// Export all storage configurations
export const storage = {
  gymImages: gymImagesStorage,
  userAvatars: userAvatarsStorage,
  passQRCodes: passQRCodesStorage,
  shopItems: shopItemsStorage,
  communityContent: communityContentStorage,
  documents: documentsStorage,
};
