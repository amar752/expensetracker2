import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../providers/category_provider.dart';
import '../providers/expense_provider.dart';
import '../providers/balance_provider.dart';
import '../providers/user_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _shimmerController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _shimmerAnimation;
  late DateTime _startTime;

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();

    // Fade animation
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );

    // Scale animation with bounce
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    );

    // Shimmer animation for loading effect
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    _shimmerAnimation = CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.easeInOut,
    );

    // Start animations
    _fadeController.forward();
    _scaleController.forward();

    _loadDataAndNavigate();
  }

  Future<void> _loadDataAndNavigate() async {
    try {
      // Load user provider first to check if user exists
      await context.read<UserProvider>().load().catchError((e) {
        debugPrint('Error loading users: $e');
      });

      final userProvider = context.read<UserProvider>();
      final hasUser = userProvider.hasUser;

      // Only load other data if user exists
      if (hasUser) {
        await Future.wait([
          context.read<CategoryProvider>().load().catchError((e) {
            debugPrint('Error loading categories: $e');
          }),
          context.read<ExpenseProvider>().load().catchError((e) {
            debugPrint('Error loading expenses: $e');
          }),
          context.read<BalanceProvider>().load().catchError((e) {
            debugPrint('Error loading balance: $e');
          }),
        ]).timeout(
          const Duration(seconds: 5),
          onTimeout: () {
            debugPrint('Data loading timed out');
            return <void>[];
          },
        );
      }
    } catch (e) {
      debugPrint('Error during initialization: $e');
    }

    final elapsed = DateTime.now().difference(_startTime);
    final minDuration = const Duration(seconds: 2);
    if (elapsed < minDuration) {
      await Future.delayed(minDuration - elapsed);
    }

    if (mounted) {
      final userProvider = context.read<UserProvider>();
      if (userProvider.hasUser) {
        Navigator.pushReplacementNamed(context, '/main');
      } else {
        Navigator.pushReplacementNamed(context, '/user_setup');
      }
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF1a1d3a),
              const Color(0xFF0f1123),
              const Color(0xFF1e2139),
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Animated background circles
            Positioned(
              top: -100,
              right: -100,
              child: AnimatedBuilder(
                animation: _shimmerAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: 1.0 + (_shimmerAnimation.value * 0.1),
                    child: Container(
                      width: 300,
                      height: 300,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            const Color(0xFF6C5CE7).withOpacity(0.15),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Positioned(
              bottom: -150,
              left: -150,
              child: AnimatedBuilder(
                animation: _shimmerAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: 1.0 + ((1 - _shimmerAnimation.value) * 0.1),
                    child: Container(
                      width: 400,
                      height: 400,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            const Color(0xFF00D4FF).withOpacity(0.1),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            // Main content
            Center(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Animated Lottie with scale
                    ScaleTransition(
                      scale: _scaleAnimation,
                      child: Container(
                        width: 280,
                        height: 280,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF6C5CE7).withOpacity(0.3),
                              blurRadius: 40,
                              spreadRadius: 10,
                            ),
                          ],
                        ),
                        child: Lottie.asset(
                          'assets/lottie/Wallet Essentials_ Money & Savings.json',
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.account_balance_wallet,
                              size: 120,
                              color: Color(0xFF6C5CE7),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Animated title with gradient
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [Color(0xFF6C5CE7), Color(0xFF00D4FF)],
                      ).createShader(bounds),
                      child: const Text(
                        'Expense Tracker',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Subtitle with shimmer effect
                    AnimatedBuilder(
                      animation: _shimmerAnimation,
                      builder: (context, child) {
                        return Opacity(
                          opacity: 0.6 + (_shimmerAnimation.value * 0.4),
                          child: Text(
                            'Manage your finances smartly',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white.withOpacity(0.9),
                              fontWeight: FontWeight.w300,
                              letterSpacing: 0.5,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 48),
                    // Animated loading indicator
                    AnimatedBuilder(
                      animation: _shimmerAnimation,
                      builder: (context, child) {
                        return Container(
                          width: 200,
                          height: 4,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(2),
                            color: Colors.white.withOpacity(0.1),
                          ),
                          child: Stack(
                            children: [
                              Container(
                                width: 200 * _shimmerAnimation.value,
                                height: 4,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(2),
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF6C5CE7),
                                      Color(0xFF00D4FF),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
