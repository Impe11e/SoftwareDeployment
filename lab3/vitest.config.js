import { defineConfig } from 'vitest/config';

export default defineConfig({
  test: {
    coverage: {
      provider: 'v8',
      reporter: ['text', 'json', 'html'],
      include: ['mywebapp/src/app.js', 'mywebapp/src/controllers/**', 'mywebapp/src/services/**'],
    },
  },
});