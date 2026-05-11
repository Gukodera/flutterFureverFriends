import 'package:flutter/material.dart';
import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' hide Path;

// [GLOBAL STATE SIMULATION]
Map<String, dynamic>? globalActiveTeleconsult;

class VetClinicScreen extends StatefulWidget {
  const VetClinicScreen({super.key});

  @override
  State<VetClinicScreen> createState() => _VetClinicScreenState();
}

class _VetClinicScreenState extends State<VetClinicScreen> {
  final List<Map<String, dynamic>> clinics = [
    {
      'id': '1',
      'name': 'Panabo Pet Care Center',
      'location': 'Gredu St, Panabo City',
      'specs': 'Surgery, Vaccination, Grooming',
      'hours': '8:00 AM - 5:00 PM',
      'isVerified': true,
      'isSubscribed': true,
      'contact': '+63 912 345 6789',
      'email': 'care@panabovet.com',
      'lat': 7.30845,
      'lng': 125.68490,
      'image': 'https://scontent.fdvo8-1.fna.fbcdn.net/v/t39.30808-6/482960188_626009359958061_4491078109021388613_n.jpg?stp=cp6_dst-jpg_tt6&_nc_cat=109&ccb=1-7&_nc_sid=2a1932&_nc_eui2=AeEoDwKnVRoapKHTyHyHB_ofx2jksa3LtB3HaOSxrcu0HdYlGezsdc_wlSNRagg12FMT_QhFsgcs8Hc2XBwv8hPp&_nc_ohc=bminvENKCOQQ7kNvwHXBaxh&_nc_oc=AdqkhLk8WAHWNVSxhOaUPWtFY40bJSqtjqxuvzTMOGq0CE960JsNlxNN6DcxNzLRi_A&_nc_zt=23&_nc_ht=scontent.fdvo8-1.fna&_nc_gid=r2cZpLJXgTr3ZwuEpc8cFg&_nc_ss=7a2a8&oh=00_Af6r6lBasaeUwFRPcilR8inIDhQfAnajs_nQ1-0SSogBfw&oe=6A06366B',
    },
    {
      'id': '2',
      'name': 'Boca Vet Clinic',
      'location': 'National Highway, Panabo',
      'specs': 'Emergency, Diagnostics, X-Ray',
      'hours': '24/7 Open',
      'isVerified': true,
      'isSubscribed': false,
      'contact': '+63 922 888 1234',
      'email': 'hospital@davaovet.org',
      'lat': 7.31200,
      'lng': 125.68600,
      'image': 'https://cdn-ildhhon.nitrocdn.com/ZeVlwfcBdQnibDljTBYNekjxgEiWVHiT/assets/images/optimized/rev-3e3e819/eadn-wc05-15392779.nxedge.io/wp-content/uploads/2024/12/WhatsApp-Image-2024-12-02-at-6.12.37-PM.jpeg',
    },
    {
      'id': '3',
      'name': 'Warwick Vet Clinic',
      'location': 'Brgy. San Francisco, Panabo',
      'specs': 'General Checkup, Dental',
      'hours': '9:00 AM - 6:00 PM',
      'isVerified': false,
      'isSubscribed': false,
      'contact': '+63 933 444 5555',
      'email': 'hello@happypaws.ph',
      'lat': 7.30500,
      'lng': 125.68000,
      'image': 'https://images.zoogletools.com/s:bzglfiles/u/50199/5f678479ce2de302d1306b46a7e81af2661b37be/original/reception-pic.jpg/!!/b%3AW1sicmVzaXplIiwxODg5XSxbIm1heCJdLFsid2UiXV0%3D/meta%3AeyJzcmNCdWNrZXQiOiJiemdsZmlsZXMifQ%3D%3D.jpg',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: CustomScrollView(
        slivers: [
          // [REDESIGN] Modern TopBar (SliverAppBar)
          SliverAppBar(
            expandedHeight: 120,
            floating: true,
            pinned: true,
            backgroundColor: Colors.white,
            elevation: 0,
            automaticallyImplyLeading: false,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              title: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.canPop(context) ? Navigator.pop(context) : null,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: const Color(0xFF4A9B8E).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF4A9B8E), size: 16),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text('Vet Services', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 20)),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const VetTransactionsScreen())),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[200]!)),
                      child: const Icon(Icons.history_rounded, color: Color(0xFF4A9B8E), size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Active Appointment Monitor
                  if (globalActiveTeleconsult != null) ...[
                    _buildActiveAppointmentCard(context),
                    const SizedBox(height: 24),
                  ],

                  Row(
                    children: [
                      _buildQuickAction(context, Icons.calendar_month_rounded, 'Book Appointment', Colors.blue, () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const VetBookingScreen()));
                      }),
                      const SizedBox(width: 16),
                      _buildQuickAction(context, Icons.video_call_rounded, 'Vet On Call', Colors.redAccent, () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const VetOnCallScreen()));
                      }),
                    ],
                  ),
                  const SizedBox(height: 32),
                  
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFF4A9B8E), Color(0xFF3D8277)]),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [BoxShadow(color: const Color(0xFF4A9B8E).withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6))],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Grow Your Clinic!', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        const Text('List your clinic and reach more pet owners in Panabo City.', style: TextStyle(color: Colors.white70, fontSize: 14)),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('₱299 / Month', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => const ClinicRegistrationScreen()));
                              },
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: const Color(0xFF4A9B8E), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                              child: const Text('Register Now', style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  const Text('Partner Clinics', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                  const SizedBox(height: 16),
                  
                  ...clinics.map((clinic) => _buildClinicCard(clinic)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveAppointmentCard(BuildContext context) {
    final vet = globalActiveTeleconsult?['vet'] ?? 'Vet Doctor';
    final time = globalActiveTeleconsult?['time'] ?? 'Today';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF4A9B8E).withOpacity(0.3), width: 1.5),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: const Text('ACTIVE NOW', style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close, size: 16, color: Colors.grey),
                onPressed: () => setState(() => globalActiveTeleconsult = null),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text('Your Teleconsultation', style: TextStyle(fontSize: 14, color: Colors.grey)),
          const SizedBox(height: 4),
          Text(vet, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.access_time_filled, size: 16, color: Color(0xFF4A9B8E)),
              const SizedBox(width: 8),
              Text('Scheduled for $time', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => VideoConsultationScreen(vetName: vet)));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4A9B8E),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                elevation: 0,
              ),
              child: const Text('Join 1v1 Consultation', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction(BuildContext context, IconData icon, String title, Color color, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
          child: Column(
            children: [
              Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle), child: Icon(icon, color: color, size: 28)),
              const SizedBox(height: 12),
              Text(title ?? 'Action', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildClinicCard(Map<String, dynamic> clinic) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => ClinicDetailsScreen(clinic: clinic)));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))]),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                clinic['image'] ?? '', 
                width: 80, 
                height: 80, 
                fit: BoxFit.cover,
                errorBuilder: (c, e, s) => Container(width: 80, height: 80, color: Colors.grey[200], child: const Icon(Icons.local_hospital_rounded, color: Color(0xFF4A9B8E))),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text(clinic['name'] ?? 'Clinic', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), overflow: TextOverflow.ellipsis)),
                      if (clinic['isVerified'] == true) ...[
                        const SizedBox(width: 4),
                        const Icon(Icons.verified, color: Colors.blue, size: 16),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(clinic['location'] ?? 'Location', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  const SizedBox(height: 4),
                  Text(clinic['specs'] ?? 'General Services', style: const TextStyle(color: Colors.black54, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.access_time_filled, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(clinic['hours'] ?? 'Always Open', style: const TextStyle(color: Colors.grey, fontSize: 11)),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: (clinic['isSubscribed'] ?? false) ? Colors.green.withOpacity(0.1) : Colors.grey.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                        child: Text((clinic['isSubscribed'] ?? false) ? 'Active' : 'Inactive', style: TextStyle(color: (clinic['isSubscribed'] ?? false) ? Colors.green : Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
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
}

class ClinicDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> clinic;
  const ClinicDetailsScreen({super.key, required this.clinic});

  @override
  Widget build(BuildContext context) {
    final LatLng position = LatLng(clinic['lat'] ?? 7.30845, clinic['lng'] ?? 125.68490);

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Image.network(clinic['image'] ?? '', fit: BoxFit.cover),
            ),
            backgroundColor: const Color(0xFF4A9B8E),
            leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white), onPressed: () => Navigator.pop(context)),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text(clinic['name'] ?? 'Clinic', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold))),
                      if (clinic['isVerified'] == true) ...[
                        const SizedBox(width: 8),
                        const Icon(Icons.verified, color: Colors.blue, size: 24),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(clinic['location'] ?? 'Location', style: const TextStyle(fontSize: 16, color: Colors.grey)),
                  const SizedBox(height: 24),
                  
                  const Text('About Clinic', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  _buildDetailRow(Icons.medical_services_outlined, clinic['specs'] ?? 'General Services'),
                  _buildDetailRow(Icons.access_time, clinic['hours'] ?? 'Always Open'),
                  
                  const SizedBox(height: 32),
                  const Text('Location', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Container(
                    height: 200,
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.grey[200]!)),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: FlutterMap(
                        options: MapOptions(initialCenter: position, initialZoom: 15),
                        children: [
                          TileLayer(urlTemplate: 'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png', subdomains: const ['a', 'b', 'c', 'd']),
                          MarkerLayer(markers: [Marker(point: position, child: const Icon(Icons.location_on, color: Colors.red, size: 40))]),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  const Text('Contact Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  _buildContactTile(Icons.phone, clinic['contact'] ?? ''),
                  _buildContactTile(Icons.email, clinic['email'] ?? ''),
                  
                  const SizedBox(height: 48),
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => VetBookingScreen(
                          clinicId: clinic['id'], 
                          clinicName: clinic['name'],
                          clinicLat: clinic['lat'],
                          clinicLng: clinic['lng'],
                        )));
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4A9B8E), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                      child: const Text('Book Appointment', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF4A9B8E), size: 18),
          const SizedBox(width: 8),
          Expanded(child: Text(text ?? '', style: const TextStyle(fontSize: 15, color: Colors.black87))),
        ],
      ),
    );
  }

  Widget _buildContactTile(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF4A9B8E), size: 20),
          const SizedBox(width: 12),
          Text(text ?? '', style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}

