/** @type {import('ts-jest').JestConfigWithTsJest} */

module.exports = {
  roots: ['<rootDir>/src'],
  transform: { '^.+\\.tsx?$': 'ts-jest' },
  testMatch: ['<rootDir>/src/__tests__/*.ts'],
  moduleFileExtensions: ['ts', 'tsx', 'js', 'jsx', 'json'],
  testPathIgnorePatterns: ['node_modules/', 'dist/', '__tests__suites__', '__tests__setup__'],
  globalSetup: '<rootDir>/src/__tests__setup__/setup.ts',
  globalTeardown: '<rootDir>/src/__tests__setup__/teardown.ts',
  testTimeout: 1000000,
};
