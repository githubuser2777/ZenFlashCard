import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 3D Flip Card Component for Flashcard Study & Review
/// Features optimized 3D perspective rotation, natural depth scaling,
/// and RepaintBoundary isolation for 60/120fps smooth animation.
class FlipCard3D extends StatefulWidget {
  final Widget front;
  final Widget back;
  final ValueChanged<bool>? onFlip;
  final Duration duration;

  const FlipCard3D({
    super.key,
    required this.front,
    required this.back,
    this.onFlip,
    this.duration = const Duration(milliseconds: 450),
  });

  @override
  State<FlipCard3D> createState() => FlipCard3DState();
}

class FlipCard3DState extends State<FlipCard3D>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isFront = true;

  bool get isFront => _isFront;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
      reverseCurve: Curves.easeInOutCubic,
    );
  }

  @override
  void didUpdateWidget(covariant FlipCard3D oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.duration != widget.duration) {
      _controller.duration = widget.duration;
    }
  }

  void flip() {
    if (_controller.isAnimating) return;
    HapticFeedback.lightImpact();
    if (_isFront) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
    _isFront = !_isFront;
    widget.onFlip?.call(!_isFront);
  }

  void reset() {
    if (!_isFront) {
      _controller.reverse();
      _isFront = true;
      widget.onFlip?.call(false);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: flip,
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final progress = _animation.value;
          final angle = progress * pi;
          final isFrontFacing = progress < 0.5;

          // 3D physical depth effect: Card slightly recedes at 90 degrees
          final depthScale = 1.0 - (sin(progress * pi) * 0.06);

          return Transform(
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.0012) // Subtle perspective
              ..scaleByDouble(depthScale, depthScale, 1.0, 1.0)
              ..rotateY(angle),
            alignment: Alignment.center,
            child: RepaintBoundary(
              child: isFrontFacing
                  ? widget.front
                  : Transform(
                      transform: Matrix4.identity()..rotateY(pi),
                      alignment: Alignment.center,
                      child: widget.back,
                    ),
            ),
          );
        },
      ),
    );
  }
}
