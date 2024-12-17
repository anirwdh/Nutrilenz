import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../widgets/custom_search_bar.dart';
import '../widgets/voice_search_button.dart';
import '../widgets/animated_background.dart';
import '../widgets/food_card.dart';
import '../screens/nutrition_info_screen.dart';
import '../providers/food_provider.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  String _recognizedText = '';
  String _searchText = '';
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  String _selectedUnit = 'g';
  List<String> _quantities = [];
  String _selectedQuantity = '100';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..forward();

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 1.0, curve: Curves.easeIn),
      ),
    );

    _updateQuantitiesByUnit(_selectedUnit);
    _selectedQuantity = _quantities.first;
    _quantityController.text = _selectedQuantity;
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateFoodSearch();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _searchController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    setState(() {
      _searchText = value;
      _updateFoodSearch();
    });
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchText = '';
      _updateFoodSearch();
    });
  }

  void _onQuantityChanged(String value) {
    setState(() {
      _selectedQuantity = value;
      _quantityController.text = value;
      _updateFoodSearch();
    });
  }

  void _updateFoodSearch() {
    final foodProvider = Provider.of<FoodProvider>(context, listen: false);
    setState(() => _isLoading = true);
    
    final double quantity = double.tryParse(_selectedQuantity) ?? 0;
    if (quantity <= 0) return;
    
    foodProvider.searchFood('${quantity.toString()} $_selectedUnit $_searchText')
      .then((_) => setState(() => _isLoading = false))
      .catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${error.toString()}')),
        );
        setState(() => _isLoading = false);
      });
  }

  void _onUnitChanged(String? newValue) {
    if (newValue != null) {
      setState(() {
        _selectedUnit = newValue;
        _updateQuantitiesByUnit(newValue);
        _selectedQuantity = _quantities.first;
        _quantityController.text = _selectedQuantity;
        _updateFoodSearch();
      });
    }
  }

  void _onSearchPressed() {
    if (_searchText.isEmpty) return;
    _updateFoodSearch();
  }

  void _updateQuantitiesByUnit(String unit) {
    setState(() {
      if (unit == 'piece') {
        _quantities = List.generate(20, (index) => '${index + 1}');
      } else {
        _quantities = ['50', '100', '150', '200', '250', '300', '450', '500', '750', '1000'];
      }
      
      if (!_quantities.contains(_selectedQuantity)) {
        _selectedQuantity = _quantities.first;
        _quantityController.text = _selectedQuantity;
      }
    });
  }

  Future<void> _captureImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      // TODO: Implement image processing and food recognition
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Image captured. Processing not yet implemented.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                children: [
                  _buildHeader(),
                  const SizedBox(height: 20),
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 30),
                        padding: const EdgeInsets.fromLTRB(25, 35, 25, 25),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.95),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 40,
                              offset: const Offset(0, 20),
                              spreadRadius: -5,
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Column(
                              children: [
                                Image.asset(
                                  'assets/images/nutrilenz_logo.png',
                                  width: 180,
                                  height: 180,
                                  fit: BoxFit.contain,
                                ),
                                const SizedBox(height: 15),
                                Text(
                                  'Scan, Search, Speak – Simplify Nutrition with NutriLenz.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF2E7D32),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            _buildSearchSection(),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      VoiceSearchButton(
                        onSearchComplete: (text) {
                          setState(() {
                            _recognizedText = text;
                            _searchController.text = text;
                            _searchText = text;
                            _updateFoodSearch();
                          });
                        },
                      ),
                      ElevatedButton.icon(
                        onPressed: _captureImage,
                        icon: const Icon(Icons.camera_alt),
                        label: const Text('Snap'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E7D32),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildSearchResults(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(width: 40), // Placeholder for balance
          Text(
            'Home',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NutritionInfoScreen()),
              );
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.info_outline,
                color: Color(0xFFE94057),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchSection() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextField(
                  controller: _quantityController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Quantity',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _selectedQuantity = value;
                      _updateFoodSearch();
                    });
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: DropdownButtonFormField<String>(
                  value: _selectedUnit,
                  decoration: InputDecoration(
                    labelText: 'Unit',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  items: ['g', 'ml', 'piece'].map((String unit) {
                    return DropdownMenuItem(
                      value: unit,
                      child: Text(unit),
                    );
                  }).toList(),
                  onChanged: _onUnitChanged,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                flex: 4,
                child: CustomSearchBar(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  onClear: _clearSearch,
                  hintText: 'Enter food name',
                ),
              ),
              const SizedBox(width: 10),
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: _onSearchPressed,
                color: const Color(0xFFE94057),
              ),
            ],
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _quantities.map((quantity) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: Text(quantity),
                    selected: _selectedQuantity == quantity,
                    onSelected: (selected) {
                      if (selected) {
                        _onQuantityChanged(quantity);
                      }
                    },
                    selectedColor: const Color(0xFFE94057),
                    labelStyle: TextStyle(
                      color: _selectedQuantity == quantity ? Colors.white : Colors.black,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    return Consumer<FoodProvider>(
      builder: (context, foodProvider, child) {
        if (_isLoading) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFFE94057)));
        }
        
        final foods = foodProvider.foods;
        if (foods.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search_off, 
                  size: 64, 
                  color: Colors.white.withOpacity(0.7)
                ),
                const SizedBox(height: 16),
                Text(
                  'No foods found. Try a different search.',
                  style: TextStyle(
                    fontSize: 16, 
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w500
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: foods.length,
          itemBuilder: (context, index) {
            final food = foods[index];
            return FoodCard(food: food);
          },
        );
      },
    );
  }
}

