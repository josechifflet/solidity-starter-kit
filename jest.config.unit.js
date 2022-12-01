/** @type {import('ts-jest').JestConfigWithTsJest} */

module.exports = {
  preset: 'ts-jest',
  testEnvironment: 'node',
  setupFilesAfterEnv: ['<rootDir>/jest.config/env.unit.setup.ts'],
  modulePathIgnorePatterns: [
    'dist',
    'node_modules',
    '__tests__',
    '__tests__setup__',
    '__tests__suites__',
  ],
  collectCoverage: true,
  testMatch: ['<rootDir>/src/**/*.test.ts'],
  collectCoverageFrom: [
    '<rootDir>/src/**/*.ts',
    '!<rootDir>/dist',
    '!**/__mocks__/*.js',
    '!<rootDir>/src/__tests__/*.ts',
    '!<rootDir>/src/__tests__setup__/*.ts',
    '!<rootDir>/src/__tests__suites__/*.spec.ts',
  ],
  coverageThreshold: {
    global: {
      functions: 80,
      lines: 80,
    },
  },
  coverageReporters: [['text', { skipFull: true }], 'text-summary'],
};
