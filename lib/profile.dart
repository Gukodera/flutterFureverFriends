import 'package:flutter/material.dart';
import 'pets.dart';
import 'favorite.dart';
import 'PetScreen.dart';
import 'CommunityChat/chat.dart';
import 'pet_data.dart';
import 'admin_chat.dart';
import 'PetScreen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildProfileHeader(isTablet),
            const SizedBox(height: 30),
            _buildStatsRow(isTablet),
            const SizedBox(height: 30),
            _buildMenuSection(isTablet),
            const SizedBox(height: 30),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
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
                  icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: Colors.black87),
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const HomeScreen())),
                ),
              ),
              const Text(
                'My Profile',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 40), 
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(bool isTablet) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF4A9B8E), width: 3),
              ),
              child: CircleAvatar(
                radius: isTablet ? 80 : 60,
                backgroundImage: const AssetImage('assets/profile.jpg'),
                backgroundColor: Colors.grey[300],
              ),
            ),
            Container(
              margin: const EdgeInsets.only(bottom: 8, right: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF4A9B8E),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
              ),
              child: IconButton(
                icon: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                onPressed: () {},
                constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Text(
          'Bae Suzy',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Panabo City, Philippines',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow(bool isTablet) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isTablet ? 60 : 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem('Adopted', '2'),
            Container(height: 40, width: 1, color: Colors.grey[200]),
            _buildStatItem('Favorites', '12'),
            Container(height: 40, width: 1, color: Colors.grey[200]),
            _buildStatItem('Messages', '5'),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF4A9B8E),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[500],
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuSection(bool isTablet) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isTablet ? 60 : 20),
      child: Column(
        children: [
          _buildMenuItem(
            icon: Icons.person_outline_rounded,
            title: 'Edit Profile',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const EditProfileScreen()),
              );
            },
          ),
          const SizedBox(height: 16),
          _buildMenuItem(
            icon: Icons.pets_outlined,
            title: 'My Requests',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MyRequestsScreen()),
              );
            },
          ),
          const SizedBox(height: 16),
          _buildMenuItem(
            icon: Icons.shield_outlined,
            title: 'Privacy & Security',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PrivacySecurityScreen()),
              );
            },
          ),
          const SizedBox(height: 16),
          _buildMenuItem(
            icon: Icons.help_outline_rounded,
            title: 'Help & Support',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AdminChatScreen()),
              );
            },
          ),
          const SizedBox(height: 16),
          _buildMenuItem(
            icon: Icons.logout_rounded,
            title: 'Logout',
            onTap: () {
               // Add logout logic here
            },
            isDestructive: true,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Widget? trailing,
    bool isDestructive = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isDestructive 
                ? Colors.red.withOpacity(0.1) 
                : const Color(0xFF4A9B8E).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: isDestructive ? Colors.red : const Color(0xFF4A9B8E),
            size: 22,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isDestructive ? Colors.red : Colors.black87,
          ),
        ),
        trailing: trailing ?? Icon(
          Icons.arrow_forward_ios_rounded,
          size: 16,
          color: Colors.grey[400],
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
          currentIndex: 4, // Profile tab active
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
                // Navigate to PetsScreen or Add Pet
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
                // Already on Profile
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

// --- Sub-Screens ---

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Edit Profile', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Center(
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  const CircleAvatar(
                    radius: 60,
                    backgroundImage: AssetImage('assets/profile.jpg'),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Color(0xFF4A9B8E),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            _buildTextField('Full Name', 'Bae Suzy'),
            const SizedBox(height: 20),
            _buildTextField('Email', 'baesuzy@example.com'),
            const SizedBox(height: 20),
            _buildTextField('Phone', '+63 912 345 6789'),
            const SizedBox(height: 20),
            _buildTextField('Location', 'Panabo City, Philippines'),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A9B8E),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Save Changes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, String initialValue) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.grey)),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: initialValue,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          ),
        ),
      ],
    );
  }
}

class MyRequestsScreen extends StatelessWidget {
  const MyRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('My Requests', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        physics: const BouncingScrollPhysics(),
        children: [
          _buildRequestCard(
            context,
            'Max',
            'Dog',
            'assets/dog3.jpg',
            'Pending Approval',
            'Applied on Dec 1, 2023',
            Colors.orange,
          ),
          const SizedBox(height: 20),
          _buildRequestCard(
            context,
            'Luna',
            'Cat',
            'assets/cat1.jpg',
            'Approved',
            'Applied on Nov 28, 2023',
            const Color(0xFF4A9B8E),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestCard(BuildContext context, String name, String type, String image, String status, String date, Color statusColor) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Navigate to details or status page
          },
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.asset(image, width: 70, height: 70, fit: BoxFit.cover),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            type,
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            date,
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Status',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: statusColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            status,
                            style: TextStyle(
                              color: statusColor,
                              fontWeight: FontWeight.bold,
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
        ),
      ),
    );
  }
}

class PrivacySecurityScreen extends StatelessWidget {
  const PrivacySecurityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Privacy & Security', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildSectionTitle('Security'),
          _buildSettingItem(
            context,
            'Change Password',
            Icons.lock_outline,
            onTap: () => _showChangePasswordDialog(context),
          ),
          _buildSettingItem(
            context,
            'Two-Factor Authentication',
            Icons.security,
            onTap: () {},
          ),
          const SizedBox(height: 30),
          _buildSectionTitle('Privacy'),
          _buildSettingItem(
            context,
            'Profile Visibility',
            Icons.visibility_outlined,
            onTap: () {},
          ),
          _buildSettingItem(
            context,
            'Blocked Users',
            Icons.block,
            onTap: () {},
          ),
          _buildSettingItem(
            context,
            'Data & Permissions',
            Icons.data_usage,
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, left: 4),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF4A9B8E)),
      ),
    );
  }

  Widget _buildSettingItem(BuildContext context, String title, IconData icon, {required VoidCallback onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.grey[600]),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        trailing: Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey[400]),
        onTap: onTap,
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Change Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Current Password',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'New Password',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Confirm New Password',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Password changed successfully!'), backgroundColor: Color(0xFF4A9B8E)),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4A9B8E),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }
}
