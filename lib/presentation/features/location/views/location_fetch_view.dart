import 'package:flutter/material.dart';
import '../../../../core/utils/location_service.dart';
import '../../../../data/data_sources/local/hive_service.dart';
import '../../../../core/theme/app_themes.dart';
import '../../home/views/home_view.dart';

class LocationFetchView extends StatefulWidget {
  final Function(AppTheme) onThemeChanged;
  
  const LocationFetchView({super.key, required this.onThemeChanged});

  @override
  State<LocationFetchView> createState() => _LocationFetchViewState();
}

class _LocationFetchViewState extends State<LocationFetchView>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;
  late Animation<double> _fadeAnimation;
  
  bool _isLoading = true;
  String _statusMessage = 'Detecting your location...';

  @override
  void initState() {
    super.initState();
    _initializeAnimation();
    _fetchLocation();
  }

  void _initializeAnimation() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _controller.repeat(reverse: true);
  }

  Future<void> _fetchLocation() async {
    // Simulate delay for better UX
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _statusMessage = 'Getting your coordinates...';
    });

    // Get location
    final position = await LocationService.getCurrentLocation();

    if (position != null) {
      setState(() {
        _statusMessage = 'Fetching address...';
      });

      // Get address from coordinates
      final address = await LocationService.getAddressFromCoordinates(
        position.latitude,
        position.longitude,
      );

      // Save to Hive
      await HiveService.saveLocation(
        latitude: position.latitude,
        longitude: position.longitude,
        address: address,
      );

      setState(() {
        _statusMessage = 'Location saved successfully!';
        _isLoading = false;
      });

      // Navigate to home
      await Future.delayed(const Duration(seconds: 1));
      
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeView(
              onThemeChanged: widget.onThemeChanged,
            ),
          ),
        );
      }
    } else {
      setState(() {
        _statusMessage = 'Unable to detect location';
        _isLoading = false;
      });

      // Show error dialog
      if (mounted) {
        _showLocationErrorDialog();
      }
    }
  }

  void _showLocationErrorDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Location Permission Required'),
        content: const Text(
          'We need your location to show nearby stores and best deals. Please enable location permission in settings.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _fetchLocation();
            },
            child: const Text('Retry'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => HomeView(
                    onThemeChanged: widget.onThemeChanged,
                  ),
                ),
              );
            },
            child: const Text('Skip'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated location icon
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Transform.scale(
                  scale: _pulseAnimation.value,
                  child: Opacity(
                    opacity: _fadeAnimation.value,
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        color: theme.primaryColor.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.location_on,
                        size: 80,
                        color: theme.primaryColor,
                      ),
                    ),
                  ),
                );
              },
            ),
            
            const SizedBox(height: 40),
            
            // Status message
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                _statusMessage,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.tertiary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Loading indicator
            if (_isLoading)
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
              ),
            
            const SizedBox(height: 40),
            
            // Info text
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'This helps us show you the best deals from nearby stores',
                style: TextStyle(
                  fontSize: 14,
                  color: theme.colorScheme.tertiary.withOpacity(0.6),
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
