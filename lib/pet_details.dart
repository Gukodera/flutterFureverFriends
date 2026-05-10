import 'package:flutter/material.dart';
import 'admin_chat.dart';
import 'favorites_manager.dart';
import 'firebase_service.dart';
import 'dart:convert';

class PetDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> pet;

  const PetDetailsScreen({super.key, required this.pet});

  @override
  State<PetDetailsScreen> createState() => _PetDetailsScreenState();
}

class _PetDetailsScreenState extends State<PetDetailsScreen> {
  final firebaseService = FirebaseService();
  bool _hasRequested = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkIfRequested();
  }

  Future<void> _checkIfRequested() async {
    try {
      // Get all user's adoption requests
      final requests = await firebaseService.getUserAdoptionRequests().first;
      
      // Check if this pet has been requested
      final hasRequest = requests.any((req) => 
        req['petId'] == widget.pet['id'] && 
        req['status'] == 'pending'
      );
      
      if (mounted) {
        setState(() {
          _hasRequested = hasRequest;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

void _showSuccessModal() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        final size = MediaQuery.of(context).size;
        final isSmallScreen = size.width < 360;
        
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: EdgeInsets.all(isSmallScreen ? 20.0 : 32.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4A9B8E).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_circle,
                    color: const Color(0xFF4A9B8E),
                    size: isSmallScreen ? 50 : 60,
                  ),
                ),
                SizedBox(height: isSmallScreen ? 16 : 24),
                Text(
                  'Request Successful!',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 18 : 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  softWrap: false,
                  maxLines: 1,
                  overflow: TextOverflow.visible,
                ),
                SizedBox(height: isSmallScreen ? 8 : 12),
                Text(
                  'Your adoption request for ${widget.pet['name']} has been submitted successfully.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 13 : 15,
                    color: Colors.grey[600],
                    height: 1.5,
                  ),
                ),
                SizedBox(height: isSmallScreen ? 16 : 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // Close modal
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4A9B8E),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 12 : 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      'Got it!',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 14 : 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // Full Screen Image with Gradient Overlay
          Positioned.fill(
            bottom: size.height * 0.45,
            child: Hero(
              tag: 'pet-${widget.pet['id'] ?? widget.pet['name']}',
              child: Stack(
                fit: StackFit.expand,
                children: [
                  widget.pet['imageBase64'] != null && (widget.pet['imageBase64'] as String).isNotEmpty
                      ? Image.memory(
                          base64Decode(widget.pet['imageBase64']),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: Colors.grey[300],
                            child: const Icon(Icons.pets, size: 100, color: Colors.grey),
                          ),
                        )
                      : Image.asset(
                          widget.pet['image'] ?? 'assets/placeholder.png',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: Colors.grey[300],
                            child: const Icon(Icons.pets, size: 100, color: Colors.grey),
                          ),
                        ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.3),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Custom App Bar
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CircleAvatar(
                  backgroundColor: Colors.white.withOpacity(0.2),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                ListenableBuilder(
                  listenable: FavoritesManager(),
                  builder: (context, _) {
                    final isFav = FavoritesManager().isFavorite(widget.pet);
                    return GestureDetector(
                      onTap: () => FavoritesManager().toggleFavorite(widget.pet),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isFav ? Icons.favorite : Icons.favorite_border,
                          color: isFav ? Colors.redAccent : Colors.white,
                          size: 24,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // Content Sheet
          DraggableScrollableSheet(
            initialChildSize: 0.55,
            minChildSize: 0.55,
            maxChildSize: 0.9,
            builder: (context, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 20,
                      offset: Offset(0, -5),
                    ),
                  ],
                ),
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                  children: [
                    // Handle bar
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Header: Name, Type, Location
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                (widget.pet['name'] ?? 'Unknown').toString(),
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                  height: 1.1,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Icons.location_on_rounded, size: 16, color: const Color(0xFF4A9B8E)),
                                  const SizedBox(width: 4),
                                  Text(
                                    (widget.pet['location'] ?? 'Unknown').toString(),
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4A9B8E).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            (widget.pet['type'] ?? 'Pet').toString().toUpperCase(),
                            style: const TextStyle(
                              color: Color(0xFF4A9B8E),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Attributes Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildAttributeBadge('Sex', (widget.pet['gender'] ?? '').toString(), Icons.male),
                        _buildAttributeBadge('Age', widget.pet['age'] is int ? '${widget.pet['age']} yrs' : (widget.pet['age'] ?? 'Unknown'), Icons.calendar_today_rounded),
                        _buildAttributeBadge('Weight', '5.5 kg', Icons.monitor_weight_rounded),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Owner/Shelter Info
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[200]!),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: const Color(0xFF4A9B8E), width: 2),
                            ),
                            child: const CircleAvatar(
                              radius: 24,
                              backgroundImage: AssetImage('assets/profile.jpg'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Panabo Shelter',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Pet Owner',
                                  style: TextStyle(
                                    color: Colors.grey[500],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AdminChatScreen(petName: widget.pet['name']),
                                ),
                              );
                            },
                            icon: const Icon(Icons.chat_bubble_rounded, color: Colors.white, size: 20),
                            style: IconButton.styleFrom(
                              backgroundColor: const Color(0xFF4A9B8E),
                              padding: const EdgeInsets.all(12),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Description
                    const Text(
                      'About me',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${widget.pet['name']} is a very friendly and energetic ${widget.pet['type'] ?? 'pet'} looking for a forever home. Loves to play and is good with kids. Fully vaccinated and trained.',
                      style: TextStyle(
                        color: Colors.grey[600],
                        height: 1.6,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Action Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: _isLoading
                          ? Center(
                              child: CircularProgressIndicator(
                                color: const Color(0xFF4A9B8E),
                              ),
                            )
                          : ElevatedButton(
                              onPressed: _hasRequested ? null : () async {
                                // Show confirmation dialog
                                final confirmed = await showDialog<bool>(
                                  context: context,
                                  builder: (dialogContext) => AlertDialog(
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                    title: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF4A9B8E).withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: const Icon(Icons.pets, color: Color(0xFF4A9B8E)),
                                        ),
                                        const SizedBox(width: 12),
                                        const Text('Adopt Pet'),
                                      ],
                                    ),
                                    content: Text('Do you want to submit an adoption request for ${widget.pet['name']}?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(dialogContext, false),
                                        child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                                      ),
                                      ElevatedButton(
                                        onPressed: () => Navigator.pop(dialogContext, true),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFF4A9B8E),
                                          foregroundColor: Colors.white,
                                        ),
                                        child: const Text('Submit Request'),
                                      ),
                                    ],
                                  ),
                                );

                                if (confirmed == true && mounted) {
                                  try {
                                    // Submit adoption request to Firebase
                                    await firebaseService.submitAdoptionRequest(
                                      petId: widget.pet['id'] ?? '',
                                      petName: widget.pet['name'] ?? 'Unknown',
                                      petType: widget.pet['type'] ?? 'Unknown',
                                      message: 'I would like to adopt ${widget.pet['name']}',
                                      petImageBase64: widget.pet['imageBase64'],
                                    );

                                    if (mounted) {
                                      setState(() {
                                        _hasRequested = true;
                                      });
                                      
                                      // Show success modal
                                      _showSuccessModal();
                                    }
                                  } catch (e) {
                                    if (mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Error: $e'),
                                          backgroundColor: Colors.red,
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                        ),
                                      );
                                    }
                                  }
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _hasRequested 
                                    ? Colors.grey[400] 
                                    : const Color(0xFF4A9B8E),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                elevation: _hasRequested ? 0 : 8,
                                shadowColor: const Color(0xFF4A9B8E).withOpacity(0.4),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (_hasRequested)
                                    const Padding(
                                      padding: EdgeInsets.only(right: 8),
                                      child: Icon(Icons.hourglass_empty, size: 20),
                                    ),
                                  Text(
                                    _hasRequested ? 'Request in Process' : 'Adopt Me',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAttributeBadge(String label, String value, IconData icon) {
    return Container(
      width: 100,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFF4A9B8E), size: 24),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
