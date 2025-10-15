import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'data/data_sources/local/hive_service.dart';
import 'core/theme/app_themes.dart';
import 'presentation/features/splash/views/splash_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  await HiveService.init();
  await HiveService.openBoxes();
  
  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ),
  );
  
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late AppTheme _currentTheme;

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  void _loadTheme() {
    // Load saved theme from Hive
    final savedTheme = HiveService.getSelectedTheme();
    _currentTheme = _getThemeFromString(savedTheme);
  }

  AppTheme _getThemeFromString(String themeName) {
    switch (themeName) {
      case 'India':
        return AppTheme.india;
      case 'Bangladesh':
        return AppTheme.bangladesh;
      case 'Nepal':
        return AppTheme.nepal;
      case 'Bhutan':
        return AppTheme.bhutan;
      case 'Singapore':
        return AppTheme.singapore;
      case 'Sri Lanka':
        return AppTheme.sriLanka;
      default:
        return AppTheme.india;
    }
  }

  void _changeTheme(AppTheme newTheme) {
    setState(() {
      _currentTheme = newTheme;
    });
    // Save to Hive
    HiveService.saveSelectedTheme(AppThemes.getThemeName(newTheme));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shopping Assistant',
      debugShowCheckedModeBanner: false,
      theme: AppThemes.themes[_currentTheme],
      home: SplashView(onThemeChanged: _changeTheme),
    );
  }
}
