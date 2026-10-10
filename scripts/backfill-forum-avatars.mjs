import pkg from '@supabase/supabase-js';
const { createClient } = pkg;

const SUPABASE_URL = process.env.SUPABASE_URL || process.env.NEXT_PUBLIC_SUPABASE_URL;
const SUPABASE_SERVICE_ROLE_KEY = process.env.SUPABASE_SERVICE_ROLE_KEY || process.env.SUPABASE_SERVICE_ROLE_KEY;
const AVATAR_BUCKET = process.env.AVATAR_BUCKET || 'avatars';

if (!SUPABASE_URL || !SUPABASE_SERVICE_ROLE_KEY) {
  console.error('Missing SUPABASE_URL or SUPABASE_SERVICE_ROLE_KEY environment variables.');
  console.error('Example (PowerShell): $env:SUPABASE_URL="https://..."; $env:SUPABASE_SERVICE_ROLE_KEY="key"; node scripts/backfill-forum-avatars.mjs');
  process.exit(1);
}

const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY, {
  auth: { persistSession: false },
});

const BATCH_SIZE = 100;
const SLEEP_MS = 200; // small pause between updates to avoid bursts

function sleep(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

async function resolveAvatarUrl(profile) {
  if (!profile) return null;
  const avatarPath = profile.avatar_path || profile.avatarPath || null;
  if (!avatarPath) return null;

  // Normalize path
  const path = avatarPath.replace(/^\/+/, '');

  try {
    // Try public URL first (synchronous return)
    const { data: publicData } = supabase.storage.from(AVATAR_BUCKET).getPublicUrl(path);
    if (publicData && publicData.publicUrl) {
      return publicData.publicUrl;
    }
  } catch (err) {
    // ignore and try signed URL
  }

  try {
    const signed = await supabase.storage.from(AVATAR_BUCKET).createSignedUrl(path, 60 * 60);
    if (signed && signed.data && signed.data.signedUrl) return signed.data.signedUrl;
  } catch (err) {
    console.warn('createSignedUrl failed for', path, err?.message || err);
  }

  return null;
}

async function updateRowsForProfile(profile, dryRun = false, force = false) {
  const resolved = await resolveAvatarUrl(profile);
  const display = profile.full_name || profile.fullName || profile.username || profile.display_name || null;

  if (!resolved && !display) return { skipped: true };

  const updates = {};
  if (resolved) updates.author_avatar_url = resolved;
  // also persist the original storage path for traceability and future re-resolution
  if (profile.avatar_path) updates.author_avatar_path = profile.avatar_path;
  if (display) updates.author_display = display;

  if (dryRun) {
    return { dryRun: true, updates, profileId: profile.id };
  }

  // Persist the resolved avatar URL back to the profiles table when available.
  // Only write if the profile.avatar_url is not set (or if forced by CLI flag in future)
  if (resolved) {
    try {
      if (!profile.avatar_url || force) {
        const updProfileRes = await supabase.from('profiles').update({ avatar_url: resolved }).eq('id', profile.id);
        if (updProfileRes.error) {
          console.error('Error updating profiles for', profile.id, updProfileRes.error.message || updProfileRes.error);
        }
      }
    } catch (err) {
      console.error('Exception updating profile:', profile.id, err?.message || err);
    }
  }

  // Update threads
  const threadsRes = await supabase.from('forum_threads').update(updates).eq('author_id', profile.id).select('id', { head: false });
  if (threadsRes.error) {
    console.error('Error updating forum_threads for', profile.id, threadsRes.error.message || threadsRes.error);
  }

  // Update posts
  const postsRes = await supabase.from('forum_posts').update(updates).eq('author_id', profile.id).select('id', { head: false });
  if (postsRes.error) {
    console.error('Error updating forum_posts for', profile.id, postsRes.error.message || postsRes.error);
  }

  return {
    profileId: profile.id,
    threadsUpdated: threadsRes?.data?.length ?? 0,
    postsUpdated: postsRes?.data?.length ?? 0,
  };
}

async function ensureColumnsExist() {
  try {
    // Query information_schema for author_avatar_url in both tables
    const { data, error } = await supabase
      .from('information_schema.columns')
      .select('column_name, table_name')
      .in('table_name', ['forum_threads', 'forum_posts', 'profiles'])
      .in('column_name', ['author_avatar_url', 'avatar_url']);

    if (error) {
      console.warn('Could not query information_schema.columns:', error.message || error);
      return { ok: false, reason: 'query_failed' };
    }

    const found = new Set((data || []).map((r) => `${r.table_name}.${r.column_name}`));
    const threadsHas = found.has('forum_threads.author_avatar_url');
    const postsHas = found.has('forum_posts.author_avatar_url');
    const profilesHas = found.has('profiles.avatar_url');
    return { ok: threadsHas && postsHas && profilesHas, threadsHas, postsHas, profilesHas };
  } catch (err) {
    console.warn('Error checking columns:', err?.message || err);
    return { ok: false, reason: 'exception' };
  }
}

async function run(dryRun = false) {
  console.log('Starting forum avatar backfill' + (dryRun ? ' (dry-run)' : ''));

  let page = 0;
  let totalProcessed = 0;
  while (true) {
    const { data: profiles, error } = await supabase
      .from('profiles')
      .select('id, username, full_name, avatar_path, avatar_url')
      .range(page * BATCH_SIZE, (page + 1) * BATCH_SIZE - 1);

    if (error) {
      console.error('Error fetching profiles:', error.message || error);
      break;
    }

    if (!profiles || profiles.length === 0) {
      break;
    }

    console.log(`Processing batch ${page + 1} (${profiles.length} profiles)`);

    for (const profile of profiles) {
      try {
        const res = await updateRowsForProfile(profile, dryRun, force);
        totalProcessed++;
        if (dryRun) {
          console.log('Dry:', profile.id, res.updates);
        } else {
          console.log('Updated:', profile.id, 'threads:', res.threadsUpdated, 'posts:', res.postsUpdated);
        }
        await sleep(SLEEP_MS);
      } catch (err) {
        console.error('Failed for profile', profile.id, err?.message || err);
      }
    }

    page += 1;
  }

  console.log('Backfill complete. Profiles processed:', totalProcessed);
}

// CLI
const args = process.argv.slice(2);
const dryRun = args.includes('--dry-run') || args.includes('-n');
const force = args.includes('--force') || args.includes('-f');

(async () => {
  if (!force) {
    const info = await ensureColumnsExist();
    if (!info.ok) {
      const missing = [];
      if (!info.threadsHas) missing.push('forum_threads.author_avatar_url');
      if (!info.postsHas) missing.push('forum_posts.author_avatar_url');
      if (!info.profilesHas) missing.push('profiles.avatar_url');
      console.warn('Missing expected columns:', missing.join(', '));
      console.warn('- Apply the migration in `db/migrations/002_add_author_avatar_url.sql` before running the full backfill (for forum columns).');
      console.warn("- Re-run with '--force' to attempt updates anyway (not recommended). If `profiles.avatar_url` is missing, ensure your `profiles` table has this column.");
      process.exit(1);
    }
  }

  await run(dryRun);
})().catch((err) => {
  console.error('Fatal error during backfill:', err?.message || err);
  process.exit(1);
});
