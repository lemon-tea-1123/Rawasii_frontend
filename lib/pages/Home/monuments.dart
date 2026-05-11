import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:rawasii/services/api.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'https://rawasiibackend-production.up.railway.app';


  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  static Future<String> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('username') ?? 'Username';
  }

  static Future<Map<String, String>> getHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  static Future<List<Map<String, dynamic>>> getMonuments() async {
    final headers = await getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/monuments_in_danger_page'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data['monuments']);
    }
    throw Exception('Failed to load monuments: ${response.body}');
  }

  static Future<bool> reportMonument({
    required String monumentName,
    required String region,
    required String description,
    required String urgenceLevel,
    required String dangerType,
    required List<String> imageUrls,
  }) async {
    final headers = await getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/monuments_in_danger_page/report'),
      headers: headers,
      body: jsonEncode({
        'monument_name': monumentName,
        'region': region,
        'description': description,
        'urgence_level': urgenceLevel,
        'danger_type': dangerType,
        'image_urls': imageUrls,
      }),
    );
    return response.statusCode == 201;
  }

  static Future<bool> updateStatus({
    required int monumentId,
    required String status,
  }) async {
    final headers = await getHeaders();
    final response = await http.put(
      Uri.parse('$baseUrl/monuments_in_danger_page/update_status'),
      headers: headers,
      body: jsonEncode({'monument_id': monumentId, 'status': status}),
    );
    return response.statusCode == 200;
  }

  static Future<bool> deleteMonument({required int monumentId}) async {
    final headers = await getHeaders();
    final response = await http.delete(
      Uri.parse('$baseUrl/monuments_in_danger_page/delete'),
      headers: headers,
      body: jsonEncode({'monument_id': monumentId}),
    );
    return response.statusCode == 200;
  }
}

class FullScreenPhoto extends StatelessWidget {
  final String photoUrl;
  const FullScreenPhoto({super.key, required this.photoUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(child: Image.network(photoUrl, fit: BoxFit.contain)),
    );
  }
}

class Monument {
  final int id;
  final String username;
  final String name;
  final String location;
  final String dangerType;
  final String urgency;
  String status;
  final String date;
  final List<String> photoUrls;

  Monument({
    required this.id,
    required this.username,
    required this.name,
    required this.location,
    required this.dangerType,
    required this.urgency,
    required this.status,
    required this.date,
    required this.photoUrls,
  });

  factory Monument.fromJson(Map<String, dynamic> json) {
    final images = (json['image'] as List<dynamic>? ?? [])
        .map((img) => img['image_path'].toString())
        .toList();
    return Monument(
      id: json['monument_in_danger_id'] as int,
      username:
          (json['user'] as Map<String, dynamic>?)?['username'] ?? 'Unknown',
      name: json['monument_name'] ?? '',
      location: json['region'] ?? '',
      dangerType: json['danger_type'] ?? '',
      urgency: json['urgence_level'] ?? 'Medium',
      status: json['status'] ?? 'Reported',
      date: (json['created_at'] as String).substring(0, 10),
      photoUrls: List<String>.from(images),
    );
  }
}

class MonumentsInDangerPage extends StatefulWidget {
  const MonumentsInDangerPage({super.key});

  @override
  State<MonumentsInDangerPage> createState() => _MonumentsInDangerPageState();
}

