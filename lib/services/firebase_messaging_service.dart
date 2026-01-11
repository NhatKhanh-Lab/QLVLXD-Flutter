import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Firebase Cloud Messaging Service
/// 
/// Push notifications for:
/// - New invoice created
/// - Low stock alerts
/// - Admin messages to employees
/// - System notifications
class FirebaseMessagingService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Request notification permissions
  static Future<bool> requestPermission() async {
    try {
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      return settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;
    } catch (e) {
      debugPrint('FCM permission error: $e');
      return false;
    }
  }

  // Get FCM token
  static Future<String?> getToken() async {
    try {
      final token = await _messaging.getToken();
      debugPrint('FCM Token: $token');
      return token;
    } catch (e) {
      debugPrint('FCM getToken error: $e');
      return null;
    }
  }

  // Save token to Firestore for user
  static Future<void> saveTokenToFirestore(String userId, String token) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'fcmToken': token,
        'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Save FCM token error: $e');
    }
  }

  // Delete token when user logs out
  static Future<void> deleteToken() async {
    try {
      await _messaging.deleteToken();
    } catch (e) {
      debugPrint('Delete FCM token error: $e');
    }
  }

  // Handle foreground messages
  static void setupForegroundHandler() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('FCM Foreground message: ${message.notification?.title}');
      // Show local notification or update UI
      // You can use flutter_local_notifications package here
    });
  }

  // Handle background messages
  @pragma('vm:entry-point')
  static Future<void> handleBackgroundMessage(RemoteMessage message) async {
    debugPrint('FCM Background message: ${message.notification?.title}');
    // Handle background notification
  }

  // Send notification to specific user
  static Future<void> sendNotificationToUser({
    required String userId,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      // Get user's FCM token from Firestore
      final userDoc = await _firestore.collection('users').doc(userId).get();
      final fcmToken = userDoc.data()?['fcmToken'] as String?;

      if (fcmToken == null) {
        debugPrint('User $userId has no FCM token');
        return;
      }

      // In production, you would use Cloud Functions or Admin SDK
      // to send notifications. For now, we'll just log it.
      debugPrint('Would send notification to $userId: $title - $body');
      
      // TODO: Implement using Cloud Functions or Admin SDK
      // Example Cloud Function:
      // https://firebase.google.com/docs/cloud-messaging/send-message
    } catch (e) {
      debugPrint('Send notification error: $e');
    }
  }

  // Send notification to all users with specific role
  static Future<void> sendNotificationToRole({
    required String role,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      final usersSnapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: role)
          .where('isActive', isEqualTo: true)
          .get();

      for (final doc in usersSnapshot.docs) {
        final fcmToken = doc.data()['fcmToken'] as String?;
        if (fcmToken != null) {
          // Send to each user
          await sendNotificationToUser(
            userId: doc.id,
            title: title,
            body: body,
            data: data,
          );
        }
      }
    } catch (e) {
      debugPrint('Send notification to role error: $e');
    }
  }

  // Initialize FCM
  static Future<void> initialize() async {
    try {
      // Request permission
      await requestPermission();

      // Get token
      final token = await getToken();
      if (token != null) {
        debugPrint('FCM initialized with token: $token');
      }

      // Setup foreground handler
      setupForegroundHandler();

      // Setup background handler
      FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
    } catch (e) {
      debugPrint('FCM initialization error: $e');
    }
  }
}

