/**
 * QuantumEnergyOS - Mobile Entry Point
 * React Native application bootstrap
 */

import {AppRegistry} from 'react-native';
import App from './App';
import {name as appName} from './app.json';

// Register the main application component
AppRegistry.registerComponent(appName, () => App);

// Optional: Initialize performance monitoring
import {setJSExceptionHandler} from 'react-native-exception-handler';
import * as Sentry from '@sentry/react-native';

// Configure Sentry for error tracking
Sentry.init({
  dsn: 'https://your-sentry-dsn.ingest.sentry.io/project-id',
  tracesSampleRate: 0.2,
  enableAutoSessionTracking: true,
  debug: __DEV__,
});

// Global error handler
setJSExceptionHandler((error, isFatal) => {
  console.error('Global JS Exception:', error);
  if (isFatal) {
    Sentry.withScope(scope => {
      scope.setSeverity('fatal');
      Sentry.captureException(error);
    });
  }
}, true);