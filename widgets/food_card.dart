import 'package:flutter/material.dart';
import '../models/food_item.dart';

class FoodCard extends StatelessWidget {
  final FoodItem food;

  const FoodCard({Key? key, required this.food}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${food.name} (${food.quantity} ${food.unit})',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text('Calories: ${food.calories.toStringAsFixed(1)} kcal'),
            Text('Protein: ${food.protein.toStringAsFixed(1)} g'),
            Text('Carbs: ${food.carbs.toStringAsFixed(1)} g'),
            Text('Fats: ${food.fats.toStringAsFixed(1)} g'),
            const SizedBox(height: 8),
            Text('Micronutrients:', style: Theme.of(context).textTheme.titleMedium),
            ...food.micronutrients.entries.map(
              (entry) => Text('${entry.key}: ${entry.value.toStringAsFixed(1)} mg'),
            ),
          ],
        ),
      ),
    );
  }
}

