import 'package:flutter/material.dart';
import 'login.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF4A9B8E),
              Color(0xFF3D8B7E),
              Color(0xFF2D7A6E),
            ],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth < 600;
              final isTablet =
                  constraints.maxWidth >= 600 && constraints.maxWidth < 1200;

              return SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 20 : 40,
                    vertical: isMobile ? 16 : 28,
                  ),
                  child: Column(
                    children: [
                      SizedBox(height: constraints.maxHeight * 0.03),

                      // Logo
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.pets,
                              color: Colors.white,
                              size: isMobile ? 20 : 28,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Furever Friends',
                              style: TextStyle(
                                fontSize: isMobile ? 16 : 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: constraints.maxHeight * 0.08),

                      // Images section
                      SizedBox(
                        height: isMobile ? 280 : 420,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Positioned(
                              top: 20,
                              left: 15,
                              child: Container(
                                width: isMobile ? 100 : 140,
                                height: isMobile ? 100 : 140,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: RadialGradient(
                                    colors: [
                                      Colors.white.withOpacity(0.1),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            // Floating decorative elements
                            Positioned(
                              top: 15,
                              right: 30,
                              child: Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.pets,
                                  color: Colors.white.withOpacity(0.6),
                                  size: isMobile ? 18 : 26,
                                ),
                              ),
                            ),
                            Positioned(
                              top: 80,
                              left: 15,
                              child: Container(
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.favorite,
                                  color: Colors.white.withOpacity(0.5),
                                  size: isMobile ? 16 : 22,
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 50,
                              right: 30,
                              child: Container(
                                padding: EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.18),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.pets,
                                  color: Colors.white.withOpacity(0.6),
                                  size: isMobile ? 14 : 20,
                                ),
                              ),
                            ),

                            // Top-left circle - DOG
                            Positioned(
                              top: 25,
                              left: 5,
                              child: _buildPetCircle(
                                size: isMobile ? 140 : 150,
                                asset: 'assets/dog.jpg',
                                fallbackColor: Color(0xFFFFE0B2),
                                fallbackGradient: [
                                  Color(0xFFFFE0B2),
                                  Color(0xFFFFCC80),
                                ],
                              ),
                            ),

                            // Top-right circle - CAT
                            Positioned(
                              top: 0,
                              right: 0.5,
                              child: _buildPetCircle(
                                size: isMobile ? 140 : 120,
                                asset: 'assets/cat.jpg',
                                fallbackColor: Color(0xFFE1BEE7),
                                fallbackGradient: [
                                  Color(0xFFE1BEE7),
                                  Color(0xFFCE93D8),
                                ],
                              ),
                            ),

                            // Center large circle
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Center(
                                child: _buildPetCircle(
                                  size: isMobile ? 180 : 280,
                                  asset: 'assets/partner.jpg',
                                  fallbackColor: Color(0xFFFFF9C4),
                                  fallbackGradient: [
                                    Color(0xFFFFF9C4),
                                    Color(0xFFFFE082),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: constraints.maxHeight * 0.03),

                      // Title
                      ShaderMask(
                        shaderCallback: (bounds) => LinearGradient(
                          colors: [
                            Colors.white,
                            Colors.white.withOpacity(0.95),
                          ],
                        ).createShader(bounds),
                        child: Text(
                          'Find Your FurBabies 🐾',
                          style: TextStyle(
                            fontSize: isMobile ? 28 : 40,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            height: 1.15,
                            letterSpacing: -0.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),

                      SizedBox(height: isMobile ? 16 : 24),

                      // Subtitle
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: isMobile ? 8 : 12),
                        child: Text(
                          'Discover adorable pets waiting for a loving home. Your new best friend is just a tap away!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: isMobile ? 14 : 16,
                            color: Colors.white.withOpacity(0.95),
                            height: 1.6,
                            letterSpacing: 0.3,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),

                      SizedBox(height: isMobile ? 20 : 28),

                      // Feature chips
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: isMobile ? 8 : 12,
                        runSpacing: 8,
                        children: [
                          _buildFeatureChip(Icons.verified, '100% Verified',
                              isMobile),
                          _buildFeatureChip(
                              Icons.favorite, 'Best Match', isMobile),
                          _buildFeatureChip(
                              Icons.security, 'Safe & Secure', isMobile),
                        ],
                      ),

                      SizedBox(height: isMobile ? 28 : 40),

                      // Login button
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(32),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 20,
                              offset: Offset(0, 10),
                            ),
                            BoxShadow(
                              color: Colors.white.withOpacity(0.1),
                              blurRadius: 10,
                              offset: Offset(0, -2),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const LoginPage()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Color(0xFF4A9B8E),
                            minimumSize:
                                Size(double.infinity, isMobile ? 56 : 70),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(32),
                            ),
                            elevation: 0,
                            shadowColor: Colors.transparent,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Get Started',
                                style: TextStyle(
                                  fontSize: isMobile ? 16 : 20,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              SizedBox(width: isMobile ? 8 : 12),
                              Icon(
                                Icons.arrow_forward_rounded,
                                size: isMobile ? 20 : 26,
                                color: Color(0xFF4A9B8E),
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: isMobile ? 12 : 16),

                      // Trust indicator
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.shield_outlined,
                            size: isMobile ? 14 : 16,
                            color: Colors.white.withOpacity(0.7),
                          ),
                          SizedBox(width: isMobile ? 6 : 8),
                          Text(
                            'Your data is safe with us',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: isMobile ? 12 : 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: isMobile ? 16 : 20),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPetCircle({
    required double size,
    required String asset,
    required Color fallbackColor,
    required List<Color> fallbackGradient,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            Colors.white.withOpacity(0.95),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 20,
            offset: Offset(0, 10),
            spreadRadius: 2,
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(-5, -5),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(6.0),
        child: ClipOval(
          child: Image.asset(
            asset,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: fallbackGradient),
                ),
                child: Icon(
                  Icons.pets,
                  size: size * 0.5,
                  color: fallbackColor,
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureChip(IconData icon, String label, bool isMobile) {
    return Container(
      padding:
          EdgeInsets.symmetric(horizontal: isMobile ? 10 : 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: isMobile ? 12 : 14,
            color: Colors.white,
          ),
          SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: isMobile ? 10 : 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
