import 'package:flutter/material.dart';
import 'dart:ui';

class AnimatedBackground extends StatefulWidget {
  final Widget child;

  const AnimatedBackground({Key? key, required this.child}) : super(key: key);

  @override
  _AnimatedBackgroundState createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground> with TickerProviderStateMixin {
  late AnimationController _colorAnimationController;
  late AnimationController _blurAnimationController;
  late Animation<Color?> _colorAnimation;
  late Animation<double> _blurAnimation;

  final List<Color> _gradientColors = [
    Colors.lightBlue.withOpacity(0.3),
    Colors.blue.withOpacity(0.3),
    Colors.lightBlue.shade100.withOpacity(0.3),
    Colors.blue.shade200.withOpacity(0.3),
  ];

  @override
  void initState() {
    super.initState();

    _colorAnimationController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();

    _blurAnimationController = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    )..repeat(reverse: true);

    _colorAnimation = TweenSequence<Color?>(
      _gradientColors.asMap().entries.map((e) {
        int idx = e.key;
        return TweenSequenceItem(
          weight: 1.0,
          tween: ColorTween(
            begin: e.value,
            end: _gradientColors[(idx + 1) % _gradientColors.length],
          ),
        );
      }).toList(),
    ).animate(_colorAnimationController);

    _blurAnimation = Tween<double>(begin: 0.0, end: 5.0)
        .animate(_blurAnimationController);
  }

  @override
  void dispose() {
    _colorAnimationController.dispose();
    _blurAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        AnimatedBuilder(
          animation: Listenable.merge([_colorAnimationController, _blurAnimationController]),
          builder: (context, child) {
            return Stack(
              children: [
                Container(
                  color: Colors.white,
                ),
                BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: _blurAnimation.value,
                    sigmaY: _blurAnimation.value,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          _colorAnimation.value ?? Colors.transparent,
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
        widget.child,
      ],
    );
  }
}
