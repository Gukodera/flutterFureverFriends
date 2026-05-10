import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' if (dart.library.html) 'dart:html' as html;

class ImageHelper {
  static final ImagePicker _picker = ImagePicker();

  /// Pick an image from gallery and convert to base64
  static Future<String?> pickImageAsBase64({
    int maxWidth = 1024,
    int maxHeight = 1024,
    int quality = 85,
  }) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: maxWidth.toDouble(),
        maxHeight: maxHeight.toDouble(),
        imageQuality: quality,
      );

      if (image == null) return null;

      final bytes = await image.readAsBytes();
      return base64Encode(bytes);
    } catch (e) {
      print('Error picking image: $e');
      return null;
    }
  }

  /// Pick an image from camera and convert to base64
  static Future<String?> takePhotoAsBase64({
    int maxWidth = 1024,
    int maxHeight = 1024,
    int quality = 85,
  }) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: maxWidth.toDouble(),
        maxHeight: maxHeight.toDouble(),
        imageQuality: quality,
      );

      if (image == null) return null;

      final bytes = await image.readAsBytes();
      return base64Encode(bytes);
    } catch (e) {
      print('Error taking photo: $e');
      return null;
    }
  }

  /// Convert base64 string to Uint8List for displaying
  static Uint8List? base64ToImage(String? base64String) {
    if (base64String == null || base64String.isEmpty) return null;
    
    try {
      return base64Decode(base64String);
    } catch (e) {
      print('Error decoding base64: $e');
      return null;
    }
  }

  /// Check if a string is a base64 image
  static bool isBase64Image(String? str) {
    if (str == null || str.isEmpty) return false;
    
    // Basic check for base64 format
    final base64Pattern = RegExp(r'^[A-Za-z0-9+/]+={0,2}$');
    return base64Pattern.hasMatch(str);
  }

  /// Get image size in KB from base64 string
  static double getBase64ImageSizeKB(String base64String) {
    final bytes = base64Decode(base64String);
    return bytes.length / 1024;
  }

  /// Compress base64 image if it's too large
  static String compressBase64IfNeeded(
    String base64String, {
    double maxSizeKB = 500,
  }) {
    final currentSize = getBase64ImageSizeKB(base64String);
    
    if (currentSize <= maxSizeKB) {
      return base64String;
    }
    
    // If too large, you might need to re-encode with lower quality
    // For now, just return as is - implement compression if needed
    print('Warning: Image is ${currentSize.toStringAsFixed(2)}KB, exceeds ${maxSizeKB}KB');
    return base64String;
  }

  /// Show image picker dialog
  static Future<String?> showImageSourceDialog(context) async {
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Select Image Source'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library, color: Color(0xFF4A9B8E)),
                title: const Text('Gallery'),
                onTap: () async {
                  Navigator.pop(context);
                  final base64 = await pickImageAsBase64();
                  if (base64 != null && context.mounted) {
                    Navigator.pop(context, base64);
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Color(0xFF4A9B8E)),
                title: const Text('Camera'),
                onTap: () async {
                  Navigator.pop(context);
                  final base64 = await takePhotoAsBase64();
                  if (base64 != null && context.mounted) {
                    Navigator.pop(context, base64);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
