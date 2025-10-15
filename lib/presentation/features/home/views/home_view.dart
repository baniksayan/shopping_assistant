import 'package:flutter/material.dart';

/// Home screen - placeholder for Task 2
class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping Assistant'),
      ),
      body: const Center(
        child: Text('Home Screen - Coming Soon'),
      ),
    );
  }
}