class ClinicRegistrationScreen extends StatefulWidget {
  const ClinicRegistrationScreen({super.key});

  @override
  State<ClinicRegistrationScreen> createState() => _ClinicRegistrationScreenState();
}

class _ClinicRegistrationScreenState extends State<ClinicRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  bool _isLoadingLocation = false;

  Future<void> _detectLocation() async {
    setState(() => _isLoadingLocation = true);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
        Position position = await Geolocator.getCurrentPosition();
        setState(() {
          _locationController.text = "${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)} (Panabo City Area)";
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error detecting location: $e')));
    } finally {
      setState(() => _isLoadingLocation = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('List Your Clinic'), backgroundColor: Colors.white, elevation: 0, foregroundColor: Colors.black87),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('CLINIC NAME', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: 'e.g. Panabo Pet Wellness',
                  filled: true,
                  fillColor: const Color(0xFFF8F9FA),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                ),
                validator: (val) => val!.isEmpty ? 'Name required' : null,
              ),
              const SizedBox(height: 24),

              const Text('LOCATION', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(
                  hintText: 'Enter address or use GPS',
                  filled: true,
                  fillColor: const Color(0xFFF8F9FA),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  suffixIcon: IconButton(
                    icon: _isLoadingLocation 
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.my_location, color: Color(0xFF4A9B8E)),
                    onPressed: _detectLocation,
                  ),
                ),
                validator: (val) => val!.isEmpty ? 'Location required' : null,
              ),
              const SizedBox(height: 48),
              
              const Text('Subscription Plan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: const Color(0xFF4A9B8E).withOpacity(0.05), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFF4A9B8E))),
                child: Row(
                  children: const [
                    Icon(Icons.star, color: Color(0xFF4A9B8E)),
                    SizedBox(width: 12),
                    Text('Monthly Listing', style: TextStyle(fontWeight: FontWeight.bold)),
                    Spacer(),
                    Text('₱299/mo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF4A9B8E))),
                  ],
                ),
              ),
              const SizedBox(height: 60),
              
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => VetPaymentScreen(
                        itemName: 'Listing: ${_nameController.text}',
                        amount: 299.00,
                        platformFee: 0.00,
                      )));
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4A9B8E), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                  child: const Text('Proceed to Payment', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class VetBookingScreen extends StatelessWidget {
  final String? clinicId;
  final String? clinicName;
  final double? clinicLat;
  final double? clinicLng;
  const VetBookingScreen({super.key, this.clinicId, this.clinicName, this.clinicLat, this.clinicLng});

  final List<Map<String, dynamic>> allVets = const [
    {'name': 'Dr. Sarah Santos', 'spec': 'Canine Specialist', 'rating': 4.9, 'image': 'https://images.pexels.com/photos/6235228/pexels-photo-6235228.jpeg?auto=compress&cs=tinysrgb&w=800', 'clinicId': '1'},
    {'name': 'Dr. Mark Lopez', 'spec': 'Feline Surgeon', 'rating': 4.8, 'image': 'https://images.pexels.com/photos/6234614/pexels-photo-6234614.jpeg?auto=compress&cs=tinysrgb&w=800', 'clinicId': '2'},
    {'name': 'Dr. Anna Gomez', 'spec': 'Bird & Rabbit Vet', 'rating': 4.7, 'image': 'https://images.pexels.com/photos/6235116/pexels-photo-6235116.jpeg?auto=compress&cs=tinysrgb&w=800', 'clinicId': '3'},
    {'name': 'Dr. James Yap', 'spec': 'Exotic Pets Specialist', 'rating': 4.9, 'image': 'https://images.pexels.com/photos/5327585/pexels-photo-5327585.jpeg?auto=compress&cs=tinysrgb&w=800', 'clinicId': '1'},
  ];

  @override
  Widget build(BuildContext context) {
    final filteredVets = clinicId == null 
        ? allVets 
        : allVets.where((v) => v['clinicId'] == clinicId).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(clinicName != null ? 'Doctors at $clinicName' : 'Select a Vet'), 
        backgroundColor: Colors.white, 
        elevation: 0, 
        foregroundColor: Colors.black87
      ),
      body: filteredVets.isEmpty 
      ? const Center(child: Text('No doctors available for this clinic.'))
      : ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: filteredVets.length,
        itemBuilder: (context, index) {
          final vet = filteredVets[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)]),
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(radius: 30, backgroundImage: NetworkImage(vet['image'] ?? '')),
              title: Text(vet['name'] ?? 'Vet Doctor', style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(vet['spec'] ?? 'Specialist'),
                  Row(children: [const Icon(Icons.star, color: Colors.orange, size: 14), const SizedBox(width: 4), Text(vet['rating']?.toString() ?? '5.0', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold))]),
                ],
              ),
              trailing: ElevatedButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => BookingDetailsScreen(
                    vet: vet, 
                    clinicName: clinicName,
                    lat: clinicLat,
                    lng: clinicLng,
                  )));
                },
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4A9B8E), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: const Text('Book', style: TextStyle(color: Colors.white)),
              ),
            ),
          );
        },
      ),
    );
  }
}

class BookingDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> vet;
  final String? clinicName;
  final double? lat;
  final double? lng;
  const BookingDetailsScreen({super.key, required this.vet, this.clinicName, this.lat, this.lng});

  @override
  State<BookingDetailsScreen> createState() => _BookingDetailsScreenState();
}

class _BookingDetailsScreenState extends State<BookingDetailsScreen> {
  String selectedType = 'In-Clinic Visit';
  String selectedTime = '10:00 AM';
  final List<String> times = [
    '09:00 AM', '10:00 AM', '11:00 AM', 
    '02:00 PM', '03:00 PM', '04:00 PM',
    '06:00 PM', '07:00 PM', '08:00 PM', '09:00 PM'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Booking Details'), backgroundColor: Colors.white, elevation: 0, foregroundColor: Colors.black87),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Choose Booking Type', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildTypeCard('In-Clinic Visit', Icons.storefront_rounded),
                const SizedBox(width: 16),
                _buildTypeCard('Teleconsultation', Icons.videocam_rounded),
              ],
            ),
            const SizedBox(height: 32),
            const Text('Select Time Slot', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: times.map((time) => ChoiceChip(
                label: Text(time),
                selected: selectedTime == time,
                onSelected: (val) => setState(() => selectedTime = time),
                selectedColor: const Color(0xFF4A9B8E),
                labelStyle: TextStyle(color: selectedTime == time ? Colors.white : Colors.black87),
              )).toList(),
            ),
            const SizedBox(height: 48),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: const Color(0xFFF8F9FA), borderRadius: BorderRadius.circular(20)),
              child: Column(
                children: [
                  _buildSummaryRow('Consultation Fee', '₱500.00'),
                  _buildSummaryRow('Service Fee', '₱50.00', isBold: true),
                  const Divider(height: 24),
                  _buildSummaryRow('Total Amount', '₱550.00', isBold: true, isLarge: true),
                ],
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => VetPaymentScreen(
                    itemName: 'Booking with ${widget.vet['name']}',
                    amount: 500.00,
                    platformFee: 50.00,
                    isBooking: true,
                    bookingDetails: {
                      'vet': widget.vet['name'],
                      'time': selectedTime,
                      'type': selectedType,
                      'clinic': widget.clinicName ?? 'Partner Clinic',
                      'lat': widget.lat,
                      'lng': widget.lng,
                    },
                  )));
                },
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4A9B8E), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                child: const Text('Confirm & Pay', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeCard(String type, IconData icon) {
    bool isSelected = selectedType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedType = type),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF4A9B8E).withOpacity(0.1) : Colors.white,
            border: Border.all(color: isSelected ? const Color(0xFF4A9B8E) : Colors.grey[200]!, width: 2),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? const Color(0xFF4A9B8E) : Colors.grey, size: 32),
              const SizedBox(height: 8),
              Text(type, textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? const Color(0xFF4A9B8E) : Colors.grey, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isBold = false, bool isLarge = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: isLarge ? 16 : 14)),
          Text(value, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal, fontSize: isLarge ? 20 : 14, color: isLarge ? const Color(0xFF4A9B8E) : Colors.black87)),
        ],
      ),
    );
  }
}

