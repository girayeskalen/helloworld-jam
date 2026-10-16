import { defineConfig } from '@playwright/test';

export default defineConfig({
  testDir: './tests',
  workers: 1,
  timeout: 30_000,
  use: { baseURL: 'http://127.0.0.1:5174', viewport: { width: 1360, height: 840 }, headless: true },
  webServer: {
    command: 'npm run dev -- --port 5174 --strictPort',
    url: 'http://127.0.0.1:5174',
    env: { BROWSER: 'none' },
    reuseExistingServer: false,
  },
});
