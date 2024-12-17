import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/food_provider.dart';
import '../models/food_search.dart';

class FoodSearchWidget extends StatefulWidget {
  const FoodSearchWidget({Key? key}) : super(key: key);

  @override
  _FoodSearchWidgetState createState() => _FoodSearchWidgetState();
}

class _FoodSearchWidgetState extends State<FoodSearchWidget> {
  final _formKey = GlobalKey<FormState>();
  String _foodName = '';
  double _quantity = 100;
  String _unit = 'g';

  void _submitSearch() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final foodSearch = FoodSearch(
        foodName: _foodName,
        quantity: _quantity,
        unit: _unit,
      );
      Provider.of<FoodProvider>(context, listen: false)
          .searchFood('${_quantity.toString()} $_unit $_foodName');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Food Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a food name';
                  }
                  return null;
                },
                onSaved: (value) {
                  _foodName = value!;
                },
              ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: InputDecoration(labelText: 'Quantity'),
                      keyboardType: TextInputType.number,
                      initialValue: _quantity.toString(),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a quantity';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _quantity = double.parse(value!);
                      },
                    ),
                  ),
                  SizedBox(width: 16),
                  DropdownButton<String>(
                    value: _unit,
                    items: ['g', 'ml', 'piece'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _unit = newValue!;
                      });
                    },
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: _submitSearch,
                child: Text('Search'),
              ),
            ],
          ),
        ),
        SizedBox(height: 20),
        Consumer<FoodProvider>(
          builder: (context, foodProvider, child) {
            if (foodProvider.foods.isEmpty) {
              return Text('No results found.');
            }
            return Column(
              children: foodProvider.foods.map((food) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${food.name} (${food.quantity} ${food.unit})',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        SizedBox(height: 8),
                        Text('Calories: ${food.calories.toStringAsFixed(1)} kcal'),
                        Text('Protein: ${food.protein.toStringAsFixed(1)} g'),
                        Text('Carbs: ${food.carbs.toStringAsFixed(1)} g'),
                        Text('Fats: ${food.fats.toStringAsFixed(1)} g'),
                        SizedBox(height: 8),
                        Text('Micronutrients:'),
                        ...food.micronutrients.entries.map(
                          (entry) => Text('${entry.key}: ${entry.value.toStringAsFixed(1)} mg'),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}

