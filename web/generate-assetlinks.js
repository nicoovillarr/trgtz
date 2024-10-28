console.log('Genearating assetlinks.json...');

import { mkdirSync, writeFileSync } from 'fs';
import { join } from 'path';

const assetLinksJson = process.env.ASSET_LINKS_JSON;

if (assetLinksJson) {
  const dirPath = join(process.cwd(), 'dist/.well-known');
  const filePath = join(dirPath, 'assetlinks.json');

  mkdirSync(dirPath, { recursive: true });

  writeFileSync(filePath, assetLinksJson);
  console.log('assetlinks.json file generated sucessfully on .well-known/');
} else {
  console.error('ASSET_LINKS_JSON env variable is required.');
  process.exit(1);
}
