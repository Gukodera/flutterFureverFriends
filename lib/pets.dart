import 'package:flutter/material.dart';
import 'favorites_manager.dart';
import 'pet_details.dart';
import 'PetScreen.dart';
import 'CommunityChat/chat.dart';
import 'profile.dart';
import 'favorite.dart';
import 'pet_data.dart';
import 'firebase_service.dart';
import 'dart:convert';
import 'vet_doctor.dart';
import 'breeder_marketplace.dart';

class PetsScreen extends StatefulWidget {
  final List<Map<String, dynamic>> pets;
  const PetsScreen({super.key, required this.pets});

  @override
  State<PetsScreen> createState() => _PetsScreenState();
}

class _PetsScreenState extends State<PetsScreen> {
  // categories: use lowercase for comparison
  final List<String> categories = ['all', 'dog', 'cat', 'rabbit', 'bird'];
  String selectedCategory = 'all';
  String? _userPhotoBase64;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final userData = await FirebaseService().getUserProfile();
      if (mounted && userData != null) {
        setState(() {
          _userPhotoBase64 = userData['photoURL'];
        });
      }
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  List<Map<String, dynamic>> get filteredPets {
    if (selectedCategory == 'all') return widget.pets;
    return widget.pets.where((p) {
      // prefer explicit 'type' field
      final typeField = (p['type'] ?? '').toString().toLowerCase();
      if (typeField.isNotEmpty) return typeField == selectedCategory;

      // fallback: infer from image filename if available
      final img = (p['image'] ?? '').toString().toLowerCase();
      if (img.contains('dog')) return selectedCategory == 'dog';
      if (img.contains('cat')) return selectedCategory == 'cat';
      if (img.contains('rabbit')) return selectedCategory == 'rabbit';
      if (img.contains('bird')) return selectedCategory == 'bird';

      // fallback: don't show if unknown
      return false;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(context),
      drawer: _buildDrawer(context),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCategoryChips(),
            const SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: FirebaseService().getPets(),
                builder: (context, snapshot) {
                  // Loading
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: Color(0xFF4A9B8E)),
                    );
                  }

                  // Get pets from Firebase or fallback to local
                  final allPetsData = snapshot.data ?? widget.pets;
                  
                  // Filter by category
                  final filteredPets = selectedCategory == 'all'
                      ? allPetsData
                      : allPetsData.where((p) {
                          final type = (p['type'] ?? '').toString().toLowerCase();
                          return type == selectedCategory;
                        }).toList();

                  // Empty state
                  if (filteredPets.isEmpty) {
                    return Center(
                      child: Text(
                        'No pets found',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    );
                  }

                  // Grid
                  return GridView.builder(
                    padding: EdgeInsets.zero,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: isTablet ? 3 : 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.75,
                    ),
                    itemCount: filteredPets.length,
                    itemBuilder: (context, index) {
                      return _buildPetCard(filteredPets[index]);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    // Match HomeScreen app bar style: menu icon and profile avatar
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            children: [
              Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.menu, size: 28, color: Colors.black87),
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                ),
              ),
              const Spacer(),
              const Text(
                'Available To Adopt',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: const Color(0xFF4A9B8E),
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.grey[200],
                      backgroundImage: _userPhotoBase64 != null
                          ? MemoryImage(base64Decode(_userPhotoBase64!))
                          : null,
                      child: _userPhotoBase64 == null
                          ? const Icon(Icons.person, color: Colors.grey, size: 20)
                          : null,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Color(0xFF4A9B8E),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.pets, size: 48, color: Colors.white),
                  SizedBox(height: 12),
                  Text(
                    'Furever Friends',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          _buildDrawerItem(
            icon: Icons.local_hospital_outlined,
            title: 'Vet Clinic',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const VetClinicScreen()),
              );
            },
          ),
          _buildDrawerItem(
            icon: Icons.pets_outlined,
            title: 'Breeder Marketplace',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const BreederMarketplaceHome()),
              );
            },
          ),
          _buildDrawerItem(
            icon: Icons.shopping_bag_outlined,
            title: 'Pet Shop',
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Pet Shop is under development!'), backgroundColor: Color(0xFF4A9B8E)),
              );
            },
          ),
          _buildDrawerItem(
            icon: Icons.content_cut_outlined,
            title: 'Grooming',
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Grooming Services are under development!'), backgroundColor: Color(0xFF4A9B8E)),
              );
            },
          ),
          const Divider(),
          _buildDrawerItem(
            icon: Icons.info_outline,
            title: 'About Us',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => const AboutUsScreen()));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF4A9B8E)),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
    );
  }

  Widget _buildCategoryChips() {
    final categories = [
      {'icon': Icons.pets, 'label': 'All', 'value': 'all'},
      {'icon': Icons.pets, 'label': 'Dog', 'value': 'dog'},
      {'icon': Icons.pets, 'label': 'Cat', 'value': 'cat'},
      {'icon': Icons.cruelty_free, 'label': 'Rabbit', 'value': 'rabbit'},
      {'icon': Icons.flutter_dash, 'label': 'Bird', 'value': 'bird'},
    ];

    return SizedBox(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = selectedCategory == category['value'];

          return GestureDetector(
            onTap: () {
              setState(() {
                selectedCategory = category['value'] as String;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF4A9B8E) : Colors.white,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: isSelected ? const Color(0xFF4A9B8E) : Colors.grey[200]!,
                  width: 1.5,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: const Color(0xFF4A9B8E).withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [],
              ),
              child: Row(
                children: [
                  Icon(
                    category['icon'] as IconData,
                    color: isSelected ? Colors.white : Colors.grey[500],
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    category['label'] as String,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey[600],
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPetCard(Map<String, dynamic> pet) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PetDetailsScreen(pet: pet),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// IMAGE SECTION
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Hero(
                  tag: 'pet-${pet['name']}',
                  child: pet['imageBase64'] != null && (pet['imageBase64'] as String).isNotEmpty
                      ? Image.memory(
                          base64Decode(pet['imageBase64']),
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Center(
                              child: Icon(
                                Icons.pets,
                                size: 50,
                                color: Colors.grey[400],
                              ),
                            );
                          },
                        )
                      : Image.asset(
                          pet['image'] ?? 'assets/placeholder.png',
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Center(
                              child: Icon(
                                Icons.pets,
                                size: 50,
                                color: Colors.grey[400],
                               ),
                            );
                          },
                        ),
                ),
              ),
            ),

            /// TEXT + DETAILS SECTION
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// NAME + HEART ICON
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        (pet['name'] ?? 'Unknown').toString(),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      ListenableBuilder(
                        listenable: FavoritesManager(),
                        builder: (context, _) {
                          final isFav = FavoritesManager().isFavorite(pet);
                          return InkWell(
                            onTap: () {
                              FavoritesManager().toggleFavorite(pet);
                              final isNowFav = FavoritesManager().isFavorite(pet);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    isNowFav ? 'Added to favorites' : 'Removed from favorites',
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  backgroundColor: const Color(0xFF4A9B8E),
                                  duration: const Duration(seconds: 1),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(20),
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Icon(
                                isFav ? Icons.favorite : Icons.favorite_border,
                                color: isFav ? const Color(0xFF4A9B8E) : Colors.teal,
                                size: 20,
                              ),
                            ),
                          );
                        }
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  /// LOCATION ROW
                  Row(
                    children: [
                      Icon(Icons.location_on,
                          size: 14, color: Colors.grey[500]),
                      const SizedBox(width: 4),
                      Text(
                        (pet['location'] ?? 'Unknown').toString(),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),

                  /// GENDER + AGE ROW
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        pet['gender'] == 'male' ? Icons.male : Icons.female,
                        size: 14,
                        color: pet['gender'] == 'male'
                            ? Colors.pink[300]
                            : Colors.blue[300],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        pet['age'] is int ? '${pet['age']} yrs' : (pet['age'] ?? 'Unknown'),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
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
          currentIndex: 2, // Pets tab active
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
                // already on Pets but refresh logic if needed
                 Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => PetsScreen(pets: allPets)),
                );
                break;
              case 3:
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const CommunityChatScreen()),
                );
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

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About Us'),
        backgroundColor: const Color(0xFF4A9B8E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  const Icon(Icons.pets, size: 80, color: Color(0xFF4A9B8E)),
                  const SizedBox(height: 16),
                  const Text(
                    'Furever Friends',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF4A9B8E)),
                  ),
                  Text(
                    'Connecting Hearts, One Paw at a Time',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600], fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            const Text(
              'Our Mission',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'At Furever Friends, we believe every pet deserves a loving home and every owner deserves professional support. Our platform bridges the gap between responsible breeders, veterinary services, and passionate pet lovers in Panabo City and beyond.',
              style: TextStyle(fontSize: 16, height: 1.6, color: Colors.black87),
            ),
            const SizedBox(height: 32),
            const Text(
              'What We Offer',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildFeatureItem(Icons.verified_user, 'Verified Breeders', 'Ensuring ethical and healthy breeding standards.'),
            _buildFeatureItem(Icons.local_hospital, 'Professional Vet Care', 'Connecting you with the best clinics and 1v1 teleconsultations.'),
            _buildFeatureItem(Icons.favorite, 'Adoption Center', 'Finding perfect homes for pets in need.'),
            const SizedBox(height: 40),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF4A9B8E).withOpacity(0.05),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF4A9B8E).withOpacity(0.2)),
              ),
              child: Column(
                children: const [
                  Text(
                    'Version 1.0.0',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF4A9B8E)),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Developed with ❤️ for the Pet Community of Panabo City.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: const Color(0xFF4A9B8E).withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: const Color(0xFF4A9B8E), size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text(desc, style: const TextStyle(fontSize: 14, color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}