import 'package:flutter/material.dart';
import 'firebase_service.dart';
import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' hide Path;

class PetSelectionScreen extends StatefulWidget {
  const PetSelectionScreen({super.key});

  @override
  State<PetSelectionScreen> createState() => _PetSelectionScreenState();
}

class _PetSelectionScreenState extends State<PetSelectionScreen> {
  // Mock tracking status for pets in this session
  final Map<String, bool> _mockSubscribedPets = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Track Your Pet',
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontWeight: FontWeight.w800,
            fontSize: 22,
            fontFamily: 'Outfit',
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1E293B), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: FirebaseService().getAdoptedPets(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF4A9B8E),
                strokeWidth: 3,
              ),
            );
          }

          final pets = snapshot.data ?? [];

          if (pets.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4A9B8E).withOpacity(0.08),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.pets_rounded,
                        size: 64,
                        color: Color(0xFF4A9B8E),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'No Adopted Pets Yet',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Register a GPS collar to add your pet and begin monitoring them in real-time.',
                      style: TextStyle(
                        color: Color(0xFF64748B),
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            physics: const BouncingScrollPhysics(),
            itemCount: pets.length,
            itemBuilder: (context, index) {
              final pet = pets[index];
              final bool isSubscribed = _mockSubscribedPets[pet['id']] ?? false;

              return Container(
                margin: const EdgeInsets.only(bottom: 18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.white,
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      // Circular pet image with a dynamic border based on active status
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSubscribed
                                ? const Color(0xFF10B981) // Green for active subscription
                                : const Color(0xFFF59E0B), // Orange for inactive
                            width: 2.5,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(40),
                          child: (pet['imageBase64'] != null)
                              ? (pet['imageBase64']!.startsWith('http')
                                  ? Image.network(pet['imageBase64'], width: 64, height: 64, fit: BoxFit.cover)
                                  : Image.memory(base64Decode(pet['imageBase64']), width: 64, height: 64, fit: BoxFit.cover))
                              : Container(
                                  width: 64,
                                  height: 64,
                                  color: const Color(0xFF4A9B8E).withOpacity(0.1),
                                  child: const Icon(Icons.pets, color: Color(0xFF4A9B8E)),
                                ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      
                      // Pet Information
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              pet['name'] ?? 'Unknown',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 18,
                                  color: Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              pet['type'] ?? 'Pet',
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF64748B),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Micro status badge
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: isSubscribed
                                    ? const Color(0xFF10B981).withOpacity(0.12)
                                    : const Color(0xFFF59E0B).withOpacity(0.12),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: isSubscribed
                                          ? const Color(0xFF10B981)
                                          : const Color(0xFFF59E0B),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    isSubscribed ? 'Active Tracking' : 'No Tracking Plan',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: isSubscribed
                                          ? const Color(0xFF059669)
                                          : const Color(0xFFD97706),
                                      fontWeight: FontWeight.w800,
                                      height: 1.0,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Tracking/Subscription Button
                      ElevatedButton(
                        onPressed: () {
                          if (isSubscribed) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => PetTrackingLoadingScreen(pet: pet)),
                            );
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SubscriptionPlanScreen(
                                  pet: pet,
                                  onSuccess: () {
                                    setState(() {
                                      _mockSubscribedPets[pet['id']] = true;
                                    });
                                  },
                                ),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isSubscribed
                              ? const Color(0xFF4A9B8E)
                              : const Color(0xFF475569),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        child: Text(
                          isSubscribed ? 'Track' : 'Subscribe',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const RegisterCollarScreen()),
          );
        },
        label: const Text(
          'Register Collar',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.2,
          ),
        ),
        icon: const Icon(Icons.add_location_alt_rounded, color: Colors.white),
        backgroundColor: const Color(0xFF4A9B8E),
        elevation: 6,
      ),
    );
  }
}

class RegisterCollarScreen extends StatefulWidget {
  final bool fromChoice;
  const RegisterCollarScreen({super.key, this.fromChoice = false});

  @override
  State<RegisterCollarScreen> createState() => _RegisterCollarScreenState();
}

