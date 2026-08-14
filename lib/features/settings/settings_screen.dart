import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../settings/settings_viewmodel.dart';
import '../../shared/theme/app_colors.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Consumer<SettingsViewModel>(
        builder: (context, settingsVM, child) {
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text('Appearance', style: AppTypography.title.copyWith(color: AppColors.textSecondary)),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.bgSurface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2))],
                ),
                child: Column(
                  children: [
                    _buildThemeTile(
                      title: 'System',
                      icon: LucideIcons.monitor,
                      isSelected: settingsVM.themeMode == ThemeMode.system,
                      onTap: () {
                        HapticFeedback.lightImpact();
                        settingsVM.setThemeMode(ThemeMode.system);
                      },
                    ),
                    const Divider(height: 1, indent: 56),
                    _buildThemeTile(
                      title: 'Dark',
                      icon: LucideIcons.moon,
                      isSelected: settingsVM.themeMode == ThemeMode.dark,
                      onTap: () {
                        HapticFeedback.lightImpact();
                        settingsVM.setThemeMode(ThemeMode.dark);
                      },
                    ),
                    const Divider(height: 1, indent: 56),
                    _buildThemeTile(
                      title: 'Light',
                      icon: LucideIcons.sun,
                      isSelected: settingsVM.themeMode == ThemeMode.light,
                      onTap: () {
                        HapticFeedback.lightImpact();
                        settingsVM.setThemeMode(ThemeMode.light);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Text('About', style: AppTypography.title.copyWith(color: AppColors.textSecondary)),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.bgSurface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2))],
                ),
                child: ListTile(
                  leading: const Icon(LucideIcons.info, color: AppColors.primary),
                  title: const Text('Version', style: AppTypography.body),
                  trailing: Text('1.0.0', style: AppTypography.body.copyWith(color: AppColors.textSecondary)),
                ),
              )
            ],
          );
        },
      ),
    );
  }

  Widget _buildThemeTile({
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: isSelected ? AppColors.primary : AppColors.textSecondary),
      title: Text(
        title,
        style: AppTypography.body.copyWith(
          color: isSelected ? AppColors.primary : AppColors.textPrimary,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      trailing: isSelected ? const Icon(LucideIcons.check, color: AppColors.primary) : null,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );
  }
}