class VetOnCallScreen extends StatelessWidget {
  const VetOnCallScreen({super.key});

  final List<Map<String, dynamic>> onlineVets = const [
    {'name': 'Dr. Emily Chen', 'image': 'https://images.pexels.com/photos/6235228/pexels-photo-6235228.jpeg?auto=compress&cs=tinysrgb&w=800', 'isOnline': true},
    {'name': 'Dr. Robert Tan', 'image': 'https://images.pexels.com/photos/6234614/pexels-photo-6234614.jpeg?auto=compress&cs=tinysrgb&w=800', 'isOnline': true},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(title: const Text('Vet On Call'), backgroundColor: Colors.white, elevation: 0, foregroundColor: Colors.black87),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: onlineVets.length,
        itemBuilder: (context, index) {
          final vet = onlineVets[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)]),
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Stack(
                children: [
                  CircleAvatar(radius: 30, backgroundImage: NetworkImage(vet['image'] ?? '')),
                  Positioned(bottom: 0, right: 0, child: Container(width: 16, height: 16, decoration: BoxDecoration(color: Colors.green, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)))),
                ],
              ),
              title: Text(vet['name'] ?? 'Vet Doctor', style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('Available for urgent call'),
              trailing: ElevatedButton(
                onPressed: () => _showCallSummary(context, vet),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: const Text('Call Now', style: TextStyle(color: Colors.white)),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showCallSummary(BuildContext context, Map<String, dynamic> vet) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRow('Urgent Consultation', '₱800.00'),
            _buildRow('Platform Fee', '₱50.00'),
            const Divider(height: 32),
            _buildRow('Total Payable', '₱850.00', isBold: true),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (context) => VetPaymentScreen(
                    itemName: 'Urgent Call with ${vet['name']}',
                    amount: 800.00,
                    platformFee: 50.00,
                    isUrgent: true,
                    bookingDetails: {
                      'vet': vet['name'],
                      'type': 'Urgent Teleconsultation',
                      'time': 'Immediate',
                    },
                  )));
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28))),
                child: const Text('Proceed to Payment', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal, fontSize: isBold ? 18 : 14)),
        ],
      ),
    );
  }
}

