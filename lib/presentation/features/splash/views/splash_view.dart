import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Animated Splash Screen for Shopping Assistant
/// Features multiple synchronized animations including:
/// - Shopping bag scale and pulse
/// - Product items flying into the bag
/// - Text fade and slide animations
/// - Smooth transition effects
class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView>
    with TickerProviderStateMixin {
  // Animation controllers
  late AnimationController _bagController;
  late AnimationController _itemsController;
  late AnimationController _textController;
  late AnimationController _pulseController;
  late AnimationController _shimmerController;

  // Animations
  late Animation<double> _bagScale;
  late Animation<double> _bagSlide;
  late Animation<double> _textOpacity;
  late Animation<double> _textSlide;
  late Animation<double> _pulseAnimation;
  late Animation<double> _shimmerAnimation;
  
  // Product animations (3 items)
  late List<Animation<double>> _itemAnimations;
  late List<Animation<double>> _itemRotations;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimationSequence();
  }

  void _initializeAnimations() {
    // Bag animation controller (1.2 seconds)
    _bagController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    // Items animation controller (1.5 seconds)
    _itemsController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Text animation controller (1 second)
    _textController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    // Pulse animation (continuous)
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Shimmer animation (continuous)
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Bag scale animation (bounce effect)
    _bagScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _bagController,
        curve: Curves.elasticOut,
      ),
    );

    // Bag slide animation (from bottom)
    _bagSlide = Tween<double>(begin: 100.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _bagController,
        curve: Curves.easeOutCubic,
      ),
    );

    // Text animations
    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: Curves.easeIn,
      ),
    );

    _textSlide = Tween<double>(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: Curves.easeOutCubic,
      ),
    );

    // Pulse animation (scale effect)
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );

    // Shimmer animation
    _shimmerAnimation = Tween<double>(begin: -2.0, end: 2.0).animate(
      CurvedAnimation(
        parent: _shimmerController,
        curve: Curves.linear,
      ),
    );

    // Product item animations (3 items with staggered timing)
    _itemAnimations = List.generate(
      3,
      (index) => Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _itemsController,
          curve: Interval(
            index * 0.2, // Staggered start
            0.6 + (index * 0.2), // Staggered end
            curve: Curves.easeOutCubic,
          ),
        ),
      ),
    );

    // Item rotation animations
    _itemRotations = List.generate(
      3,
      (index) => Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _itemsController,
          curve: Interval(
            index * 0.2,
            0.6 + (index * 0.2),
            curve: Curves.easeOut,
          ),
        ),
      ),
    );
  }

  void _startAnimationSequence() async {
    // Start bag animation
    await Future.delayed(const Duration(milliseconds: 300));
    _bagController.forward();

    // Start items animation
    await Future.delayed(const Duration(milliseconds: 800));
    _itemsController.forward();

    // Start text animation
    await Future.delayed(const Duration(milliseconds: 1200));
    _textController.forward();

    // Start continuous pulse
    await Future.delayed(const Duration(milliseconds: 1500));
    _pulseController.repeat(reverse: true);

    // Start shimmer effect
    _shimmerController.repeat();

    // Navigate to home after all animations
    await Future.delayed(const Duration(milliseconds: 3500));
    if (mounted) {
      // TODO: Navigate to home screen
      // Navigator.pushReplacement(
      //   context,
      //   MaterialPageRoute(builder: (context) => const HomeView()),
      // );
    }
  }

  @override
  void dispose() {
    _bagController.dispose();
    _itemsController.dispose();
    _textController.dispose();
    _pulseController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFF4E9D7), // India theme background
      body: Stack(
        children: [
          // Animated background circles
          _buildBackgroundCircles(size),

          // Main content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Shopping animation container
                SizedBox(
                  height: 350,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Product items
                      ..._buildProductItems(size),

                      // Shopping bag
                      _buildShoppingBag(),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // App title with animation
                _buildAppTitle(),

                const SizedBox(height: 12),

                // Tagline with animation
                _buildTagline(),

                const SizedBox(height: 60),

                // Loading indicator
                _buildLoadingIndicator(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundCircles(Size size) {
    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, child) {
        return Stack(
          children: [
            Positioned(
              top: -100 + (_shimmerAnimation.value * 20),
              right: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFD97D55).withOpacity(0.1),
                ),
              ),
            ),
            Positioned(
              bottom: -150 + (_shimmerAnimation.value * -15),
              left: -100,
              child: Container(
                width: 350,
                height: 350,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFB8C4A9).withOpacity(0.1),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  List<Widget> _buildProductItems(Size size) {
    // Product positions (x, y) relative to bag center
    final positions = [
      const Offset(-120, -150), // Top left
      const Offset(120, -140),  // Top right
      const Offset(0, -180),    // Top center
    ];

    // Product icons
    final icons = [
      Icons.shopping_basket,
      Icons.local_grocery_store,
      Icons.shopping_bag,
    ];

    final colors = [
      const Color(0xFF6FA4AF),
      const Color(0xFFD97D55),
      const Color(0xFFB8C4A9),
    ];

    return List.generate(3, (index) {
      return AnimatedBuilder(
        animation: _itemsController,
        builder: (context, child) {
          final progress = _itemAnimations[index].value;
          final rotation = _itemRotations[index].value;

          // Calculate current position (move from start position to bag)
          final currentX = positions[index].dx * (1 - progress);
          final currentY = positions[index].dy * (1 - progress);

          return Positioned(
            left: size.width / 2 + currentX - 25,
            top: 175 + currentY - 25,
            child: Opacity(
              opacity: progress,
              child: Transform.rotate(
                angle: rotation * math.pi * 2,
                child: Transform.scale(
                  scale: 1.0 - (progress * 0.5), // Shrink as it moves
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: colors[index].withOpacity(0.9),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: colors[index].withOpacity(0.3),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Icon(
                      icons[index],
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      );
    });
  }

  Widget _buildShoppingBag() {
    return AnimatedBuilder(
      animation: Listenable.merge([_bagController, _pulseController]),
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _bagSlide.value),
          child: Transform.scale(
            scale: _bagScale.value * _pulseAnimation.value,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                color: const Color(0xFFD97D55),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFD97D55).withOpacity(0.4),
                    blurRadius: 30,
                    spreadRadius: 10,
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Bag icon
                  const Icon(
                    Icons.shopping_bag_outlined,
                    size: 80,
                    color: Colors.white,
                  ),
                  // Sparkle effect
                  AnimatedBuilder(
                    animation: _shimmerController,
                    builder: (context, child) {
                      return Positioned(
                        left: 20 + (_shimmerAnimation.value * 60),
                        child: Container(
                          width: 3,
                          height: 140,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.white.withOpacity(0.0),
                                Colors.white.withOpacity(0.6),
                                Colors.white.withOpacity(0.0),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAppTitle() {
    return AnimatedBuilder(
      animation: _textController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _textSlide.value),
          child: Opacity(
            opacity: _textOpacity.value,
            child: const Text(
              'Shopping Assistant',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFFD97D55),
                letterSpacing: 1.2,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTagline() {
    return AnimatedBuilder(
      animation: _textController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _textSlide.value),
          child: Opacity(
            opacity: _textOpacity.value * 0.8,
            child: const Text(
              'Find the best deals around you',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF6FA4AF),
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingIndicator() {
    return AnimatedBuilder(
      animation: _textController,
      builder: (context, child) {
        return Opacity(
          opacity: _textOpacity.value,
          child: SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(
                const Color(0xFFD97D55).withOpacity(0.7),
              ),
            ),
          ),
        );
      },
    );
  }
}
