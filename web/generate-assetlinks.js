console.log('Genearating assetlinks.json...');

import { mkdirSync, writeFileSync } from 'fs';
import { join } from 'path';

const assetLinksBase64 = process.env.ASSET_LINKS_JSON;

if (assetLinksBase64) {
  const assetLinksJson = Buffer.from(assetLinksBase64, 'base64').toString('utf-8');

  const dirPath = join(process.cwd(), './public/.well-known');
  const filePath = join(dirPath, 'assetlinks.json');

  mkdirSync(dirPath, { recursive: true });

  writeFileSync(filePath, assetLinksJson);
  console.log('assetlinks.json file generated sucessfully on .well-known/');
} else {
  console.error('ASSET_LINKS_JSON env variable is required.');
  process.exit(1);
}
