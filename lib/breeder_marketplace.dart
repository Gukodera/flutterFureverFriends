import 'package:flutter/material.dart';
import 'dart:async';
import 'breeder_marketplace_data.dart';

// [DESIGN SYSTEM]
const Color kMarketPrimary = Color(0xFF4A9B8E);
const Color kMarketSecondary = Color(0xFFF1F8F7);
const Color kMarketAccent = Color(0xFFFFD166);
const Color kMarketText = Color(0xFF1A1A1A);
const Color kMarketBg = Color(0xFFFDFDFD);

class BreederMarketplaceHome extends StatefulWidget {
  const BreederMarketplaceHome({super.key});

  @override
  State<BreederMarketplaceHome> createState() => _BreederMarketplaceHomeState();
}

class _BreederMarketplaceHomeState extends State<BreederMarketplaceHome> {
  String selectedFilter = 'All';
  final List<String> filters = ['All', 'For Sale', 'Stud Services', 'Verified Breeders'];
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  List<MarketplacePet> get filteredPets {
    return mockMarketplacePets.where((pet) {
      final matchesSearch = pet.name.toLowerCase().contains(_searchQuery.toLowerCase()) || 
                           pet.breed.toLowerCase().contains(_searchQuery.toLowerCase());
      
      if (selectedFilter == 'All') return matchesSearch;
      if (selectedFilter == 'For Sale') return matchesSearch && pet.type == 'For Sale';
      if (selectedFilter == 'Stud Services') return matchesSearch && pet.type == 'Stud';
      if (selectedFilter == 'Verified Breeders') {
        final breeder = mockBreeders.firstWhere((b) => b.id == pet.breederId);
        return matchesSearch && breeder.isVerified;
      }
      return matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kMarketBg,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
              child: _buildSearchBar(),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: _buildFilterChips(),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverToBoxAdapter(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(selectedFilter == 'All' ? 'Featured Pets' : selectedFilter, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  TextButton(onPressed: () {}, child: const Text('See All', style: TextStyle(color: kMarketPrimary))),
                ],
              ),
            ),
          ),
          if (filteredPets.isEmpty) 
            const SliverFillRemaining(child: Center(child: Text('No pets found matching your criteria.')))
          else
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.75,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final pet = filteredPets[index];
                    return _buildPetCard(pet);
                  },
                  childCount: filteredPets.length,
                ),
              ),
            ),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Text('Top Rated Breeders', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final breeder = mockBreeders[index];
                return _buildBreederListTile(breeder);
              },
              childCount: mockBreeders.length,
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const BreederDashboard())),
        backgroundColor: kMarketPrimary,
        icon: const Icon(Icons.dashboard_rounded, color: Colors.white),
        label: const Text('Breeder Dashboard', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 140,
      pinned: true,
      backgroundColor: kMarketPrimary,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [kMarketPrimary, Color(0xFF3D8277)],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Breeder Marketplace', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                Text('Trusted and Verified Partners', style: TextStyle(color: Colors.white70, fontSize: 13)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (v) => setState(() => _searchQuery = v),
        decoration: InputDecoration(
          hintText: 'Search pets or breeds...',
          prefixIcon: const Icon(Icons.search, color: kMarketPrimary),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          suffixIcon: _searchQuery.isNotEmpty 
            ? IconButton(icon: const Icon(Icons.clear), onPressed: () {
                _searchController.clear();
                setState(() => _searchQuery = '');
              })
            : null,
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = selectedFilter == filter;
          return GestureDetector(
            onTap: () => setState(() => selectedFilter = filter),
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? kMarketPrimary : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isSelected ? kMarketPrimary : Colors.grey[200]!),
                boxShadow: isSelected ? [BoxShadow(color: kMarketPrimary.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))] : [],
              ),
              child: Center(
                child: Text(
                  filter,
                  style: TextStyle(color: isSelected ? Colors.white : Colors.grey[600], fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPetCard(MarketplacePet pet) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => PetDetailScreen(pet: pet))),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                    child: Image.network(pet.imageUrl, width: double.infinity, height: double.infinity, fit: BoxFit.cover),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: Colors.black.withOpacity(0.6), borderRadius: BorderRadius.circular(12)),
                      child: Text(pet.type, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
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
                  Text(pet.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text(pet.breed, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                  const SizedBox(height: 8),
                  Text(
                    '₱${pet.price.toStringAsFixed(0)}',
                    style: const TextStyle(color: kMarketPrimary, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBreederListTile(Breeder breeder) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => BreederProfileScreen(breeder: breeder))),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey[100]!),
        ),
        child: Row(
          children: [
            CircleAvatar(radius: 30, backgroundImage: NetworkImage(breeder.imageUrl)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(breeder.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      if (breeder.isVerified) ...[
                        const SizedBox(width: 4),
                        const Icon(Icons.verified, color: Colors.blue, size: 16),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(breeder.specialtyBreeds.join(', '), style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, color: kMarketAccent, size: 16),
                      const SizedBox(width: 4),
                      Text('${breeder.rating}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      const SizedBox(width: 8),
                      Text('(${breeder.reviews} reviews)', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

// --- BREEDER PROFILE SCREEN (STATIC) ---

class BreederProfileScreen extends StatelessWidget {
  final Breeder breeder;
  const BreederProfileScreen({super.key, required this.breeder});

  @override
  Widget build(BuildContext context) {
    final breederPets = mockMarketplacePets.where((p) => p.breederId == breeder.id).toList();

    return Scaffold(
      backgroundColor: kMarketBg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), shape: BoxShape.circle),
                child: const Icon(Icons.arrow_back_ios_new, color: kMarketPrimary, size: 16),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(breeder.imageUrl, fit: BoxFit.cover),
                  Container(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.black.withOpacity(0.3), Colors.black.withOpacity(0.7)]))),
                ],
              ),
              title: Text(breeder.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.verified, color: Colors.blue, size: 24),
                      const SizedBox(width: 8),
                      const Text('Verified Breeder', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      const Spacer(),
                      const Icon(Icons.star_rounded, color: kMarketAccent),
                      Text(' ${breeder.rating} (${breeder.reviews})', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text('About', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(breeder.bio, style: const TextStyle(color: Colors.black54, height: 1.6)),
                  const SizedBox(height: 32),
                  const Text('Specialties', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: breeder.specialtyBreeds.map((b) => Chip(label: Text(b), backgroundColor: kMarketSecondary, side: BorderSide.none)).toList(),
                  ),
                  const SizedBox(height: 32),
                  Text('${breeder.name}\'s Listings', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.75,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final pet = breederPets[index];
                  return _buildSmallPetCard(context, pet);
                },
                childCount: breederPets.length,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))]),
        child: SizedBox(
          width: double.infinity,
          height: 60,
          child: ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.chat_bubble_outline_rounded, color: Colors.white),
            label: const Text('Inquire Now', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            style: ElevatedButton.styleFrom(backgroundColor: kMarketPrimary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
          ),
        ),
      ),
    );
  }

  Widget _buildSmallPetCard(BuildContext context, MarketplacePet pet) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => PetDetailScreen(pet: pet))),
      child: Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey[100]!)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: ClipRRect(borderRadius: const BorderRadius.vertical(top: Radius.circular(16)), child: Image.network(pet.imageUrl, width: double.infinity, fit: BoxFit.cover))),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(pet.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text('₱${pet.price.toStringAsFixed(0)}', style: const TextStyle(color: kMarketPrimary, fontWeight: FontWeight.bold, fontSize: 12)),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}

