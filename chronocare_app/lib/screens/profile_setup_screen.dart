import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/api_service.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _ageController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  
  String _selectedGender = 'male';
  String _selectedActivityLevel = 'moderately_active';
  String _selectedHealthGoal = 'maintenance';
  
  bool _isLoading = false;
  bool _hasProfile = false;
  Map<String, dynamic>? _profile;

  final List<String> _genders = ['male', 'female', 'other'];
  final Map<String, String> _activityLevels = {
    'sedentary': 'Sedentary (little or no exercise)',
    'lightly_active': 'Lightly Active (exercise 1-3 days/week)',
    'moderately_active': 'Moderately Active (exercise 3-5 days/week)',
    'very_active': 'Very Active (exercise 6-7 days/week)',
    'extra_active': 'Extra Active (very hard exercise, physical job)',
  };
  final Map<String, String> _healthGoals = {
    'weight_loss': 'Weight Loss',
    'maintenance': 'Maintenance',
    'muscle_gain': 'Muscle Gain',
  };

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _ageController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await ApiService.getProfile();
      if (mounted && profile != null) {
        setState(() {
          _profile = profile;
          _hasProfile = true;
          _ageController.text = (profile['age'] ?? '').toString();
          _weightController.text = (profile['weight'] ?? '').toString();
          _heightController.text = (profile['height'] ?? '').toString();
          _selectedGender = profile['gender'] ?? 'male';
          _selectedActivityLevel = profile['activity_level'] ?? 'moderately_active';
          _selectedHealthGoal = profile['health_goals'] ?? 'maintenance';
        });
      }
    } catch (e) {
      // Profile doesn't exist yet, that's okay
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await ApiService.updateProfile(
        age: int.parse(_ageController.text),
        weight: double.parse(_weightController.text),
        height: double.parse(_heightController.text),
        gender: _selectedGender,
        activityLevel: _selectedActivityLevel,
        healthGoals: _selectedHealthGoal,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_hasProfile ? 'Profile updated!' : 'Profile created!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_hasProfile ? 'Edit Profile' : 'Setup Profile'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: Colors.blue),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _hasProfile
                              ? 'Update your profile to get personalized health recommendations.'
                              : 'Complete your profile to unlock AI-powered health insights and personalized recommendations.',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Age
              TextFormField(
                controller: _ageController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: 'Age',
                  prefixIcon: Icon(Icons.cake),
                  border: OutlineInputBorder(),
                  helperText: 'Enter your age in years',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your age';
                  }
                  final age = int.tryParse(value);
                  if (age == null || age < 1 || age > 120) {
                    return 'Please enter a valid age';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Weight
              TextFormField(
                controller: _weightController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Weight (kg)',
                  prefixIcon: Icon(Icons.monitor_weight),
                  border: OutlineInputBorder(),
                  helperText: 'Enter your weight in kilograms',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your weight';
                  }
                  final weight = double.tryParse(value);
                  if (weight == null || weight < 20 || weight > 300) {
                    return 'Please enter a valid weight';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Height
              TextFormField(
                controller: _heightController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Height (cm)',
                  prefixIcon: Icon(Icons.height),
                  border: OutlineInputBorder(),
                  helperText: 'Enter your height in centimeters',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your height';
                  }
                  final height = double.tryParse(value);
                  if (height == null || height < 50 || height > 250) {
                    return 'Please enter a valid height';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Gender
              DropdownButtonFormField<String>(
                value: _selectedGender,
                decoration: const InputDecoration(
                  labelText: 'Gender',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                items: _genders.map((gender) {
                  return DropdownMenuItem(
                    value: gender,
                    child: Text(gender.substring(0, 1).toUpperCase() + gender.substring(1)),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _selectedGender = value!),
              ),
              const SizedBox(height: 16),

              // Activity Level
              DropdownButtonFormField<String>(
                value: _selectedActivityLevel,
                decoration: const InputDecoration(
                  labelText: 'Activity Level',
                  prefixIcon: Icon(Icons.fitness_center),
                  border: OutlineInputBorder(),
                ),
                items: _activityLevels.entries.map((entry) {
                  return DropdownMenuItem(
                    value: entry.key,
                    child: Text(entry.value),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _selectedActivityLevel = value!),
              ),
              const SizedBox(height: 16),

              // Health Goals
              DropdownButtonFormField<String>(
                value: _selectedHealthGoal,
                decoration: const InputDecoration(
                  labelText: 'Health Goal',
                  prefixIcon: Icon(Icons.flag),
                  border: OutlineInputBorder(),
                ),
                items: _healthGoals.entries.map((entry) {
                  return DropdownMenuItem(
                    value: entry.key,
                    child: Text(entry.value),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _selectedHealthGoal = value!),
              ),
              const SizedBox(height: 32),

              // Calculate BMI Info
              if (_weightController.text.isNotEmpty && _heightController.text.isNotEmpty) ...[
                _buildBMIInfo(),
                const SizedBox(height: 16),
              ],

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _saveProfile,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save),
                  label: Text(_isLoading ? 'Saving...' : (_hasProfile ? 'Update Profile' : 'Create Profile')),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBMIInfo() {
    try {
      final weight = double.parse(_weightController.text);
      final height = double.parse(_heightController.text) / 100; // Convert cm to m
      final bmi = weight / (height * height);
      
      String category;
      Color color;
      if (bmi < 18.5) {
        category = 'Underweight';
        color = Colors.blue;
      } else if (bmi < 25) {
        category = 'Normal';
        color = Colors.green;
      } else if (bmi < 30) {
        category = 'Overweight';
        color = Colors.orange;
      } else {
        category = 'Obese';
        color = Colors.red;
      }

      return Card(
        color: color.withOpacity(0.1),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  const Text('BMI', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  Text(
                    bmi.toStringAsFixed(1),
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color),
                  ),
                ],
              ),
              Column(
                children: [
                  const Text('Category', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  Text(
                    category,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      return const SizedBox.shrink();
    }
  }
}

