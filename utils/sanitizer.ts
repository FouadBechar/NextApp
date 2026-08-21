// Minimal server-side sanitizer: escape HTML to prevent XSS.
export function sanitizeText(input: string | null | undefined): string {
  if (!input) return '';
  // Convert to string and trim
  const s = String(input).trim();
  // Basic escape of HTML special characters
  return s
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#39;');
}

export function truncate(input: string | null | undefined, max = 20000) {
  if (!input) return '';
  const s = String(input);
  return s.length > max ? s.slice(0, max) : s;
}
