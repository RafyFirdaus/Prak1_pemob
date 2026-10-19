import 'dart:math' as math;
import 'package:flutter/material.dart';

class CardFlipEffect extends StatefulWidget {
  const CardFlipEffect({
    required this.child,
    required this.delayAmount,
    super.key,
  });
  final Widget child;
  final double delayAmount;

  @override
  State<CardFlipEffect> createState() => _CardFlipEffectState();
}

class _CardFlipEffectState extends State<CardFlipEffect>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<double> _animationWithDelay;
  Widget? _previousChild;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    _configureAnimation();
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() => _previousChild = null);
      }
    });
  }

  void _configureAnimation() {
    // Extend total time so every card rotates for the same duration.
    _controller.duration = Duration(
      milliseconds: (500 * (1 + widget.delayAmount)).round(),
    );
    _animationWithDelay = TweenSequence<double>([
      if (widget.delayAmount > 0)
        TweenSequenceItem(
          tween: ConstantTween<double>(0),
          weight: widget.delayAmount,
        ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0,
          end: 1,
        ).chain(CurveTween(curve: Curves.easeInOutCubic)),
        weight: 1,
      ),
    ]).animate(_controller);
  }

  @override
  void didUpdateWidget(covariant CardFlipEffect oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.delayAmount != widget.delayAmount) _configureAnimation();
    if (oldWidget.child.key != widget.child.key) {
      _previousChild = oldWidget.child;
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final progress = _animationWithDelay.value;
        final animating = _controller.isAnimating;
        return IgnorePointer(
          ignoring: animating,
          child: Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateX(animating ? progress * math.pi : 0),
            child: animating
                ? progress < 0.5
                      ? _previousChild ?? child
                      : Transform.flip(flipY: true, child: child)
                : child,
          ),
        );
      },
      child: widget.child,
    );
  }
}
