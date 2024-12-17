import 'package:flutter/material.dart';

class NutritionInfoScreen extends StatefulWidget {
  const NutritionInfoScreen({super.key});

  @override
  _NutritionInfoScreenState createState() => _NutritionInfoScreenState();
}

class _NutritionInfoScreenState extends State<NutritionInfoScreen> with SingleTickerProviderStateMixin {
  String? selectedGender;
  double? age;
  double? weight;
  double? height;
  String? activityLevel;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final Map<String, Map<String, dynamic>> activityLevels = {
    'Sedentary': {
      'multiplier': 1.2,
      'proteinFactor': 1.2, // g/kg
      'description': 'Little or no exercise'
    },
    'Lightly Active': {
      'multiplier': 1.375,
      'proteinFactor': 1.4,
      'description': '1-3 days/week'
    },
    'Moderately Active': {
      'multiplier': 1.55,
      'proteinFactor': 1.6,
      'description': '3-5 days/week'
    },
    'Very Active': {
      'multiplier': 1.725,
      'proteinFactor': 1.8,
      'description': '6-7 days/week'
    },
    'Extra Active': {
      'multiplier': 1.9,
      'proteinFactor': 2.0,
      'description': 'Athletes/2x training'
    }
  };

  final List<double> weightOptions = List.generate(161, (index) => 40.0 + index);
  final List<double> heightOptions = List.generate(81, (index) => 140.0 + index);
  final List<double> ageOptions = List.generate(83, (index) => 18.0 + index);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    
    selectedGender = 'male';
    age = 25;
    weight = 70;
    height = 170;
    activityLevel = 'Moderately Active';
    
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double calculateBasalMetabolicRate() {
    if (selectedGender == null || age == null || weight == null || height == null) return 0;
    
    // Mifflin-St Jeor Equation
    double bmr = (10 * weight!) + (6.25 * height!) - (5 * age!);
    bmr += selectedGender == 'male' ? 5 : -161;
    
    return bmr;
  }

  double calculateTotalDailyEnergyExpenditure() {
    double bmr = calculateBasalMetabolicRate();
    double activityMultiplier = activityLevels[activityLevel]?['multiplier'] ?? 1.2;
    return bmr * activityMultiplier;
  }

  Map<String, double> calculateMacros() {
    double tdee = calculateTotalDailyEnergyExpenditure();
    
    // Protein based on activity level
    double proteinFactor = activityLevels[activityLevel]?['proteinFactor'] ?? 1.2;
    double protein = weight! * proteinFactor;
    
    // Fats: 25% of total calories
    double fats = (0.25 * tdee) / 9;
    
    // Carbs: Remaining calories
    double proteinCalories = protein * 4;
    double fatCalories = fats * 9;
    double remainingCalories = tdee - proteinCalories - fatCalories;
    double carbs = remainingCalories / 4;
    
    return {
      'protein': protein,
      'carbs': carbs,
      'fats': fats,
    };
  }

