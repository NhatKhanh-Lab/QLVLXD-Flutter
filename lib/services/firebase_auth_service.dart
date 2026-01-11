import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/user.dart' as app_user;

class FirebaseAuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String usersCollection = 'users';

  // Get current Firebase user
  static User? get currentFirebaseUser => _auth.currentUser;

  // Get current user stream
  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with email and password
  static Future<app_user.User?> signInWithEmailPassword(
    String email,
    String password,
  ) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        return await getUserByUid(credential.user!.uid);
      }
      return null;
    } on FirebaseAuthException catch (e) {
      debugPrint('Sign in error: ${e.code} - ${e.message}');
      return null;
    } catch (e) {
      debugPrint('Sign in error: $e');
      return null;
    }
  }

  // Sign in with username (custom authentication - SIMPLIFIED: Only Firestore)
  static Future<app_user.User?> signInWithUsername(
    String username,
    String password,
  ) async {
    try {
      // Get user document by username
      final userQuery = await _firestore
          .collection(usersCollection)
          .where('username', isEqualTo: username)
          .limit(1)
          .get();

      if (userQuery.docs.isEmpty) {
        debugPrint('User not found: $username');
        return null;
      }

      final userDoc = userQuery.docs.first;
      final userData = userDoc.data();
      
      // Validate data
      if (userData == null || userData is! Map<String, dynamic>) {
        debugPrint('Invalid user data for: $username');
        return null;
      }

      // Check if user is active
      final isActive = userData['isActive'] is bool 
          ? userData['isActive'] as bool
          : (userData['isActive']?.toString().toLowerCase() == 'true');
      
      if (!isActive) {
        debugPrint('User is inactive: $username');
        return null;
      }

      final storedPassword = userData['password']?.toString();

      debugPrint('Checking password for user: $username');
      
      // Simple password check (in production, use hashed passwords)
      if (storedPassword == null || storedPassword != password) {
        debugPrint('Password mismatch for user: $username');
        return null;
      }

      // Parse user from Firestore data
      final user = app_user.User.fromMap(userData);
      debugPrint('User authenticated: ${user.fullName} (${user.role.name})');
      return user;
    } catch (e) {
      debugPrint('Sign in with username error: $e');
      return null;
    }
  }

  // Sign up new user (admin only) - SIMPLIFIED: Only use Firestore, no Firebase Auth
  static Future<app_user.User?> signUp({
    required String email,
    required String password,
    required String username,
    required String fullName,
    required app_user.UserRole role,
    String? phone,
    String? createdBy,
  }) async {
    try {
      // Check if email already exists in Firestore
      final emailQuery = await _firestore
          .collection(usersCollection)
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      // Filter active users manually
      final activeEmailUsers = emailQuery.docs
          .where((doc) {
            final data = doc.data();
            return data != null && 
                   data is Map<String, dynamic> &&
                   (data['isActive'] == true || data['isActive'] == 'true');
          })
          .toList();

      if (activeEmailUsers.isNotEmpty) {
        debugPrint('Email already exists in Firestore: $email');
        throw Exception('Email đã tồn tại trong hệ thống');
      }

      // Check if username already exists
      final usernameQuery = await _firestore
          .collection(usersCollection)
          .where('username', isEqualTo: username)
          .limit(1)
          .get();

      // Filter active users manually
      final activeUsernameUsers = usernameQuery.docs
          .where((doc) {
            final data = doc.data();
            return data != null && 
                   data is Map<String, dynamic> &&
                   (data['isActive'] == true || data['isActive'] == 'true');
          })
          .toList();

      if (activeUsernameUsers.isNotEmpty) {
        debugPrint('Username already exists in Firestore: $username');
        throw Exception('Tên đăng nhập đã tồn tại');
      }

      // Generate unique ID (simple approach - no Firebase Auth needed)
      final userId = 'user_${DateTime.now().millisecondsSinceEpoch}_${username.hashCode}';

      // Create user document in Firestore only (no Firebase Auth)
      final now = DateTime.now();
      final user = app_user.User(
        id: userId,
        username: username,
        password: password, // In production, hash this
        fullName: fullName,
        email: email,
        phone: phone,
        role: role,
        isActive: true,
        createdAt: now,
        updatedAt: now,
        createdBy: createdBy,
      );

      await _firestore
          .collection(usersCollection)
          .doc(userId)
          .set(user.toMap());

      debugPrint('User created successfully in Firestore: $email (ID: $userId)');
      return user;
    } catch (e) {
      debugPrint('Sign up error: $e');
      if (e.toString().contains('đã tồn tại') || e.toString().contains('already exists')) {
        rethrow; // Re-throw validation errors
      }
      throw Exception('Lỗi tạo tài khoản: $e');
    }
  }

  // Sign out
  static Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      debugPrint('Sign out error: $e');
    }
  }

  // Get user by Firebase UID
  static Future<app_user.User?> getUserByUid(String uid) async {
    try {
      final doc = await _firestore.collection(usersCollection).doc(uid).get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        if (data is Map<String, dynamic>) {
          return app_user.User.fromMap(data);
        }
      }
      return null;
    } catch (e) {
      debugPrint('Get user by UID error: $e');
      return null;
    }
  }

  // Get user by username
  static Future<app_user.User?> getUserByUsername(String username) async {
    try {
      final query = await _firestore
          .collection(usersCollection)
          .where('username', isEqualTo: username)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        final data = query.docs.first.data();
        if (data != null && data is Map<String, dynamic>) {
          return app_user.User.fromMap(data);
        }
      }
      return null;
    } catch (e) {
      debugPrint('Get user by username error: $e');
      return null;
    }
  }

  // Update user
  static Future<bool> updateUser(app_user.User user) async {
    try {
      await _firestore
          .collection(usersCollection)
          .doc(user.id)
          .update(user.toMap());
      return true;
    } catch (e) {
      debugPrint('Update user error: $e');
      return false;
    }
  }

  // Delete user (soft delete - set isActive to false)
  static Future<bool> deleteUser(String userId) async {
    try {
      await _firestore.collection(usersCollection).doc(userId).update({
        'isActive': false,
        'updatedAt': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      debugPrint('Delete user error: $e');
      return false;
    }
  }

  // Get all users
  static Stream<List<app_user.User>> getAllUsers() {
    return _firestore
        .collection(usersCollection)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
          final users = <app_user.User>[];
          for (final doc in snapshot.docs) {
            try {
              final data = doc.data();
              if (data != null && data is Map<String, dynamic>) {
                users.add(app_user.User.fromMap(data));
              }
            } catch (e) {
              debugPrint('Error parsing user ${doc.id}: $e');
              // Skip invalid users
            }
          }
          return users;
        });
  }

  // Get users by role
  static Stream<List<app_user.User>> getUsersByRole(app_user.UserRole role) {
    // Use single where clause and filter manually to avoid composite index requirement
    return _firestore
        .collection(usersCollection)
        .where('role', isEqualTo: role.name)
        .snapshots()
        .map((snapshot) {
          final users = <app_user.User>[];
          for (final doc in snapshot.docs) {
            try {
              final data = doc.data();
              if (data != null && 
                  data is Map<String, dynamic> &&
                  (data['isActive'] == true || data['isActive'] == 'true')) {
                users.add(app_user.User.fromMap(data));
              }
            } catch (e) {
              debugPrint('Error parsing user ${doc.id}: $e');
              // Skip invalid users
            }
          }
          return users;
        });
  }

  // Initialize default admin user - SIMPLIFIED: Only Firestore
  static Future<void> initializeDefaultAdmin() async {
    try {
      // Check if admin exists in Firestore
      final adminQuery = await _firestore
          .collection(usersCollection)
          .where('username', isEqualTo: 'admin')
          .limit(1)
          .get();

      if (adminQuery.docs.isEmpty) {
        debugPrint('Creating default admin user...');
        // Create default admin
        final adminEmail = 'admin@quanlyvlxd.com';
        final adminPassword = 'admin123';
        final now = DateTime.now();

        // Simple ID generation (no Firebase Auth needed)
        final adminId = 'admin_${now.millisecondsSinceEpoch}';

        // Create user document in Firestore only
        final admin = app_user.User(
          id: adminId,
          username: 'admin',
          password: adminPassword, // Store password for custom auth
          fullName: 'Quản trị viên',
          email: adminEmail,
          role: app_user.UserRole.admin,
          isActive: true,
          createdAt: now,
          updatedAt: now,
        );

        await _firestore
            .collection(usersCollection)
            .doc(adminId)
            .set(admin.toMap());
        
        debugPrint('Default admin user created in Firestore: $adminId');
      } else {
        debugPrint('Admin user already exists');
      }
    } catch (e) {
      debugPrint('Initialize default admin error: $e');
      debugPrint('Make sure Firebase is configured: flutterfire configure');
    }
  }
}

