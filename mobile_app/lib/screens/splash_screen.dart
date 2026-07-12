import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_lock_provider.dart';
import '../providers/license_provider.dart';
import '../providers/shop_profile_provider.dart';
import '../utils/app_colors.dart';
import 'app_lock_screen.dart';
import 'dashboard_screen.dart';
import 'trial_lock_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _logoCtrl;
  late final AnimationController _textCtrl;
  late final AnimationController _progressCtrl;

  late final Animation<double> _logoScale;
  late final Animation<double> _logoFade;
  late final Animation<double> _textFade;
  late final Animation<Offset> _textSlide;
  late final Animation<double> _subtitleFade;

  @override
  void initState() {
    super.initState();

    _logoCtrl     = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _textCtrl     = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _progressCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1900));

    _logoScale = Tween<double>(begin: 0.3, end: 1.0)
        .animate(CurvedAnimation(parent: _logoCtrl, curve: Curves.elasticOut));
    _logoFade  = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _logoCtrl, curve: const Interval(0.0, 0.4, curve: Curves.easeIn)));
    _textFade  = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _textCtrl, curve: Curves.easeIn));
    _textSlide = Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero)
        .animate(CurvedAnimation(parent: _textCtrl, curve: Curves.easeOutCubic));
    _subtitleFade = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _textCtrl, curve: const Interval(0.5, 1.0, curve: Curves.easeIn)));

    _logoCtrl.forward().then((_) => _textCtrl.forward());
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _progressCtrl.forward();
    });

    Timer(const Duration(milliseconds: 2800), () {
      if (!mounted) return;
      final trialExpired = context.read<LicenseProvider>().isTrialExpired;
      final locked = context.read<AppLockProvider>().isEnabled;
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => trialExpired
              ? const TrialLockScreen()
              : (locked ? const AppLockScreen() : const DashboardScreen()),
          transitionsBuilder: (_, anim, __, child) =>
              FadeTransition(opacity: anim, child: child),
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    });
  }

  @override
  void dispose() {
    _logoCtrl.dispose();
    _textCtrl.dispose();
    _progressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final shopName = context.watch<ShopProfileProvider>().shopName.toUpperCase();
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.heroGradient),
        child: Stack(
          children: [
            // Decorative orbs
            Positioned(
              top: -100, right: -100,
              child: _orb(260, Colors.white.withOpacity(0.04)),
            ),
            Positioned(
              bottom: -120, left: -80,
              child: _orb(320, AppColors.accent.withOpacity(0.06)),
            ),
            Positioned(
              top: 120, left: -60,
              child: _orb(180, Colors.white.withOpacity(0.03)),
            ),

            SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 2),

                  // Logo orb
                  ScaleTransition(
                    scale: _logoScale,
                    child: FadeTransition(
                      opacity: _logoFade,
                      child: Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.08),
                          border: Border.all(
                              color: AppColors.accent.withOpacity(0.45), width: 1.5),
                          boxShadow: [
                            BoxShadow(
                                color: AppColors.accent.withOpacity(0.18),
                                blurRadius: 50,
                                spreadRadius: 12),
                          ],
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(4),
                          child: Image(
                            image: AssetImage('assets/images/icon.png'),
                            width: 64,
                            height: 64,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 52),

                  // Brand text
                  SlideTransition(
                    position: _textSlide,
                    child: FadeTransition(
                      opacity: _textFade,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            shopName,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 36,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 4,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  FadeTransition(
                    opacity: _subtitleFade,
                    child: Text(
                      'The Art of Perfect Fit',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.55),
                        fontSize: 14,
                        letterSpacing: 2.5,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),

                  const Spacer(flex: 2),

                  // Progress bar
                  FadeTransition(
                    opacity: _subtitleFade,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 80),
                      child: AnimatedBuilder(
                        animation: _progressCtrl,
                        builder: (_, __) => ClipRRect(
                          borderRadius: BorderRadius.circular(2),
                          child: LinearProgressIndicator(
                            value: _progressCtrl.value,
                            backgroundColor: Colors.white.withOpacity(0.12),
                            color: AppColors.accent,
                            minHeight: 2,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 52),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _orb(double size, Color color) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      );
}
