import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../services/api_service.dart';

class MedicalRecordsScreen extends StatefulWidget {
  const MedicalRecordsScreen({super.key});

  @override
  State<MedicalRecordsScreen> createState() => _MedicalRecordsScreenState();
}

class _MedicalRecordsScreenState extends State<MedicalRecordsScreen> {
  List<dynamic> _records = [];
  bool _isLoading = true;
  bool _isUploading = false;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  Future<void> _loadRecords() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final records = await ApiService.getMedicalRecords();
      if (mounted) {
        setState(() {
          _records = records;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load records: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _uploadFile(File file, String recordType) async {
    setState(() {
      _isUploading = true;
    });

    try {
      final token = await ApiService.getToken();
      if (token == null) {
        throw Exception('Not authenticated');
      }

      final uri = Uri.parse('${ApiService.baseUrl}/records');
      final request = http.MultipartRequest('POST', uri);
      request.headers['Authorization'] = 'Bearer $token';
      
      final fileName = file.path.split('/').last;
      final fileExtension = fileName.split('.').last.toLowerCase();
      
      String? contentType;
      if (['jpg', 'jpeg', 'png'].contains(fileExtension)) {
        contentType = 'image/$fileExtension';
      } else if (fileExtension == 'pdf') {
        contentType = 'application/pdf';
      }

      request.files.add(
        await http.MultipartFile.fromPath('file', file.path,
            contentType: contentType != null ? MediaType.parse(contentType) : null),
      );
      request.fields['record_type'] = recordType;

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 201) {
        await _loadRecords();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Record uploaded successfully!')),
          );
        }
      } else {
        throw Exception(jsonDecode(responseBody)['error'] ?? 'Upload failed');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        final recordType = await _showRecordTypeDialog();
        if (recordType != null) {
          await _uploadFile(File(image.path), recordType);
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick image: ${e.toString()}')),
      );
    }
  }

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'],
      );

      if (result != null && result.files.single.path != null) {
        final recordType = await _showRecordTypeDialog();
        if (recordType != null) {
          await _uploadFile(File(result.files.single.path!), recordType);
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick file: ${e.toString()}')),
      );
    }
  }

  Future<String?> _showRecordTypeDialog() async {
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Record Type'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Lab Report'),
              leading: const Icon(Icons.science),
              onTap: () => Navigator.pop(context, 'lab_report'),
            ),
            ListTile(
              title: const Text('Prescription'),
              leading: const Icon(Icons.medication),
              onTap: () => Navigator.pop(context, 'prescription'),
            ),
            ListTile(
              title: const Text('Scan Result'),
              leading: const Icon(Icons.assignment),
              onTap: () => Navigator.pop(context, 'scan_result'),
            ),
            ListTile(
              title: const Text('Other'),
              leading: const Icon(Icons.description),
              onTap: () => Navigator.pop(context, 'general'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteRecord(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Record'),
        content: const Text('Are you sure you want to delete this record?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await ApiService.deleteMedicalRecord(id);
        await _loadRecords();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Record deleted')),
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
  }

  IconData _getFileIcon(String? fileType) {
    if (fileType == null) return Icons.insert_drive_file;
    if (fileType.contains('image')) return Icons.image;
    if (fileType.contains('pdf')) return Icons.picture_as_pdf;
    return Icons.insert_drive_file;
  }

  Color _getRecordTypeColor(String? recordType) {
    switch (recordType) {
      case 'lab_report':
        return Colors.blue;
      case 'prescription':
        return Colors.green;
      case 'scan_result':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medical Records'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadRecords,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Upload Buttons
                Container(
                  padding: const EdgeInsets.all(16.0),
                  color: Colors.teal.shade50,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _isUploading ? null : _pickImage,
                        icon: const Icon(Icons.image),
                        label: const Text('Upload Image'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          foregroundColor: Colors.white,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: _isUploading ? null : _pickFile,
                        icon: const Icon(Icons.insert_drive_file),
                        label: const Text('Upload File'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                if (_isUploading)
                  const LinearProgressIndicator(),

                // Records List
                Expanded(
                  child: _records.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.folder_open, size: 64, color: Colors.grey[400]),
                              const SizedBox(height: 16),
                              Text(
                                'No medical records yet.\nUpload your first record!',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _loadRecords,
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16.0),
                            itemCount: _records.length,
                            itemBuilder: (context, index) {
                              final record = _records[index];
                              final date = DateTime.parse(record['created_at']);

                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor:
                                        _getRecordTypeColor(record['record_type'])
                                            .withOpacity(0.2),
                                    child: Icon(
                                      _getFileIcon(record['file_type']),
                                      color: _getRecordTypeColor(record['record_type']),
                                    ),
                                  ),
                                  title: Text(
                                    record['file_name'] ?? 'Unknown',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        record['record_type']?.toString().replaceAll('_', ' ').toUpperCase() ??
                                            'GENERAL',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: _getRecordTypeColor(record['record_type']),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        '${date.day}/${date.month}/${date.year}',
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ],
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => _deleteRecord(record['id']),
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
}

