import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

class FirebaseStorageService {
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  // Upload product image
  static Future<String?> uploadProductImage({
    required String productId,
    required XFile imageFile,
  }) async {
    try {
      final ref = _storage.ref().child('products/$productId/${DateTime.now().millisecondsSinceEpoch}.jpg');
      final uploadTask = ref.putFile(File(imageFile.path));
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      debugPrint('Upload product image error: $e');
      return null;
    }
  }

  // Upload from bytes (for web)
  static Future<String?> uploadProductImageFromBytes({
    required String productId,
    required List<int> imageBytes,
    required String fileName,
  }) async {
    try {
      final ref = _storage.ref().child('products/$productId/$fileName');
      final uploadTask = ref.putData(
        Uint8List.fromList(imageBytes),
        SettableMetadata(contentType: 'image/jpeg'),
      );
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      debugPrint('Upload product image from bytes error: $e');
      return null;
    }
  }

  // Delete product image
  static Future<bool> deleteProductImage(String imageUrl) async {
    try {
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
      return true;
    } catch (e) {
      debugPrint('Delete product image error: $e');
      return false;
    }
  }

  // Upload user avatar
  static Future<String?> uploadUserAvatar({
    required String userId,
    required XFile imageFile,
  }) async {
    try {
      final ref = _storage.ref().child('users/$userId/avatar.jpg');
      final uploadTask = ref.putFile(File(imageFile.path));
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      debugPrint('Upload user avatar error: $e');
      return null;
    }
  }

  // Get download URL
  static Future<String?> getDownloadUrl(String path) async {
    try {
      return await _storage.ref(path).getDownloadURL();
    } catch (e) {
      debugPrint('Get download URL error: $e');
      return null;
    }
  }
}