// --- BREEDER DASHBOARD ---

class BreederDashboard extends StatelessWidget {
  const BreederDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kMarketBg,
      appBar: AppBar(
        title: const Text('My Breeder Dashboard'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: kMarketText,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatsGrid(),
            const SizedBox(height: 32),
            const Text('Manage My Pets', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildActionCard(Icons.add_circle_outline_rounded, 'Add New Pet Listing', 'Sell or Stud Services', kMarketPrimary, () {}),
            _buildActionCard(Icons.folder_shared_outlined, 'Manage Litters', 'Track births and growth records', Colors.blue, () {}),
            _buildActionCard(Icons.workspace_premium_outlined, 'Premium Membership', 'Boost visibility by 10x', kMarketAccent, () => _showSubscriptionSheet(context)),
            const SizedBox(height: 32),
            const Text('Verification Status', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
              child: Row(
                children: [
                  const Icon(Icons.verified_user_rounded, color: Colors.blue, size: 32),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Identity Verified', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blue)),
                        Text('Your account is trusted by our community.', style: TextStyle(fontSize: 12, color: Colors.blueGrey)),
                      ],
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

  Widget _buildStatsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard('Total Sales', '₱0', Icons.payments_rounded, Colors.green),
        _buildStatCard('Active Pets', '0', Icons.pets_rounded, kMarketPrimary),
        _buildStatCard('Profile Views', '1.2k', Icons.remove_red_eye_rounded, Colors.orange),
        _buildStatCard('Avg. Rating', '3.0', Icons.star_rounded, kMarketAccent),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const Spacer(),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildActionCard(IconData icon, String title, String subtitle, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey[100]!)),
        child: Row(
          children: [
            Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle), child: Icon(icon, color: color)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(subtitle, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
              ]),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  void _showSubscriptionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 24),
            const Text('Upgrade to Premium', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Unlock exclusive features and grow your business.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 32),
            _buildPlanCard('Standard', 'Free', ['1 Pet Listings', 'Standard Visibility', 'Basic Support'], false),
            const SizedBox(height: 16),
            _buildPlanCard('Pro Breeder', '₱499/mo', ['3 Pet Listings', 'Featured Badge', 'Direct Chat Priority', 'Analytics Dashboard'], true),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(backgroundColor: kMarketPrimary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                child: const Text('Continue to Payment', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanCard(String name, String price, List<String> perks, bool isSelected) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isSelected ? kMarketPrimary.withOpacity(0.05) : Colors.white,
        border: Border.all(color: isSelected ? kMarketPrimary : Colors.grey[200]!, width: 2),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              Text(price, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: kMarketPrimary)),
            ],
          ),
          const SizedBox(height: 16),
          ...perks.map((p) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(children: [const Icon(Icons.check_circle_rounded, size: 16, color: kMarketPrimary), const SizedBox(width: 8), Text(p, style: const TextStyle(fontSize: 13))]),
          )),
        ],
      ),
    );
  }
}

