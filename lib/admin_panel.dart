import 'package:flutter/material.dart';
import 'firebase_service.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'image_helper.dart';
import 'admin_reply_screen.dart';

class AdminPanel extends StatefulWidget {
  const AdminPanel({super.key});

  @override
  State<AdminPanel> createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final firebaseService = FirebaseService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    
    // Security check
    if (!firebaseService.isAdmin) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Access Denied: Admin privileges required'),
            backgroundColor: Colors.red,
          ),
        );
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 24),
                      _buildStatsOverview(),
                    ],
                  ),
                ),
              ),
              SliverPersistentHeader(
                delegate: _SliverAppBarDelegate(
                  _buildCustomTabBar(),
                ),
                pinned: true,
              ),
            ];
          },
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildPetsTab(),
              _buildRequestsTab(),
              _buildHistoryTab(),
              _buildChatsTab(),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddPetDialog(),
        backgroundColor: Colors.teal, // Premium feel
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Add Pet', style: TextStyle(color: Colors.white)),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Dashboard',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: Colors.teal,
                letterSpacing: -1,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Welcome back, Admin',
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey[200]!, width: 2),
          ),
          child: IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsOverview() {
    return SizedBox(
      height: 140,
      child: ListView(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none, // Allows shadow to overflow nicely
        children: [
          StreamBuilder<List<Map<String, dynamic>>>(
            stream: firebaseService.getPets(),
            builder: (context, snapshot) {
              final count = snapshot.data?.length ?? 0;
              return _buildStatCard('Total Pets', count.toString(), Icons.pets_outlined, const Color(0xFFE0F2F1), const Color(0xFF00695C));
            },
          ),
          const SizedBox(width: 16),
          StreamBuilder<List<Map<String, dynamic>>>(
            stream: firebaseService.getAllAdoptionRequests(),
            builder: (context, snapshot) {
              final count = snapshot.data?.where((r) => r['status'] == 'pending').length ?? 0;
              return _buildStatCard('Pending', count.toString(), Icons.pending_outlined, const Color(0xFFFFF3E0), const Color(0xFFEF6C00));
            },
          ),
          const SizedBox(width: 16),
          StreamBuilder<List<Map<String, dynamic>>>(
            stream: firebaseService.getAllAdminChats(),
            builder: (context, snapshot) {
              final chats = snapshot.data ?? [];
              final count = chats.length;
              return _buildStatCard('Total Chats', count.toString(), Icons.chat_bubble_outline_rounded, const Color(0xFFE3F2FD), const Color(0xFF1565C0));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color bgColor, Color iconColor) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.6),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: iconColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: iconColor.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCustomTabBar() {
    return Container(
      height: 80, // Explicit total height matching the delegate
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(30),
        ),
        padding: const EdgeInsets.all(4),
        child: TabBar(
          controller: _tabController,
          indicator: BoxDecoration(
            color: Colors.teal,
            borderRadius: BorderRadius.circular(26),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          labelColor: Colors.white,
          unselectedLabelColor: Colors.grey[600],
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          dividerColor: Colors.transparent,
          indicatorSize: TabBarIndicatorSize.tab,
          tabs: const [
            Tab(text: 'Pets'),
            Tab(text: 'Requests'),
            Tab(text: 'History'),
            Tab(text: 'Chats'),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryTab() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: firebaseService.getAllAdoptionRequests(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Colors.black));
        }
        
        final allRequests = snapshot.data ?? [];
        // Filter for approved or rejected requests (Logs)
        final history = allRequests.where((r) => 
          r['status'] == 'approved' || r['status'] == 'rejected'
        ).toList();

        if (history.isEmpty) {
          return _buildEmptyState(Icons.history, 'No request history');
        }
        
        return ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: history.length,
          separatorBuilder: (_,__) => const SizedBox(height: 16),
          itemBuilder: (context, index) => _buildRequestCard(history[index], isHistory: true),
        );
      },
    );
  }

  Widget _buildPetsTab() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: firebaseService.getPets(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptyState(Icons.pets_outlined, 'No pets added yet');
        }
        final pets = snapshot.data!;
        
        return ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: pets.length,
          separatorBuilder: (_,__) => const SizedBox(height: 12),
          itemBuilder: (context, index) => _buildPetCard(pets[index]),
        );
      },
    );
  }

  Widget _buildPetCard(Map<String, dynamic> pet) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: Row(
        children: [
          Hero(
            tag: 'pet_${pet['id']}',
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                image: pet['imageBase64'] != null && (pet['imageBase64'] as String).isNotEmpty
                    ? DecorationImage(
                        image: MemoryImage(base64Decode(pet['imageBase64'])),
                        fit: BoxFit.cover,
                      )
                    : DecorationImage(
                        image: AssetImage(pet['image'] ?? 'assets/dog1.jpg'),
                        fit: BoxFit.cover,
                        onError: (_,__) {},
                      ),
                color: Colors.grey[200],
              ),
              child: (pet['image'] == null && pet['imageBase64'] == null) 
                  ? const Icon(Icons.pets, color: Colors.grey) 
                  : null,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pet['name'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${pet['type']} • ${pet['age']}',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[500],
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _showEditPetDialog(pet),
            icon: const Icon(Icons.edit_outlined, size: 20, color: Colors.black,),
            style: IconButton.styleFrom(
              backgroundColor: Colors.grey[50], 
              shape: const CircleBorder(),
            ),
          ),
          const SizedBox(width: 4),
          IconButton(
            onPressed: () => _deletePet(pet['id']),
            icon: const Icon(Icons.delete_outline, size: 20, color: Colors.red),
            style: IconButton.styleFrom(
              backgroundColor: Colors.red[50], 
              shape: const CircleBorder(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestsTab() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: firebaseService.getAllAdoptionRequests(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Colors.black));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptyState(Icons.inbox_outlined, 'No requests found');
        }
        final allRequests = snapshot.data!;
        // Filter ONLY pending requests
        final requests = allRequests.where((r) => r['status'] == 'pending').toList();

        if (requests.isEmpty) {
           return _buildEmptyState(Icons.inbox_outlined, 'No pending requests');
        }
        
        return ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: requests.length,
          separatorBuilder: (_,__) => const SizedBox(height: 16),
          itemBuilder: (context, index) => _buildRequestCard(requests[index]),
        );
      },
    );
  }

  Widget _buildRequestCard(Map<String, dynamic> request, {bool isHistory = false}) {
    final status = request['status'] ?? 'pending';
    final isPending = status == 'pending';
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey[100]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.grey[100],
                child: const Icon(Icons.person, color: Colors.grey),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request['userName'] ?? 'Unknown',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    Text(
                      'for ${request['petName']}',
                      style: TextStyle(color: Colors.grey[500], fontSize: 12),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: isPending ? Colors.orange[50] : (status == 'approved' ? Colors.green[50] : Colors.red[50]),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isPending ? Colors.orange : (status == 'approved' ? Colors.green : Colors.red),
                  ),
                ),
              ),
            ],
          ),
          if (isPending) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Divider(height: 1),
            ),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => _updateRequestStatus(request['id'], 'rejected'),
                    child: const Text('Decline', style: TextStyle(color: Colors.grey)),
                  ),
                ),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _updateRequestStatus(request['id'], 'approved'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Approve'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildChatsTab() {
      return StreamBuilder<List<Map<String, dynamic>>>(
      stream: firebaseService.getAllAdminChats(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
           return const Center(child: CircularProgressIndicator(color: Colors.black));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptyState(Icons.chat_bubble_outline_rounded, 'No messages');
        }
        final chats = snapshot.data!;
        
        return ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: chats.length,
          separatorBuilder: (_,__) => const SizedBox(height: 12),
          itemBuilder: (context, index) => _buildChatCard(chats[index]),
        );
      },
    );
  }

  Widget _buildChatCard(Map<String, dynamic> chat) {
    final unread = chat['unreadByAdmin'] ?? 0;
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AdminReplyScreen(
              chatId: chat['id'],
              userName: chat['userName'] ?? 'Unknown User',
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey[100]!),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.grey[100],
              radius: 24,
              child: const Icon(Icons.person_outline, color: Colors.black),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        chat['userName'] ?? 'User',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      Text(
                        _formatDate(chat['lastMessageAt']),
                        style: TextStyle(color: Colors.grey[400], fontSize: 11),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          chat['lastMessage'] ?? 'Started a chat',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: unread > 0 ? Colors.black : Colors.grey[500],
                            fontWeight: unread > 0 ? FontWeight.w600 : FontWeight.normal,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      if (unread > 0)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            unread.toString(),
                            style: const TextStyle(color: Colors.white, fontSize: 10),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(IconData icon, String label) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 48, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(label, style: TextStyle(color: Colors.grey[400])),
        ],
      ),
    );
  }

  // --- Helpers (Same as before) ---
  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return '';
    if (timestamp is Timestamp) {
      final date = timestamp.toDate();
      final now = DateTime.now();
      if (date.year == now.year && date.month == now.month && date.day == now.day) {
        return DateFormat('h:mm a').format(date);
      }
      return DateFormat('MMM d').format(date);
    }
    return '';
  }

  Future<void> _updateRequestStatus(String id, String status) async {
    try {
      await firebaseService.updateAdoptionRequestStatus(id, status);
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _deletePet(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Pet', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Are you sure you want to delete this pet? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await firebaseService.deletePet(id);
    }
  }

  // --- NEW: Success Modal ---
  void _showSuccessModal(String action, String petName) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allows content to take up more screen space
      backgroundColor: Colors.transparent,
      builder: (modalContext) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(25.0)),
            boxShadow: [
              BoxShadow(blurRadius: 10, color: Colors.black.withOpacity(0.1)),
            ],
          ),
          child: SafeArea(
            minimum: const EdgeInsets.only(top: 20), // Responsive padding
            child: Padding(
              padding: const EdgeInsets.all(30.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.check_circle_rounded,
                    color: Colors.teal,
                    size: 80,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Success!',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'The Pet $petName has been successfully $action.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(modalContext),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Done', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // --- Dialogs (Modified to call success modal) ---
  void _showAddPetDialog() {
    _showPetDialog(action: 'added');
  }
  
  void _showEditPetDialog(Map<String, dynamic> pet) {
    _showPetDialog(pet: pet, action: 'updated');
  }

  void _showPetDialog({Map<String, dynamic>? pet, required String action}) {
    final isEditing = pet != null;
    final nameController = TextEditingController(text: pet?['name']);
    final ageController = TextEditingController(text: pet?['age']?.toString().replaceAll(' yrs', ''));
    final locationController = TextEditingController(text: pet?['location']);
    String selectedType = pet?['type'] ?? 'dog';
    String selectedGender = pet?['gender'] ?? 'male';
    String? selectedImageBase64 = pet?['imageBase64'];
    final service = firebaseService; // Capture reference
    final rootContext = context; // Capture context for modal display

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (builderContext, setState) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          // Use ConstrainedBox to control size on large screens, while SingleChildScrollView allows responsiveness
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isEditing ? 'Edit Pet' : 'New Pet',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 24),
                    
                    // Image Picker
                    Center(
                      child: GestureDetector(
                        onTap: () async {
                            final base64 = await ImageHelper.pickImageAsBase64();
                            if (base64 != null) setState(() => selectedImageBase64 = base64);
                          },
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            shape: BoxShape.circle,
                            image: selectedImageBase64 != null 
                                ? DecorationImage(fit: BoxFit.cover, image: MemoryImage(base64Decode(selectedImageBase64!)))
                                : null,
                          ),
                          child: selectedImageBase64 == null 
                            ? const Icon(Icons.add_a_photo, color: Colors.grey)
                            : null,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    _buildTextField(nameController, 'Name', Icons.pets),
                    const SizedBox(height: 16),
                    
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: selectedType,
                            decoration: _inputDecoration('Type', Icons.category),
                            items: ['dog', 'cat', 'bird', 'rabbit', 'other']
                                .map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                            onChanged: (v) => setState(() => selectedType = v!),
                          ),
                        ),
                        const SizedBox(width: 12),
                          Expanded(
                          child: DropdownButtonFormField<String>(
                            value: selectedGender,
                            decoration: _inputDecoration('Gender', Icons.wc),
                            items: ['male', 'female']
                                .map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                            onChanged: (v) => setState(() => selectedGender = v!),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(ageController, 'Age', Icons.cake, isNumber: true),
                    const SizedBox(height: 16),
                    _buildTextField(locationController, 'Location', Icons.location_on),
                    
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                            if (nameController.text.isEmpty) return;
                            final petName = nameController.text.trim();
                            final data = {
                              'name': petName,
                              'type': selectedType,
                              'gender': selectedGender,
                              'age': '${ageController.text} yrs',
                              'location': locationController.text.trim(),
                              'imageBase64': selectedImageBase64,
                            };
                            
                            try {
                              if (isEditing) {
                                await service.updatePet(pet!['id'], data);
                              } else {
                                await service.addPet(data);
                              }
                              
                              // Close the dialog first
                              Navigator.pop(dialogContext);
                              
                              // Show success modal
                              _showSuccessModal(action, petName);
                            } catch (e) {
                              // Close the dialog and show a Snackbar error
                              Navigator.pop(dialogContext);
                              ScaffoldMessenger.of(rootContext).showSnackBar(
                                SnackBar(
                                  content: Text('Failed to $action pet: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.all(16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: Text(isEditing ? 'Update Pet' : 'Create Pet'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool isNumber = false}) {
      return TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: _inputDecoration(label, icon),
      );
  }
  
  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, size: 20, color: Colors.grey[400]),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[200]!)),
      filled: true,
      fillColor: Colors.grey[50],
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget _tabBar;
  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => 80;
  @override
  double get maxExtent => 80;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) => false;
}