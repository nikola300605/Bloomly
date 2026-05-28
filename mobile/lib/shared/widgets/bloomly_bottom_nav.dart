import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/router/app_router.dart';

/// Persistent bottom navigation bar with Plants / [Scan FAB] / Community / Profile.
/// Wraps the shell child from go_router.
class BloomlyBottomNav extends StatelessWidget {
  final Widget child;

  const BloomlyBottomNav({super.key, required this.child});

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/community')) return 1;
    if (location.startsWith('/profile')) return 2;
    return 0; // home / plants
  }

  @override
  Widget build(BuildContext context) {
    final idx = _currentIndex(context);
    return Scaffold(
      body: child,
      bottomNavigationBar: _BottomBar(currentIndex: idx),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: _ScanFab(),
    );
  }
}

class _BottomBar extends StatelessWidget {
  final int currentIndex;
  const _BottomBar({required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      color: cs.surface,
      elevation: 4,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavItem(
            icon: Icons.eco_outlined,
            activeIcon: Icons.eco,
            label: 'Plants',
            active: currentIndex == 0,
            onTap: () => context.go(AppRoutes.home),
          ),
          const SizedBox(width: 64), // space for FAB
          _NavItem(
            icon: Icons.forum_outlined,
            activeIcon: Icons.forum,
            label: 'Community',
            active: currentIndex == 1,
            onTap: () => context.go(AppRoutes.community),
          ),
          _NavItem(
            icon: Icons.person_outline,
            activeIcon: Icons.person,
            label: 'You',
            active: currentIndex == 2,
            onTap: () => context.go(AppRoutes.profile),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.accent : AppColors.disabled;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(active ? activeIcon : icon, color: color, size: 22),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(fontSize: 11, color: color, fontFamily: 'Inter')),
          ],
        ),
      ),
    );
  }
}

class _ScanFab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => context.push(AppRoutes.scan),
      backgroundColor: AppColors.accent,
      foregroundColor: Colors.white,
      shape: const CircleBorder(),
      child: const Icon(Icons.camera_alt_outlined, size: 26),
    );
  }
}
