import 'package:flutter/material.dart';
import '../services/api_service.dart';

class WaterAlarmPage extends StatefulWidget {
  const WaterAlarmPage({super.key});

  @override
  State<WaterAlarmPage> createState() => _WaterAlarmPageState();
}

class _WaterAlarmPageState extends State<WaterAlarmPage> {
  List<dynamic> _waterEntries = [];
  int _goalGlasses = 8;
  bool _isLoading = true;
  bool _isSaving = false;
  Map<String, dynamic>? _nextReminder;
  Map<String, dynamic>? _schedule;

  @override
  void initState() {
    super.initState();
    _loadWaterEntries();
    _loadPredictions();
  }
  
  Future<void> _loadPredictions() async {
    try {
      final [prediction, schedule] = await Future.wait([
        ApiService.getWaterPrediction(),
        ApiService.getWaterSchedule(),
      ]);
      if (mounted) {
        setState(() {
          _nextReminder = prediction['prediction'];
          _schedule = schedule['schedule'];
          if (_nextReminder?['glassesRemaining'] != null) {
            _goalGlasses = (_nextReminder!['glassesRemaining'] as int) + _glassesConsumed;
          }
        });
      }
    } catch (e) {
      // Silently fail - predictions are optional
    }
  }

  Future<void> _loadWaterEntries() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final entries = await ApiService.getWaterEntries();
      if (mounted) {
        setState(() {
          _waterEntries = entries;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load water entries: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _drinkWater() async {
    setState(() {
      _isSaving = true;
    });

    try {
      await ApiService.createWaterEntry(1);
      await _loadWaterEntries();
      await _loadPredictions(); // Reload predictions after logging
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('💧 Great! Keep hydrating!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to log water: ${e.toString()}')),
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

  Future<void> _deleteWaterEntry(int id) async {
    try {
      await ApiService.deleteWaterEntry(id);
      await _loadWaterEntries();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Water entry deleted')),
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

  int get _glassesConsumed {
    return _waterEntries.fold(0, (sum, entry) => sum + (entry['glasses'] as int? ?? 0));
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
            icon: const Icon(Icons.schedule),
            tooltip: 'View Schedule',
            onPressed: () {
              if (_schedule != null) {
                _showScheduleDialog();
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _loadWaterEntries();
              _loadPredictions();
            },
          ),
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
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
                
                // ML Prediction Card
                if (_nextReminder != null) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Card(
                      color: Colors.blue.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            const Icon(Icons.auto_awesome, color: Colors.blue),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'AI Reminder Prediction',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                  ),
                                  Text(
                                    _nextReminder!['reason'] ?? 
                                    'Next reminder in ${_nextReminder!['nextReminderMinutes']} minutes',
                                    style: const TextStyle(fontSize: 11),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton.icon(
                      onPressed: _isSaving ? null : _drinkWater,
                      icon: _isSaving
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.water_drop, size: 28),
                      label: Text(
                        _isSaving ? 'Saving...' : 'Drink 1 Glass of Water',
                        style: const TextStyle(fontSize: 18),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: _waterEntries.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.water_drop, size: 64, color: Colors.grey),
                              SizedBox(height: 16),
                              Text(
                                'No water logged today.\nDrink your first glass!',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 16, color: Colors.grey),
                              ),
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
                              child: RefreshIndicator(
                                onRefresh: _loadWaterEntries,
                                child: ListView.builder(
                                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                  itemCount: _waterEntries.length,
                                  itemBuilder: (context, index) {
                                    final entry = _waterEntries[index];
                                    final date = DateTime.parse(entry['created_at']);
                                    return Card(
                                      margin: const EdgeInsets.only(bottom: 8),
                                      child: ListTile(
                                        leading: CircleAvatar(
                                          backgroundColor: Colors.blue.shade100,
                                          child: const Icon(Icons.water_drop, color: Colors.blue),
                                        ),
                                        title: Text('${entry['glasses']} glass${entry['glasses'] > 1 ? 'es' : ''} of water'),
                                        trailing: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              '${date.hour}:${date.minute.toString().padLeft(2, '0')}',
                                              style: const TextStyle(color: Colors.grey),
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.delete, color: Colors.red),
                                              onPressed: () => _deleteWaterEntry(entry['id']),
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
                ),
              ],
            ),
    );
  }
  
  void _showScheduleDialog() {
    if (_schedule == null || (_schedule!['schedule'] as List).isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No schedule available. Set up your profile first.')),
      );
      return;
    }
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.schedule, color: Colors.blue),
            SizedBox(width: 8),
            Text('Daily Hydration Schedule'),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: (_schedule!['schedule'] as List).length,
            itemBuilder: (context, index) {
              final reminder = (_schedule!['schedule'] as List)[index];
              return ListTile(
                dense: true,
                leading: const Icon(Icons.access_time, size: 20),
                title: Text(reminder['time'] ?? ''),
                subtitle: Text(reminder['message'] ?? ''),
              );
            },
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
}

