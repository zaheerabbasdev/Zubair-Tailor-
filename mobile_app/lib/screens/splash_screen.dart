import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import 'dashboard_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.6, curve: Curves.easeIn)),
    );

    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic)),
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
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 360;

    return Scaffold(
      backgroundColor: AppColors.primary, // Deep Brown replaced with Primary
      body: Stack(
        children: [
          // Background Decorative circles
          Positioned(
            top: -size.width * 0.25,
            right: -size.width * 0.25,
            child: Container(
              width: size.width * 0.75,
              height: size.width * 0.75,
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -size.width * 0.125,
            left: -size.width * 0.125,
            child: Container(
              width: size.width * 0.5,
              height: size.width * 0.5,
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
            ),
          ),
          
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 20.0 : 32.0, 
                vertical: isSmallScreen ? 24.0 : 48.0,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Column(
                        children: [
                          Container(
                            padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              shape: BoxShape.circle,
                              border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.5)),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFD4AF37).withOpacity(0.2),
                                  blurRadius: 30,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: Image.asset(
                              'assets/images/logo.png',
                              width: size.width * 0.35,
                              height: size.width * 0.35,
                            ),
                          ),
                          SizedBox(height: isSmallScreen ? 32 : 48),
                          Text(
                            "ZUBAIR TAILORS",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: isSmallScreen ? 24 : 32,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 4,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "The Art of Perfect Fit",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: isSmallScreen ? 14 : 18,
                              letterSpacing: 2,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(),
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (context, animation, secondaryAnimation) => const DashboardScreen(),
                              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                return FadeTransition(opacity: animation, child: child);
                              },
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          foregroundColor: AppColors.textDark,
                          padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 16 : 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 10,
                          shadowColor: const Color(0xFFD4AF37).withOpacity(0.5),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "GET STARTED",
                              style: TextStyle(
                                fontSize: isSmallScreen ? 16 : 18,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Icon(Icons.arrow_forward_rounded),
                          ],
                        ),
                      ),
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
}
