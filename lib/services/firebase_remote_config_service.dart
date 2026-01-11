import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';

/// Firebase Remote Config Service
/// 
/// Change app configuration remotely without updating the app
/// - VAT rate
/// - Min stock threshold
/// - Feature flags
/// - App settings
class FirebaseRemoteConfigService {
  static final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;

  // Default values
  static const Map<String, dynamic> _defaults = {
    'vat_rate': 0.1, // 10%
    'min_stock_threshold': 10,
    'enable_notifications': true,
    'enable_analytics': true,
    'app_version': '1.0.0',
    'maintenance_mode': false,
  };

  // Initialize Remote Config
  static Future<void> initialize() async {
    try {
      await _remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 10),
          minimumFetchInterval: const Duration(hours: 1),
        ),
      );

      await _remoteConfig.setDefaults(_defaults);
      await _remoteConfig.fetchAndActivate();

      debugPrint('Remote Config initialized');
    } catch (e) {
      debugPrint('Remote Config initialization error: $e');
    }
  }

  // Fetch and activate
  static Future<bool> fetchAndActivate() async {
    try {
      return await _remoteConfig.fetchAndActivate();
    } catch (e) {
      debugPrint('Remote Config fetch error: $e');
      return false;
    }
  }

  // Get values
  static double getVatRate() {
    return _remoteConfig.getDouble('vat_rate');
  }

  static int getMinStockThreshold() {
    return _remoteConfig.getInt('min_stock_threshold');
  }

  static bool isNotificationsEnabled() {
    return _remoteConfig.getBool('enable_notifications');
  }

  static bool isAnalyticsEnabled() {
    return _remoteConfig.getBool('enable_analytics');
  }

  static String getAppVersion() {
    return _remoteConfig.getString('app_version');
  }

  static bool isMaintenanceMode() {
    return _remoteConfig.getBool('maintenance_mode');
  }

  // Get any value
  static String getString(String key) {
    return _remoteConfig.getString(key);
  }

  static int getInt(String key) {
    return _remoteConfig.getInt(key);
  }

  static double getDouble(String key) {
    return _remoteConfig.getDouble(key);
  }

  static bool getBool(String key) {
    return _remoteConfig.getBool(key);
  }
}

