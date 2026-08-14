import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../shared/theme/app_colors.dart';
import '../../shared/components/zen_button.dart';

/// Key for storing welcome onboarding completion state
const String kHasSeenWelcomeKey = 'has_seen_welcome_v1';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _completeWelcome() async {
    HapticFeedback.mediumImpact();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(kHasSeenWelcomeKey, true);
    } catch (_) {}
    if (mounted) {
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgMain : AppColors.lightBgMain,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 40,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Top bar with Skip button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: _completeWelcome,
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.textSecondary,
                              minimumSize: const Size(48, 48),
                            ),
                            child: const Text(
                              'Skip',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ).animate().fadeIn(duration: 400.ms, delay: 600.ms),
                        ],
                      ),

                      const Spacer(flex: 1),

                      // Zen Animated Ensō Circle + Core Icon
                      Center(
                        child: AnimatedBuilder(
                          animation: _pulseController,
                          builder: (context, child) {
                            final pulseValue = Curves.easeInOutSine
                                .transform(_pulseController.value);
                            return SizedBox(
                              width: 170,
                              height: 170,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Outer breathing aura ring
                                  Container(
                                    width: 150 + (pulseValue * 20),
                                    height: 150 + (pulseValue * 20),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: RadialGradient(
                                        colors: [
                                          AppColors.primary.withValues(
                                              alpha: 0.15 + (pulseValue * 0.1)),
                                          AppColors.primary
                                              .withValues(alpha: 0.0),
                                        ],
                                      ),
                                    ),
                                  ),
                                  // Ensō Painted Zen Ring
                                  Transform.rotate(
                                    angle: pulseValue * 0.15,
                                    child: CustomPaint(
                                      size: const Size(140, 140),
                                      painter: _ZenEnsoPainter(
                                        color: isDark
                                            ? AppColors.primaryLight
                                            : AppColors.primary,
                                        progress: 1.0,
                                        glowAlpha: 0.3 + (pulseValue * 0.2),
                                      ),
                                    ),
                                  ),
                                  // Inner Core Container
                                  Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isDark
                                          ? AppColors.bgSurface
                                          : AppColors.lightBgSurface,
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.primary
                                              .withValues(alpha: 0.25),
                                          blurRadius: 16,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                    child: const Center(
                                      child: Icon(
                                        LucideIcons.sparkles,
                                        color: AppColors.primaryLight,
                                        size: 36,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      )
                          .animate()
                          .scale(
                            begin: const Offset(0.7, 0.7),
                            end: const Offset(1.0, 1.0),
                            duration: 800.ms,
                            curve: Curves.easeOutBack,
                          )
                          .fadeIn(duration: 600.ms),

                      const SizedBox(height: 32),

                      // Title & Subtitle Staggered Animation
                      Text(
                        'ZenFlashCards',
                        style: AppTypography.display.copyWith(
                          fontSize: 30,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.5,
                          color: isDark
                              ? AppColors.textPrimary
                              : AppColors.lightTextPrimary,
                        ),
                      )
                          .animate()
                          .fadeIn(duration: 600.ms, delay: 200.ms)
                          .slideY(
                            begin: 0.3,
                            end: 0,
                            duration: 600.ms,
                            curve: Curves.easeOutCubic,
                          ),

                      const SizedBox(height: 8),

                      Text(
                        'Dark · Calm · Focused',
                        style: AppTypography.label.copyWith(
                          fontSize: 13,
                          letterSpacing: 2.0,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryLight,
                        ),
                      )
                          .animate()
                          .fadeIn(duration: 600.ms, delay: 350.ms)
                          .slideY(begin: 0.3, end: 0, duration: 600.ms),

                      const SizedBox(height: 12),

                      Text(
                        'Learn vocabulary the mindful way with spaced repetition and effortless focus.',
                        textAlign: TextAlign.center,
                        style: AppTypography.body.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                      )
                          .animate()
                          .fadeIn(duration: 600.ms, delay: 500.ms)
                          .slideY(begin: 0.2, end: 0, duration: 600.ms),

                      const SizedBox(height: 28),

                      // 3 Feature Zen Highlights
                      _buildFeatureTile(
                        icon: LucideIcons.brain,
                        title: 'SM-2 Spaced Repetition',
                        description:
                            'Scientifically optimized review schedules.',
                        delayMs: 650,
                      ),
                      const SizedBox(height: 12),
                      _buildFeatureTile(
                        icon: LucideIcons.layers,
                        title: 'Active 3D Recall & Quiz',
                        description: 'Smooth tactile flips and test sessions.',
                        delayMs: 750,
                      ),
                      const SizedBox(height: 12),
                      _buildFeatureTile(
                        icon: LucideIcons.moon,
                        title: 'Distraction-Free Zen',
                        description:
                            'Clean dark aesthetic crafted for deep study.',
                        delayMs: 850,
                      ),

                      const Spacer(flex: 2),
                      const SizedBox(height: 24),

                      // Action Button
                      SizedBox(
                        width: double.infinity,
                        child: ZenButton(
                          label: 'Begin Journey',
                          icon: const Icon(LucideIcons.arrowRight, size: 18),
                          onPressed: _completeWelcome,
                        ),
                      )
                          .animate()
                          .fadeIn(duration: 600.ms, delay: 950.ms)
                          .slideY(
                            begin: 0.3,
                            end: 0,
                            duration: 600.ms,
                            curve: Curves.easeOutBack,
                          ),

                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFeatureTile({
    required IconData icon,
    required String title,
    required String description,
    required int delayMs,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.bgSurface : AppColors.lightBgSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark
              ? AppColors.divider.withValues(alpha: 0.4)
              : AppColors.divider.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primaryLight, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.title.copyWith(
                    fontSize: 14,
                    color: isDark
                        ? AppColors.textPrimary
                        : AppColors.lightTextPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms, delay: delayMs.ms).slideX(
        begin: 0.1, end: 0, duration: 500.ms, curve: Curves.easeOutCubic);
  }
}

/// Custom painter that draws an Ensō (Zen circle) with soft tapered brush stroke
class _ZenEnsoPainter extends CustomPainter {
  final Color color;
  final double progress;
  final double glowAlpha;

  _ZenEnsoPainter({
    required this.color,
    required this.progress,
    required this.glowAlpha,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (min(size.width, size.height) / 2) - 10;

    // Outer subtle glow
    final glowPaint = Paint()
      ..color = color.withValues(alpha: glowAlpha * 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

    final rect = Rect.fromCircle(center: center, radius: radius);
    // Draw open circle arc ~ 310 degrees (representing the Ensō open brush)
    const sweepAngle = 2 * pi * 0.86;
    const startAngle = -pi * 0.65;

    canvas.drawArc(rect, startAngle, sweepAngle * progress, false, glowPaint);

    // Main stroke
    final mainPaint = Paint()
      ..shader = SweepGradient(
        startAngle: 0,
        endAngle: 2 * pi,
        colors: [
          color.withValues(alpha: 0.3),
          color,
          color.withValues(alpha: 0.9),
          color.withValues(alpha: 0.4),
        ],
        stops: const [0.0, 0.4, 0.75, 1.0],
        transform: const GradientRotation(-pi * 0.5),
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.5
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, startAngle, sweepAngle * progress, false, mainPaint);
  }

  @override
  bool shouldRepaint(covariant _ZenEnsoPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.glowAlpha != glowAlpha ||
        oldDelegate.color != color;
  }
}
