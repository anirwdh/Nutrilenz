import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../models/food_item.dart';

class FoodProvider with ChangeNotifier {
  List<FoodItem> _foods = [];
  Map<String, dynamic> _foodData = {};

  List<FoodItem> get foods => _foods;

  FoodProvider() {
    _loadFoodData();
  }

  Future<void> _loadFoodData() async {
    try {
      final String response = await rootBundle.loadString('assets/fooddb.json');
      _foodData = await json.decode(response);
      print('Food data loaded successfully');
    } catch (e) {
      print('Error loading food data: $e');
    }
  }

  Future<void> searchFood(String query) async {
    if (query.isEmpty) {
      _foods = [];
      notifyListeners();
      return;
    }

    try {
      final RegExp quantityRegex = RegExp(
        r'(\d+(?:\.\d+)?)\s*(gm|ml|piece|g|pieces|grams|milliliters)\s+(.+)',
        caseSensitive: false
      );
      final match = quantityRegex.firstMatch(query.toLowerCase());

      String foodName;
      double quantity = 1.0;
      String unit = 'g';

      if (match != null) {
        quantity = double.parse(match.group(1)!);
        String rawUnit = match.group(2)!.toLowerCase();
        unit = _normalizeUnit(rawUnit);
        foodName = match.group(3)!.trim();
      } else {
        foodName = query.toLowerCase().trim();
      }

      Map<String, dynamic>? foodItem = _findFoodItem(foodName);

      if (foodItem != null) {
        final scaledNutrition = _calculateNutrition(foodItem, quantity, unit);

        _foods = [
          FoodItem(
            name: foodName,
            calories: scaledNutrition['calories']!,
            protein: scaledNutrition['protein']!,
            carbs: scaledNutrition['carbs']!,
            fats: scaledNutrition['fats']!,
            micronutrients: Map<String, double>.from(scaledNutrition['micros'] as Map),
            imageUrl: 'https://via.placeholder.com/150',
            quantity: quantity,
            unit: unit,
          )
        ];
      } else {
        _foods = [];
      }

      notifyListeners();
    } catch (e) {
      print('Error searching for food: $e');
      _foods = [];
      notifyListeners();
    }
  }

  Map<String, dynamic>? _findFoodItem(String foodName) {
    for (var category in _foodData.keys) {
      if (_foodData[category] is Map<String, dynamic>) {
        var categoryData = _foodData[category] as Map<String, dynamic>;
        if (categoryData.containsKey(foodName)) {
          return categoryData[foodName];
        }
      }
    }
    return null;
  }

  String _normalizeUnit(String rawUnit) {
    switch (rawUnit) {
      case 'grams':
      case 'g':
      case 'gm':
        return 'g';
      case 'milliliters':
      case 'ml':
        return 'ml';
      case 'pieces':
      case 'piece':
        return 'piece';
      default:
        return 'g';
    }
  }

  Map<String, dynamic> _calculateNutrition(Map<String, dynamic> foodItem, double quantity, String unit) {
    Map<String, dynamic> macros = foodItem['macros'] ?? {};
    Map<String, dynamic> micros = foodItem['micros'] ?? {};

    double scalingFactor = _calculateScalingFactor(unit, quantity, foodItem);

    final scaledMacros = macros.map((key, value) => MapEntry(key, (value as num).toDouble() * scalingFactor));
    final scaledMicros = micros.map((key, value) => MapEntry(key, (value as num).toDouble() * scalingFactor));

    var result = Map<String, dynamic>.from(scaledMacros);
    result['micros'] = scaledMicros;
    return result;
  }

  double _calculateScalingFactor(String unit, double quantity, Map<String, dynamic> foodItem) {
    String baseQuantity = foodItem.keys.first;
    Map<String, dynamic> baseQuantityRegex = _parseQuantity(baseQuantity);

    if (unit == baseQuantityRegex['unit']) {
      return quantity / baseQuantityRegex['amount'];
    } else {
      // Default to 100g if units don't match
      return quantity / 100;
    }
  }

  Map<String, dynamic> _parseQuantity(String quantityString) {
    final RegExp quantityRegex = RegExp(r'(\d+(?:\.\d+)?)\s*(\w+)');
    final match = quantityRegex.firstMatch(quantityString);

    if (match != null) {
      return {
        'amount': double.parse(match.group(1)!),
        'unit': _normalizeUnit(match.group(2)!),
      };
    } else {
      return {
        'amount': 100,
        'unit': 'g',
      };
    }
  }
}

