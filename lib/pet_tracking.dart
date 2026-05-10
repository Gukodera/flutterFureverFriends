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
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Track Your Pet', 
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: FirebaseService().getAdoptedPets(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF4A9B8E)));
          }

          final pets = snapshot.data ?? [];

          if (pets.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.pets, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  const Text('No adopted pets found', style: TextStyle(fontSize: 18, color: Colors.grey)),
                  const SizedBox(height: 8),
                  const Text('Register a collar to start tracking!', style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: pets.length,
            itemBuilder: (context, index) {
              final pet = pets[index];
              final bool isSubscribed = _mockSubscribedPets[pet['id']] ?? false;

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: (pet['imageBase64'] != null)
                        ? (pet['imageBase64']!.startsWith('http') 
                            ? Image.network(pet['imageBase64'], width: 60, height: 60, fit: BoxFit.cover)
                            : Image.memory(base64Decode(pet['imageBase64']), width: 60, height: 60, fit: BoxFit.cover))
                        : Container(width: 60, height: 60, color: Colors.grey[200], child: const Icon(Icons.pets)),
                  ),
                  title: Text(pet['name'] ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(pet['type'] ?? 'Pet'),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            isSubscribed ? Icons.check_circle : Icons.error_outline,
                            size: 14,
                            color: isSubscribed ? Colors.green : Colors.orange,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isSubscribed ? 'Active Subscription' : 'No Tracking Plan',
                            style: TextStyle(
                              fontSize: 12,
                              color: isSubscribed ? Colors.green : Colors.orange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  trailing: ElevatedButton(
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
                      backgroundColor: isSubscribed ? const Color(0xFF4A9B8E) : Colors.blueAccent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                    child: Text(isSubscribed ? 'Track' : 'Subscribe'),
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
        label: const Text('Register Collar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        icon: const Icon(Icons.add_location_alt_rounded, color: Colors.white),
        backgroundColor: const Color(0xFF4A9B8E),
      ),
    );
  }
}

class RegisterCollarScreen extends StatefulWidget {
  const RegisterCollarScreen({super.key});

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
            builder: (context) => SubscriptionPlanScreen(
              pet: petData,
              onSuccess: () {
                // Just for state update if needed
              },
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Register GPS Collar', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Connect your hardware to the app by entering the collar details below.',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
              const SizedBox(height: 32),
              
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF4A9B8E), width: 2),
                    ),
                    child: _image != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(60),
                            child: Image.file(_image!, fit: BoxFit.cover),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.camera_alt_outlined, color: Color(0xFF4A9B8E), size: 32),
                              SizedBox(height: 4),
                              Text('Upload Photo', style: TextStyle(fontSize: 12, color: Color(0xFF4A9B8E))),
                            ],
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 40),

              const Text('COLLAR ID', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _collarIdController,
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

              const Text('PET NAME', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _petNameController,
                decoration: InputDecoration(
                  hintText: 'Enter your dog\'s name',
                  filled: true,
                  fillColor: const Color(0xFFF8F9FA),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  prefixIcon: const Icon(Icons.pets_rounded, color: Color(0xFF4A9B8E)),
                ),
                validator: (value) => value == null || value.isEmpty ? 'Pet name is required' : null,
              ),
              
              const SizedBox(height: 60),
              
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: _isUploading ? null : _handleRegister,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A9B8E),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: _isUploading 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Register & Subscribe', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ],
          ),
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
    _pulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))..repeat();
    _rotateController = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat();

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
      backgroundColor: Colors.white,
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
                      return Container(
                        width: 100 + (progress * 200),
                        height: 100 + (progress * 200),
                        decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: const Color(0xFF4A9B8E).withOpacity(1.0 - progress), width: 2)),
                      );
                    },
                  );
                }),
                RotationTransition(
                  turns: _rotateController,
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(shape: BoxShape.circle, gradient: SweepGradient(colors: [const Color(0xFF4A9B8E).withOpacity(0.0), const Color(0xFF4A9B8E).withOpacity(0.5)], stops: const [0.75, 1.0])),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(40),
                    child: (widget.pet['imageBase64'] != null)
                        ? (widget.pet['imageBase64']!.startsWith('http') 
                            ? Image.network(widget.pet['imageBase64'], width: 80, height: 80, fit: BoxFit.cover)
                            : Image.memory(base64Decode(widget.pet['imageBase64']), width: 80, height: 80, fit: BoxFit.cover))
                        : Container(width: 80, height: 80, color: const Color(0xFF4A9B8E).withOpacity(0.1), child: const Icon(Icons.pets, size: 40, color: Color(0xFF4A9B8E))),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 60),
            const Text('Locating your pet...', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87)),
            const SizedBox(height: 12),
            Text('Connecting to ${widget.pet['name']}\'s collar GPS', style: const TextStyle(fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 48),
            const SizedBox(width: 40, height: 40, child: CircularProgressIndicator(strokeWidth: 3, valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4A9B8E)))),
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Tracking Plan', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: const Color(0xFF4A9B8E).withOpacity(0.1), shape: BoxShape.circle), child: const Icon(Icons.location_searching_rounded, size: 64, color: Color(0xFF4A9B8E)))),
            const SizedBox(height: 24),
            Center(child: Column(children: [const Text('GPS Collar Subscription', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)), const SizedBox(height: 8), Text('Enable tracking for ${pet['name']}', style: const TextStyle(fontSize: 16, color: Colors.grey))])),
            const SizedBox(height: 40),
            _buildFeatureRow(Icons.gps_fixed, 'Real-time GPS Tracking', 'Track your pet anywhere in the Philippines.'),
            _buildFeatureRow(Icons.history, 'Location History', 'View where your pet has been in the last 24 hours.'),
            _buildFeatureRow(Icons.notifications_active, 'Geo-fencing Alerts', 'Get notified when your pet leaves a safe zone.'),
            const SizedBox(height: 40),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: const Color(0xFFF8F9FA), borderRadius: BorderRadius.circular(24), border: Border.all(color: const Color(0xFF4A9B8E).withOpacity(0.3), width: 2)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [Text('Monthly Plan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)), Text('Recurring every month', style: TextStyle(color: Colors.grey, fontSize: 12))]),
                  const Text('₱200', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF4A9B8E))),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const Text('Payment Method', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(border: Border.all(color: Colors.blue, width: 2), borderRadius: BorderRadius.circular(16), color: Colors.blue.withOpacity(0.05)),
              child: Row(
                children: [
                  Image.asset('assets/gcash.jpg', width: 40, height: 40, fit: BoxFit.contain, errorBuilder: (c, e, s) => const Icon(Icons.payment, color: Colors.blue)),
                  const SizedBox(width: 16),
                  const Text('GCash', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)),
                  const Spacer(),
                  const Icon(Icons.check_circle, color: Colors.blue),
                ],
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(width: double.infinity, height: 60, child: ElevatedButton(onPressed: () => _showProcessingDialog(context), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4A9B8E), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)), elevation: 0), child: const Text('Pay ₱200.00', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)))),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureRow(IconData icon, String title, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF4A9B8E), size: 28),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), Text(desc, style: const TextStyle(color: Colors.grey, fontSize: 14))])),
        ],
      ),
    );
  }

  void _showProcessingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator(color: Color(0xFF4A9B8E))),
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
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle, size: 100, color: Colors.green),
              const SizedBox(height: 24),
              const Text('Payment Successful!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              const Text('Tracking plan has been activated for your pet. You can now start tracking in real-time.', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: Colors.grey)),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: onDone,
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4A9B8E), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28))),
                  child: const Text('Start Tracking Now', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
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
      backgroundColor: const Color(0xFFF8F9FA),
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(initialCenter: petLocation, initialZoom: 16.0, interactionOptions: const InteractionOptions(flags: InteractiveFlag.all)),
            children: [
              TileLayer(urlTemplate: 'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png', subdomains: const ['a', 'b', 'c', 'd'], userAgentPackageName: 'com.example.appdev'),
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
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))]),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.pets, color: Color(0xFF4A9B8E), size: 14), const SizedBox(width: 8), Text(pet['name'] ?? 'Justin', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87))]),
                              const SizedBox(height: 2),
                              const Text('Active · Online Now', style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                        CustomPaint(size: const Size(16, 8), painter: TrianglePainter(color: Colors.white)),
                        const SizedBox(height: 4),
                        Container(padding: const EdgeInsets.all(6), decoration: const BoxDecoration(color: Color(0xFF4A9B8E), shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4))]), child: const Icon(Icons.pets, color: Colors.white, size: 20)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Container(decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]), child: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 18), onPressed: () => Navigator.pop(context))),
                  const Expanded(child: Text('Panabo City, Davao del Norte', textAlign: TextAlign.center, style: TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.bold))),
                  Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]), child: const Icon(Icons.my_location_rounded, color: Color(0xFF4A9B8E), size: 20)),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(32)), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, -5))]),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.location_on_rounded, color: Color(0xFF4A9B8E), size: 24),
                          const SizedBox(width: 12),
                          Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [Text('COORDINATES', style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)), SizedBox(height: 4), Text('7.30845, 125.68490', style: TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.bold))]),
                        ],
                      ),
                      Row(children: const [Icon(Icons.signal_cellular_alt_rounded, color: Color(0xFF4A9B8E), size: 16), SizedBox(width: 4), Text('5G', style: TextStyle(color: Color(0xFF4A9B8E), fontWeight: FontWeight.bold))]),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(children: [const Icon(Icons.pets_rounded, color: Color(0xFF4A9B8E), size: 24), const SizedBox(width: 12), Text(pet['name'] ?? 'Justin', style: const TextStyle(color: Colors.black87, fontSize: 20, fontWeight: FontWeight.bold))]),
                  const SizedBox(height: 24),
                  SizedBox(width: double.infinity, height: 56, child: ElevatedButton.icon(onPressed: () {}, icon: const Icon(Icons.gps_fixed_rounded), label: const Text('Track Your Pet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4A9B8E), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)), elevation: 4, shadowColor: const Color(0xFF4A9B8E).withOpacity(0.3)))),
                  const SizedBox(height: 16),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [Container(width: 10, height: 10, decoration: const BoxDecoration(color: Color(0xFF00C853), shape: BoxShape.circle)), const SizedBox(width: 8), const Text('Active · Online Now', style: TextStyle(color: Color(0xFF4A9B8E), fontSize: 14))]),
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
