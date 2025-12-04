import 'package:flutter/material.dart';
import 'favorites_manager.dart';
import 'pets.dart';
import 'PetScreen.dart';
import 'CommunityChat/chat.dart';
import 'profile.dart';
import 'pet_details.dart';
import 'pet_data.dart'; // Import shared data

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'My Favorites',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: ListenableBuilder(
        listenable: FavoritesManager(),
        builder: (context, child) {
          final favorites = FavoritesManager().favorites;
          
          if (favorites.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Icon(Icons.favorite_border_rounded, size: 80, color: Colors.grey[300]),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'No favorites yet',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.grey[800],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Start adding friends you love!',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[500],
                    ),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => PetsScreen(pets: allPets)),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4A9B8E),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 0,
                    ),
                    child: const Text('Explore Pets'),
                  ),
                ],
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(20),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.75,
            ),
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              final pet = favorites[index];
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.1),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: _controller,
                  curve: Interval(
                    index * 0.1,
                    1.0,
                    curve: Curves.easeOut,
                  ),
                )),
                child: FadeTransition(
                  opacity: Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
                    parent: _controller,
                    curve: Interval(index * 0.1, 1.0, curve: Curves.easeOut),
                  )),
                  child: _buildFavoriteCard(pet),
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildFavoriteCard(Map<String, dynamic> pet) {
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
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    child: Hero(
                      tag: 'fav-${pet['name']}',
                      child: Image.asset(
                        pet['image'],
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: Colors.grey[200],
                          child: const Center(child: Icon(Icons.pets, color: Colors.grey)),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: GestureDetector(
                      onTap: () {
                        FavoritesManager().toggleFavorite(pet);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.favorite_rounded,
                          color: Color(0xFF4A9B8E),
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
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
          currentIndex: 1, // Favorites tab active
          onTap: (index) {
            switch (index) {
              case 0:
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const HomeScreen()),
                );
                break;
              case 1:
                // Already on Favorites
                break;
              case 2:
                // Navigate to PetsScreen with ALL pets
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