class _MonumentsInDangerPageState extends State<MonumentsInDangerPage> {
  List<Monument> _monuments = [];
  bool _isLoading = true;
  String _currentUsername = 'Username';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final username = await ApiService.getUsername() ?? 'Username';
      final data = await ApiService.getMonuments();
      setState(() {
        _currentUsername = username;
        _monuments = data.map((m) => Monument.fromJson(m)).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e', style: GoogleFonts.tajawal()),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Color _urgencyColor(String urgency) {
    switch (urgency) {
      case 'Critical':
        return const Color(0xFFB71C1C);
      case 'High':
        return const Color(0xFFE65100);
      case 'Medium':
        return const Color(0xFFF9A825);
      case 'Low':
        return const Color(0xFF2E7D32);
      default:
        return Colors.grey;
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Saved':
        return const Color(0xFF2E7D32);
      case 'Under intervention':
        return const Color(0xFF1565C0);
      case 'Lost':
        return const Color(0xFF4A148C);
      default:
        return const Color(0xFF4A2C24);
    }
  }

  void _openForm() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ReportForm(onAdd: _loadData),
    );
  }

  void _changeStatus(Monument monument) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFFF2EDE6),
        title: Text(
          'Change Status',
          style: GoogleFonts.tajawal(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF4A2C24),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['Reported', 'Under intervention', 'Saved', 'Lost']
              .map(
                (status) => GestureDetector(
                  onTap: () async {
                    Navigator.pop(context);
                    final ok = await ApiService.updateStatus(
                      monumentId: monument.id,
                      status: status,
                    );
                    if (ok) {
                      setState(() => monument.status = status);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Failed to update status',
                            style: GoogleFonts.tajawal(),
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: monument.status == status
                          ? const Color(0xFF4A2C24)
                          : Colors.white.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      status,
                      style: GoogleFonts.tajawal(
                        color: monument.status == status
                            ? Colors.white
                            : const Color(0xFF4A2C24),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  Future<void> _deleteMonument(Monument monument, int index) async {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFFF2EDE6),
        title: Text(
          'Delete post?',
          style: GoogleFonts.tajawal(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF4A2C24),
          ),
        ),
        content: Text(
          'This action cannot be undone.',
          style: GoogleFonts.tajawal(color: const Color(0xFF4A2C24)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.tajawal(color: const Color(0xFF4A2C24)),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final ok = await ApiService.deleteMonument(
                monumentId: monument.id,
              );
              if (ok) {
                setState(() => _monuments.removeAt(index));
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Failed to delete',
                      style: GoogleFonts.tajawal(),
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: Text(
              'Delete',
              style: GoogleFonts.tajawal(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2EDE6),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'EN',
                          style: GoogleFonts.tajawal(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: const Color(0xFF4A2C24),
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.language,
                          size: 18,
                          color: Color(0xFF4A2C24),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Monuments in Danger',
                    style: GoogleFonts.tajawal(
                      color: const Color(0xFF4A2C24),
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: _loadData,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.refresh,
                        size: 18,
                        color: Color(0xFF4A2C24),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            if (_monuments.isNotEmpty)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      color: Color(0xFF4A2C24),
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '${_monuments.length} monument(s) reported in danger',
                      style: GoogleFonts.tajawal(
                        color: const Color(0xFF4A2C24),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 12),

            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF4A2C24),
                      ),
                    )
                  : _monuments.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.health_and_safety_outlined,
                            size: 64,
                            color: const Color(0xFF4A2C24).withOpacity(0.4),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No monuments reported yet',
                            style: GoogleFonts.tajawal(
                              color: const Color(0xFF4A2C24).withOpacity(0.8),
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tap "Report" to signal a monument in danger',
                            style: GoogleFonts.tajawal(
                              color: const Color(0xFF4A2C24).withOpacity(0.5),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadData,
                      color: const Color(0xFF4A2C24),
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _monuments.length,
                        itemBuilder: (context, index) {
                          final m = _monuments[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 14),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 18,
                                      backgroundColor: const Color(
                                        0xFF4A2C24,
                                      ).withOpacity(0.2),
                                      child: const Icon(
                                        Icons.person,
                                        color: Color(0xFF4A2C24),
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            m.username,
                                            style: GoogleFonts.tajawal(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: const Color(0xFF4A2C24),
                                            ),
                                          ),
                                          Text(
                                            m.date,
                                            style: GoogleFonts.tajawal(
                                              fontSize: 11,
                                              color: const Color(
                                                0xFF4A2C24,
                                              ).withOpacity(0.6),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    PopupMenuButton<String>(
                                      color: const Color(0xFFF2EDE6),
                                      icon: const Icon(
                                        Icons.more_vert,
                                        color: Color(0xFF4A2C24),
                                      ),
                                      onSelected: (value) {
                                        if (value == 'status') {
                                          _changeStatus(m);
                                        } else if (value == 'delete') {
                                          _deleteMonument(m, index);
                                        }
                                      },
                                      itemBuilder: (_) => [
                                        PopupMenuItem(
                                          value: 'status',
                                          child: Row(
                                            children: [
                                              const Icon(
                                                Icons.edit,
                                                color: Color(0xFF4A2C24),
                                                size: 18,
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                'Change status',
                                                style: GoogleFonts.tajawal(
                                                  color: const Color(
                                                    0xFF4A2C24,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        PopupMenuItem(
                                          value: 'delete',
                                          child: Row(
                                            children: [
                                              const Icon(
                                                Icons.delete,
                                                color: Colors.red,
                                                size: 18,
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                'Delete',
                                                style: GoogleFonts.tajawal(
                                                  color: Colors.red,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  m.name,
                                  style: GoogleFonts.tajawal(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF4A2C24),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.location_on,
                                      size: 14,
                                      color: Color(0xFF4A2C24),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      m.location,
                                      style: GoogleFonts.tajawal(
                                        fontSize: 13,
                                        color: const Color(0xFF4A2C24),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  m.dangerType,
                                  style: GoogleFonts.tajawal(
                                    fontSize: 13,
                                    color: const Color(0xFF4A2C24),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                if (m.photoUrls.isNotEmpty) ...[
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: m.photoUrls.length == 1
                                        ? GestureDetector(
                                            onTap: () => Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) => FullScreenPhoto(
                                                  photoUrl: m.photoUrls[0],
                                                ),
                                              ),
                                            ),
                                            child: Image.network(
                                              m.photoUrls[0],
                                              width: double.infinity,
                                              height: 200,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) =>
                                                  Container(
                                                    height: 200,
                                                    color: const Color(
                                                      0xFF4A2C24,
                                                    ).withOpacity(0.1),
                                                    child: const Icon(
                                                      Icons.image,
                                                      color: Color(0xFF4A2C24),
                                                    ),
                                                  ),
                                            ),
                                          )
                                        : SizedBox(
                                            height: 200,
                                            child: ListView.builder(
                                              scrollDirection: Axis.horizontal,
                                              itemCount: m.photoUrls.length,
                                              itemBuilder: (context, i) =>
                                                  GestureDetector(
                                                    onTap: () => Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (_) =>
                                                            FullScreenPhoto(
                                                              photoUrl: m
                                                                  .photoUrls[i],
                                                            ),
                                                      ),
                                                    ),
                                                    child: Container(
                                                      width: 200,
                                                      margin:
                                                          const EdgeInsets.only(
                                                            right: 4,
                                                          ),
                                                      clipBehavior:
                                                          Clip.hardEdge,
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              12,
                                                            ),
                                                      ),
                                                      child: Image.network(
                                                        m.photoUrls[i],
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                  ),
                                            ),
                                          ),
                                  ),
                                  const SizedBox(height: 12),
                                ],
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _urgencyColor(
                                          m.urgency,
                                        ).withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: _urgencyColor(m.urgency),
                                          width: 1,
                                        ),
                                      ),
                                      child: Text(
                                        m.urgency,
                                        style: GoogleFonts.tajawal(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: _urgencyColor(m.urgency),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    GestureDetector(
                                      onTap: () => _changeStatus(m),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: _statusColor(
                                            m.status,
                                          ).withOpacity(0.12),
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                          border: Border.all(
                                            color: _statusColor(m.status),
                                            width: 1,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              m.status,
                                              style: GoogleFonts.tajawal(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w500,
                                                color: _statusColor(m.status),
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            Icon(
                                              Icons.edit,
                                              size: 11,
                                              color: _statusColor(m.status),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openForm,
        backgroundColor: const Color(0xFF4A2C24),
        icon: const Icon(Icons.add_alert, color: Colors.white),
        label: Text(
          'Report',
          style: GoogleFonts.tajawal(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class ReportForm extends StatefulWidget {
  final VoidCallback onAdd;
  const ReportForm({super.key, required this.onAdd});

  @override
  State<ReportForm> createState() => _ReportFormState();
}

class _ReportFormState extends State<ReportForm> {
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _dangerController = TextEditingController();
  final _periodController = TextEditingController();

  String _selectedUrgency = 'Medium';
  String _selectedHeritageType = 'Civil';
  final List<XFile> _photos = [];
  final ImagePicker _picker = ImagePicker();
  bool _isSubmitting = false;

  final List<String> _urgencyLevels = ['Low', 'Medium', 'High', 'Critical'];
  final List<String> _heritageTypes = [
    'Civil',
    'Religious',
    'Military',
    'Funerary',
  ];

  Future<void> _pickPhoto() async {
    if (_photos.length >= 5) return;
    final XFile? photo = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (photo != null) setState(() => _photos.add(photo));
  }

  void _removePhoto(int index) => setState(() => _photos.removeAt(index));

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.tajawal(
        color: const Color(0xFF4A2C24).withOpacity(0.4),
        fontSize: 13,
      ),
      filled: true,
      fillColor: Colors.white.withOpacity(0.7),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
    );
  }

  // ✅ MODIFICATION ICI — upload photos as base64
  Future<void> _submit() async {
    if (_nameController.text.isEmpty ||
        _locationController.text.isEmpty ||
        _dangerController.text.isEmpty ||
        _periodController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please fill in all required fields',
            style: GoogleFonts.tajawal(),
          ),
          backgroundColor: const Color(0xFF4A2C24),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // ✅ Convert photos to base64
      final List<String> imageUrls = [];
      for (final photo in _photos) {
        final bytes = await photo.readAsBytes();
        final base64Str = base64Encode(bytes);
        imageUrls.add('data:image/jpeg;base64,$base64Str');
      }

      final ok = await ApiService.reportMonument(
        monumentName: _nameController.text,
        region: _locationController.text,
        description: _dangerController.text,
        urgenceLevel: _selectedUrgency,
        dangerType: _selectedHeritageType,
        imageUrls: imageUrls, // ✅ maintenant avec les vraies photos
      );

      if (ok) {
        widget.onAdd();
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to submit report',
              style: GoogleFonts.tajawal(),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e', style: GoogleFonts.tajawal()),
          backgroundColor: Colors.red,
        ),
      );
    }

    setState(() => _isSubmitting = false);
  }

  Widget _label(String text) => Text(
    text,
    style: GoogleFonts.tajawal(
      fontSize: 13,
      color: const Color(0xFF4A2C24),
      fontWeight: FontWeight.w500,
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFFF2EDE6),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: const Color(0xFF4A2C24).withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              'Report a Monument',
              style: GoogleFonts.tajawal(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF4A2C24),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "Help preserve Algeria's heritage",
              style: GoogleFonts.tajawal(
                fontSize: 13,
                color: const Color(0xFF4A2C24).withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 24),

            _label('Monument name *'),
            const SizedBox(height: 6),
            TextField(
              controller: _nameController,
              style: GoogleFonts.tajawal(color: const Color(0xFF4A2C24)),
              decoration: _inputDecoration('e.g. Casbah of Algiers'),
            ),
            const SizedBox(height: 14),

            _label('Location *'),
            const SizedBox(height: 6),
            TextField(
              controller: _locationController,
              style: GoogleFonts.tajawal(color: const Color(0xFF4A2C24)),
              decoration: _inputDecoration('e.g. Algiers, Tlemcen...'),
            ),
            const SizedBox(height: 14),

            _label('Nature of danger *'),
            const SizedBox(height: 6),
            TextField(
              controller: _dangerController,
              maxLines: 2,
              style: GoogleFonts.tajawal(color: const Color(0xFF4A2C24)),
              decoration: _inputDecoration('Describe the danger...'),
            ),
            const SizedBox(height: 14),

            _label('Heritage type *'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _heritageTypes.map((type) {
                final selected = _selectedHeritageType == type;
                return GestureDetector(
                  onTap: () => setState(() => _selectedHeritageType = type),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: selected
                          ? const Color(0xFF4A2C24)
                          : Colors.white.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFF4A2C24),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      type,
                      style: GoogleFonts.tajawal(
                        fontSize: 13,
                        color: selected
                            ? Colors.white
                            : const Color(0xFF4A2C24),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 14),

            _label('Historical period *'),
            const SizedBox(height: 6),
            TextField(
              controller: _periodController,
              style: GoogleFonts.tajawal(color: const Color(0xFF4A2C24)),
              decoration: _inputDecoration('e.g. Roman, Ottoman, Islamic...'),
            ),
            const SizedBox(height: 14),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _label('Photos'),
                Text(
                  '${_photos.length}/5',
                  style: GoogleFonts.tajawal(
                    fontSize: 12,
                    color: const Color(0xFF4A2C24),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 90,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  if (_photos.length < 5)
                    GestureDetector(
                      onTap: _pickPhoto,
                      child: Container(
                        width: 90,
                        height: 90,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: const Color(0xFF4A2C24),
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.add_a_photo,
                              color: Color(0xFF4A2C24),
                              size: 26,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Add photo',
                              style: GoogleFonts.tajawal(
                                fontSize: 11,
                                color: const Color(0xFF4A2C24),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ..._photos.asMap().entries.map((entry) {
                    return Stack(
                      children: [
                        Container(
                          width: 90,
                          height: 90,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          clipBehavior: Clip.hardEdge,
                          child: (() {
                            try {
                              return Image.file(
                                File(entry.value.path),
                                fit: BoxFit.cover,
                              );
                            } catch (e) {
                              return Image.network(
                                entry.value.path,
                                fit: BoxFit.cover,
                              );
                            }
                          })(),
                        ),
                        Positioned(
                          top: 2,
                          right: 10,
                          child: GestureDetector(
                            onTap: () => _removePhoto(entry.key),
                            child: Container(
                              width: 22,
                              height: 22,
                              decoration: const BoxDecoration(
                                color: Color(0xFF4A2C24),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 14,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ],
              ),
            ),
            const SizedBox(height: 14),

            _label('Urgency level'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _urgencyLevels.map((level) {
                final selected = _selectedUrgency == level;
                return GestureDetector(
                  onTap: () => setState(() => _selectedUrgency = level),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: selected
                          ? const Color(0xFF4A2C24)
                          : Colors.white.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFF4A2C24),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      level,
                      style: GoogleFonts.tajawal(
                        fontSize: 13,
                        color: selected
                            ? Colors.white
                            : const Color(0xFF4A2C24),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 28),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A2C24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _isSubmitting ? null : _submit,
                child: _isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        'Submit Report',
                        style: GoogleFonts.tajawal(
                          fontSize: 15,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
