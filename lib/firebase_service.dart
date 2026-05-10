import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;
  User? get currentUser => _auth.currentUser;

  // Check if current user is admin
  bool get isAdmin {
    const adminEmails = ['admin@test.com', 'admin@furever.com', 'test@test.com'];
    return currentUser?.email != null && adminEmails.contains(currentUser!.email);
  }

  // ==================== PETS ====================
  
  /// Add a new pet to Firestore
  Future<String> addPet(Map<String, dynamic> petData) async {
    try {
      final docRef = await _firestore.collection('pets').add({
        ...petData,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'ownerId': currentUserId,
      });
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to add pet: $e');
    }
  }

  /// Get user's adopted pets
  Stream<List<Map<String, dynamic>>> getAdoptedPets() {
    if (currentUserId == null) return Stream.value([]);
    
    return _firestore
        .collection('pets')
        .where('adoptedBy', isEqualTo: currentUserId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => {'id': doc.id, ...doc.data()})
            .toList());
  }

  /// Get all pets (excludes adopted pets)
  Stream<List<Map<String, dynamic>>> getPets() {
    return _firestore
        .collection('pets')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => {'id': doc.id, ...doc.data()})
            .where((pet) => pet['isAdopted'] != true) // Filter out adopted pets
            .toList());
  }

  /// Get pets by category (excludes adopted pets)
  Stream<List<Map<String, dynamic>>> getPetsByCategory(String category) {
    return _firestore
        .collection('pets')
        .where('type', isEqualTo: category.toLowerCase())
        .snapshots() // removed orderBy to avoid composite index requirement
        .map((snapshot) {
          final pets = snapshot.docs
              .map((doc) => {'id': doc.id, ...doc.data()})
              .where((pet) => pet['isAdopted'] != true)
              .toList();
          
          // Sort client-side
          pets.sort((a, b) {
            final aTime = (a['createdAt'] as Timestamp?)?.toDate() ?? DateTime(0);
            final bTime = (b['createdAt'] as Timestamp?)?.toDate() ?? DateTime(0);
            return bTime.compareTo(aTime); // Descending
          });
          
          return pets;
        });
  }

  /// Get a single pet by ID
  Future<Map<String, dynamic>?> getPetById(String petId) async {
    try {
      final doc = await _firestore.collection('pets').doc(petId).get();
      if (doc.exists) {
        return {'id': doc.id, ...doc.data()!};
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get pet: $e');
    }
  }

  /// Update pet information
  Future<void> updatePet(String petId, Map<String, dynamic> updates) async {
    try {
      await _firestore.collection('pets').doc(petId).update({
        ...updates,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      // If pet name was updated, also update all adoption requests for this pet
      if (updates.containsKey('name')) {
        final requestsSnapshot = await _firestore
            .collection('adoptionRequests')
            .where('petId', isEqualTo: petId)
            .get();
        
        for (final doc in requestsSnapshot.docs) {
          await doc.reference.update({
            'petName': updates['name'],
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      }
    } catch (e) {
      throw Exception('Failed to update pet: $e');
    }
  }

  /// Delete a pet
  Future<void> deletePet(String petId) async {
    try {
      await _firestore.collection('pets').doc(petId).delete();
      
      // Also delete any pending adoption requests for this pet?
      // Optional: keep them for records or delete them. For now, let's keep them but maybe mark as cancelled?
      // Or just leave them. If the pet is gone, the request is invalid. 
      // Let's at least mark requests as 'unavailable'
      
      final requests = await _firestore
          .collection('adoptionRequests')
          .where('petId', isEqualTo: petId)
          .get();

      for (final doc in requests.docs) {
        await doc.reference.update({'status': 'cancelled'});
      }

    } catch (e) {
      throw Exception('Failed to delete pet: $e');
    }
  }



  // ==================== FAVORITES ====================
  
  /// Add pet to favorites
  Future<void> addToFavorites(String petId) async {
    if (currentUserId == null) throw Exception('User not logged in');
    
    try {
      await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('favorites')
          .doc(petId)
          .set({
        'petId': petId,
        'addedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to add to favorites: $e');
    }
  }

  /// Remove pet from favorites
  Future<void> removeFromFavorites(String petId) async {
    if (currentUserId == null) throw Exception('User not logged in');
    
    try {
      await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('favorites')
          .doc(petId)
          .delete();
    } catch (e) {
      throw Exception('Failed to remove from favorites: $e');
    }
  }

  /// Get user's favorite pets
  Stream<List<String>> getFavoritePetIds() {
    if (currentUserId == null) return Stream.value([]);
    
    return _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('favorites')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.id).toList());
  }

  /// Check if pet is favorited
  Future<bool> isFavorite(String petId) async {
    if (currentUserId == null) return false;
    
    try {
      final doc = await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('favorites')
          .doc(petId)
          .get();
      return doc.exists;
    } catch (e) {
      return false;
    }
  }

  // ==================== ADOPTION REQUESTS ====================
  
  /// Submit an adoption request
  Future<String> submitAdoptionRequest({
    required String petId,
    required String petName,
    required String petType,
    String? message,
    String? petImageBase64,
  }) async {
    if (currentUserId == null) throw Exception('User not logged in');
    
    try {
      final docRef = await _firestore.collection('adoptionRequests').add({
        'petId': petId,
        'petName': petName,
        'petType': petType,
        'petImageBase64': petImageBase64,
        'userId': currentUserId,
        'userName': currentUser?.displayName ?? 'Anonymous',
        'userEmail': currentUser?.email ?? '',
        'message': message ?? '',
        'status': 'pending', // pending, approved, rejected
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to submit adoption request: $e');
    }
  }

  /// Get user's adoption requests
  Stream<List<Map<String, dynamic>>> getUserAdoptionRequests() {
    if (currentUserId == null) return Stream.value([]);
    
    return _firestore
        .collection('adoptionRequests')
        .where('userId', isEqualTo: currentUserId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => {'id': doc.id, ...doc.data()})
            .toList());
  }

  /// Update adoption request status (admin only)
  Future<void> updateAdoptionRequestStatus(String requestId, String status) async {
    try {
      // Get the request to find the petId and userId
      final requestDoc = await _firestore.collection('adoptionRequests').doc(requestId).get();
      final requestData = requestDoc.data();
      final petId = requestData?['petId'];
      final userId = requestData?['userId'];
      final petName = requestData?['petName'] ?? 'your pet';
      
      // Update the request status
      await _firestore.collection('adoptionRequests').doc(requestId).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      // If approved, mark the pet as adopted so it won't show in listings
      if (status == 'approved' && petId != null) {
        await _firestore.collection('pets').doc(petId).update({
          'isAdopted': true,
          'adoptedAt': FieldValue.serverTimestamp(),
          'adoptedBy': userId,
        });
        
        // Send automatic congratulations message to user via admin chat
        if (userId != null) {
          final threadId = '${userId}_admin';
          await _firestore.collection('adminChats').doc(threadId).collection('messages').add({
            'message': '🎉 Congratulations! Your adoption request for "$petName" has been APPROVED!\n\n📍 Please visit our shelter at:\nFurever Friends Pet Shelter\nPanabo City, Philippines\n\n⏰ Operating Hours:\nMonday - Saturday: 9:00 AM - 5:00 PM\nSunday: Closed\n\n📞 Contact: +63 912 345 6789\n\nBring a valid ID and this message when you visit. We can\'t wait to see you! 🐾',
            'senderId': 'admin',
            'senderName': 'Furever Friends Admin',
            'createdAt': FieldValue.serverTimestamp(),
            'isAdmin': true,
          });
          
          // Update the chat's last message
          await _firestore.collection('adminChats').doc(threadId).set({
            'userId': userId,
            'userName': requestData?['userName'] ?? 'User', // Also ensure userName is set
            'lastMessage': 'Your adoption request has been approved! 🎉',
            'lastMessageAt': FieldValue.serverTimestamp(),
            'unreadCount': FieldValue.increment(1),
            'unreadByAdmin': 0, // Admin just sent it, so read by admin
          }, SetOptions(merge: true));
        }
        
        // Also reject all other pending requests for this pet
        final otherRequests = await _firestore
            .collection('adoptionRequests')
            .where('petId', isEqualTo: petId)
            .where('status', isEqualTo: 'pending')
            .get();
        
        for (final doc in otherRequests.docs) {
          if (doc.id != requestId) {
            final otherData = doc.data();
            final otherUserId = otherData['userId'];
            if (otherUserId != null) {
              await doc.reference.update({
                'status': 'rejected',
                'updatedAt': FieldValue.serverTimestamp(),
              });
              
              // Notify this user that they were not selected
              await _sendRejectionMessage(otherUserId, petName, otherData['userName'] ?? 'User');
            }
          }
        }
      } else if (status == 'rejected' && userId != null) {
        await _sendRejectionMessage(userId, petName, requestData?['userName'] ?? 'User');
      }
    } catch (e) {
      throw Exception('Failed to update request status: $e');
    }
  }

  Future<void> _sendRejectionMessage(String userId, String petName, String userName) async {
    final threadId = '${userId}_admin';
    await _firestore.collection('adminChats').doc(threadId).collection('messages').add({
      'message': 'We appreciate your interest in adopting "$petName".\n\nUnfortunately, we are unable to proceed with your adoption request at this time. This decision was made after careful consideration of all applications to ensure the best match for the pet\'s needs.\n\nWe encourage you to check out our other lovely pets looking for a home!',
      'senderId': 'admin',
      'senderName': 'Furever Friends Admin',
      'createdAt': FieldValue.serverTimestamp(),
      'isAdmin': true,
    });
    
    // Update the chat's last message
    await _firestore.collection('adminChats').doc(threadId).set({
      'userId': userId,
      'userName': userName,
      'lastMessage': 'Update regarding your adoption request for $petName',
      'lastMessageAt': FieldValue.serverTimestamp(),
      'unreadCount': FieldValue.increment(1),
      'unreadByAdmin': 0,
    }, SetOptions(merge: true));
  }

  // ==================== USER PROFILE ====================
  
  /// Create or update user profile
  Future<void> updateUserProfile({
    String? displayName,
    String? photoURL,
    String? phoneNumber,
    String? location,
  }) async {
    if (currentUserId == null) throw Exception('User not logged in');
    
    try {
      final updates = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
      };
      
      if (displayName != null) updates['displayName'] = displayName;
      if (photoURL != null) updates['photoURL'] = photoURL;
      if (phoneNumber != null) updates['phoneNumber'] = phoneNumber;
      if (location != null) updates['location'] = location;
      
      await _firestore
          .collection('users')
          .doc(currentUserId)
          .set(updates, SetOptions(merge: true));
      
      // Also update Firebase Auth profile
      // Also update Firebase Auth profile (best effort)
      if (displayName != null || photoURL != null) {
        try {
          if (displayName != null) await currentUser?.updateDisplayName(displayName);
          // Only update photoURL in Auth if it's a valid URL, otherwise skip to avoid errors with Base64
          if (photoURL != null && (photoURL.startsWith('http') || photoURL.length < 2000)) {
             await currentUser?.updatePhotoURL(photoURL);
          }
        } catch (e) {
          // Ignore auth update errors (e.g. invalid photo URL format for Auth)
          print('Auth profile update failed: $e');
        }
      }
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  /// Get user profile
  Future<Map<String, dynamic>?> getUserProfile([String? userId]) async {
    final uid = userId ?? currentUserId;
    if (uid == null) return null;
    
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return {'id': doc.id, ...doc.data()!};
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user profile: $e');
    }
  }

  // ==================== COMMUNITY CHAT ====================
  
  /// Send a message to community chat
  Future<void> sendCommunityMessage(String message) async {
    if (currentUserId == null) throw Exception('User not logged in');
    
    try {
      // Reload user to get the latest displayName
      await currentUser?.reload();
      final updatedUser = _auth.currentUser;
      
      await _firestore.collection('communityMessages').add({
        'userId': currentUserId,
        'userName': updatedUser?.displayName ?? 'Anonymous',
        'userPhoto': updatedUser?.photoURL ?? '',
        'message': message,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }

  /// Get community messages
  Stream<List<Map<String, dynamic>>> getCommunityMessages({int limit = 50}) {
    return _firestore
        .collection('communityMessages')
        .orderBy('createdAt', descending: false)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => {'id': doc.id, ...doc.data()})
            .toList());
  }

  /// Delete a message (user can only delete their own)
  Future<void> deleteCommunityMessage(String messageId) async {
    if (currentUserId == null) throw Exception('User not logged in');
    
    try {
      final doc = await _firestore.collection('communityMessages').doc(messageId).get();
      if (doc.exists && doc.data()?['userId'] == currentUserId) {
        await doc.reference.delete();
      } else {
        throw Exception('Not authorized to delete this message');
      }
    } catch (e) {
      throw Exception('Failed to delete message: $e');
    }
  }

  // ==================== ADMIN CHAT ====================
  
  /// Send message to admin
  Future<void> sendAdminMessage(String message, {String? petId}) async {
    if (currentUserId == null) throw Exception('User not logged in');
    
    try {
      // Reload user to get the latest displayName
      await currentUser?.reload();
      final updatedUser = _auth.currentUser;
      
      // Create or get chat thread
      final threadId = '${currentUserId}_admin';
      
      await _firestore
          .collection('adminChats')
          .doc(threadId)
          .collection('messages')
          .add({
        'senderId': currentUserId,
        'senderName': updatedUser?.displayName ?? 'User',
        'message': message,
        'petId': petId,
        'isAdmin': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
      
      // Update thread metadata
      await _firestore.collection('adminChats').doc(threadId).set({
        'userId': currentUserId,
        'userName': updatedUser?.displayName ?? 'User',
        'lastMessage': message,
        'lastMessageAt': FieldValue.serverTimestamp(),
        'unreadByAdmin': FieldValue.increment(1),
      }, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to send admin message: $e');
    }
  }

  /// Get admin chat messages
  Stream<List<Map<String, dynamic>>> getAdminChatMessages() {
    if (currentUserId == null) return Stream.value([]);
    
    final threadId = '${currentUserId}_admin';
    
    return _firestore
        .collection('adminChats')
        .doc(threadId)
        .collection('messages')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => {'id': doc.id, ...doc.data()})
            .toList());
  }

  /// Get admin chat messages for a specific user (admin view)
  Stream<List<Map<String, dynamic>>> getAdminChatMessagesForUser(String chatId) {
    return _firestore
        .collection('adminChats')
        .doc(chatId)
        .collection('messages')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => {'id': doc.id, ...doc.data()})
            .toList());
  }

  /// Send admin reply to user
  Future<void> sendAdminReply(String chatId, String message) async {
    try {
      // Add message to chat
      await _firestore
          .collection('adminChats')
          .doc(chatId)
          .collection('messages')
          .add({
        'senderId': 'admin',
        'senderName': 'Furever Friends Admin',
        'message': message,
        'isAdmin': true,
        'createdAt': FieldValue.serverTimestamp(),
      });
      
      // Update thread metadata
      await _firestore.collection('adminChats').doc(chatId).set({
        'lastMessage': message,
        'lastMessageAt': FieldValue.serverTimestamp(),
        'unreadByAdmin': 0,
        'unreadCount': FieldValue.increment(1),
      }, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to send admin reply: $e');
    }
  }

  /// Mark admin chat as read by admin
  Future<void> markAdminChatAsRead(String chatId) async {
    try {
      await _firestore.collection('adminChats').doc(chatId).update({
        'unreadByAdmin': 0,
      });
    } catch (e) {
      // Silently fail
    }
  }

  // ==================== STATISTICS ====================
  
  /// Get user statistics
  Future<Map<String, int>> getUserStats() async {
    if (currentUserId == null) {
      return {'adopted': 0, 'favorites': 0, 'messages': 0};
    }
    
    try {
      // Get adopted pets count
      final adoptedSnapshot = await _firestore
          .collection('adoptionRequests')
          .where('userId', isEqualTo: currentUserId)
          .where('status', isEqualTo: 'approved')
          .get();
      
      // Get favorites count
      final favoritesSnapshot = await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('favorites')
          .get();
      
      // Get messages count
      final messagesSnapshot = await _firestore
          .collection('communityMessages')
          .where('userId', isEqualTo: currentUserId)
          .get();
      
      return {
        'adopted': adoptedSnapshot.docs.length,
        'favorites': favoritesSnapshot.docs.length,
        'messages': messagesSnapshot.docs.length,
      };
    } catch (e) {
      return {'adopted': 0, 'favorites': 0, 'messages': 0};
    }
  }

  // ==================== ADMIN FUNCTIONS ====================
  
  /// Get all adoption requests (admin only)
  Stream<List<Map<String, dynamic>>> getAllAdoptionRequests() {
    return _firestore
        .collection('adoptionRequests')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => {'id': doc.id, ...doc.data()})
            .toList());
  }

  /// Get all admin chats (admin only)
  Stream<List<Map<String, dynamic>>> getAllAdminChats() {
    return _firestore
        .collection('adminChats')
        .orderBy('lastMessageAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => {'id': doc.id, ...doc.data()})
            .toList());
  }

  /// Get all users (admin only)
  Stream<List<Map<String, dynamic>>> getAllUsers() {
    return _firestore
        .collection('users')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => {'id': doc.id, ...doc.data()})
            .toList());
  }

  Future<void> logout() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception('Failed to logout: $e');
    }
  }

  /// Change password
  Future<void> changePassword(String currentPassword, String newPassword) async {
    if (currentUserId == null) throw Exception('User not logged in');
    if (currentUser?.email == null) throw Exception('User email not found');

    try {
      // Re-authenticate user
      final credential = EmailAuthProvider.credential(
        email: currentUser!.email!,
        password: currentPassword,
      );
      
      await currentUser!.reauthenticateWithCredential(credential);
      
      // Update password
      await currentUser!.updatePassword(newPassword);
      
      // Logout will be handled by the UI after success message
    } catch (e) {
      throw Exception('Failed to change password: $e');
    }
  }
}

