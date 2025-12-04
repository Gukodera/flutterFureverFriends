import 'package:flutter/material.dart';
import 'login.dart';
import 'pets.dart';
import 'CommunityChat/chat.dart';
import 'profile.dart';
import 'favorites_manager.dart';
import 'pet_details.dart';
import 'favorite.dart';
import 'pet_data.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedCategory = 0; 

  // Use the shared data, but limit to 4 for the home screen
  final List<Map<String, dynamic>> _pets = allPets.take(4).toList();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          children: [
            // App Bar
            _buildAppBar(context),
            
            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isTablet ? 32.0 : 20.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      
                      // Search Bar
                      _buildSearchBar(),
                      
                      const SizedBox(height: 24),
                      
                      // Modern Banner Card
                      _buildModernBanner(isTablet),
                      
                      const SizedBox(height: 28),
                      
                      // Pet Categories
                      _buildSectionHeader('Pet Categories'),
                      
                      const SizedBox(height: 16),
                      
                      _buildModernCategories(),
                      
                      const SizedBox(height: 28),
                      
                      // Adopt Pet Section
                      _buildSectionHeader('Adopt Pet', showSeeAll: true),
                      
                      const SizedBox(height: 16),
                      
                      // Pet Grid (Limited to 4)
                      _buildPetGrid(isTablet),
                      
                      const SizedBox(height: 32),

                      // Donate Section (New Position)
                      _buildDonateSection(),
                      
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      
      // Bottom Navigation Bar
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.grid_view_rounded, size: 24, color: Colors.black87),
              onPressed: () {},
            ),
          ),
          Column(
            children: [
              Text(
                'Location',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Row(
                children: [
                  Icon(Icons.location_on, size: 14, color: Color(0xFF4A9B8E)),
                  SizedBox(width: 4),
                  Text(
                    'Panabo City',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF4A9B8E), width: 2),
            ),
            child: const CircleAvatar(
              radius: 20,
              backgroundImage: AssetImage('assets/profile.jpg'),
              backgroundColor: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search for a friend...',
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
          prefixIcon: Icon(Icons.search_rounded, color: Colors.grey[400]),
          suffixIcon: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF4A9B8E),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.tune_rounded, color: Colors.white, size: 20),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildModernBanner(bool isTablet) {
    return Container(
      width: double.infinity,
      height: isTablet ? 220 : 180, // Increased height to prevent overflow
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4A9B8E).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: const LinearGradient(
                colors: [Color(0xFF4A9B8E), Color(0xFF2D9E8E)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          // Decorative Circles
          Positioned(
            top: -20,
            right: -20,
            child: CircleAvatar(
              radius: 60,
              backgroundColor: Colors.white.withOpacity(0.1),
            ),
          ),
          Positioned(
            bottom: -30,
            left: -30,
            child: CircleAvatar(
              radius: 80,
              backgroundColor: Colors.white.withOpacity(0.1),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(20.0), // Reduced padding
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'New Arrival',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8), // Reduced spacing
                      const Text(
                        'Find your\nperfect match',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 12), // Reduced spacing
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF2D9E8E),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Check Now',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Image.asset(
                    'assets/banner.jpg', // Ensure this asset exists or use a generic one
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.pets,
                      size: 80,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, {bool showSeeAll = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        if (showSeeAll)
          TextButton(
            onPressed: () {
               Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PetsScreen(pets: allPets),
                ),
              );
            },
            child: const Text(
              'See All',
              style: TextStyle(
                color: Color(0xFF4A9B8E),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildModernCategories() {
    final categories = [
      {'icon': Icons.pets, 'label': 'All'},
      {'icon': Icons.pets, 'label': 'Dog'},
      {'icon': Icons.pets, 'label': 'Cat'},
      {'icon': Icons.cruelty_free, 'label': 'Rabbit'},
      {'icon': Icons.flutter_dash, 'label': 'Bird'},
    ];

    return SizedBox(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          final isSelected = _selectedCategory == index;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategory = index;
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
                    categories[index]['icon'] as IconData,
                    color: isSelected ? Colors.white : Colors.grey[500],
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    categories[index]['label'] as String,
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

  Widget _buildDonateSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF4E5),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.volunteer_activism_rounded,
              color: Colors.orange,
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Make a Difference',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your donation helps us provide food, shelter, and medical care for our furry friends.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // Add donation logic here
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4A9B8E),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Donate Now',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPetGrid(bool isTablet) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isTablet ? 3 : 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemCount: _pets.length,
      itemBuilder: (context, index) {
        return _buildPetCard(_pets[index]);
      },
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
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
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
                                size: 40,
                                color: Colors.grey[300],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: ListenableBuilder(
                      listenable: FavoritesManager(),
                      builder: (context, _) {
                        final isFav = FavoritesManager().isFavorite(pet);
                        return GestureDetector(
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
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isFav ? Icons.favorite : Icons.favorite_border,
                              color: isFav ? const Color(0xFF4A9B8E) : Colors.grey[400],
                              size: 18,
                            ),
                          ),
                        );
                      }
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pet['name'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.location_on_rounded, size: 14, color: Colors.grey[400]),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          pet['location'],
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        pet['age'],
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black87,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Icon(
                        pet['gender'] == 'female' ? Icons.female : Icons.male,
                        size: 16,
                        color: pet['gender'] == 'female' 
                            ? Colors.pink[300] 
                            : Colors.blue[300],
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

  Widget _buildBottomNav() {
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
          currentIndex: 0,
           onTap: (index) {
          
        switch (index) {
            case 0:
              // Home
              break;
            case 1:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const FavoriteScreen(),
                ),
              );
              break;
            case 2:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => PetsScreen(pets: allPets),
                ),
              );
              break;
            case 3:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) =>  const CommunityChatScreen(),
                ),
              );
              break;
            case 4:
             Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) =>   const ProfileScreen(),
                ),
              );
              break;
          }
        },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite_rounded),
              label: 'Favorites',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add_circle_rounded, size: 40, color: Color(0xFF4A9B8E)),
              label: 'Add',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_rounded),
              label: 'Messages',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}