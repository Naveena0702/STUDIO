import 'package:flutter/material.dart';
void main() {
  runApp(const ChronoCareApp());
}

class ChronoCareApp extends StatelessWidget {
  const ChronoCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ChronoCare',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const ChronoCareHomePage(),
    );
  }
}

class ChronoCareHomePage extends StatelessWidget {
  const ChronoCareHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('ChronoCare'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.access_time,
              size: 80,
              color: Colors.blue,
            ),
            const SizedBox(height: 20),
            const Text(
              'Welcome to ChronoCare',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Your health management companion',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 40),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildFeatureCard(
                    context,
                    'AI Symptom Checker',
                    Icons.psychology,
                    Colors.purple,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AISymptomCheckerPage()),
                    ),
                  ),
                  _buildFeatureCard(
                    context,
                    'Journal',
                    Icons.book,
                    Colors.green,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const JournalPage()),
                    ),
                  ),
                  _buildFeatureCard(
                    context,
                    'Diet',
                    Icons.restaurant,
                    Colors.orange,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const DietPage()),
                    ),
                  ),
                  _buildFeatureCard(
                    context,
                    'Water Alarm',
                    Icons.water_drop,
                    Colors.blue,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const WaterAlarmPage()),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 48,
                color: color,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// AI Symptom Checker Page
class AISymptomCheckerPage extends StatefulWidget {
  const AISymptomCheckerPage({super.key});

  @override
  State<AISymptomCheckerPage> createState() => _AISymptomCheckerPageState();
}

class _AISymptomCheckerPageState extends State<AISymptomCheckerPage> {
  final TextEditingController _symptomController = TextEditingController();
  final List<String> _selectedSymptoms = [];
  String _analysisResult = '';

  final List<String> _commonSymptoms = [
    'Headache', 'Fever', 'Cough', 'Fatigue', 'Nausea',
    'Dizziness', 'Chest Pain', 'Shortness of Breath',
    'Stomach Pain', 'Joint Pain', 'Skin Rash', 'Sleep Issues'
  ];

  void _analyzeSymptoms() {
    if (_selectedSymptoms.isEmpty && _symptomController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please describe your symptoms')),
      );
      return;
    }