class _RegisterCollarScreenState extends State<RegisterCollarScreen> {
  final _formKey = GlobalKey<FormState>();
  final _collarIdController = TextEditingController();
  final _petNameController = TextEditingController();
  File? _image;
  String? _imageBase64;
  bool _isUploading = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 50);

    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _image = File(pickedFile.path);
        _imageBase64 = base64Encode(bytes);
      });
    }
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isUploading = true);

    try {
      final petData = {
        'name': _petNameController.text.trim(),
        'collarId': _collarIdController.text.trim(),
        'imageBase64': _imageBase64,
        'type': 'Dog',
        'isAdopted': true,
        'adoptedBy': FirebaseService().currentUserId,
      };

      final petId = await FirebaseService().addPet(petData);
      petData['id'] = petId;

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => DeviceDetectionScreen(
              pet: petData,
              fromChoice: widget.fromChoice,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Register GPS Collar',
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Color(0xFF1E293B)),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Bring your pet online. Enter the GPS collar ID and connect it to your dashboard.',
                style: TextStyle(color: Color(0xFF64748B), fontSize: 15, height: 1.5),
              ),
              const SizedBox(height: 32),
              
              // Clean Circle Image Uploader
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Stack(
                    children: [
                      Container(
                        width: 130,
                        height: 130,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFF4A9B8E), width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: _image != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(65),
                                child: Image.file(_image!, fit: BoxFit.cover),
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(Icons.camera_alt_outlined, color: Color(0xFF4A9B8E), size: 36),
                                  SizedBox(height: 6),
                                  Text(
                                    'Upload Image',
                                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF4A9B8E)),
                                  ),
                                ],
                              ),
                      ),
                      if (_image != null)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: Color(0xFF4A9B8E),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.edit, size: 14, color: Colors.white),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // Inputs card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'COLLAR ID',
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: Color(0xFF64748B), letterSpacing: 0.5),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _collarIdController,
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                      decoration: InputDecoration(
                        hintText: 'e.g. FF-GPS-12345',
                        filled: true,
                        fillColor: const Color(0xFFF8F9FA),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                        prefixIcon: const Icon(Icons.qr_code_scanner_rounded, color: Color(0xFF4A9B8E)),
                      ),
                      validator: (value) => value == null || value.isEmpty ? 'Collar ID is required' : null,
                    ),
                    const SizedBox(height: 24),

                    const Text(
                      'PET NAME',
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: Color(0xFF64748B), letterSpacing: 0.5),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _petNameController,
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                      decoration: InputDecoration(
                        hintText: 'Enter your companion\'s name',
                        filled: true,
                        fillColor: const Color(0xFFF8F9FA),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                        prefixIcon: const Icon(Icons.pets_rounded, color: Color(0xFF4A9B8E)),
                      ),
                      validator: (value) => value == null || value.isEmpty ? 'Pet name is required' : null,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 48),
              
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isUploading ? null : _handleRegister,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A9B8E),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    elevation: 4,
                    shadowColor: const Color(0xFF4A9B8E).withOpacity(0.3),
                  ),
                  child: _isUploading 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Register Collar',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DeviceDetectionScreen extends StatefulWidget {
  final Map<String, dynamic> pet;
  final bool fromChoice;
  const DeviceDetectionScreen({super.key, required this.pet, this.fromChoice = false});

  @override
  State<DeviceDetectionScreen> createState() => _DeviceDetectionScreenState();
}