// --- PET DETAIL SCREEN ---

class PetDetailScreen extends StatelessWidget {
  final MarketplacePet pet;
  const PetDetailScreen({super.key, required this.pet});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 400,
            pinned: true,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), shape: BoxShape.circle),
                child: const Icon(Icons.arrow_back_ios_new, color: kMarketPrimary, size: 16),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(background: Image.network(pet.imageUrl, fit: BoxFit.cover)),
            backgroundColor: kMarketPrimary,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(color: kMarketPrimary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                        child: Text(pet.type, style: const TextStyle(color: kMarketPrimary, fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                      const Spacer(),
                      const Icon(Icons.share_rounded, color: Colors.grey),
                      const SizedBox(width: 16),
                      const Icon(Icons.favorite_border_rounded, color: Colors.grey),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(pet.name, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('${pet.breed} • ${pet.age}', style: const TextStyle(fontSize: 18, color: Colors.grey)),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildInfoItem(Icons.vaccines_rounded, 'Vaccinated', pet.isVaccinated ? 'Yes' : 'No'),
                      _buildInfoItem(Icons.monitor_heart_rounded, 'Health', 'Verified'),
                      _buildInfoItem(Icons.male_rounded, 'Gender', pet.gender),
                    ],
                  ),
                  const Divider(height: 48),
                  const Text('Price', style: TextStyle(fontSize: 16, color: Colors.grey)),
                  const SizedBox(height: 4),
                  Text(
                    '₱${pet.price.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: kMarketPrimary),
                  ),
                  const SizedBox(height: 32),
                  const Text('About this pet', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  const Text(
                    'This lovely pet is ready for a new home. Raised with care and love by a verified breeder. Health records are available for review.',
                    style: TextStyle(color: Colors.black54, height: 1.6, fontSize: 15),
                  ),
                  const SizedBox(height: 32),
                  const Text('Health Records', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: kMarketSecondary, borderRadius: BorderRadius.circular(16)),
                    child: Row(
                      children: [
                        const Icon(Icons.picture_as_pdf_rounded, color: Colors.red, size: 32),
                        const SizedBox(width: 16),
                        const Expanded(child: Text('Official Health Record.pdf', style: TextStyle(fontWeight: FontWeight.bold))),
                        IconButton(onPressed: () {}, icon: const Icon(Icons.download_rounded, color: kMarketPrimary)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))]),
        child: Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 60,
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(side: const BorderSide(color: kMarketPrimary), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                  child: const Text('Contact Breeder', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: kMarketPrimary)),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: SizedBox(
                height: 60,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(backgroundColor: kMarketPrimary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                  child: const Text('Request Booking', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: kMarketSecondary, shape: BoxShape.circle), child: Icon(icon, color: kMarketPrimary, size: 24)),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      ],
    );
  }
}
