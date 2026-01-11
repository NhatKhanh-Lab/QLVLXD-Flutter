import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

/// Firebase Crashlytics Service
/// 
/// Automatically track and report crashes
/// - Catch unhandled exceptions
/// - Track custom errors
/// - Get crash reports in Firebase Console
class FirebaseCrashlyticsService {
  static final FirebaseCrashlytics _crashlytics = FirebaseCrashlytics.instance;

  // Initialize Crashlytics
  static void initialize() {
    // Pass all uncaught errors to Crashlytics
    FlutterError.onError = (errorDetails) {
      _crashlytics.recordFlutterFatalError(errorDetails);
    };

    // Pass all uncaught asynchronous errors to Crashlytics
    PlatformDispatcher.instance.onError = (error, stack) {
      _crashlytics.recordError(error, stack, fatal: true);
      return true;
    };
  }

  // Log custom error
  static Future<void> recordError(
    dynamic exception,
    StackTrace? stack, {
    String? reason,
    bool fatal = false,
  }) async {
    try {
      await _crashlytics.recordError(
        exception,
        stack,
        reason: reason,
        fatal: fatal,
      );
      debugPrint('Crashlytics: Error recorded - $exception');
    } catch (e) {
      debugPrint('Crashlytics error: $e');
    }
  }

  // Log custom message
  static Future<void> log(String message) async {
    try {
      await _crashlytics.log(message);
      debugPrint('Crashlytics: Log - $message');
    } catch (e) {
      debugPrint('Crashlytics log error: $e');
    }
  }

  // Set user identifier
  static Future<void> setUserId(String userId) async {
    try {
      await _crashlytics.setUserIdentifier(userId);
    } catch (e) {
      debugPrint('Crashlytics setUserId error: $e');
    }
  }

  // Set custom key-value pairs
  static Future<void> setCustomKey(String key, dynamic value) async {
    try {
      await _crashlytics.setCustomKey(key, value);
    } catch (e) {
      debugPrint('Crashlytics setCustomKey error: $e');
    }
  }
}

