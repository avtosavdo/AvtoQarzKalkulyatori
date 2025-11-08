import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loancalculator/screens/loan_calculator_page.dart';
import 'dart:async';
import 'package:lottie/lottie.dart';
// import 'package:flutter_svg/flutter_svg.dart'; // Agar SVG ishlatmoqchi bo'lsangiz

/// Professional Splash Screen with animation
///
/// Features:
/// - Lottie animation support
/// - SVG support
/// - Gradient background
/// - Auto navigation
/// - Smooth transitions
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _navigateToHome();
    _setSystemUIOverlay();
  }

  /// Animation'larni sozlash
  void _initializeAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.8, curve: Curves.elasticOut),
      ),
    );

    _animationController.forward();
  }

  /// System UI o'rnatish (full screen effect)
  void _setSystemUIOverlay() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );
  }

  /// Asosiy ekranga o'tish (3 soniyadan keyin)
  void _navigateToHome() {
    Timer(const Duration(seconds: 3), () {
      // System UI ni qayta tiklash
      SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.manual,
        overlays: SystemUiOverlay.values,
      );

      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const LoanCalculatorPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeInOut;

            var tween = Tween(begin: begin, end: end).chain(
              CurveTween(curve: curve),
            );

            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 800),
        ),
      );
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: size.width,
        height: size.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF1976D2), // Primary blue
              const Color(0xFF1565C0), // Darker blue
              const Color(0xFF0D47A1), // Deep blue
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),

              // Logo Animation
              FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: _buildLogo(size),
                ),
              ),

              const Spacer(flex: 1),

              // App Name
              FadeTransition(
                opacity: _fadeAnimation,
                child: _buildAppName(),
              ),

              const SizedBox(height: 8),

              // Tagline
              FadeTransition(
                opacity: _fadeAnimation,
                child: _buildTagline(),
              ),

              const Spacer(flex: 2),

              // Loading Indicator
              FadeTransition(
                opacity: _fadeAnimation,
                child: _buildLoadingIndicator(),
              ),

              const SizedBox(height: 24),

              // Company Name
              FadeTransition(
                opacity: _fadeAnimation,
                child: _buildCompanyName(),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  /// Logo widget
  Widget _buildLogo(Size size) {
    // VARIANT 1: Lottie Animation (agar splash_logo.json bo'lsa)
    return Container(
      width: size.width * 0.5,
      height: size.width * 0.5,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Lottie.asset(
        'assets/splash/splash_logo.json',
        fit: BoxFit.contain,
        repeat: true,
        // Agar animation o'ynamaslik kerak bo'lsa:
        // repeat: false,
        // animate: false,
      ),
    );

    // VARIANT 2: SVG Image (agar splash_logo.svg bo'lsa)
    // Uncomment this and comment Lottie variant if using SVG
    /*
    return Container(
      width: size.width * 0.5,
      height: size.width * 0.5,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: SvgPicture.asset(
        'assets/splash/splash_logo.svg',
        fit: BoxFit.contain,
        colorFilter: const ColorFilter.mode(
          Colors.white,
          BlendMode.srcIn,
        ),
      ),
    );
    */

    // VARIANT 3: Icon (agar faqat icon bo'lsa)
    /*
    return Container(
      width: size.width * 0.4,
      height: size.width * 0.4,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: const Icon(
        Icons.directions_car,
        size: 100,
        color: Color(0xFF1976D2),
      ),
    );
    */
  }

  /// App Name
  Widget _buildAppName() {
    return const Text(
      'Avto Qarz Kalkulyatori',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        letterSpacing: 1.2,
        shadows: [
          Shadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
    );
  }

  /// Tagline
  Widget _buildTagline() {
    return Text(
      'Kredit to\'lovlarini oson hisoblang',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: Colors.white.withOpacity(0.9),
        letterSpacing: 0.5,
      ),
    );
  }

  /// Loading Indicator
  Widget _buildLoadingIndicator() {
    return SizedBox(
      width: 40,
      height: 40,
      child: CircularProgressIndicator(
        strokeWidth: 3,
        valueColor: AlwaysStoppedAnimation<Color>(
          Colors.white.withOpacity(0.8),
        ),
      ),
    );
  }

  /// Company Name
  Widget _buildCompanyName() {
    return Column(
      children: [
        Text(
          'AUTOGRAPH AUTOMOTIVE GROUP',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.white.withOpacity(0.7),
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'v1.0.0',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w400,
            color: Colors.white.withOpacity(0.5),
          ),
        ),
      ],
    );
  }
}
