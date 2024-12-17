import 'package:flutter/material.dart';

class NutriLenzLogo extends StatelessWidget {
  final double size;
  
  const NutriLenzLogo({super.key, required this.size});
  
  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        image: DecorationImage(
          image: AssetImage('assets/cropc.jpg'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
