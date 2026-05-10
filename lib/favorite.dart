import 'package:flutter/material.dart';
import 'dart:convert';
import 'favorites_manager.dart';
import 'pets.dart';
import 'PetScreen.dart'; 
import 'CommunityChat/chat.dart';
import 'profile.dart';
import 'pet_details.dart';
import 'pet_data.dart';
import 'firebase_service.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  String selectedCategory = 'All';
  final List<String> categories = ['All', 'Dog', 'Cat', 'Bird', 'Bunny', 'Other'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA), // Very subtle grey for contrast
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(),
            _buildFilterChips(),
            const SizedBox(height: 10),
            Expanded(
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: FirebaseService().getPets(),
                builder: (context, petsSnapshot) {
                  return ListenableBuilder(
                    listenable: FavoritesManager(),
                    builder: (context, child) {
                      final favoritePets = FavoritesManager().favorites;
                      
                      // Sync with Firebase status (remove adopted)
                      final availablePetIds = petsSnapshot.hasData 
                          ? petsSnapshot.data!.map((p) => p['id'] ?? p['name']).toSet()
                          : <String>{};
                      
                      var favorites = favoritePets.where((pet) {
                        final petId = pet['id'] ?? pet['name'];
                        if (petsSnapshot.hasData) {
                          return availablePetIds.contains(petId);
                        }
                        return pet['isAdopted'] != true;
                      }).toList();

                      // Apply Category Filter
                      if (selectedCategory != 'All') {
                        favorites = favorites.where((pet) {
                          final type = (pet['type'] ?? '').toString().toLowerCase();
                          // Handle "Bunny" vs "Rabbit" naming differences if any
                          if (selectedCategory == 'Bunny' && (type == 'rabbit' || type == 'bunny')) return true;
                          return type == selectedCategory.toLowerCase();
                        }).toList();
                      }

                      if (favorites.isEmpty) {
                        return _buildEmptyState(selectedCategory != 'All');
                      }

                      return GridView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 20,
                          childAspectRatio: 0.7, // Taller cards for premium feel
                        ),
                        itemCount: favorites.length,
                        itemBuilder: (context, index) => _buildPremiumCard(favorites[index]),
                      );
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

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Favorites',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1,
                  color: Colors.teal,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Your loved companions',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          Container(
             padding: const EdgeInsets.all(12),
             decoration: BoxDecoration(
               color: Colors.white,
               shape: BoxShape.circle,
               border: Border.all(color: Colors.grey[200]!),
             ),
             child: const Icon(Icons.favorite, color: Colors.pinkAccent),
          )
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return SizedBox(
      height: 45,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = selectedCategory == category;
          return GestureDetector(
            onTap: () => setState(() => selectedCategory = category),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected ? Colors.teal : Colors.white,
                borderRadius: BorderRadius.circular(100),
                border: Border.all(color: isSelected ? Colors.transparent : Colors.grey[300]!),
                boxShadow: isSelected 
                  ? [BoxShadow(color: Colors.teal.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 4))] 
                  : [],
              ),
              child: Text(
                category,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.teal,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPremiumCard(Map<String, dynamic> pet) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute( builder: (context) => PetDetailsScreen(pet: pet)),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.teal.withOpacity(0.04),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24), bottom: Radius.circular(0)),
                    child: Hero(
                      tag: 'fav_${pet['id'] ?? pet['name']}',
                      child: pet['imageBase64'] != null && (pet['imageBase64'] as String).isNotEmpty
                          ? Image.memory(
                              base64Decode(pet['imageBase64']),
                              fit: BoxFit.cover,
                            )
                          : Image.asset(
                              pet['image'] ?? 'assets/placeholder_dog.png',
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: GestureDetector(
                      onTap: () => FavoritesManager().toggleFavorite(pet),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.95),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(color: Colors.teal.withOpacity(0.1), blurRadius: 4),
                          ],
                        ),
                        child: const Icon(Icons.close_rounded, size: 16, color: Colors.teal),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pet['name'],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      height: 1.1,
                      color: Colors.teal,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${pet['age']} • ${pet['type']}',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[500],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isFiltered) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
             decoration: BoxDecoration(
               color: Colors.grey[100],
               shape: BoxShape.circle,
             ),
             child: Icon(
               isFiltered ? Icons.filter_list_off_rounded : Icons.favorite_border_rounded, 
               size: 40, 
               color: Colors.grey[400],
             ),
          ),
          const SizedBox(height: 24),
          Text(
            isFiltered ? 'No pets in this category' : 'No favorites yet',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[800],
              fontWeight: FontWeight.w600,
            ),
          ),
          if (!isFiltered) ...[
            const SizedBox(height: 8),
            Text(
              'Start adding friends you love!',
              style: TextStyle(
                fontSize: 14,
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
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white, // Premium teal
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                elevation: 0,
              ),
              child: const Text('Explore Pets'),
            ),
          ],
        ],
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
            color: Colors.teal.withOpacity(0.04),
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
          selectedItemColor: Colors.teal, 
          unselectedItemColor: Colors.grey[400],
          showSelectedLabels: false,
          showUnselectedLabels: false,
          elevation: 0,
          currentIndex: 1, 
          onTap: (index) {
             if (index == 1) return;
             switch (index) {
              case 0:
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeScreen()));
                break;
              case 2:
                // Ensure correct PetsScreen import usage
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => PetsScreen(pets: allPets)));
                break;
              case 3:
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const CommunityChatScreen()));
                break;
              case 4:
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const ProfileScreen()));
                break;
            }
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_rounded, size: 26), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.favorite_rounded, size: 26), label: 'Favorites'),
            BottomNavigationBarItem(icon: Icon(Icons.add_circle_rounded, size: 42, color: Colors.teal), label: 'Add'),
            BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline_rounded, size: 26), label: 'Messages'),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline_rounded, size: 26), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}
