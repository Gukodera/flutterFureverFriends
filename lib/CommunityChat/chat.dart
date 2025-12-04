import 'package:flutter/material.dart';
import '../PetScreen.dart';
import '../favorite.dart';
import '../pets.dart';
import '../profile.dart';
import '../pet_data.dart';

class CommunityChatScreen extends StatefulWidget {
  const CommunityChatScreen({super.key});

  @override
  State<CommunityChatScreen> createState() => _CommunityChatScreenState();
}

class _CommunityChatScreenState extends State<CommunityChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  List<Map<String, dynamic>> _messages = [
    {
      'username': 'Sarah Miller',
      'avatar': 'assets/user1.jpg',
      'message': 'Just adopted a beautiful golden retriever! So happy! 🐕',
      'time': '10:30 AM',
      'isMe': false,
    },
    {
      'username': 'You',
      'avatar': 'assets/profile.jpg',
      'message': 'Congratulations! That\'s wonderful news!',
      'time': '10:32 AM',
      'isMe': true,
    },
    {
      'username': 'Maturan',
      'avatar': 'assets/user2.jpg',
      'message': 'Does anyone know a good vet in Panabo City?',
      'time': '10:35 AM',
      'isMe': false,
    },
    {
      'username': 'James Cases',
      'avatar': 'assets/user3.jpg',
      'message': 'I recommend Dr. Santos Animal Clinic. They\'re excellent!',
      'time': '10:37 AM',
      'isMe': false,
    },
  ];

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    setState(() {
      _messages.add({
        'username': 'You',
        'avatar': 'assets/profile.jpg',
        'message': _messageController.text.trim(),
        'time': _getCurrentTime(),
        'isMe': true,
      });
    });

    _messageController.clear();
    
    // Auto scroll to bottom
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _getCurrentTime() {
    final now = DateTime.now();
    final hour = now.hour > 12 ? now.hour - 12 : now.hour;
    final minute = now.minute.toString().padLeft(2, '0');
    final period = now.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        shadowColor: Colors.black.withOpacity(0.1),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen()),
            );
          },
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Community Chat',
              style: TextStyle(
                color: Colors.black87,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '124 members online',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black87),
            onPressed: () {
              _showChatOptions(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages List
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? 32.0 : 16.0,
                vertical: 16.0,
              ),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _buildMessageBubble(_messages[index], isTablet);
              },
            ),
          ),

          // Message Input
          _buildMessageInput(isTablet),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message, bool isTablet) {
    final isMe = message['isMe'] as bool;
    final size = MediaQuery.of(context).size;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: 18,
              backgroundColor: const Color(0xFF4A9B8E),
              child: CircleAvatar(
                radius: 16,
                backgroundImage: AssetImage(message['avatar']),
                backgroundColor: Colors.grey[300],
                onBackgroundImageError: (exception, stackTrace) {},
                child: Icon(Icons.person, color: Colors.grey[400], size: 20),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                if (!isMe)
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 4),
                    child: Text(
                      message['username'],
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                Container(
                  constraints: BoxConstraints(
                    maxWidth: isTablet ? 400 : size.width * 0.65,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isMe ? const Color(0xFF4A9B8E) : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isMe ? 16 : 4),
                      bottomRight: Radius.circular(isMe ? 4 : 16),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    message['message'],
                    style: TextStyle(
                      color: isMe ? Colors.white : Colors.black87,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 4, left: 4, right: 4),
                  child: Text(
                    message['time'],
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[500],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (isMe) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 18,
              backgroundColor: const Color(0xFF4A9B8E),
              child: CircleAvatar(
                radius: 16,
                backgroundImage: AssetImage(message['avatar']),
                backgroundColor: Colors.grey[300],
                onBackgroundImageError: (exception, stackTrace) {},
                child: Icon(Icons.person, color: Colors.grey[400], size: 20),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageInput(bool isTablet) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 32.0 : 16.0,
        vertical: 12.0,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              icon: Icon(Icons.add_circle_outline, color: Colors.grey[600]),
              onPressed: () {
                _showAttachmentOptions(context);
              },
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: _messageController,
                  decoration: InputDecoration(
                    hintText: 'Type a message...',
                    hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                  maxLines: null,
                  textCapitalization: TextCapitalization.sentences,
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: const BoxDecoration(
                color: Color(0xFF4A9B8E),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.send, color: Colors.white, size: 20),
                onPressed: _sendMessage,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAttachmentOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo, color: Color(0xFF4A9B8E)),
              title: const Text('Photo'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Photo upload coming soon!'),
                    backgroundColor: Color(0xFF4A9B8E),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.pets, color: Color(0xFF4A9B8E)),
              title: const Text('Share Pet'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Share pet coming soon!'),
                    backgroundColor: Color(0xFF4A9B8E),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.location_on, color: Color(0xFF4A9B8E)),
              title: const Text('Location'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Location sharing coming soon!'),
                    backgroundColor: Color(0xFF4A9B8E),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showChatOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.info_outline, color: Color(0xFF4A9B8E)),
              title: const Text('Chat Info'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.notifications_off_outlined, color: Color(0xFF4A9B8E)),
              title: const Text('Mute Notifications'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Notifications muted'),
                    backgroundColor: Color(0xFF4A9B8E),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.report_outlined, color: Colors.red),
              title: const Text('Report'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF4A9B8E),
          unselectedItemColor: Colors.grey[400],
          showSelectedLabels: false,
          showUnselectedLabels: false,
          elevation: 0,
          currentIndex: 3, // Messages tab active
          onTap: (index) {
            switch (index) {
              case 0:
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const HomeScreen()),
                );
                break;
              case 1:
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const FavoriteScreen()),
                );
                break;
              case 2:
                 Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => PetsScreen(pets: allPets)),
                );
                break;
              case 3:
                // Already on Messages
                break;
              case 4:
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfileScreen()),
                );
                break;
            }
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.favorite_rounded), label: 'Favorites'),
            BottomNavigationBarItem(icon: Icon(Icons.add_circle_rounded, size: 40, color: Color(0xFF4A9B8E)), label: 'Add'),
            BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_rounded), label: 'Messages'),
            BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}