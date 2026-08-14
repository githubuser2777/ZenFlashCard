import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

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
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(LucideIcons.home),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: Icon(LucideIcons.barChart2),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: Icon(LucideIcons.settings),
          label: '',
        ),
      ],
    );
  }
}