class _DeviceDetectionScreenState extends State<DeviceDetectionScreen> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotateController;
  bool _isDetected = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 2500))..repeat();
    _rotateController = AnimationController(vsync: this, duration: const Duration(seconds: 6))..repeat();

    // Simulate detection process
    Timer(const Duration(milliseconds: 3000), () {
      if (mounted) {
        setState(() => _isDetected = true);
        _pulseController.stop();
        _rotateController.stop();
        
        // Return to pet selection after success message
        Timer(const Duration(milliseconds: 2000), () {
          if (mounted) {
            if (widget.fromChoice) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const PetSelectionScreen()),
              );
            } else {
              Navigator.pop(context);
            }
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                if (!_isDetected) ...List.generate(3, (index) {
                  return AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      double progress = (_pulseController.value + (index * 0.33)) % 1.0;
                      double curvedValue = Curves.easeInOut.transform(progress);
                      return Container(
                        width: 100 + (curvedValue * 150),
                        height: 100 + (curvedValue * 150),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle, 
                          border: Border.all(
                            color: const Color(0xFF4A9B8E).withOpacity((1.0 - curvedValue) * 0.6), 
                            width: 1.5,
                          ),
                        ),
                      );
                    },
                  );
                }),
                if (!_isDetected) RotationTransition(
                  turns: _rotateController,
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle, 
                      gradient: SweepGradient(
                        colors: [
                          const Color(0xFF4A9B8E).withOpacity(0.0), 
                          const Color(0xFF4A9B8E).withOpacity(0.25),
                        ], 
                        stops: const [0.5, 1.0],
                      ),
                    ),
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: _isDetected ? const Color(0xFFD1FAE5) : Colors.white, 
                    shape: BoxShape.circle,
                    border: Border.all(color: _isDetected ? const Color(0xFF10B981) : const Color(0xFF4A9B8E), width: 3),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(60),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        (widget.pet['imageBase64'] != null)
                            ? (widget.pet['imageBase64']!.startsWith('http') 
                                ? Image.network(widget.pet['imageBase64'], width: 110, height: 110, fit: BoxFit.cover)
                                : Image.memory(base64Decode(widget.pet['imageBase64']), width: 110, height: 110, fit: BoxFit.cover))
                            : Container(width: 110, height: 110, color: const Color(0xFF4A9B8E).withOpacity(0.1), child: const Icon(Icons.pets, size: 50, color: Color(0xFF4A9B8E))),
                        if (_isDetected)
                          Container(
                            width: 110,
                            height: 110,
                            color: const Color(0xFF10B981).withOpacity(0.3),
                            child: const Icon(Icons.check, color: Colors.white, size: 60),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 60),
            Text(
              _isDetected ? 'Device Connected!' : 'Scanning for Collar...', 
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
            ),
            const SizedBox(height: 12),
            Text(
              _isDetected 
                ? 'Collar ID: ${widget.pet['collarId']} Verified' 
                : 'Searching for GPS collar ${widget.pet['collarId']} nearby', 
              style: const TextStyle(fontSize: 16, color: Color(0xFF64748B)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            if (!_isDetected) const CircularProgressIndicator(color: Color(0xFF4A9B8E), strokeWidth: 3),
            if (_isDetected) const Text('Saving configuration...', style: TextStyle(color: Color(0xFF4A9B8E), fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
      ),
    );
  }
}

class PetTrackingLoadingScreen extends StatefulWidget {
  final Map<String, dynamic> pet;
  const PetTrackingLoadingScreen({super.key, required this.pet});

  @override
  State<PetTrackingLoadingScreen> createState() => _PetTrackingLoadingScreenState();
}

