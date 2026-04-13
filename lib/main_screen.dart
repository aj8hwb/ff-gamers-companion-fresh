import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'utils/constants.dart';
import 'screens/optimize_tab.dart';
import 'screens/tools_tab.dart';
import 'screens/config_tab.dart';
import 'screens/extras_tab.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    OptimizeTab(),
    ToolsTab(),
    ConfigTab(),
    ExtrasTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Ionicons.flash, color: AppColors.electricBlue, size: 24),
            const SizedBox(width: 8),
            const Text('FF COMPANION'),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Ionicons.settings), onPressed: () {}),
        ],
      ),
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.darkGray,
          boxShadow: [
            BoxShadow(
              color: AppColors.electricBlue.withValues(alpha: 0.2),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: AppColors.electricBlue,
          unselectedItemColor: AppColors.gray,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(fontSize: 12),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Ionicons.rocket_outline),
              activeIcon: Icon(Ionicons.rocket),
              label: 'Optimize',
            ),
            BottomNavigationBarItem(
              icon: Icon(Ionicons.game_controller_outline),
              activeIcon: Icon(Ionicons.game_controller),
              label: 'Tools',
            ),
            BottomNavigationBarItem(
              icon: Icon(Ionicons.settings_outline),
              activeIcon: Icon(Ionicons.settings),
              label: 'Config',
            ),
            BottomNavigationBarItem(
              icon: Icon(Ionicons.sparkles_outline),
              activeIcon: Icon(Ionicons.sparkles),
              label: 'Extras',
            ),
          ],
        ),
      ),
    );
  }
}
