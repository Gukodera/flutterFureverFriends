import 'package:flutter/material.dart';
import 'favorites_manager.dart';
import 'pet_details.dart';
import 'PetScreen.dart';
import 'CommunityChat/chat.dart';
import 'profile.dart';
import 'favorite.dart';
import 'pet_data.dart';

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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCategoryChips(),
            const SizedBox(height: 16),
            Expanded(
              child: filteredPets.isEmpty
                  ? Center(
                      child: Text(
                        'No pets found',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    )
                  : GridView.builder(
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
              IconButton(
                icon: const Icon(Icons.menu, size: 28, color: Colors.black87),
                onPressed: () {
                  // keep same behavior as HomeScreen (no change)
                },
              ),
              const Spacer(),
              const Text(
                'Pets',
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
                  child: const CircleAvatar(
                    radius: 18,
                    backgroundImage: AssetImage('assets/profile.jpg'),
                    backgroundColor: Colors.grey,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
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
          /// IMAGE SECTION — EXACT SAME BEHAVIOR
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Hero(
                tag: 'pet-${pet['name']}',
                child: Image.asset(
                  pet['image'],
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

          /// TEXT + DETAILS SECTION — EXACT MATCH
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
                      pet['name'],
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
                      pet['location'],
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),

                /// GENDER + AGE ROW
                Row(
                  children: [
                    Icon(
                      pet['gender'] == 'female' ? Icons.female : Icons.male,
                      size: 16,
                      color: pet['gender'] == 'female'
                          ? Colors.pink[300]
                          : Colors.blue[300],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      pet['age'],
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