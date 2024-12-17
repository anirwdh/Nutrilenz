class FoodItem {
  final String name;
  final double calories;
  final double protein;
  final double carbs;
  final double fats;
  final Map<String, double> micronutrients;
  final String imageUrl;
  final double quantity;
  final String unit;

  FoodItem({
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fats,
    required this.micronutrients,
    required this.imageUrl,
    required this.quantity,
    required this.unit,
  });
}

