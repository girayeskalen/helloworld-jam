import { defineConfig } from 'vite';

export default defineConfig({
  base: './',
  server: { host: '127.0.0.1', open: true },
  preview: { host: '127.0.0.1' },
});
