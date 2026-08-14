import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../settings/settings_viewmodel.dart';
import '../../shared/theme/app_colors.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Consumer<SettingsViewModel>(
        builder: (context, settingsVM, child) {
          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            physics: const BouncingScrollPhysics(),
            children: [
              Text(
                'APPEARANCE',
                style: AppTypography.label.copyWith(
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryLight,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color:
                      isDark ? AppColors.bgSurface : AppColors.lightBgSurface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark
                        ? AppColors.divider.withValues(alpha: 0.4)
                        : AppColors.divider.withValues(alpha: 0.15),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color:
                          Colors.black.withValues(alpha: isDark ? 0.15 : 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    )
                  ],
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
              ).animate().fadeIn(duration: 350.ms).slideY(begin: 0.1, end: 0),
              const SizedBox(height: 28),
              Text(
                'EXPERIENCE',
                style: AppTypography.label.copyWith(
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryLight,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color:
                      isDark ? AppColors.bgSurface : AppColors.lightBgSurface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark
                        ? AppColors.divider.withValues(alpha: 0.4)
                        : AppColors.divider.withValues(alpha: 0.15),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color:
                          Colors.black.withValues(alpha: isDark ? 0.15 : 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    )
                  ],
                ),
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(LucideIcons.sparkles,
                        color: AppColors.primaryLight, size: 20),
                  ),
                  title: Text(
                    'Replay Welcome Animation',
                    style: AppTypography.body.copyWith(
                      color: isDark
                          ? AppColors.textPrimary
                          : AppColors.lightTextPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: Text(
                    'View the Zen intro & onboarding',
                    style: AppTypography.caption
                        .copyWith(color: AppColors.textSecondary),
                  ),
                  trailing: const Icon(LucideIcons.chevronRight,
                      size: 18, color: AppColors.textSecondary),
                  onTap: () {
                    HapticFeedback.lightImpact();
                    context.push('/welcome');
                  },
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
              )
                  .animate()
                  .fadeIn(duration: 350.ms, delay: 100.ms)
                  .slideY(begin: 0.1, end: 0),
              const SizedBox(height: 28),
              Text(
                'ABOUT',
                style: AppTypography.label.copyWith(
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryLight,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color:
                      isDark ? AppColors.bgSurface : AppColors.lightBgSurface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark
                        ? AppColors.divider.withValues(alpha: 0.4)
                        : AppColors.divider.withValues(alpha: 0.15),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color:
                          Colors.black.withValues(alpha: isDark ? 0.15 : 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    )
                  ],
                ),
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(LucideIcons.info,
                        color: AppColors.primaryLight, size: 20),
                  ),
                  title: Text(
                    'ZenFlashCards',
                    style: AppTypography.body.copyWith(
                      color: isDark
                          ? AppColors.textPrimary
                          : AppColors.lightTextPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: const Text('Version 1.0.0+1',
                      style: AppTypography.caption),
                  trailing: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('Pro Max', style: AppTypography.label),
                  ),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
              )
                  .animate()
                  .fadeIn(duration: 350.ms, delay: 200.ms)
                  .slideY(begin: 0.1, end: 0),
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
      leading: Icon(
        icon,
        color: isSelected ? AppColors.primaryLight : AppColors.textSecondary,
        size: 20,
      ),
      title: Text(
        title,
        style: AppTypography.body.copyWith(
          color: isSelected ? AppColors.primaryLight : AppColors.textSecondary,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      trailing: isSelected
          ? const Icon(LucideIcons.check,
              color: AppColors.primaryLight, size: 20)
          : null,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );
  }
}