class VetPaymentScreen extends StatefulWidget {
  final String itemName;
  final double amount;
  final double platformFee;
  final bool isUrgent;
  final bool isBooking;
  final Map<String, dynamic>? bookingDetails;

  const VetPaymentScreen({
    super.key,
    required this.itemName,
    required this.amount,
    required this.platformFee,
    this.isUrgent = false,
    this.isBooking = false,
    this.bookingDetails,
  });

  @override
  State<VetPaymentScreen> createState() => _VetPaymentScreenState();
}

class _VetPaymentScreenState extends State<VetPaymentScreen> {
  String selectedMethod = 'GCash';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Payment Summary'), backgroundColor: Colors.white, elevation: 0, foregroundColor: Colors.black87),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Item Breakdown', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: const Color(0xFFF8F9FA), borderRadius: BorderRadius.circular(20)),
              child: Column(
                children: [
                  _buildPayRow(widget.itemName, '₱${widget.amount.toStringAsFixed(2)}'),
                  _buildPayRow('Platform Fee', '₱${widget.platformFee.toStringAsFixed(2)}'),
                  const Divider(height: 24),
                  _buildPayRow('Total Amount', '₱${(widget.amount + widget.platformFee).toStringAsFixed(2)}', isBold: true, isLarge: true),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const Text('Payment Method', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildMethodCard('GCash', 'assets/gcash.jpg', Colors.blue),
            const SizedBox(height: 12),
            _buildMethodCard('Maya', 'assets/maya.jpg', Colors.green),
            const SizedBox(height: 12),
            _buildMethodCard('Credit Card', null, Colors.orange, icon: Icons.credit_card_rounded),
            const SizedBox(height: 60),
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: () => _handlePayment(context),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4A9B8E), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                child: const Text('Pay Now', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMethodCard(String name, String? asset, Color color, {IconData? icon}) {
    bool isSelected = selectedMethod == name;
    return GestureDetector(
      onTap: () => setState(() => selectedMethod = name),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.05) : Colors.white,
          border: Border.all(color: isSelected ? color : Colors.grey[200]!, width: 2),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            if (asset != null)
              Image.asset(asset, width: 32, height: 32, errorBuilder: (c, e, s) => Icon(icon ?? Icons.payment, color: color))
            else
              Icon(icon ?? Icons.payment, color: color, size: 32),
            const SizedBox(width: 16),
            Text(name, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isSelected ? color : Colors.black87)),
            const Spacer(),
            if (isSelected) Icon(Icons.check_circle, color: color),
          ],
        ),
      ),
    );
  }

  Widget _buildPayRow(String label, String value, {bool isBold = false, bool isLarge = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(label, style: TextStyle(color: Colors.grey[600], fontSize: isLarge ? 16 : 14))),
          Text(value, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal, fontSize: isLarge ? 20 : 14)),
        ],
      ),
    );
  }

  void _handlePayment(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator(color: Color(0xFF4A9B8E))),
    );

    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context); 
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => VetSuccessScreen(
        isUrgent: widget.isUrgent,
        isBooking: widget.isBooking,
        bookingDetails: widget.bookingDetails,
      )));
    });
  }
}

