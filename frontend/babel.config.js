module.exports = {
  presets: ['module:metro-react-native-babel-preset'],
  plugins: [
    // React Native Reanimated (for worklets)
    'react-native-reanimated/plugin',
    // Optional chaining / nullish coalescing
    '@babel/plugin-proposal-optional-chaining',
    '@babel/plugin-proposal-nullish-coalescing-operator',
    // Decorators (if used in future)
    // ['@babel/plugin-proposal-decorators', { legacy: true }],
    // ['@babel/plugin-proposal-class-properties', { loose: true }],
  ],
};