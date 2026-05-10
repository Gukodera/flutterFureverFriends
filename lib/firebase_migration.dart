import 'package:flutter/material.dart';
import 'firebase_service.dart';
import 'pet_data.dart';

/// One-time migration screen to upload local pets to Firebase
class FirebaseMigrationScreen extends StatefulWidget {
  const FirebaseMigrationScreen({super.key});

  @override
  State<FirebaseMigrationScreen> createState() => _FirebaseMigrationScreenState();
}

class _FirebaseMigrationScreenState extends State<FirebaseMigrationScreen> {
  final firebaseService = FirebaseService();
  bool _isMigrating = false;
  String _status = '';
  int _uploaded = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Firebase Migration', style: TextStyle(color: Colors.black87)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.cloud_upload_outlined,
                size: 80,
                color: _isMigrating ? const Color(0xFF4A9B8E) : Colors.grey[400],
              ),
              const SizedBox(height: 24),
              Text(
                'Upload Pets to Firebase',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'This will upload ${allPets.length} pets from local data to Firestore',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 32),
              if (_status.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF4A9B8E)),
                  ),
                  child: Text(
                    _status,
                    style: const TextStyle(
                      color: Color(0xFF4A9B8E),
                      fontSize: 14,
                    ),
                  ),
                ),
              const SizedBox(height: 24),
              if (_isMigrating)
                Column(
                  children: [
                    const CircularProgressIndicator(color: Color(0xFF4A9B8E)),
                    const SizedBox(height: 16),
                    Text('Uploaded: $_uploaded / ${allPets.length}'),
                  ],
                )
              else
                ElevatedButton.icon(
                  onPressed: _migratePets,
                  icon: const Icon(Icons.upload),
                  label: const Text('Start Migration'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A9B8E),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _migratePets() async {
    setState(() {
      _isMigrating = true;
      _status = 'Starting migration...';
      _uploaded = 0;
    });

    try {
      for (var pet in allPets) {
        setState(() {
          _status = 'Uploading ${pet['name']}...';
        });

        await firebaseService.addPet({
          'name': pet['name'],
          'type': pet['type'],
          'age': pet['age'],
          'gender': pet['gender'],
          'location': pet['location'],
          'image': pet['image'], // Asset path for now
          'description': pet['description'] ?? 'A lovely pet looking for a home',
          'weight': pet['weight'] ?? 'Unknown',
          'color': pet['color'] ?? 'Unknown',
        });

        setState(() {
          _uploaded++;
        });

        // Small delay to avoid overwhelming Firestore
        await Future.delayed(const Duration(milliseconds: 300));
      }

      setState(() {
        _status = '✅ Migration complete! ${_uploaded} pets uploaded to Firebase.';
        _isMigrating = false;
      });

      // Show success dialog
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text('Success!'),
            content: Text('${_uploaded} pets have been uploaded to Firebase Firestore.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Close migration screen
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      setState(() {
        _status = '❌ Error: $e';
        _isMigrating = false;
      });
    }
  }
}
