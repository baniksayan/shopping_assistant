import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'presentation/features/splash/views/splash_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  await Hive.initFlutter();
  
  // Open settings box
  await Hive.openBox('settings');
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shopping Assistant',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFD97D55)),
        useMaterial3: true,
      ),
      home: const SplashView(),
    );
  }
}
