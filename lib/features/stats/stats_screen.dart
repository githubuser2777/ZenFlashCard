import 'package:flutter/material.dart';
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
              // We can add FLChart later
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text('Total Decks: ${statsVM.totalDecks}\nTotal Cards: ${statsVM.totalCards}'),
                ),
              ),
            ],
          );
        },
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
      ),
      child: Row(
        children: [
          const Text('🔥', style: TextStyle(fontSize: 40)),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$streak Day Streak',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
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
