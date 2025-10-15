import 'package:flutter/material.dart';
import 'dart:io';
import 'package:animated_text_kit/animated_text_kit.dart';
import '../../../../data/data_sources/local/hive_service.dart';
import '../../../../data/models/user_model.dart';
import '../../../../core/theme/app_themes.dart';
import '../../../../core/utils/location_service.dart';
import '../widgets/app_drawer.dart';
import '../../profile/views/profile_view.dart';
import '../../search/views/search_view.dart';

class HomeView extends StatefulWidget {
  final Function(AppTheme) onThemeChanged;
  
  const HomeView({super.key, required this.onThemeChanged});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();
  
  UserModel? _user;
  bool _isLoadingLocation = false;
  
  late AnimationController _locationAnimController;
  late Animation<double> _locationPulse;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _initLocationAnimation();
    _autoDetectLocation();
  }

  void _initLocationAnimation() {
    _locationAnimController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _locationPulse = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(
        parent: _locationAnimController,
        curve: Curves.easeInOut,
      ),
    );
  }

  void _loadUserData() {
    setState(() {
      _user = HiveService.getCurrentUser();
    });
  }

  Future<void> _autoDetectLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });
    
    _locationAnimController.repeat(reverse: true);

    final position = await LocationService.getCurrentLocation();

    if (position != null) {
      final address = await LocationService.getAddressFromCoordinates(
        position.latitude,
        position.longitude,
      );

      await HiveService.saveLocation(
        latitude: position.latitude,
        longitude: position.longitude,
        address: address,
      );

      _loadUserData();
    }

    setState(() {
      _isLoadingLocation = false;
    });
    
    _locationAnimController.stop();
    _locationAnimController.reset();
  }

  void _openSearch({bool withVoice = false}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchView(openWithVoice: withVoice),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _locationAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: theme.scaffoldBackgroundColor,
      drawer: AppDrawer(
        user: _user,
        onThemeChanged: widget.onThemeChanged,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Custom App Bar
            _buildCustomAppBar(theme),
            
            // Main Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Animated Logo Section
                    _buildAnimatedLogoSection(theme),
                    
                    const SizedBox(height: 30),
                    
                    // Search Bar
                    _buildSearchBar(theme),
                    
                    const SizedBox(height: 30),
                    
                    // Quick Actions
                    _buildQuickActions(theme),
                    
                    const SizedBox(height: 30),
                    
                    // Features Section
                    _buildFeaturesSection(theme),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomAppBar(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Hamburger Menu
          IconButton(
            icon: Icon(Icons.menu, color: theme.primaryColor),
            onPressed: () {
              _scaffoldKey.currentState?.openDrawer();
            },
          ),
          
          const SizedBox(width: 8),
          
          // Location Display
          Expanded(
            child: GestureDetector(
              onTap: _autoDetectLocation,
              child: Row(
                children: [
                  if (_isLoadingLocation)
                    AnimatedBuilder(
                      animation: _locationAnimController,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _locationPulse.value,
                          child: Icon(
                            Icons.location_on,
                            color: theme.primaryColor,
                            size: 20,
                          ),
                        );
                      },
                    )
                  else
                    Icon(
                      Icons.location_on,
                      color: theme.primaryColor,
                      size: 20,
                    ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Current Location',
                          style: TextStyle(
                            fontSize: 10,
                            color: theme.colorScheme.tertiary.withOpacity(0.6),
                          ),
                        ),
                        Text(
                          _isLoadingLocation
                              ? 'Detecting...'
                              : _user?.shortLocation ?? 'Unknown',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.tertiary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(width: 8),
          
          // Profile Picture/Icon
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfileView(
                    onThemeChanged: widget.onThemeChanged,
                    onProfileUpdated: _loadUserData,
                  ),
                ),
              );
            },
            child: _buildProfileAvatar(theme),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileAvatar(ThemeData theme) {
    if (_user?.profileImagePath != null && _user!.profileImagePath!.isNotEmpty) {
      return Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: theme.primaryColor, width: 2),
          image: DecorationImage(
            image: FileImage(File(_user!.profileImagePath!)),
            fit: BoxFit.cover,
          ),
        ),
      );
    } else {
      return Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: theme.primaryColor,
          border: Border.all(color: theme.primaryColor, width: 2),
        ),
        child: Center(
          child: Text(
            _user?.initials ?? 'U',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      );
    }
  }

  Widget _buildAnimatedLogoSection(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.primaryColor.withOpacity(0.1),
            theme.colorScheme.secondary.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          // App Logo with pulse animation
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 800),
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: theme.primaryColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: theme.primaryColor.withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.shopping_bag_outlined,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
              );
            },
          ),
          
          const SizedBox(height: 20),
          
          // Greeting
          Text(
            'Hi, ${_user?.firstName ?? "User"}!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: theme.primaryColor,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Animated Text
          SizedBox(
            height: 60,
            child: AnimatedTextKit(
              animatedTexts: [
                TypewriterAnimatedText(
                  'Search for products...',
                  textStyle: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.tertiary,
                  ),
                  speed: const Duration(milliseconds: 100),
                ),
                TypewriterAnimatedText(
                  'Find best deals...',
                  textStyle: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.tertiary,
                  ),
                  speed: const Duration(milliseconds: 100),
                ),
                TypewriterAnimatedText(
                  'Compare prices...',
                  textStyle: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.tertiary,
                  ),
                  speed: const Duration(milliseconds: 100),
                ),
                TypewriterAnimatedText(
                  'Save money!',
                  textStyle: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.tertiary,
                  ),
                  speed: const Duration(milliseconds: 100),
                ),
              ],
              repeatForever: true,
              pause: const Duration(milliseconds: 1000),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(ThemeData theme) {
    return GestureDetector(
      onTap: () => _openSearch(),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: AbsorbPointer(
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search products, stores, deals...',
              hintStyle: TextStyle(
                color: theme.colorScheme.tertiary.withOpacity(0.5),
              ),
              prefixIcon: Icon(Icons.search, color: theme.primaryColor),
              suffixIcon: IconButton(
                icon: Icon(Icons.mic, color: theme.primaryColor),
                onPressed: () => _openSearch(withVoice: true),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.tertiary,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildQuickActionCard(
              icon: Icons.store,
              label: 'Nearby\nStores',
              color: theme.primaryColor,
              onTap: () {},
            ),
            _buildQuickActionCard(
              icon: Icons.local_offer,
              label: 'Best\nDeals',
              color: theme.colorScheme.secondary,
              onTap: () {},
            ),
            _buildQuickActionCard(
              icon: Icons.compare_arrows,
              label: 'Compare\nPrices',
              color: theme.colorScheme.tertiary,
              onTap: () {},
            ),
            _buildQuickActionCard(
              icon: Icons.category,
              label: 'All\nCategories',
              color: const Color(0xFFFF6B6B),
              onTap: () {},
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 75,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: color,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturesSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Explore Features',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.tertiary,
          ),
        ),
        const SizedBox(height: 16),
        _buildFeatureCard(
          icon: Icons.store_outlined,
          title: 'Discover Nearby Stores',
          description: 'Find stores around your current location with real-time updates',
          theme: theme,
        ),
        const SizedBox(height: 12),
        _buildFeatureCard(
          icon: Icons.price_check_outlined,
          title: 'Smart Price Comparison',
          description: 'Compare prices across multiple stores and save money',
          theme: theme,
        ),
        const SizedBox(height: 12),
        _buildFeatureCard(
          icon: Icons.notifications_active_outlined,
          title: 'Deal Alerts',
          description: 'Get notified about exclusive deals and discounts',
          theme: theme,
        ),
      ],
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
    required ThemeData theme,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 55,
            height: 55,
            decoration: BoxDecoration(
              color: theme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: theme.primaryColor, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.tertiary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    color: theme.colorScheme.tertiary.withOpacity(0.6),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
