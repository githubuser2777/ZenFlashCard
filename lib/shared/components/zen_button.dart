import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart'; // To use AppTypography indirectly

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

class _ZenButtonState extends State<ZenButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.onPressed != null) _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.onPressed != null) _controller.reverse();
  }

  void _onTapCancel() {
    if (widget.onPressed != null) _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: widget.onPressed,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          decoration: _getDecoration(),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
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
