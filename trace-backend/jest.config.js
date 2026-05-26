// jest.config.js
export default {
  testEnvironment: 'node',
  transform: {},
  moduleNameMapper: {
    // map the exact module path to the manual mock
    '^src/helpers/permissionsHelpers/journeyPermissionsHelpers.js$':
      '<rootDir>/tests/mocks/journeyPermissionsHelpersMock.js',
  },
};
