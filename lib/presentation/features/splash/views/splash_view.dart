import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../../data/data_sources/local/hive_service.dart';
import '../../../../core/theme/app_themes.dart';
import '../../auth/views/login_view.dart';
import '../../home/views/home_view.dart';

class SplashView extends StatefulWidget {
  final Function(AppTheme) onThemeChanged;
  
  const SplashView({super.key, required this.onThemeChanged});

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
  
  late List<Animation<double>> _itemAnimations;
  late List<Animation<double>> _itemRotations;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimationSequence();
  }

  void _initializeAnimations() {
    _bagController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _itemsController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _textController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _bagScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _bagController, curve: Curves.elasticOut),
    );

    _bagSlide = Tween<double>(begin: 100.0, end: 0.0).animate(
      CurvedAnimation(parent: _bagController, curve: Curves.easeOutCubic),
    );

    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeIn),
    );

    _textSlide = Tween<double>(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOutCubic),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _shimmerAnimation = Tween<double>(begin: -2.0, end: 2.0).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.linear),
    );

    _itemAnimations = List.generate(
      3,
      (index) => Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _itemsController,
          curve: Interval(
            index * 0.2,
            0.6 + (index * 0.2),
            curve: Curves.easeOutCubic,
          ),
        ),
      ),
    );

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
    await Future.delayed(const Duration(milliseconds: 300));
    _bagController.forward();

    await Future.delayed(const Duration(milliseconds: 800));
    _itemsController.forward();

    await Future.delayed(const Duration(milliseconds: 1200));
    _textController.forward();

    await Future.delayed(const Duration(milliseconds: 1500));
    _pulseController.repeat(reverse: true);
    _shimmerController.repeat();

    await Future.delayed(const Duration(milliseconds: 3500));
    
    if (mounted) {
      _navigateToNextScreen();
    }
  }

  void _navigateToNextScreen() {
    // Check if user is logged in
    final isLoggedIn = HiveService.isUserLoggedIn();
    
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => isLoggedIn 
          ? HomeView(onThemeChanged: widget.onThemeChanged)
          : LoginView(onThemeChanged: widget.onThemeChanged),
      ),
    );
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
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          _buildBackgroundCircles(size, theme),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 350,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      ..._buildProductItems(size, theme),
                      _buildShoppingBag(theme),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                _buildAppTitle(theme),
                const SizedBox(height: 12),
                _buildTagline(theme),
                const SizedBox(height: 60),
                _buildLoadingIndicator(theme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundCircles(Size size, ThemeData theme) {
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
                  color: theme.primaryColor.withOpacity(0.1),
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
                  color: theme.colorScheme.secondary.withOpacity(0.1),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  List<Widget> _buildProductItems(Size size, ThemeData theme) {
    final positions = [
      const Offset(-120, -150),
      const Offset(120, -140),
      const Offset(0, -180),
    ];

    final icons = [
      Icons.shopping_basket,
      Icons.local_grocery_store,
      Icons.shopping_bag,
    ];

    final colors = [
      theme.colorScheme.tertiary,
      theme.primaryColor,
      theme.colorScheme.secondary,
    ];

    return List.generate(3, (index) {
      return AnimatedBuilder(
        animation: _itemsController,
        builder: (context, child) {
          final progress = _itemAnimations[index].value;
          final rotation = _itemRotations[index].value;

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
                  scale: 1.0 - (progress * 0.5),
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
                    child: Icon(icons[index], color: Colors.white, size: 28),
                  ),
                ),
              ),
            ),
          );
        },
      );
    });
  }

  Widget _buildShoppingBag(ThemeData theme) {
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
                color: theme.primaryColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: theme.primaryColor.withOpacity(0.4),
                    blurRadius: 30,
                    spreadRadius: 10,
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Icon(
                    Icons.shopping_bag_outlined,
                    size: 80,
                    color: Colors.white,
                  ),
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

  Widget _buildAppTitle(ThemeData theme) {
    return AnimatedBuilder(
      animation: _textController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _textSlide.value),
          child: Opacity(
            opacity: _textOpacity.value,
            child: Text(
              'Shopping Assistant',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: theme.primaryColor,
                letterSpacing: 1.2,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTagline(ThemeData theme) {
    return AnimatedBuilder(
      animation: _textController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _textSlide.value),
          child: Opacity(
            opacity: _textOpacity.value * 0.8,
            child: Text(
              'Find the best deals around you',
              style: TextStyle(
                fontSize: 16,
                color: theme.colorScheme.tertiary,
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingIndicator(ThemeData theme) {
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
                theme.primaryColor.withOpacity(0.7),
              ),
            ),
          ),
        );
      },
    );
  }
}
