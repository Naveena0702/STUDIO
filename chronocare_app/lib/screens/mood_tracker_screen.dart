import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';

class MoodTrackerScreen extends StatefulWidget {
  const MoodTrackerScreen({super.key});

  @override
  State<MoodTrackerScreen> createState() => _MoodTrackerScreenState();
}

class _MoodTrackerScreenState extends State<MoodTrackerScreen> {
  final TextEditingController _textController = TextEditingController();
  List<dynamic> _moodHistory = [];
  Map<String, dynamic>? _analytics;
  Map<String, dynamic>? _latestAnalysis;
  bool _isLoading = true;
  bool _isAnalyzing = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final results = await Future.wait([
        ApiService.getMoodHistory(),
        ApiService.getMoodAnalytics(),
      ]);

      if (mounted) {
        setState(() {
          _moodHistory = results[0] as List<dynamic>;
          _analytics = results[1] as Map<String, dynamic>;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load data: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _analyzeMood() async {
    if (_textController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter some text to analyze')),
      );
      return;
    }

    setState(() {
      _isAnalyzing = true;
    });

    try {
      final result = await ApiService.analyzeMood(_textController.text.trim(), null);
      await _loadData();

      if (mounted) {
        setState(() {
          _latestAnalysis = result['analysis'];
          _isAnalyzing = false;
        });
        _textController.clear();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Mood analyzed: ${result['analysis']['mood']}')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to analyze: ${e.toString()}')),
        );
      }
    }
  }

  String _getMoodEmoji(String mood) {
    switch (mood) {
      case 'happy':
        return '😀';
      case 'sad':
        return '😔';
      case 'anxious':
        return '😟';
      case 'angry':
        return '😡';
      case 'calm':
        return '😌';
      default:
        return '😐';
    }
  }

  Color _getMoodColor(String mood) {
    switch (mood) {
      case 'happy':
        return Colors.green;
      case 'sad':
        return Colors.blue;
      case 'anxious':
        return Colors.orange;
      case 'angry':
        return Colors.red;
      case 'calm':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Mood Tracker'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Analysis Input
                  Card(
                    color: Colors.purple.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'How are you feeling?',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _textController,
                            maxLines: 3,
                            decoration: const InputDecoration(
                              hintText: 'Describe your current mood or feelings...',
                              border: OutlineInputBorder(),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _isAnalyzing ? null : _analyzeMood,
                              icon: _isAnalyzing
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : const Icon(Icons.psychology),
                              label: Text(_isAnalyzing ? 'Analyzing...' : 'Analyze Mood'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.purple,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Latest Analysis Result
                  if (_latestAnalysis != null) ...[
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  _getMoodEmoji(_latestAnalysis!['mood']),
                                  style: const TextStyle(fontSize: 32),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _latestAnalysis!['mood'].toString().toUpperCase(),
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: _getMoodColor(_latestAnalysis!['mood']),
                                        ),
                                      ),
                                      Text(
                                        'Confidence: ${((_latestAnalysis!['confidence'] ?? 0) * 100).toStringAsFixed(0)}%',
                                        style: const TextStyle(fontSize: 14, color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],

                  // Analytics Summary
                  if (_analytics != null) ...[
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Mood Analytics (Last 7 Days)',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Column(
                                  children: [
                                    Text(
                                      '${_analytics!['total_entries'] ?? 0}',
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const Text('Total Entries', style: TextStyle(fontSize: 12)),
                                  ],
                                ),
                                Column(
                                  children: [
                                    Text(
                                      _getMoodEmoji(_analytics!['dominant_mood'] ?? 'neutral'),
                                      style: const TextStyle(fontSize: 24),
                                    ),
                                    Text(
                                      _analytics!['dominant_mood']?.toString().toUpperCase() ?? 'NEUTRAL',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                                Column(
                                  children: [
                                    Text(
                                      '${((_analytics!['average_confidence'] ?? 0) * 100).toStringAsFixed(0)}%',
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const Text('Avg Confidence', style: TextStyle(fontSize: 12)),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            if (_analytics!['mood_distribution'] != null)
                              _buildMoodDistributionChart(_analytics!['mood_distribution']),
                          ],
                        ),
                      ),
                    ),
                  ],

                  // Mood History
                  const SizedBox(height: 16),
                  const Text(
                    'Mood History',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _moodHistory.isEmpty
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(32.0),
                            child: Text(
                              'No mood entries yet. Start tracking your mood!',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _moodHistory.length,
                          itemBuilder: (context, index) {
                            final entry = _moodHistory[index];
                            final date = DateTime.parse(entry['created_at']);
                            final mood = entry['detected_mood'];

                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: _getMoodColor(mood).withOpacity(0.2),
                                  child: Text(
                                    _getMoodEmoji(mood),
                                    style: const TextStyle(fontSize: 24),
                                  ),
                                ),
                                title: Text(
                                  entry['text_input'] ?? '',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                subtitle: Text(
                                  DateFormat('MMM d, y • h:mm a').format(date),
                                  style: const TextStyle(fontSize: 12),
                                ),
                                trailing: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      mood.toUpperCase(),
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: _getMoodColor(mood),
                                        fontSize: 12,
                                      ),
                                    ),
                                    Text(
                                      '${((entry['confidence_score'] ?? 0) * 100).toStringAsFixed(0)}%',
                                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ],
              ),
            ),
    );
  }

  Widget _buildMoodDistributionChart(Map<String, dynamic> distribution) {
    final entries = distribution.entries.toList();
    final total = entries.fold<int>(0, (sum, e) => sum + (e.value as int));

    return Column(
      children: entries.map((entry) {
        final percentage = total > 0 ? (entry.value / total * 100) : 0.0;
        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Row(
            children: [
              SizedBox(
                width: 80,
                child: Text(
                  entry.key.toUpperCase(),
                  style: TextStyle(
                    fontSize: 12,
                    color: _getMoodColor(entry.key),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: LinearProgressIndicator(
                  value: percentage / 100,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(_getMoodColor(entry.key)),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${entry.value} (${percentage.toStringAsFixed(0)}%)',
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

