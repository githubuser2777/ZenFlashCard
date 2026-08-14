import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import '../../shared/theme/app_colors.dart';
import '../../shared/components/zen_button.dart';

class SessionResultScreen extends StatefulWidget {
  final int correctCount;
  final int totalCount;

  const SessionResultScreen({
    super.key,
    required this.correctCount,
    required this.totalCount,
  });

  @override
  State<SessionResultScreen> createState() => _SessionResultScreenState();
}

class _SessionResultScreenState extends State<SessionResultScreen> {
  @override
  void initState() {
    super.initState();
    HapticFeedback.mediumImpact();
  }

  @override
  Widget build(BuildContext context) {
    final double percentage =
        widget.totalCount == 0 ? 0 : (widget.correctCount / widget.totalCount);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    String message = "Keep it up!";
    String subMessage = "Consistency is the key to mastery.";
    IconData messageIcon = LucideIcons.sprout;
    Color messageColor = AppColors.rateOk;

    if (percentage >= 0.8) {
      message = "Outstanding!";
      subMessage = "You demonstrated excellent recall.";
      messageIcon = LucideIcons.trophy;
      messageColor = AppColors.rateEasy;
    } else if (percentage >= 0.5) {
      message = "Great Progress!";
      subMessage = "Solid recall. Reviewing once more will cement it.";
      messageIcon = LucideIcons.sparkles;
      messageColor = AppColors.primaryLight;
    }

    return Scaffold(
      appBar: AppBar(
        leading: Semantics(
          label: 'Close result',
          child: IconButton(
            icon: const Icon(LucideIcons.x),
            onPressed: () => context.go('/'),
          ),
        ),
        title: const Text('Session Complete'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 10),

              // Animated Radial Score Gauge
              Center(
                child: TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0.0, end: percentage),
                  duration: const Duration(milliseconds: 1400),
                  curve: Curves.easeOutCubic,
                  builder: (context, animatedPercentage, child) {
                    final percentDisplay = (animatedPercentage * 100).round();
                    return SizedBox(
                      width: 190,
                      height: 190,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CustomPaint(
                            size: const Size(190, 190),
                            painter: _ZenScoreRingPainter(
                              progress: animatedPercentage,
                              trackColor: isDark
                                  ? AppColors.bgSurface
                                  : AppColors.divider.withValues(alpha: 0.2),
                              progressColorStart: AppColors.primary,
                              progressColorEnd: AppColors.primaryLight,
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '$percentDisplay%',
                                style: AppTypography.display.copyWith(
                                  fontSize: 34,
                                  fontWeight: FontWeight.w800,
                                  color: isDark
                                      ? AppColors.textPrimary
                                      : AppColors.lightTextPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${widget.correctCount}/${widget.totalCount} correct',
                                style: AppTypography.caption.copyWith(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              )
                  .animate()
                  .scale(
                    begin: const Offset(0.8, 0.8),
                    end: const Offset(1.0, 1.0),
                    duration: 600.ms,
                    curve: Curves.easeOutBack,
                  )
                  .fadeIn(duration: 400.ms),

              const SizedBox(height: 32),

              // Motivational Message
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: BoxDecoration(
                  color:
                      isDark ? AppColors.bgSurface : AppColors.lightBgSurface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark
                        ? AppColors.divider.withValues(alpha: 0.4)
                        : AppColors.divider.withValues(alpha: 0.15),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(messageIcon, color: messageColor, size: 22),
                        const SizedBox(width: 10),
                        Text(
                          message,
                          style: AppTypography.headline.copyWith(
                            fontSize: 18,
                            color: isDark
                                ? AppColors.textPrimary
                                : AppColors.lightTextPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subMessage,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 500.ms, delay: 400.ms).slideY(
                  begin: 0.2,
                  end: 0,
                  duration: 500.ms,
                  curve: Curves.easeOutCubic),

              const SizedBox(height: 20),

              // Breakdown Chips Row
              Row(
                children: [
                  Expanded(
                    child: _buildStatChip(
                      label: 'Correct',
                      count: widget.correctCount,
                      icon: LucideIcons.checkCircle2,
                      color: AppColors.rateEasy,
                      delayMs: 550,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _buildStatChip(
                      label: 'Incorrect',
                      count: widget.totalCount - widget.correctCount,
                      icon: LucideIcons.xCircle,
                      color: AppColors.rateHard,
                      delayMs: 650,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 48),

              // Done Button
              SizedBox(
                width: double.infinity,
                child: ZenButton(
                  label: 'Done',
                  icon: const Icon(LucideIcons.check, size: 18),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    context.go('/');
                  },
                ),
              ).animate().fadeIn(duration: 500.ms, delay: 750.ms).slideY(
                    begin: 0.3,
                    end: 0,
                    duration: 500.ms,
                    curve: Curves.easeOutBack,
                  ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatChip({
    required String label,
    required int count,
    required IconData icon,
    required Color color,
    required int delayMs,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.bgSurface : AppColors.lightBgSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTypography.caption.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                ),
              ),
              Text(
                '$count',
                style: AppTypography.title.copyWith(
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 450.ms, delay: delayMs.ms).slideY(
        begin: 0.2, end: 0, duration: 450.ms, curve: Curves.easeOutCubic);
  }
}

/// Custom painter that renders a glowing circular score ring
class _ZenScoreRingPainter extends CustomPainter {
  final double progress;
  final Color trackColor;
  final Color progressColorStart;
  final Color progressColorEnd;

  _ZenScoreRingPainter({
    required this.progress,
    required this.trackColor,
    required this.progressColorStart,
    required this.progressColorEnd,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (min(size.width, size.height) / 2) - 12;
    const strokeWidth = 14.0;

    // Track
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    if (progress <= 0) return;

    final rect = Rect.fromCircle(center: center, radius: radius);

    // Subtle glow behind progress arc
    final glowPaint = Paint()
      ..color = progressColorEnd.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth + 6
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    const startAngle = -pi / 2;
    final sweepAngle = 2 * pi * progress.clamp(0.0, 1.0);

    canvas.drawArc(rect, startAngle, sweepAngle, false, glowPaint);

    // Progress Arc
    final progressPaint = Paint()
      ..shader = SweepGradient(
        startAngle: 0,
        endAngle: 2 * pi,
        colors: [progressColorStart, progressColorEnd],
        transform: const GradientRotation(startAngle),
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, startAngle, sweepAngle, false, progressPaint);
  }

  @override
  bool shouldRepaint(covariant _ZenScoreRingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.progressColorStart != progressColorStart ||
        oldDelegate.progressColorEnd != progressColorEnd;
  }
}