  double calculateWater() {
    return selectedGender == 'male' ? 3.7 : 2.7;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Nutrition Information',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w800,
            fontSize: 24,
          ),
        ),
        backgroundColor: const Color(0xFF00b09b),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    elevation: 0,
                    color: Colors.grey[100],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          const Text(
                            'Personal Information',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildGenderButton('Male', Icons.male, selectedGender == 'male'),
                              _buildGenderButton('Female', Icons.female, selectedGender == 'female'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildDropdown('Age', age ?? 25, ageOptions, (value) {
                    setState(() => age = value);
                  }),
                  _buildDropdown('Weight (kg)', weight ?? 70, weightOptions, (value) {
                    setState(() => weight = value);
                  }),
                  _buildDropdown('Height (cm)', height ?? 170, heightOptions, (value) {
                    setState(() => height = value);
                  }),
                  const SizedBox(height: 20),
                  _buildActivityLevelDropdown(),
                  const SizedBox(height: 20),
                  _buildNutritionInfo(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown(String label, double value, List<double> options, Function(double) onChanged) {
    return Card(
      elevation: 0,
      color: Colors.grey[100],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<double>(
              value: value,
              items: options.map((double option) {
                return DropdownMenuItem<double>(
                  value: option,
                  child: Text(option.round().toString()),
                );
              }).toList(),
              onChanged: (newValue) {
                if (newValue != null) {
                  onChanged(newValue);
                }
              },
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityLevelDropdown() {
    return Card(
      elevation: 0,
      color: Colors.grey[100],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: DropdownButtonFormField<String>(
          value: activityLevel,
          isExpanded: true,
          decoration: InputDecoration(
            labelText: 'Activity Level',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          items: activityLevels.keys.map((String level) {
            return DropdownMenuItem<String>(
              value: level,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(level),
                  Text(
                    activityLevels[level]!['description'],
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              activityLevel = newValue;
            });
          },
        ),
      ),
    );
  }

  Widget _buildGenderButton(String gender, IconData icon, bool isSelected) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 140,
      height: 140,
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            selectedGender = gender.toLowerCase();
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? const Color(0xFF00b09b) : Colors.white,
          foregroundColor: isSelected ? Colors.white : Colors.grey[800],
          elevation: isSelected ? 8 : 2,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
            side: BorderSide(
              color: isSelected ? const Color(0xFF00b09b) : Colors.grey[300]!,
              width: 2,
            ),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50),
            const SizedBox(height: 12),
            Text(
              gender,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutritionInfo() {
    final isMale = selectedGender == 'male';
    final tdee = calculateTotalDailyEnergyExpenditure();
    final macros = calculateMacros();
    final water = calculateWater();
    
    return Column(
      children: [
        Card(
          elevation: 4,
          shadowColor: Colors.black26,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF00b09b), Color(0xFF96c93d)],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Recommended Daily Nutrient Intakes',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildNutrientRow(
                    'Basal Metabolic Rate (BMR):',
                    '${calculateBasalMetabolicRate().round()} kcal',
                    'Calories burned at complete rest'
                  ),
                  _buildNutrientRow(
                    'Total Daily Energy Expenditure (TDEE):',
                    '${tdee.round()} kcal',
                    'Total calories burned per day'
                  ),
                  _buildNutrientRow(
                    'Protein:',
                    '${macros['protein']?.round()}g (${(macros['protein']! / weight!).toStringAsFixed(1)}g/kg)',
                    'Based on activity level'
                  ),
                  _buildNutrientRow(
                    'Carbohydrates:',
                    '${macros['carbs']?.round()}g',
                    'Includes 25-30g fiber'
                  ),
                  _buildNutrientRow(
                    'Fats:',
                    '${macros['fats']?.round()}g',
                    '25% of total calories'
                  ),
                  _buildNutrientRow(
                    'Water:',
                    '$water L',
                    'Daily recommended intake'
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Card(
          elevation: 4,
          shadowColor: Colors.black26,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF00b09b), Color(0xFF96c93d)],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Micronutrients for ${isMale ? 'Men' : 'Women'}',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildNutrientRow(
                    'Vitamin A:',
                    isMale ? '900 µg RAE' : '700 µg RAE',
                    'Essential for vision and immune function'
                  ),
                  _buildNutrientRow(
                    'Vitamin C:',
                    isMale ? '90 mg' : '75 mg',
                    'Supports immune system'
                  ),
                  _buildNutrientRow(
                    'Vitamin D:',
                    '15-20 µg (600-800 IU)',
                    'Bone health and immunity'
                  ),
                  _buildNutrientRow(
                    'Iron:',
                    isMale ? '8 mg' : '18 mg',
                    'Oxygen transport'
                  ),
                  _buildNutrientRow(
                    'Calcium:',
                    '1,000-1,200 mg',
                    'Bone and teeth health'
                  ),
                  _buildNutrientRow(
                    'Zinc:',
                    isMale ? '11 mg' : '8 mg',
                    'Immune function and wound healing'
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNutrientRow(String label, String value, String description) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00b09b),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
