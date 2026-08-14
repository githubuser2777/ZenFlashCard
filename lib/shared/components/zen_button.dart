import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';

enum ZenButtonVariant { filled, outlined, text }

class ZenButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final ZenButtonVariant variant;
  final Widget? icon;

  const ZenButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = ZenButtonVariant.filled,
    this.icon,
  });

  @override
  State<ZenButton> createState() => _ZenButtonState();
}

class _ZenButtonState extends State<ZenButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
      reverseDuration: const Duration(milliseconds: 250),
    );
    // Use an easeOutBack curve to simulate a springy bounce on release
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
        reverseCurve: Curves.easeOutBack,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.onPressed != null) {
      _controller.forward();
    }
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.onPressed != null) {
      _controller.reverse();
    }
  }

  void _onTapCancel() {
    if (widget.onPressed != null) {
      _controller.reverse();
    }
  }

  void _onTap() {
    if (widget.onPressed != null) {
      HapticFeedback.lightImpact(); // Add haptic feedback
      widget.onPressed!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: _onTap,
      // Increase hit test area for accessibility
      behavior: HitTestBehavior.opaque,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          // Ensure minimum touch target of 48dp for accessibility
          constraints: const BoxConstraints(minHeight: 48),
          decoration: _getDecoration(),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.icon != null) ...[
                widget.icon!,
                const SizedBox(width: 8),
              ],
              Text(
                widget.label,
                style: AppTypography.label.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: _getTextColor(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  BoxDecoration _getDecoration() {
    final bool isDisabled = widget.onPressed == null;

    switch (widget.variant) {
      case ZenButtonVariant.filled:
        return BoxDecoration(
          color: isDisabled ? AppColors.divider : AppColors.primary,
          borderRadius: BorderRadius.circular(12),
        );
      case ZenButtonVariant.outlined:
        return BoxDecoration(
          color: Colors.transparent,
          border: Border.all(
            color: isDisabled ? AppColors.divider : AppColors.primary,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        );
      case ZenButtonVariant.text:
        return BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        );
    }
  }

  Color _getTextColor() {
    final bool isDisabled = widget.onPressed == null;
    if (isDisabled) return AppColors.textSecondary;

    switch (widget.variant) {
      case ZenButtonVariant.filled:
        return AppColors.textPrimary;
      case ZenButtonVariant.outlined:
      case ZenButtonVariant.text:
        return AppColors.primary;
    }
  }
}
