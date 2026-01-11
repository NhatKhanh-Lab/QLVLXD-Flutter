import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

/// Firebase Analytics Service
/// 
/// Track user behavior and app events
/// - Screen views
/// - User actions (create invoice, add product, etc.)
/// - Business events (sales, inventory, etc.)
class FirebaseAnalyticsService {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  // Log screen view
  static Future<void> logScreenView(String screenName) async {
    try {
      await _analytics.logScreenView(screenName: screenName);
      debugPrint('Analytics: Screen view - $screenName');
    } catch (e) {
      debugPrint('Analytics error: $e');
    }
  }

  // Log event
  static Future<void> logEvent({
    required String name,
    Map<String, dynamic>? parameters,
  }) async {
    try {
      await _analytics.logEvent(
        name: name,
        parameters: parameters,
      );
      debugPrint('Analytics: Event - $name');
    } catch (e) {
      debugPrint('Analytics error: $e');
    }
  }

  // ==================== Business Events ====================

  // Product events
  static Future<void> logProductAdded(String productId, String productName) async {
    await logEvent(
      name: 'product_added',
      parameters: {
        'product_id': productId,
        'product_name': productName,
      },
    );
  }

  static Future<void> logProductUpdated(String productId) async {
    await logEvent(
      name: 'product_updated',
      parameters: {'product_id': productId},
    );
  }

  static Future<void> logProductDeleted(String productId) async {
    await logEvent(
      name: 'product_deleted',
      parameters: {'product_id': productId},
    );
  }

  // Invoice events
  static Future<void> logInvoiceCreated({
    required String invoiceId,
    required double total,
    required int itemCount,
  }) async {
    await logEvent(
      name: 'invoice_created',
      parameters: {
        'invoice_id': invoiceId,
        'total': total,
        'item_count': itemCount,
      },
    );
  }

  static Future<void> logInvoiceDeleted(String invoiceId) async {
    await logEvent(
      name: 'invoice_deleted',
      parameters: {'invoice_id': invoiceId},
    );
  }

  // User events
  static Future<void> logUserLogin(String userId, String role) async {
    await logEvent(
      name: 'user_login',
      parameters: {
        'user_id': userId,
        'role': role,
      },
    );
  }

  static Future<void> logUserLogout(String userId) async {
    await logEvent(
      name: 'user_logout',
      parameters: {'user_id': userId},
    );
  }

  // Search events
  static Future<void> logProductSearch(String query, int resultCount) async {
    await logEvent(
      name: 'product_search',
      parameters: {
        'query': query,
        'result_count': resultCount,
      },
    );
  }

  // Low stock alert
  static Future<void> logLowStockAlert(int productCount) async {
    await logEvent(
      name: 'low_stock_alert',
      parameters: {'product_count': productCount},
    );
  }

  // Set user properties
  static Future<void> setUserProperty({
    required String name,
    required String value,
  }) async {
    try {
      await _analytics.setUserProperty(name: name, value: value);
    } catch (e) {
      debugPrint('Analytics setUserProperty error: $e');
    }
  }

  // Set user ID
  static Future<void> setUserId(String userId) async {
    try {
      await _analytics.setUserId(id: userId);
    } catch (e) {
      debugPrint('Analytics setUserId error: $e');
    }
  }
}

