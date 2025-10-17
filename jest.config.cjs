export default {
  // Run tests in a Node.js-like environment (not a browser)
  testEnvironment: 'node',

  // Look for test files inside /tests with names like *.test.js
  testMatch: ['**/tests/**/*.test.js'],

  // File extensions Jest will recognize
  moduleFileExtensions: ['js', 'json', 'node'],

  // Ignore test files inside node_modules
  testPathIgnorePatterns: ['/node_modules/'],

  // Optional: clear mocks between tests for consistency
  clearMocks: true,
};
