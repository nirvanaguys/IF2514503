import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'navigation/main_navigation_screen.dart';

class DaunKuApp extends StatelessWidget {
  const DaunKuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DaunKu',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const MainNavigationScreen(),
    );
  }
}
