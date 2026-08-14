import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';

enum ZenButtonVariant { filled, outlined, text }

/// Premium interactive Zen button with Spring scale physics, tactile haptics, and a11y support
class ZenButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final ZenButtonVariant variant;
  final Widget? icon;
  final double? width;
  final double height;

  const ZenButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = ZenButtonVariant.filled,
    this.icon,
    this.width,
    this.height = 48.0,
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
      duration: const Duration(milliseconds: 120),
      reverseDuration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
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
      HapticFeedback.lightImpact();
      widget.onPressed!();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.onPressed != null;

    return Semantics(
      button: true,
      enabled: isEnabled,
      label: widget.label,
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        onTap: _onTap,
        behavior: HitTestBehavior.opaque,
        child: RepaintBoundary(
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              width: widget.width,
              constraints: BoxConstraints(minHeight: widget.height),
              decoration: _getDecoration(),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
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
          boxShadow: isDisabled
              ? null
              : [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.28),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
        );
      case ZenButtonVariant.outlined:
        return BoxDecoration(
          color: Colors.transparent,
          border: Border.all(
            color: isDisabled ? AppColors.divider : AppColors.primary,
            width: 1.8,
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
    if (isDisabled) return AppColors.textSecondary.withValues(alpha: 0.6);

    switch (widget.variant) {
      case ZenButtonVariant.filled:
        return AppColors.textPrimary;
      case ZenButtonVariant.outlined:
      case ZenButtonVariant.text:
        return AppColors.primaryLight;
    }
  }
}
