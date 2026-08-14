import 'package:flutter/material.dart';
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
            padding: const EdgeInsets.all(20),
            children: [
              _buildStreakCard(statsVM.streak),
              const SizedBox(height: 16),
              _buildStatCard(
                  'Total Decks', statsVM.totalDecks, LucideIcons.library),
              const SizedBox(height: 16),
              _buildStatCard(
                  'Total Cards', statsVM.totalCards, LucideIcons.copy),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String title, int value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2))
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(title,
                style: AppTypography.title
                    .copyWith(color: AppColors.textSecondary)),
          ),
          TweenAnimationBuilder<int>(
            tween: IntTween(begin: 0, end: value),
            duration: const Duration(seconds: 1),
            curve: Curves.easeOutCubic,
            builder: (context, val, child) {
              return Text('$val', style: AppTypography.display);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStreakCard(int streak) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3730A3), AppColors.primary],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4))
        ],
      ),
      child: Row(
        children: [
          const Icon(LucideIcons.flame, color: Colors.orangeAccent, size: 40),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TweenAnimationBuilder<int>(
                tween: IntTween(begin: 0, end: streak),
                duration: const Duration(seconds: 1),
                curve: Curves.easeOutCubic,
                builder: (context, val, child) {
                  return Text(
                    '$val Day Streak',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),
              const Text(
                'Keep it up!',
                style: TextStyle(color: Colors.white70),
              )
            ],
          )
        ],
      ),
    );
  }
}
