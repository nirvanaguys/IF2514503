import 'package:flutter/material.dart';

import '../features/diagnosis/diagnosis_screen.dart';
import '../features/home/screens/home_screen.dart';
import '../features/marketplace/screens/marketplace_screen.dart';
import '../features/profile/screens/profile_screen.dart';
import 'widgets/main_bottom_nav.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({
    super.key,
    this.initialIndex = 0,
  });

  final int initialIndex;

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _onTabSelected(int index) {
    if (_currentIndex != index) {
      setState(() => _currentIndex = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          HomeScreen(
            onStartDiagnosis: () => _onTabSelected(1),
            onOpenMarketplace: () => _onTabSelected(2),
            onOpenProfile: () => _onTabSelected(3),
          ),
          const DiagnosisScreen(),
          MarketplaceScreen(
            onNavigateToDiagnosis: () => _onTabSelected(1),
            onOpenProfile: () => _onTabSelected(3),
          ),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: MainBottomNav(
        currentIndex: _currentIndex,
        onTap: _onTabSelected,
      ),
    );
  }
}
