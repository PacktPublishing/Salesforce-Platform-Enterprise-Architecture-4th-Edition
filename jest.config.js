const { jestConfig } = require('@salesforce/sfdx-lwc-jest/config');
module.exports = {
    ...jestConfig,
    moduleNameMapper: {
        '^lightning/platformShowToastEvent$':
            '<rootDir>/source/formulaforce/test/jest-mocks/lightning/platformShowToastEvent',
        '^lightning/actions$':
            '<rootDir>/source/formulaforce/test/jest-mocks/lightning/actions'
    }
};
