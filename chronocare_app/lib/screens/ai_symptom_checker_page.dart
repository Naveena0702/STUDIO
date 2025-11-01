import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AISymptomCheckerPage extends StatefulWidget {
  const AISymptomCheckerPage({super.key});

  @override
  State<AISymptomCheckerPage> createState() => _AISymptomCheckerPageState();
}

class _AISymptomCheckerPageState extends State<AISymptomCheckerPage> {
  final TextEditingController _symptomController = TextEditingController();
  final List<String> _selectedSymptoms = [];
  List<dynamic> _analyses = [];
  bool _isLoading = true;
  bool _isAnalyzing = false;

  final List<String> _commonSymptoms = [
    'Headache',
    'Fever',
    'Cough',
    'Fatigue',
    'Nausea',
    'Dizziness',
    'Chest Pain',
    'Shortness of Breath',
    'Stomach Pain',
    'Joint Pain',
    'Skin Rash',
    'Sleep Issues'
  ];

  @override
  void initState() {
    super.initState();
    _loadAnalyses();
  }

  @override
  void dispose() {
    _symptomController.dispose();
    super.dispose();
  }

  Future<void> _loadAnalyses() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final analyses = await ApiService.getSymptomAnalyses();
      if (mounted) {
        setState(() {
          _analyses = analyses;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load analyses: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _analyzeSymptoms() async {
    if (_selectedSymptoms.isEmpty && _symptomController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please describe your symptoms')),
      );
      return;
    }

    setState(() {
      _isAnalyzing = true;
    });

    try {
      final result = await ApiService.createSymptomAnalysis(
        _selectedSymptoms.join(', '),
        _symptomController.text.trim().isEmpty ? null : _symptomController.text.trim(),
      );
      
      _symptomController.clear();
      _selectedSymptoms.clear();
      await _loadAnalyses();
      
      if (mounted) {
        // Show analysis result in dialog
        final analysis = result['analysis'];
        final analysisResult = analysis['analysis_result'];
        
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Row(
              children: [
                Icon(
                  analysis['triage_level'] == 'emergency' 
                    ? Icons.warning 
                    : Icons.info_outline,
                  color: analysis['triage_level'] == 'emergency' 
                    ? Colors.red 
                    : Colors.blue,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    analysis['predicted_condition']?.toString().replaceAll('_', ' ').toUpperCase() ?? 
                    'Analysis Complete',
                  ),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (analysis['severity_score'] != null) ...[
                    Text(
                      'Severity: ${((analysis['severity_score'] ?? 0) * 100).toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: analysis['severity_score'] > 0.7 ? Colors.red : Colors.orange,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  if (analysis['triage_level'] != null) ...[
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: analysis['triage_level'] == 'emergency' 
                          ? Colors.red.shade50 
                          : Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            analysis['triage_level'] == 'emergency' 
                              ? Icons.emergency 
                              : Icons.local_hospital,
                            color: analysis['triage_level'] == 'emergency' 
                              ? Colors.red 
                              : Colors.blue,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Recommendation: ${analysis['triage_level']?.toString().replaceAll('_', ' ').toUpperCase()}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  if (analysis['recommendation'] != null) ...[
                    const Text(
                      'Recommendation:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(analysis['recommendation']),
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
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to analyze symptoms: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
        });
      }
    }
  }

  Future<void> _deleteAnalysis(int id) async {
    try {
      await ApiService.deleteSymptomAnalysis(id);
      await _loadAnalyses();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Analysis deleted')),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        title: const Text('AI Symptom Checker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAnalyses,
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
                  const Text(
                    'Select Common Symptoms:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
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
                  const Text(
                    'Or Describe Your Symptoms:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
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
                      onPressed: _isAnalyzing ? null : _analyzeSymptoms,
                      icon: _isAnalyzing
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.analytics),
                      label: Text(_isAnalyzing ? 'Analyzing...' : 'Analyze Symptoms'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Previous Analyses',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  _analyses.isEmpty
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(32.0),
                            child: Text(
                              'No analyses yet. Submit your first symptom analysis!',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _analyses.length,
                          itemBuilder: (context, index) {
                            final analysis = _analyses[index];
                            final date = DateTime.parse(analysis['created_at']);
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: ExpansionTile(
                                title: Text(
                                  '${date.day}/${date.month}/${date.year}',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(
                                  analysis['selected_symptoms'] ?? 'Custom description',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _deleteAnalysis(analysis['id']),
                                ),
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        if (analysis['selected_symptoms'] != null) ...[
                                          const Text(
                                            'Selected Symptoms:',
                                            style: TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                          Text(analysis['selected_symptoms']),
                                          const SizedBox(height: 12),
                                        ],
                                        if (analysis['custom_description'] != null) ...[
                                          const Text(
                                            'Description:',
                                            style: TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                          Text(analysis['custom_description']),
                                          const SizedBox(height: 12),
                                        ],
                                        const Text(
                                          'Analysis Result:',
                                          style: TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(height: 8),
                                        Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: Colors.green.shade50,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            analysis['analysis_result'] ?? 'No analysis available',
                                            style: const TextStyle(fontSize: 14),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ],
              ),
            ),
    );
  }
}

