import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../stats/stats_viewmodel.dart';
import '../../shared/theme/app_colors.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StatsViewModel>().loadStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Statistics')),
      body: Consumer<StatsViewModel>(
        builder: (context, statsVM, child) {
          if (statsVM.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            physics: const BouncingScrollPhysics(),
            children: [
              _buildStreakCard(statsVM.streak)
                  .animate()
                  .fadeIn(duration: 400.ms)
                  .slideY(
                      begin: 0.15,
                      end: 0,
                      duration: 400.ms,
                      curve: Curves.easeOutCubic),
              const SizedBox(height: 16),
              _buildStatCard(
                'Total Decks',
                statsVM.totalDecks,
                LucideIcons.library,
                delayMs: 100,
              ),
              const SizedBox(height: 14),
              _buildStatCard(
                'Total Flashcards',
                statsVM.totalCards,
                LucideIcons.copy,
                delayMs: 200,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String title, int value, IconData icon,
      {required int delayMs}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.bgSurface : AppColors.lightBgSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? AppColors.divider.withValues(alpha: 0.4)
              : AppColors.divider.withValues(alpha: 0.15),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primaryLight, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: AppTypography.title.copyWith(
                color:
                    isDark ? AppColors.textPrimary : AppColors.lightTextPrimary,
                fontSize: 15,
              ),
            ),
          ),
          TweenAnimationBuilder<int>(
            tween: IntTween(begin: 0, end: value),
            duration: const Duration(milliseconds: 900),
            curve: Curves.easeOutCubic,
            builder: (context, val, child) {
              return Text(
                '$val',
                style: AppTypography.display.copyWith(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? AppColors.textPrimary
                      : AppColors.lightTextPrimary,
                ),
              );
            },
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: delayMs.ms).slideY(
        begin: 0.15, end: 0, duration: 400.ms, curve: Curves.easeOutCubic);
  }

  Widget _buildStreakCard(int streak) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF3730A3), AppColors.primary],
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              LucideIcons.flame,
              color: Color(0xFFFDBA74),
              size: 32,
            ),
          )
              .animate(onPlay: (controller) => controller.repeat(reverse: true))
              .scale(
                begin: const Offset(0.95, 0.95),
                end: const Offset(1.08, 1.08),
                duration: 1200.ms,
                curve: Curves.easeInOutSine,
              ),
          const SizedBox(width: 18),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TweenAnimationBuilder<int>(
                tween: IntTween(begin: 0, end: streak),
                duration: const Duration(milliseconds: 1000),
                curve: Curves.easeOutCubic,
                builder: (context, val, child) {
                  return Text(
                    '$val Day Streak',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),
              const SizedBox(height: 2),
              const Text(
                'Keep the daily habit alive!',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
