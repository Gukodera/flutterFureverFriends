import 'package:flutter/material.dart';

class AdminChatScreen extends StatefulWidget {
  final String? petName;
  const AdminChatScreen({super.key, this.petName});

  @override
  State<AdminChatScreen> createState() => _AdminChatScreenState();
}

class _AdminChatScreenState extends State<AdminChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  final List<Map<String, dynamic>> _messages = [];

  @override
  void initState() {
    super.initState();
    // Initial greeting from Admin
    final greeting = widget.petName != null 
        ? 'Hello! I see you\'re interested in ${widget.petName}. How can I help you with the adoption process?'
        : 'Hello! How can we help you today?';
        
    _messages.add({
      'message': greeting,
      'isMe': false,
      'time': _getCurrentTime(),
    });
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    setState(() {
      _messages.add({
        'message': _messageController.text.trim(),
        'isMe': true,
        'time': _getCurrentTime(),
      });
    });

    _messageController.clear();
    
    // Auto scroll
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });

    // Simulate Admin reply
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _messages.add({
            'message': 'Thanks for your message! An adoption specialist will review your inquiry shortly.',
            'isMe': false,
            'time': _getCurrentTime(),
          });
        });
         // Auto scroll again
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // Light grey-blue background
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Stack(
              children: [
                const CircleAvatar(
                  radius: 20,
                  backgroundColor: Color(0xFF4A9B8E),
                  child: Icon(Icons.support_agent, color: Colors.white, size: 24),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.greenAccent,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Admin Support',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Online',
                  style: TextStyle(
                    color: Color(0xFF4A9B8E),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.call, color: Color(0xFF4A9B8E)),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(20),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isMe = msg['isMe'] as bool;
                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isMe ? const Color(0xFF4A9B8E) : Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(20),
                        topRight: const Radius.circular(20),
                        bottomLeft: Radius.circular(isMe ? 20 : 4),
                        bottomRight: Radius.circular(isMe ? 4 : 20),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          msg['message'],
                          style: TextStyle(
                            color: isMe ? Colors.white : Colors.black87,
                            fontSize: 15,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          msg['time'],
                          style: TextStyle(
                            color: isMe ? Colors.white.withOpacity(0.7) : Colors.grey[400],
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF5F7FA),
                borderRadius: BorderRadius.circular(24),
              ),
              child: IconButton(
                icon: const Icon(Icons.add, color: Color(0xFF4A9B8E)),
                onPressed: () {},
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F7FA),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: _messageController,
                  decoration: const InputDecoration(
                    hintText: 'Type a message...',
                    border: InputBorder.none,
                    hintStyle: TextStyle(color: Colors.grey),
                  ),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: _sendMessage,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: Color(0xFF4A9B8E),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
