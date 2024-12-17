import 'package:flutter/material.dart';
import 'dart:math' as math;

class FloatingIcons extends StatefulWidget {
  const FloatingIcons({Key? key}) : super(key: key);

  @override
  _FloatingIconsState createState() => _FloatingIconsState();
}

class _FloatingIconsState extends State<FloatingIcons> with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _scaleAnimations;
  late List<Animation<double>> _rotationAnimations;

  final List<IconData> _icons = [
    Icons.icecream,
    Icons.apple,
    Icons.local_pizza,
    Icons.bakery_dining,
    Icons.water_drop,
  ];

  final List<Color> _iconColors = [
    Colors.pink,
    Colors.red,
    Colors.orange,
    Colors.brown,
    Colors.yellow,
  ];

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(10, (index) {
      return AnimationController(
        duration: Duration(seconds: 20 + index % 4),
        vsync: this,
      )..repeat(reverse: true);
    });

    _scaleAnimations = _controllers.map((controller) {
      return Tween<double>(begin: 0.9, end: 2.8).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInOut),
      );
    }).toList();

    _rotationAnimations = _controllers.map((controller) {
      return Tween<double>(begin: -0.1, end: 0.8).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInOut),
      );
    }).toList();
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: List.generate(10, (index) {
        final random = math.Random(index);
        final iconIndex = random.nextInt(_icons.length);
        
        return AnimatedBuilder(
          animation: _controllers[index],
          builder: (context, child) {
            return Positioned(
              left: random.nextDouble() * MediaQuery.of(context).size.width,
              top: 20 + math.sin(_controllers[index].value * math.pi * 0.1 + index) * 60,
              child: Transform.rotate(
                angle: _rotationAnimations[index].value,
                child: Transform.scale(
                  scale: _scaleAnimations[index].value,
                  child: Icon(
                    _icons[iconIndex],
                    size: 30 + random.nextDouble() * 20,
                    color: _iconColors[iconIndex].withOpacity(0.6),
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
