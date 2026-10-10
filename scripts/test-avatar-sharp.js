// Simple local test for the avatar-sharp route.
// Usage: node scripts/test-avatar-sharp.js /path/to/image.jpg
// Ensure your dev server is running at http://localhost:3000 and you're authenticated (cookie-based session).

const fs = require('fs').promises;
const path = require('path');

async function main() {
  const imagePath = process.argv[2] || process.env.IMAGE_PATH;
  if (!imagePath) {
    console.error('Usage: node scripts/test-avatar-sharp.js /path/to/image.jpg');
    process.exit(1);
  }

  const abs = path.resolve(imagePath);
  const buf = await fs.readFile(abs);
  const mime = guessMime(abs) || 'image/jpeg';

  // Node 18+ global FormData & Blob
  const form = new FormData();
  const blob = new Blob([buf], { type: mime });
  form.append('file', blob, path.basename(abs));
  form.append('filename', path.basename(abs));

  console.log('Uploading', abs, 'to /api/dashboard/avatar-sharp');

  const res = await fetch('http://localhost:3000/api/dashboard/avatar-sharp', {
    method: 'POST',
    body: form,
    // Note: this script does not attach cookies; run while authenticated in browser if you rely on cookies.
  });

  const text = await res.text();
  console.log('Status:', res.status);
  console.log(text);
}

function guessMime(file) {
  const ext = path.extname(file).toLowerCase().replace('.', '');
  const map = { jpg: 'image/jpeg', jpeg: 'image/jpeg', png: 'image/png', webp: 'image/webp', gif: 'image/gif', svg: 'image/svg+xml' };
  return map[ext];
}

main().catch((err) => { console.error(err); process.exit(1); });
