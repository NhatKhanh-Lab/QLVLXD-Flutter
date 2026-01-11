import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import '../models/user.dart' as app_user;
import '../services/firebase_auth_service.dart';

class AuthProvider with ChangeNotifier {
  app_user.User? _currentUser;
  bool _isLoading = false;
  bool _isCustomAuth = false; // Track if using custom auth (username login)
  bool _isLoggingIn = false; // Track if currently logging in
  StreamSubscription? _authStateSubscription;

  app_user.User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isAdmin => _currentUser?.isAdmin ?? false;
  bool get isEmployee => _currentUser?.isEmployee ?? false;
  bool get isLoading => _isLoading;

  AuthProvider() {
    _initAuthListener();
  }

  // Listen to Firebase auth state changes (only for email-based login)
  void _initAuthListener() {
    _authStateSubscription = FirebaseAuthService.authStateChanges.listen((firebaseUser) async {
      // Ignore listener during login process to prevent race conditions
      if (_isLoggingIn) {
        debugPrint('Ignoring Firebase auth state change - login in progress');
        return;
      }

      // Only process Firebase Auth changes if NOT using custom auth
      // This prevents the listener from overriding custom auth login
      if (_isCustomAuth) {
        debugPrint('Ignoring Firebase auth state change - using custom auth');
        return;
      }

      if (firebaseUser != null) {
        // User is signed in via Firebase Auth, get user data from Firestore
        final user = await FirebaseAuthService.getUserByUid(firebaseUser.uid);
        if (user != null && user.isActive) {
          _currentUser = user;
          notifyListeners();
        } else {
          _currentUser = null;
          notifyListeners();
        }
      } else {
        // User is signed out (only clear if not using custom auth)
        if (!_isCustomAuth && !_isLoggingIn) {
          _currentUser = null;
          notifyListeners();
        }
      }
    });
  }

  @override
  void dispose() {
    _authStateSubscription?.cancel();
    super.dispose();
  }

  // Login with username/password
  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _isLoggingIn = true; // Block listener during login
    notifyListeners();

    try {
      debugPrint('=== Starting login process for: $username ===');
      
      // Try username-based login first (custom auth - works with Firestore only)
      var user = await FirebaseAuthService.signInWithUsername(username, password);
      bool isEmailLogin = false;
      
      // If that fails, try email-based login (requires Firebase Auth)
      if (user == null && username.contains('@')) {
        debugPrint('Username login failed, trying email-based login...');
        user = await FirebaseAuthService.signInWithEmailPassword(username, password);
        isEmailLogin = true;
      }

      if (user != null && user.isActive) {
        // Set flags BEFORE setting current user
        // This prevents the listener from overriding the login
        _isCustomAuth = !isEmailLogin;
        _isLoggingIn = false; // Allow listener after setting flags
        
        _currentUser = user;
        debugPrint('✓ Login successful: ${user.fullName} (${user.role.name})');
        debugPrint('✓ Using ${_isCustomAuth ? "custom" : "Firebase"} authentication');
        debugPrint('✓ Current user set, isAuthenticated: $isAuthenticated');
        
        _isLoading = false;
        notifyListeners();
        
        // Small delay to ensure state is propagated
        await Future.delayed(const Duration(milliseconds: 100));
        debugPrint('=== Login process completed ===');
        
        return true;
      }

      debugPrint('✗ Login failed: User not found or inactive');
      _isLoggingIn = false;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e, stackTrace) {
      debugPrint('✗ Login error: $e');
      debugPrint('Stack trace: $stackTrace');
      _isLoggingIn = false;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      debugPrint('=== Starting logout process ===');
      
      // Set logging in flag to prevent listener interference
      _isLoggingIn = true;
      
      // Clear custom auth flag first
      _isCustomAuth = false;
      
      // Sign out from Firebase Auth (if was using email login)
      await FirebaseAuthService.signOut();
      
      // Clear current user
      _currentUser = null;
      
      // Allow listener after clearing
      _isLoggingIn = false;
      
      debugPrint('✓ Logout successful - all state cleared');
      debugPrint('✓ isAuthenticated: $isAuthenticated');
      debugPrint('=== Logout process completed ===');
      
      notifyListeners();
      
      // Small delay to ensure state is propagated
      await Future.delayed(const Duration(milliseconds: 100));
    } catch (e) {
      debugPrint('✗ Logout error: $e');
      // Still clear user even if signOut fails
      _currentUser = null;
      _isCustomAuth = false;
      _isLoggingIn = false;
      notifyListeners();
    }
  }

  // Check if user has permission
  bool hasPermission(String permission) {
    if (_currentUser == null) return false;
    if (_currentUser!.isAdmin) return true;

    // Employee permissions
    switch (permission) {
      case 'view_products':
      case 'search_products':
      case 'create_invoice':
      case 'view_own_invoices':
      case 'view_own_statistics':
        return true;
      case 'manage_products':
      case 'manage_suppliers':
      case 'manage_customers':
      case 'manage_users':
      case 'view_all_statistics':
      case 'delete_invoice':
      case 'system_settings':
        return false;
      default:
        return false;
    }
  }
}

