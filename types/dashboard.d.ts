interface TrustedDevice {
  id: string;
  user_id?: string;
  token_hash?: string;
  created_at?: string;
  metadata?: any;
}

interface EmailPreferences {
  emailNotifications?: boolean;
  [key: string]: any;
}

interface UserProfile {
  id: string;
  full_name?: string | null;
  username?: string | null;
  avatar?: string | null;
  avatar_url?: string | null;
  avatar_path?: string | null;
  totp?: any | null;
  trustedDevice?: boolean;
}

interface Activity {
  id: string;
  title: string;
  description?: string;
  timestamp: string;
  metadata?: any;
  icon?: any;
}

// Response shape for upload APIs
interface AvatarUploadResponse {
  publicUrl?: string | null;
  path?: string | null;
  error?: { message?: string } | null;
}

interface ProfileApiResponse {
  profile?: UserProfile | null;
}

interface TrustedDevicesApiResponse {
  devices?: TrustedDevice[];
}

interface ActivitiesApiResponse {
  activities?: Activity[];
}
