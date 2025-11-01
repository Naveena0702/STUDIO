import 'package:flutter/material.dart';
import '../services/api_service.dart';

class DietPage extends StatefulWidget {
  const DietPage({super.key});

  @override
  State<DietPage> createState() => _DietPageState();
}

class _DietPageState extends State<DietPage> {
  List<dynamic> _meals = [];
  final TextEditingController _foodController = TextEditingController();
  final TextEditingController _caloriesController = TextEditingController();
  String _selectedMealType = 'Breakfast';
  final List<String> _mealTypes = ['Breakfast', 'Lunch', 'Dinner', 'Snack'];
  bool _isLoading = true;
  bool _isSaving = false;
  Map<String, dynamic>? _aiRecommendations;
  bool _isLoadingRecommendations = false;

  @override
  void initState() {
    super.initState();
    _loadMeals();
  }

  @override
  void dispose() {
    _foodController.dispose();
    _caloriesController.dispose();
    super.dispose();
  }

  Future<void> _loadMeals() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final meals = await ApiService.getMealEntries();
      if (mounted) {
        setState(() {
          _meals = meals;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load meals: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _addMeal() async {
    if (_foodController.text.trim().isEmpty || _caloriesController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in both food and calories')),
      );
      return;
    }

    final calories = int.tryParse(_caloriesController.text.trim());
    if (calories == null || calories < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid calorie amount')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await ApiService.createMealEntry(
        _foodController.text.trim(),
        calories,
        _selectedMealType,
      );
      
      _foodController.clear();
      _caloriesController.clear();
      await _loadMeals();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Meal added!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add meal: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _deleteMeal(int id) async {
    try {
      await ApiService.deleteMealEntry(id);
      await _loadMeals();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Meal deleted')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete: ${e.toString()}')),
        );
      }
    }
  }

  int get _totalCalories {
    return _meals.fold(0, (sum, meal) => sum + (meal['calories'] as int? ?? 0));
  }

  Future<void> _loadRecommendations() async {
    setState(() {
      _isLoadingRecommendations = true;
    });

    try {
      final recommendations = await ApiService.getDietRecommendations();
      if (mounted) {
        setState(() {
          _aiRecommendations = recommendations;
          _isLoadingRecommendations = false;
        });
        
        _showRecommendationsDialog(recommendations);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingRecommendations = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to get recommendations: ${e.toString()}')),
        );
      }
    }
  }

  void _showRecommendationsDialog(Map<String, dynamic> recommendations) {
    final mealPlan = recommendations['meal_plan'] ?? {};
    final remaining = mealPlan['remaining_needs'] ?? {};
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.auto_awesome, color: Colors.orange),
            SizedBox(width: 8),
            Text('AI Meal Recommendations'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Daily Goal: ${mealPlan['daily_calories'] ?? 0} calories',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              if (mealPlan['meal_plan'] != null) ...[
                const Text('Suggested Meals:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ...(mealPlan['meal_plan'] as Map).entries.map((entry) {
                  if (entry.value != null) {
                    final meal = entry.value as Map;
                    return ListTile(
                      dense: true,
                      leading: const Icon(Icons.restaurant, size: 20),
                      title: Text(entry.key.toString().toUpperCase()),
                      subtitle: Text(
                        '${meal['name']} - ${meal['calories']} cal',
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                }),
              ],
              const SizedBox(height: 12),
              if (mealPlan['recommendations'] != null) ...[
                const Text('Tips:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ...(mealPlan['recommendations'] as List).map((tip) => Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• ', style: TextStyle(color: Colors.orange)),
                      Expanded(child: Text(tip)),
                    ],
                  ),
                )),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        title: const Text('Diet Tracker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.auto_awesome),
            tooltip: 'Get AI Recommendations',
            onPressed: _loadRecommendations,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadMeals,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16.0),
                  color: Colors.orange.shade50,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          const Text('Today\'s Meals', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text('${_meals.length}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Column(
                        children: [
                          const Text('Total Calories', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text('$_totalCalories', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Column(
                        children: [
                          const Text('Goal Progress', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text('${(_totalCalories / 2000 * 100).toStringAsFixed(0)}%',
                              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Add New Meal', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _selectedMealType,
                        decoration: const InputDecoration(
                          labelText: 'Meal Type',
                          border: OutlineInputBorder(),
                        ),
                        items: _mealTypes.map((type) {
                          return DropdownMenuItem(value: type, child: Text(type));
                        }).toList(),
                        onChanged: (value) => setState(() => _selectedMealType = value!),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _foodController,
                        decoration: const InputDecoration(
                          labelText: 'Food Item',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _caloriesController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Calories',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _isSaving ? null : _addMeal,
                          icon: _isSaving
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.add),
                          label: Text(_isSaving ? 'Saving...' : 'Add Meal'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _meals.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.restaurant, size: 64, color: Colors.grey),
                              SizedBox(height: 16),
                              Text(
                                'No meals recorded yet.\nAdd your first meal!',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 16, color: Colors.grey),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _loadMeals,
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16.0),
                            itemCount: _meals.length,
                            itemBuilder: (context, index) {
                              final meal = _meals[index];
                              final date = DateTime.parse(meal['created_at']);
                              return Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: Colors.orange.shade100,
                                    child: Icon(
                                      _getMealIcon(meal['meal_type']),
                                      color: Colors.orange,
                                    ),
                                  ),
                                  title: Text(meal['food']),
                                  subtitle: Text('${meal['meal_type']} • ${meal['calories']} calories'),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        '${date.hour}:${date.minute.toString().padLeft(2, '0')}',
                                        style: const TextStyle(color: Colors.grey),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.red),
                                        onPressed: () => _deleteMeal(meal['id']),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                ),
              ],
            ),
    );
  }

  IconData _getMealIcon(String mealType) {
    switch (mealType) {
      case 'Breakfast':
        return Icons.free_breakfast;
      case 'Lunch':
        return Icons.lunch_dining;
      case 'Dinner':
        return Icons.dinner_dining;
      case 'Snack':
        return Icons.cookie;
      default:
        return Icons.restaurant;
    }
  }
}