class VetSuccessScreen extends StatelessWidget {
  final bool isUrgent;
  final bool isBooking;
  final Map<String, dynamic>? bookingDetails;

  const VetSuccessScreen({super.key, this.isUrgent = false, this.isBooking = false, this.bookingDetails});

  @override
  Widget build(BuildContext context) {
    final String refNum = 'REF-${DateTime.now().year}${DateTime.now().month}${DateTime.now().day}-${(100 + (DateTime.now().second * 7)).toString()}';
    
    if (bookingDetails != null && (bookingDetails!['type'] == 'Teleconsultation' || isUrgent)) {
      globalActiveTeleconsult = bookingDetails;
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              const SizedBox(height: 60),
              const Icon(Icons.check_circle_rounded, size: 100, color: Colors.green),
              const SizedBox(height: 24),
              const Text('Booking Confirmed!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              
              if (bookingDetails != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: const Color(0xFFF8F9FA), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey[200]!)),
                  child: Column(
                    children: [
                      _buildInfoRow('Doctor', bookingDetails!['vet']),
                      _buildInfoRow('Time', bookingDetails!['time']),
                      _buildInfoRow('Type', bookingDetails!['type']),
                      if (bookingDetails!['clinic'] != null) _buildInfoRow('Clinic', bookingDetails!['clinic']),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                if (bookingDetails!['type'] == 'In-Clinic Visit') ...[
                  const Text('Clinic Location', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  Text(bookingDetails!['clinic'] ?? 'Partner Clinic', style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 16),
                  Container(
                    height: 200,
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.grey[200]!)),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: FlutterMap(
                        options: MapOptions(
                          initialCenter: LatLng(bookingDetails!['lat'] ?? 7.30845, bookingDetails!['lng'] ?? 125.68490), 
                          initialZoom: 15
                        ),
                        children: [
                          TileLayer(urlTemplate: 'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png', subdomains: const ['a', 'b', 'c', 'd']),
                          MarkerLayer(markers: [
                            Marker(
                              point: LatLng(bookingDetails!['lat'] ?? 7.30845, bookingDetails!['lng'] ?? 125.68490), 
                              child: const Icon(Icons.location_on, color: Colors.red, size: 40)
                            )
                          ]),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
              
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(color: const Color(0xFFF8F9FA), borderRadius: BorderRadius.circular(12)),
                child: Column(
                  children: [
                    const Text('REFERENCE NUMBER', style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(refNum, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1)),
                  ],
                ),
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton(
                  onPressed: () {
                    // [BUG FIX] Don't clear entire stack, just pop back to main home if it exists
                    // If we can't pop, we just push replacement to prevent white screen
                    if (Navigator.canPop(context)) {
                      Navigator.popUntil(context, (route) => route.isFirst);
                      // Since we want to go back to the dashboard, we push it after popping to base
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const VetClinicScreen()));
                    } else {
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const VetClinicScreen()));
                    }
                  },
                  style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFF4A9B8E)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28))),
                  child: const Text('Back to Vet Services', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF4A9B8E))),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class VetTransactionsScreen extends StatelessWidget {
  const VetTransactionsScreen({super.key});

  final List<Map<String, dynamic>> transactions = const [
    {
      'id': 'REF-20240510-124',
      'title': 'Urgent Call with Dr. Emily Chen',
      'date': 'May 10, 2024 • 2:30 PM',
      'amount': '₱850.00',
      'status': 'Completed',
      'type': 'Teleconsultation',
    },
    {
      'id': 'REF-20240508-442',
      'title': 'Booking at Panabo Pet Care',
      'date': 'May 08, 2024 • 10:00 AM',
      'amount': '₱550.00',
      'status': 'Completed',
      'type': 'Clinic Visit',
    },
    {
      'id': 'REF-20240505-091',
      'title': 'Clinic Listing Subscription',
      'date': 'May 05, 2024 • 9:15 AM',
      'amount': '₱299.00',
      'status': 'Completed',
      'type': 'Subscription',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Transaction History', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: transactions.length,
        itemBuilder: (context, index) {
          final tx = transactions[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: const Color(0xFF4A9B8E).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                      child: Text(tx['type'], style: const TextStyle(color: Color(0xFF4A9B8E), fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                    Text(tx['amount'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                  ],
                ),
                const SizedBox(height: 16),
                Text(tx['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text(tx['date'], style: const TextStyle(color: Colors.grey, fontSize: 13)),
                const Divider(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(tx['id'], style: const TextStyle(color: Colors.grey, fontSize: 12, letterSpacing: 0.5)),
                    Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.green, size: 14),
                        const SizedBox(width: 4),
                        Text(tx['status'], style: const TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class VideoConsultationScreen extends StatefulWidget {
  final String vetName;
  const VideoConsultationScreen({super.key, required this.vetName});

  @override
  State<VideoConsultationScreen> createState() => _VideoConsultationScreenState();
}

class _VideoConsultationScreenState extends State<VideoConsultationScreen> {
  bool _isMicOn = true;
  bool _isCamOn = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: NetworkImage('https://images.pexels.com/photos/6235228/pexels-photo-6235228.jpeg?auto=compress&cs=tinysrgb&w=1200'),
                fit: BoxFit.cover,
                opacity: 0.8,
              ),
            ),
          ),
          
          Positioned(
            top: 60,
            left: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(color: Colors.black.withOpacity(0.5), borderRadius: BorderRadius.circular(20)),
              child: Row(
                children: [
                  Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle)),
                  const SizedBox(width: 8),
                  Text(widget.vetName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),

          Positioned(
            top: 60,
            right: 20,
            child: Container(
              width: 100,
              height: 150,
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white24, width: 2),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 10)],
              ),
              child: _isCamOn 
                ? const ClipRRect(borderRadius: BorderRadius.all(Radius.circular(14)), child: Icon(Icons.person, color: Colors.white24, size: 40))
                : const Center(child: Icon(Icons.videocam_off, color: Colors.white)),
            ),
          ),

          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildCallControl(
                  icon: _isMicOn ? Icons.mic : Icons.mic_off,
                  onTap: () => setState(() => _isMicOn = !_isMicOn),
                  color: _isMicOn ? Colors.white24 : Colors.red,
                ),
                const SizedBox(width: 24),
                _buildCallControl(
                  icon: Icons.call_end,
                  onTap: () {
                    // [BUG FIX] When ending call, go back to dashboard safely
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context);
                    } else {
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const VetClinicScreen()));
                    }
                  },
                  color: Colors.red,
                  isLarge: true,
                ),
                const SizedBox(width: 24),
                _buildCallControl(
                  icon: _isCamOn ? Icons.videocam : Icons.videocam_off,
                  onTap: () => setState(() => _isCamOn = !_isCamOn),
                  color: _isCamOn ? Colors.white24 : Colors.red,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCallControl({required IconData icon, required VoidCallback onTap, required Color color, bool isLarge = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: isLarge ? 70 : 60,
        height: isLarge ? 70 : 60,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        child: Icon(icon, color: Colors.white, size: isLarge ? 32 : 28),
      ),
    );
  }
}
