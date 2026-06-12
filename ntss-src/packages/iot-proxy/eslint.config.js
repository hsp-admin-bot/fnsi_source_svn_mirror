const js = require('@eslint/js');

module.exports = [
  js.configs.recommended,
  {
    languageOptions: {
      ecmaVersion: 2015,
      sourceType: 'commonjs',
      globals: {
        Buffer: 'readonly',
        console: 'readonly',
        exports: 'readonly',
        process: 'readonly',
        require: 'readonly'
      }
    },
    rules: {
      indent: [
        'error', 2
      ],
      'linebreak-style': [
        'error', 'unix'
      ],
      quotes: [
        'error', 'single'
      ],
      semi: ['error', 'always']
    }
  }
];
