import 'package:flutter/material.dart';
import '../custom_themes/app_theme.dart';

import 'home_screen.dart';
import 'explore_screen.dart';
import 'favorite_screen.dart';
import 'ticket_screen.dart';
import 'profile_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    ExploreScreen(),
    FavoriteScreen(),
    TicketScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWeb = screenWidth > 600;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,

      // ✅ BODY
      body: Row(
        children: [
          if (isWeb) _webSidebar(),
          Expanded(
            child: IndexedStack(
              index: _currentIndex,
              children: _screens,
            ),
          ),
        ],
      ),

      // ✅ BOTTOM NAV (MOBILE)
      bottomNavigationBar: isWeb ? null : _bottomNav(),
    );
  }

  // -------------------- MOBILE BOTTOM NAV --------------------
  Widget _bottomNav() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, -2)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _navIcon(Icons.home, "Home", 0),
          _navIcon(Icons.explore, "Explore", 1),
          _navIcon(Icons.favorite_border, "Favorite", 2),
          _navIcon(Icons.confirmation_num_outlined, "Ticket", 3),
          _navIcon(Icons.person_outline, "Profile", 4),
        ],
      ),
    );
  }

  Widget _navIcon(IconData icon, String label, int index) {
    final active = _currentIndex == index;

    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: active ? Colors.deepOrange : AppTheme.textSecondary),
          Text(
            label,
            style: TextStyle(
              color: active ? Colors.deepOrange : AppTheme.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // -------------------- WEB SIDEBAR --------------------
  Widget _webSidebar() {
    return Container(
      width: 250,
      color: AppTheme.backgroundColor,
      child: Column(
        children: [
          const SizedBox(height: 20),
          _navIconVertical(Icons.home, "Home", 0),
          _navIconVertical(Icons.explore, "Explore", 1),
          _navIconVertical(Icons.favorite_border, "Favorite", 2),
          _navIconVertical(Icons.confirmation_num_outlined, "Ticket", 3),
          _navIconVertical(Icons.person_outline, "Profile", 4),
        ],
      ),
    );
  }

  Widget _navIconVertical(IconData icon, String label, int index) {
    final active = _currentIndex == index;

    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: active ? Colors.deepOrange.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: active ? Colors.deepOrange : AppTheme.textSecondary),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                color: active ? Colors.deepOrange : AppTheme.textSecondary,
                fontSize: 14,
                fontWeight: active ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
