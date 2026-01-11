import 'package:hive/hive.dart';
import 'package:flutter/foundation.dart';

part 'user.g.dart';

enum UserRole {
  admin,
  employee,
}

@HiveType(typeId: 6)
class User extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String username;

  @HiveField(2)
  String password; // In production, should be hashed

  @HiveField(3)
  String fullName;

  @HiveField(4)
  String email;

  @HiveField(5)
  String? phone;

  @HiveField(6)
  UserRole role;

  @HiveField(7)
  bool isActive;

  @HiveField(8)
  DateTime createdAt;

  @HiveField(9)
  DateTime updatedAt;

  @HiveField(10)
  String? createdBy; // ID of admin who created this user

  User({
    required this.id,
    required this.username,
    required this.password,
    required this.fullName,
    required this.email,
    this.phone,
    required this.role,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
    this.createdBy,
  });

  // Convert to Map for Firebase
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'password': password,
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'role': role.name,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'createdBy': createdBy,
    };
  }

  // Create from Map
  factory User.fromMap(Map<String, dynamic> map) {
    try {
      // Validate and parse data safely
      final id = map['id']?.toString() ?? '';
      final username = map['username']?.toString() ?? '';
      final password = map['password']?.toString() ?? '';
      final fullName = map['fullName']?.toString() ?? '';
      final email = map['email']?.toString() ?? '';
      final phone = map['phone']?.toString();
      
      // Parse role
      UserRole role = UserRole.employee;
      if (map['role'] != null) {
        final roleStr = map['role'].toString();
        role = UserRole.values.firstWhere(
          (e) => e.name == roleStr,
          orElse: () => UserRole.employee,
        );
      }
      
      // Parse boolean
      final isActive = map['isActive'] is bool 
          ? map['isActive'] as bool
          : (map['isActive']?.toString().toLowerCase() == 'true');
      
      // Parse dates
      DateTime createdAt;
      DateTime updatedAt;
      try {
        createdAt = map['createdAt'] is DateTime
            ? map['createdAt'] as DateTime
            : DateTime.parse(map['createdAt']?.toString() ?? DateTime.now().toIso8601String());
      } catch (e) {
        createdAt = DateTime.now();
      }
      
      try {
        updatedAt = map['updatedAt'] is DateTime
            ? map['updatedAt'] as DateTime
            : DateTime.parse(map['updatedAt']?.toString() ?? DateTime.now().toIso8601String());
      } catch (e) {
        updatedAt = DateTime.now();
      }
      
      final createdBy = map['createdBy']?.toString();
      
      return User(
        id: id,
        username: username,
        password: password,
        fullName: fullName,
        email: email,
        phone: phone,
        role: role,
        isActive: isActive,
        createdAt: createdAt,
        updatedAt: updatedAt,
        createdBy: createdBy,
      );
    } catch (e) {
      // Log error and return default user
      debugPrint('Error parsing User from Map: $e');
      debugPrint('Map data: $map');
      rethrow;
    }
  }

  // Copy with method
  User copyWith({
    String? id,
    String? username,
    String? password,
    String? fullName,
    String? email,
    String? phone,
    UserRole? role,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      password: password ?? this.password,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
    );
  }

  bool get isAdmin => role == UserRole.admin;
  bool get isEmployee => role == UserRole.employee;
}