    setState(() {
      _analysisResult = '''
🤖 AI Analysis Results:

Selected Symptoms: ${_selectedSymptoms.join(', ')}

Custom Description: ${_symptomController.text}

📊 Preliminary Assessment:
Based on your symptoms, I recommend:

1. Monitor your symptoms closely
2. Stay hydrated and rest well
3. Consider over-the-counter pain relief if needed
4. Contact a healthcare professional if symptoms worsen

⚠️ Important: This is not a medical diagnosis. 
Please consult with a healthcare provider for proper medical advice.
      ''';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        title: const Text('AI Symptom Checker'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              color: Colors.purple.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Icon(Icons.psychology, size: 48, color: Colors.purple),
                    const SizedBox(height: 8),
                    const Text(
                      'AI Symptom Checker',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const Text('Describe your symptoms for AI analysis'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            const Text('Select Common Symptoms:', 
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _commonSymptoms.map((symptom) {
                bool isSelected = _selectedSymptoms.contains(symptom);
                return FilterChip(
                  label: Text(symptom),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedSymptoms.add(symptom);
                      } else {
                        _selectedSymptoms.remove(symptom);
                      }
                    });
                  },
                  selectedColor: Colors.purple.shade200,
                );
              }).toList(),
            ),
            
            const SizedBox(height: 20),
            const Text('Or Describe Your Symptoms:', 
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            
            TextField(
              controller: _symptomController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Describe your symptoms in detail...',
                border: OutlineInputBorder(),
              ),
            ),
            
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _analyzeSymptoms,
                icon: const Icon(Icons.analytics),
                label: const Text('Analyze Symptoms'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            
            if (_analysisResult.isNotEmpty) ...[
              const SizedBox(height: 20),
              Card(
                color: Colors.green.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    _analysisResult,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Journal Page
class JournalPage extends StatefulWidget {
  const JournalPage({super.key});

  @override
  State<JournalPage> createState() => _JournalPageState();
}

class _JournalPageState extends State<JournalPage> {
  final TextEditingController _journalController = TextEditingController();
  final List<JournalEntry> _entries = [];
  int _selectedMood = 3; // Default to neutral mood (1-5 scale)
  int _selectedEnergy = 3; // Default to medium energy (1-5 scale)

  void _addEntry() {
    if (_journalController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please write something in your journal')),
      );
      return;
    }

    setState(() {
      _entries.insert(0, JournalEntry(
        content: _journalController.text.trim(),
        mood: _selectedMood,
        energy: _selectedEnergy,
        date: DateTime.now(),
      ));
      _journalController.clear();
      _selectedMood = 3;
      _selectedEnergy = 3;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Journal entry added!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        title: const Text('Health Journal'),
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics),
            onPressed: () {
              // Show mood/energy analytics
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Journal Analytics'),
                  content: Text(
                    'Total Entries: ${_entries.length}\n'
                    'Average Mood: ${_entries.isEmpty ? "N/A" : (_entries.map((e) => e.mood).reduce((a, b) => a + b) / _entries.length).toStringAsFixed(1)}\n'
                    'Average Energy: ${_entries.isEmpty ? "N/A" : (_entries.map((e) => e.energy).reduce((a, b) => a + b) / _entries.length).toStringAsFixed(1)}',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // New Entry Section
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Colors.green.shade50,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('How are you feeling today?', 
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Mood:'),
                          Row(
                            children: List.generate(5, (index) {
                              IconData moodIcon;
                              switch (index) {
                                case 0:
                                  moodIcon = Icons.sentiment_very_dissatisfied;
                                  break;
                                case 1:
                                  moodIcon = Icons.sentiment_dissatisfied;
                                  break;
                                case 2:
                                  moodIcon = Icons.sentiment_neutral;
                                  break;
                                case 3:
                                  moodIcon = Icons.sentiment_satisfied;
                                  break;
                                case 4:
                                  moodIcon = Icons.sentiment_very_satisfied;
                                  break;
                                default:
                                  moodIcon = Icons.sentiment_neutral;
                              }
                              return IconButton(
                                onPressed: () => setState(() => _selectedMood = index + 1),
                                icon: Icon(
                                  moodIcon,
                                  color: _selectedMood > index ? Colors.red : Colors.grey,
                                ),
                              );
                            }),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Energy:'),
                          Row(
                            children: List.generate(5, (index) {
                              IconData energyIcon;
                              switch (index) {
                                case 0:
                                  energyIcon = Icons.battery_0_bar;
                                  break;
                                case 1:
                                  energyIcon = Icons.battery_1_bar;
                                  break;
                                case 2:
                                  energyIcon = Icons.battery_2_bar;
                                  break;
                                case 3:
                                  energyIcon = Icons.battery_3_bar;
                                  break;
                                case 4:
                                  energyIcon = Icons.battery_full;
                                  break;
                                default:
                                  energyIcon = Icons.battery_2_bar;
                              }
                              return IconButton(
                                onPressed: () => setState(() => _selectedEnergy = index + 1),
                                icon: Icon(
                                  energyIcon,
                                  color: _selectedEnergy > index ? Colors.green : Colors.grey,
                                ),
                              );
                            }),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                TextField(
                  controller: _journalController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'Write about your day, symptoms, or thoughts...',
                    border: OutlineInputBorder(),
                  ),
                ),
                
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _addEntry,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Entry'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Entries List
          Expanded(
            child: _entries.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.book, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('No journal entries yet.\nStart writing your first entry!',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16, color: Colors.grey)),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: _entries.length,
                    itemBuilder: (context, index) {
                      final entry = _entries[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${entry.date.day}/${entry.date.month}/${entry.date.year}',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Row(
                                    children: [
                                      Icon(
                                        _getMoodIcon(entry.mood),
                                        color: Colors.red,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Icon(
                                        _getEnergyIcon(entry.energy),
                                        color: Colors.green,
                                        size: 20,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(entry.content),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  IconData _getMoodIcon(int mood) {
    switch (mood) {
      case 1:
        return Icons.sentiment_very_dissatisfied;
      case 2:
        return Icons.sentiment_dissatisfied;
      case 3:
        return Icons.sentiment_neutral;
      case 4:
        return Icons.sentiment_satisfied;
      case 5:
        return Icons.sentiment_very_satisfied;
      default:
        return Icons.sentiment_neutral;
    }
  }

  IconData _getEnergyIcon(int energy) {
    switch (energy) {
      case 1:
        return Icons.battery_0_bar;
      case 2:
        return Icons.battery_1_bar;
      case 3:
        return Icons.battery_2_bar;
      case 4:
        return Icons.battery_3_bar;
      case 5:
        return Icons.battery_full;
      default:
        return Icons.battery_2_bar;
    }
  }
}

class JournalEntry {
  final String content;
  final int mood;
  final int energy;
  final DateTime date;

  JournalEntry({
    required this.content,
    required this.mood,
    required this.energy,
    required this.date,
  });
}

// Diet Page
class DietPage extends StatefulWidget {
  const DietPage({super.key});

  @override
  State<DietPage> createState() => _DietPageState();
}

class _DietPageState extends State<DietPage> {
  final List<MealEntry> _meals = [];
  final TextEditingController _foodController = TextEditingController();
  final TextEditingController _caloriesController = TextEditingController();
  String _selectedMealType = 'Breakfast';
  
  final List<String> _mealTypes = ['Breakfast', 'Lunch', 'Dinner', 'Snack'];

  void _addMeal() {
    if (_foodController.text.trim().isEmpty || _caloriesController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in both food and calories')),
      );
      return;
    }

    setState(() {
      _meals.add(MealEntry(
        food: _foodController.text.trim(),
        calories: int.tryParse(_caloriesController.text.trim()) ?? 0,
        mealType: _selectedMealType,
        time: DateTime.now(),
      ));
      _foodController.clear();
      _caloriesController.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Meal added!')),
    );
  }

  int get _totalCalories {
    return _meals.fold(0, (sum, meal) => sum + meal.calories);
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
            icon: const Icon(Icons.analytics),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Nutrition Summary'),
                  content: Text(
                    'Total Meals: ${_meals.length}\n'
                    'Total Calories: $_totalCalories\n'
                    'Average per Meal: ${_meals.isEmpty ? "0" : (_totalCalories / _meals.length).toStringAsFixed(0)}',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Daily Summary
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
          
          // Add Meal Section
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
                    return DropdownMenuItem(
                      value: type,
                      child: Text(type),
                    );
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
                    onPressed: _addMeal,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Meal'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Meals List
          Expanded(
            child: _meals.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.restaurant, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('No meals recorded yet.\nAdd your first meal!',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16, color: Colors.grey)),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: _meals.length,
                    itemBuilder: (context, index) {
                      final meal = _meals[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.orange.shade100,
                            child: Icon(
                              _getMealIcon(meal.mealType),
                              color: Colors.orange,
                            ),
                          ),
                          title: Text(meal.food),
                          subtitle: Text('${meal.mealType} • ${meal.calories} calories'),
                          trailing: Text(
                            '${meal.time.hour}:${meal.time.minute.toString().padLeft(2, '0')}',
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ),
                      );
                    },
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

class MealEntry {
  final String food;
  final int calories;
  final String mealType;
  final DateTime time;

  MealEntry({
    required this.food,
    required this.calories,
    required this.mealType,
    required this.time,
  });
}

// Water Alarm Page
class WaterAlarmPage extends StatefulWidget {
  const WaterAlarmPage({super.key});

  @override
  State<WaterAlarmPage> createState() => _WaterAlarmPageState();
}

class _WaterAlarmPageState extends State<WaterAlarmPage> {
  int _glassesConsumed = 0;
  int _reminderInterval = 60; // minutes
  bool _isReminderActive = false;
  final List<WaterEntry> _waterEntries = [];
  int _goalGlasses = 8;

  void _drinkWater() {
    setState(() {
      _glassesConsumed++;
      _waterEntries.add(WaterEntry(
        glasses: 1,
        time: DateTime.now(),
      ));
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('💧 Great! Keep hydrating!')),
    );
  }

  void _toggleReminder() {
    setState(() {
      _isReminderActive = !_isReminderActive;
    });

    if (_isReminderActive) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Water reminders activated every $_reminderInterval minutes')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Water reminders deactivated')),
      );
    }
  }

  double get _hydrationProgress {
    return (_glassesConsumed / _goalGlasses).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        title: const Text('Water Reminder'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Settings'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Reminder Interval: $_reminderInterval minutes'),
                      Slider(
                        value: _reminderInterval.toDouble(),
                        min: 15,
                        max: 180,
                        divisions: 11,
                        label: '$_reminderInterval minutes',
                        onChanged: (value) {
                          setState(() {
                            _reminderInterval = value.round();
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      Text('Daily Goal: $_goalGlasses glasses'),
                      Slider(
                        value: _goalGlasses.toDouble(),
                        min: 4,
                        max: 16,
                        divisions: 12,
                        label: '$_goalGlasses glasses',
                        onChanged: (value) {
                          setState(() {
                            _goalGlasses = value.round();
                          });
                        },
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Done'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Hydration Progress
          Container(
            padding: const EdgeInsets.all(24.0),
            color: Colors.blue.shade50,
            child: Column(
              children: [
                const Text(
                  'Today\'s Hydration',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                
                // Circular Progress Indicator
                SizedBox(
                  width: 120,
                  height: 120,
                  child: Stack(
                    children: [
                      CircularProgressIndicator(
                        value: _hydrationProgress,
                        strokeWidth: 12,
                        backgroundColor: Colors.blue.shade100,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _hydrationProgress >= 1.0 ? Colors.green : Colors.blue,
                        ),
                      ),
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '$_glassesConsumed',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '/$_goalGlasses',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                Text(
                  _hydrationProgress >= 1.0 
                    ? '🎉 Goal achieved!'
                    : '${(_goalGlasses - _glassesConsumed)} more glasses to go!',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _hydrationProgress >= 1.0 ? Colors.green : Colors.blue,
                  ),
                ),
              ],
            ),
          ),
          
          // Drink Water Button
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton.icon(
                    onPressed: _drinkWater,
                    icon: const Icon(Icons.water_drop, size: 28),
                    label: const Text('Drink 1 Glass of Water', 
                      style: TextStyle(fontSize: 18)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Reminder Toggle
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Water Reminders', 
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            Switch(
                              value: _isReminderActive,
                              onChanged: (_) => _toggleReminder(),
                              activeColor: Colors.blue,
                            ),
                          ],
                        ),
                        if (_isReminderActive) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Reminding every $_reminderInterval minutes',
                            style: TextStyle(color: Colors.green.shade700),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Water History
          Expanded(
            child: _waterEntries.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.water_drop, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('No water logged today.\nDrink your first glass!',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16, color: Colors.grey)),
                      ],
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          'Today\'s Water Intake',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          itemCount: _waterEntries.length,
                          itemBuilder: (context, index) {
                            final entry = _waterEntries[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.blue.shade100,
                                  child: const Icon(Icons.water_drop, color: Colors.blue),
                                ),
                                title: Text('${entry.glasses} glass${entry.glasses > 1 ? 'es' : ''} of water'),
                                trailing: Text(
                                  '${entry.time.hour}:${entry.time.minute.toString().padLeft(2, '0')}',
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class WaterEntry {
  final int glasses;
  final DateTime time;

  WaterEntry({
    required this.glasses,
    required this.time,
  });
}
