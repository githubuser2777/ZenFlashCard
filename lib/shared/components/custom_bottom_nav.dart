import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../theme/app_colors.dart';

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CustomBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.bgSurface : AppColors.lightBgSurface,
        border: Border(
          top: BorderSide(
            color: isDark
                ? AppColors.divider.withValues(alpha: 0.4)
                : AppColors.divider.withValues(alpha: 0.15),
            width: 1,
          ),
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        elevation: 0,
        backgroundColor: Colors.transparent,
        selectedItemColor: AppColors.primaryLight,
        unselectedItemColor: AppColors.textSecondary,
        onTap: onTap,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.library),
            activeIcon: Icon(LucideIcons.bookMarked),
            label: 'Decks',
          ),
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.barChart2),
            activeIcon: Icon(LucideIcons.barChart3),
            label: 'Stats',
          ),
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.settings),
            activeIcon: Icon(LucideIcons.settings2),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
