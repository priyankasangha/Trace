// jest.config.cjs
module.exports = {
  // Use ts-jest preset so Jest can run TypeScript files
  preset: 'ts-jest',

  // Node.js environment for tests
  testEnvironment: 'node',

  // Only run test files that match this pattern
  testMatch: ['**/src/tests/**/*.test.ts'],

  // File types Jest will recognize
  moduleFileExtensions: ['ts', 'js', 'json', 'node'],

  // Globals configuration for ts-jest
  globals: {
    'ts-jest': {
      tsconfig: 'tsconfig.json', // points to your tsconfig.json
    },
  },

  // Optional: ignore node_modules
  testPathIgnorePatterns: ['/node_modules/'],
};