class _PetTrackingLoadingScreenState extends State<PetTrackingLoadingScreen> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotateController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 2500))..repeat();
    _rotateController = AnimationController(vsync: this, duration: const Duration(seconds: 6))..repeat();

    Timer(const Duration(milliseconds: 3500), () {
      if (mounted) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => PetTrackingMapScreen(pet: widget.pet)));
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                ...List.generate(3, (index) {
                  return AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      double progress = (_pulseController.value + (index * 0.33)) % 1.0;
                      double curvedValue = Curves.easeInOut.transform(progress);
                      return Container(
                        width: 100 + (curvedValue * 150),
                        height: 100 + (curvedValue * 150),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle, 
                          border: Border.all(
                            color: const Color(0xFF4A9B8E).withOpacity((1.0 - curvedValue) * 0.6), 
                            width: 1.5,
                          ),
                        ),
                      );
                    },
                  );
                }),
                RotationTransition(
                  turns: _rotateController,
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle, 
                      gradient: SweepGradient(
                        colors: [
                          const Color(0xFF4A9B8E).withOpacity(0.0), 
                          const Color(0xFF4A9B8E).withOpacity(0.25),
                        ], 
                        stops: const [0.5, 1.0],
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(45),
                    child: (widget.pet['imageBase64'] != null)
                        ? (widget.pet['imageBase64']!.startsWith('http') 
                            ? Image.network(widget.pet['imageBase64'], width: 90, height: 90, fit: BoxFit.cover)
                            : Image.memory(base64Decode(widget.pet['imageBase64']), width: 90, height: 90, fit: BoxFit.cover))
                        : Container(width: 90, height: 90, color: const Color(0xFF4A9B8E).withOpacity(0.1), child: const Icon(Icons.pets, size: 40, color: Color(0xFF4A9B8E))),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 60),
            const Text(
              'Locating Companion...',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
            ),
            const SizedBox(height: 12),
            Text(
              'Pinging GPS receiver in ${widget.pet['name']}\'s collar',
              style: const TextStyle(fontSize: 15, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }
}

class SubscriptionPlanScreen extends StatelessWidget {
  final Map<String, dynamic> pet;
  final VoidCallback onSuccess;

  const SubscriptionPlanScreen({super.key, required this.pet, required this.onSuccess});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Tracking Plan', style: TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Color(0xFF1E293B)),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: const Color(0xFF4A9B8E).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.location_searching_rounded,
                  size: 54,
                  color: Color(0xFF4A9B8E),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: Column(
                children: [
                  const Text(
                    'GPS Tracking Plan',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Activate live telemetry for ${pet['name']}',
                    style: const TextStyle(fontSize: 15, color: Color(0xFF64748B)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 36),
            
            // Feature list inside clean card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
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
                  _buildFeatureRow(Icons.gps_fixed_rounded, 'Real-time telemetry', 'Get high-frequency precise location coordinates.'),
                  const SizedBox(height: 20),
                  _buildFeatureRow(Icons.history_rounded, 'Location analytics', 'View interactive map location history for up to 30 days.'),
                  const SizedBox(height: 20),
                  _buildFeatureRow(Icons.notifications_active_rounded, 'Safe zone notifications', 'Configure visual geofences and get instant push notifications.'),
                ],
              ),
            ),
            
            const SizedBox(height: 28),
            
            // Payment block
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFF4A9B8E).withOpacity(0.3), width: 2),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('Monthly Plan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF1E293B))),
                      SizedBox(height: 4),
                      Text('Cancel anytime', style: TextStyle(color: Color(0xFF64748B), fontSize: 12)),
                    ],
                  ),
                  const Text('P200', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF4A9B8E))),
                ],
              ),
            ),
            
            const SizedBox(height: 28),
            const Text('Payment Method', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blueAccent, width: 2),
                borderRadius: BorderRadius.circular(20),
                color: Colors.blueAccent.withOpacity(0.04),
              ),
              child: Row(
                children: [
                  Image.asset(
                    'assets/gcash.jpg',
                    width: 44,
                    height: 44,
                    fit: BoxFit.contain,
                    errorBuilder: (c, e, s) => const Icon(Icons.payment, color: Colors.blueAccent),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'GCash Checkout',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                  ),
                  const Spacer(),
                  const Icon(Icons.check_circle_rounded, color: Colors.blueAccent),
                ],
              ),
            ),
            const SizedBox(height: 40),
            
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () => _showProcessingDialog(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A9B8E),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  elevation: 4,
                  shadowColor: const Color(0xFF4A9B8E).withOpacity(0.3),
                ),
                child: const Text(
                  'Confirm and Pay â‚±200.00',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureRow(IconData icon, String title, String desc) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF4A9B8E).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: const Color(0xFF4A9B8E), size: 22),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: Color(0xFF0F172A))),
              const SizedBox(height: 2),
              Text(desc, style: const TextStyle(color: Color(0xFF64748B), fontSize: 13, height: 1.4)),
            ],
          ),
        ),
      ],
    );
  }

  void _showProcessingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Color(0xFF4A9B8E), strokeWidth: 3),
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context); // Pop loading dialog
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentSuccessScreen(
            onDone: () {
              onSuccess();
              Navigator.pop(context); // Pop PaymentSuccessScreen
            },
          ),
        ),
      );
    });
  }
}

class PaymentSuccessScreen extends StatelessWidget {
  final VoidCallback onDone;
  const PaymentSuccessScreen({super.key, required this.onDone});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  color: Color(0xFFD1FAE5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle_rounded, size: 76, color: Color(0xFF10B981)),
              ),
              const SizedBox(height: 32),
              const Text(
                'Payment Confirmed!',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
              ),
              const SizedBox(height: 16),
              const Text(
                'Telemetry stream is now open. You can begin viewing real-time locations and history on your dashboard map.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: Color(0xFF64748B), height: 1.5),
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: onDone,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A9B8E),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    elevation: 4,
                    shadowColor: const Color(0xFF4A9B8E).withOpacity(0.3),
                  ),
                  child: const Text('Start Live Tracking', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PetTrackingMapScreen extends StatelessWidget {
  final Map<String, dynamic> pet;
  const PetTrackingMapScreen({super.key, required this.pet});

  @override
  Widget build(BuildContext context) {
    final LatLng petLocation = LatLng(7.30845, 125.68490);

    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              initialCenter: petLocation,
              initialZoom: 16.0,
              interactionOptions: const InteractionOptions(flags: InteractiveFlag.all),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png',
                subdomains: const ['a', 'b', 'c', 'd'],
                userAgentPackageName: 'com.example.appdev',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: petLocation,
                    width: 250,
                    height: 150,
                    alignment: Alignment.topCenter,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.pets, color: Color(0xFF4A9B8E), size: 14),
                                  const SizedBox(width: 8),
                                  Text(
                                    pet['name'] ?? 'Justin',
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              const Text('Active Â· Online Now', style: TextStyle(color: Color(0xFF10B981), fontSize: 10, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                        CustomPaint(size: const Size(16, 8), painter: TrianglePainter(color: Colors.white)),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Color(0xFF4A9B8E),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 8,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.pets, color: Colors.white, size: 20),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          // Floating Top Navbar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1E293B), size: 18),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 12),
                      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(16)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Text(
                        'Panabo City, Davao del Norte',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Color(0xFF1E293B), fontSize: 13, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.my_location_rounded, color: Color(0xFF4A9B8E), size: 22),
                  ),
                ],
              ),
            ),
          ),
          
          // Modern bottom sheet layout
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF4A9B8E).withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.location_on_rounded, color: Color(0xFF4A9B8E), size: 20),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text('COORDINATES', style: TextStyle(color: Color(0xFF64748B), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                              SizedBox(height: 2),
                              Text('7.30845, 125.68490', style: TextStyle(color: Color(0xFF0F172A), fontSize: 15, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD1FAE5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: const [
                            Icon(Icons.signal_cellular_alt_rounded, color: Color(0xFF10B981), size: 14),
                            SizedBox(width: 4),
                            Text('5G Online', style: TextStyle(color: Color(0xFF065F46), fontSize: 11, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Pet Identity
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFF4A9B8E), width: 2),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: (pet['imageBase64'] != null)
                              ? (pet['imageBase64']!.startsWith('http') 
                                  ? Image.network(pet['imageBase64'], width: 40, height: 40, fit: BoxFit.cover)
                                  : Image.memory(base64Decode(pet['imageBase64']), width: 40, height: 40, fit: BoxFit.cover))
                              : Container(width: 40, height: 40, color: const Color(0xFF4A9B8E).withOpacity(0.1), child: const Icon(Icons.pets, size: 20, color: Color(0xFF4A9B8E))),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            pet['name'] ?? 'Justin',
                            style: const TextStyle(color: Color(0xFF0F172A), fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 2),
                          const Text('Last updated: Just now', style: TextStyle(color: Color(0xFF64748B), fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 28),
                  
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.gps_fixed_rounded),
                      label: const Text('Calibrate Device Sensor', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4A9B8E),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        elevation: 0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(color: Color(0xFF10B981), shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Battery: 85% Â· Operational',
                        style: TextStyle(color: Color(0xFF64748B), fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TrianglePainter extends CustomPainter {
  final Color color;
  TrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width / 2, size.height);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
