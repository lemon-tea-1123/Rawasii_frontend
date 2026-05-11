import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'package:rawasii/services/api.dart';

// ── MODEL ──
class Visit {
  int id;
  String username;
  String? profileImageUrl;
  String monumentName;
  String location;
  String heritageType;
  String historicalPeriod;
  String description;
  List<String> imageUrls;
  bool liked;
  int likeCount;

  Visit({
    required this.id,
    required this.username,
    this.profileImageUrl,
    required this.monumentName,
    required this.location,
    required this.heritageType,
    required this.historicalPeriod,
    required this.description,
    required this.imageUrls,
    this.liked = false,
    this.likeCount = 0,
  });

  factory Visit.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>?;
    final images = json['image'] as List<dynamic>? ?? [];
    return Visit(
      id: (json['id_visit'] as num).toInt(),
      username: user?['username']?.toString() ?? 'Unknown',
      profileImageUrl: user?['user_profile'] is List
          ? ((user!['user_profile'] as List).first
                    as Map<String, dynamic>)['profile_image_url']
                ?.toString()
          : null,
      monumentName: json['monument_name']?.toString() ?? '',
      location: json['localisation']?.toString() ?? '',
      heritageType: json['heritage_type']?.toString() ?? '',
      historicalPeriod: json['historical_period']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      imageUrls: images.map((e) => e['image_path'].toString()).toList(),
      likeCount: (json['reaction_count'] as num?)?.toInt() ?? 0,
      liked: json['liked'] as bool? ?? false,
    );
  }
}

// ── MAIN PAGE ──
class VisitsPage extends StatefulWidget {
  const VisitsPage({super.key});

  @override
  State<VisitsPage> createState() => _VisitsPageState();
}

class _VisitsPageState extends State<VisitsPage> {
  List<Visit> _visits = [];
  bool _loading = true;
  String? _currentUsername;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    _currentUsername = await ApiService.getUsername();
    await _loadVisits();
  }

  Future<void> _loadVisits() async {
    setState(() => _loading = true);
    try {
      final data = await ApiService.getVisits();
      final list = data['visits'] as List<dynamic>? ?? [];
      setState(() {
        _visits = list.map((e) => Visit.fromJson(e)).toList();
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading visits: $e')));
      }
    }
  }

  void _openForm({Visit? visitToEdit}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => VisitForm(visitToEdit: visitToEdit, onSaved: _loadVisits),
    );
  }

  Future<void> _deleteVisit(Visit v) async {
    final confirm = await showDialog<bool>(
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
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: GoogleFonts.tajawal(color: const Color(0xFF4A2C24)),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Delete',
              style: GoogleFonts.tajawal(color: Colors.red),
            ),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await ApiService.deleteVisit(v.id);
      await _loadVisits();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error deleting: $e')));
      }
    }
  }

  Future<void> _toggleLike(Visit v) async {
    // Update UI optimistically
    setState(() {
      v.liked = !v.liked;
      v.likeCount += v.liked ? 1 : -1;
    });

    try {
      final result = await ApiService.likeVisit(v.id);
      // Sync with server response
      final serverLiked = result['liked'] as bool? ?? v.liked;
      if (serverLiked != v.liked) {
        setState(() {
          v.likeCount += serverLiked ? 1 : -1;
          v.liked = serverLiked;
        });
      }
    } catch (e) {
      // Revert on error
      setState(() {
        v.liked = !v.liked;
        v.likeCount += v.liked ? 1 : -1;
      });
    }
  }

  Widget _buildTag(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFF4A2C24).withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: const Color(0xFF4A2C24)),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.tajawal(
              fontSize: 12,
              color: const Color(0xFF4A2C24),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _showFullScreen(List<String> urls, int index) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (_) => _FullScreenViewer(urls: urls, initialIndex: index),
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
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  Text(
                    'Visits',
                    style: GoogleFonts.tajawal(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF4A2C24),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.camera_alt,
                    color: Color(0xFF4A2C24),
                    size: 22,
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: _loadVisits,
                    icon: const Icon(Icons.refresh, color: Color(0xFF4A2C24)),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF4A2C24),
                      ),
                    )
                  : _visits.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.place_outlined,
                            size: 64,
                            color: const Color(0xFF4A2C24).withOpacity(0.4),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No visits yet',
                            style: GoogleFonts.tajawal(
                              fontSize: 18,
                              color: const Color(0xFF4A2C24).withOpacity(0.7),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tap "+" to share your visit',
                            style: GoogleFonts.tajawal(
                              fontSize: 14,
                              color: const Color(0xFF4A2C24).withOpacity(0.5),
                            ),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadVisits,
                      color: const Color(0xFF4A2C24),
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: _visits.length,
                        itemBuilder: (context, index) {
                          final v = _visits[index];
                          final isOwner = v.username == _currentUsername;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 20),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Header
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 20,
                                        backgroundColor: const Color(
                                          0xFF4A2C24,
                                        ).withOpacity(0.2),
                                        backgroundImage:
                                            v.profileImageUrl != null
                                            ? NetworkImage(v.profileImageUrl!)
                                            : null,
                                        child: v.profileImageUrl == null
                                            ? const Icon(
                                                Icons.person,
                                                color: Color(0xFF4A2C24),
                                                size: 22,
                                              )
                                            : null,
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          v.username,
                                          style: GoogleFonts.tajawal(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                            color: const Color(0xFF4A2C24),
                                          ),
                                        ),
                                      ),
                                      if (isOwner)
                                        PopupMenuButton<String>(
                                          color: const Color(0xFFF2EDE6),
                                          icon: const Icon(
                                            Icons.more_vert,
                                            color: Color(0xFF4A2C24),
                                          ),
                                          onSelected: (value) {
                                            if (value == 'edit') {
                                              _openForm(visitToEdit: v);
                                            } else if (value == 'delete') {
                                              _deleteVisit(v);
                                            }
                                          },
                                          itemBuilder: (_) => [
                                            PopupMenuItem(
                                              value: 'edit',
                                              child: Row(
                                                children: [
                                                  const Icon(
                                                    Icons.edit,
                                                    color: Color(0xFF4A2C24),
                                                    size: 18,
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    'Edit',
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

                                  // Location
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.location_on,
                                        color: Color(0xFF4A2C24),
                                        size: 16,
                                      ),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          '${v.monumentName} — ${v.location}',
                                          style: GoogleFonts.tajawal(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                            color: const Color(0xFF4A2C24),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),

                                  // Tags
                                  Wrap(
                                    spacing: 6,
                                    runSpacing: 4,
                                    children: [
                                      _buildTag(
                                        v.heritageType,
                                        Icons.account_balance,
                                      ),
                                      _buildTag(
                                        v.historicalPeriod,
                                        Icons.history,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),

                                  // Description
                                  Text(
                                    v.description,
                                    style: GoogleFonts.tajawal(
                                      fontSize: 14,
                                      color: const Color(0xFF4A2C24),
                                    ),
                                  ),
                                  const SizedBox(height: 10),

                                  // Images
                                  if (v.imageUrls.isNotEmpty)
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(14),
                                      child: v.imageUrls.length == 1
                                          ? GestureDetector(
                                              onTap: () => _showFullScreen(
                                                v.imageUrls,
                                                0,
                                              ),
                                              child: Image.network(
                                                v.imageUrls[0],
                                                width: double.infinity,
                                                height: 200,
                                                fit: BoxFit.cover,
                                              ),
                                            )
                                          : SizedBox(
                                              height: 200,
                                              child: ListView.builder(
                                                scrollDirection:
                                                    Axis.horizontal,
                                                itemCount: v.imageUrls.length,
                                                itemBuilder: (ctx, i) =>
                                                    GestureDetector(
                                                      onTap: () =>
                                                          _showFullScreen(
                                                            v.imageUrls,
                                                            i,
                                                          ),
                                                      child: Container(
                                                        width: 200,
                                                        margin:
                                                            const EdgeInsets.only(
                                                              right: 4,
                                                            ),
                                                        child: Image.network(
                                                          v.imageUrls[i],
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ),
                                              ),
                                            ),
                                    ),
                                  const SizedBox(height: 10),

                                  // Like button
                                  GestureDetector(
                                    onTap: () => _toggleLike(v),
                                    child: Row(
                                      children: [
                                        Icon(
                                          v.liked
                                              ? Icons.favorite
                                              : Icons.favorite_border,
                                          color: v.liked
                                              ? Colors.red
                                              : const Color(0xFF4A2C24),
                                          size: 24,
                                        ),
                                        if (v.likeCount > 0) ...[
                                          const SizedBox(width: 4),
                                          Text(
                                            '${v.likeCount}',
                                            style: GoogleFonts.tajawal(
                                              fontSize: 14,
                                              color: const Color(0xFF4A2C24),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
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
      floatingActionButton: FloatingActionButton(
        onPressed: _openForm,
        backgroundColor: const Color(0xFF4A2C24),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

// ── FULL SCREEN VIEWER ──
class _FullScreenViewer extends StatefulWidget {
  final List<String> urls;
  final int initialIndex;
  const _FullScreenViewer({required this.urls, required this.initialIndex});

  @override
  State<_FullScreenViewer> createState() => _FullScreenViewerState();
}

class _FullScreenViewerState extends State<_FullScreenViewer> {
  late PageController _controller;
  late int _current;

  @override
  void initState() {
    super.initState();
    _current = widget.initialIndex;
    _controller = PageController(initialPage: widget.initialIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.zero,
      child: Stack(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(color: Colors.black87),
          ),
          Center(
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.8,
              child: PageView.builder(
                controller: _controller,
                itemCount: widget.urls.length,
                onPageChanged: (i) => setState(() => _current = i),
                itemBuilder: (_, i) => InteractiveViewer(
                  child: Image.network(widget.urls[i], fit: BoxFit.contain),
                ),
              ),
            ),
          ),
          Positioned(
            top: 40,
            right: 16,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Color(0xFF4A2C24),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 20),
              ),
            ),
          ),
          if (widget.urls.length > 1)
            Positioned(
              bottom: 80,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  widget.urls.length,
                  (i) => Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: i == _current
                          ? const Color(0xFFF2EDE6)
                          : Colors.white38,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── VISIT FORM ──
class VisitForm extends StatefulWidget {
  final Visit? visitToEdit;
  final VoidCallback onSaved;
  const VisitForm({super.key, this.visitToEdit, required this.onSaved});

  @override
  State<VisitForm> createState() => _VisitFormState();
}

class _VisitFormState extends State<VisitForm> {
  late TextEditingController _monumentNameController;
  late TextEditingController _locationController;
  late TextEditingController _historicalPeriodController;
  late TextEditingController _descriptionController;

  String? _selectedHeritageType;
  List<XFile> _newPhotos = [];
  List<Uint8List> _newPhotoBytes = [];
  List<String> _existingUrls = [];
  bool _uploading = false;

  final ImagePicker _picker = ImagePicker();
  final List<String> _heritageTypes = [
    'Civil',
    'Religious',
    'Military',
    'Funerary',
  ];

  @override
  void initState() {
    super.initState();
    final v = widget.visitToEdit;
    _monumentNameController = TextEditingController(
      text: v?.monumentName ?? '',
    );
    _locationController = TextEditingController(text: v?.location ?? '');
    _historicalPeriodController = TextEditingController(
      text: v?.historicalPeriod ?? '',
    );
    _descriptionController = TextEditingController(text: v?.description ?? '');
    _selectedHeritageType = v?.heritageType;
    _existingUrls = List.from(v?.imageUrls ?? []);
  }

  int get _totalPhotos => _existingUrls.length + _newPhotos.length;

  Future<void> _pickPhoto() async {
    if (_totalPhotos >= 5) return;
    final XFile? photo = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (photo != null) {
      final bytes = await photo.readAsBytes();
      setState(() {
        _newPhotos.add(photo);
        _newPhotoBytes.add(bytes);
      });
    }
  }

  InputDecoration _inputDecoration(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: GoogleFonts.tajawal(
      color: const Color(0xFF4A2C24).withOpacity(0.4),
      fontSize: 14,
    ),
    filled: true,
    fillColor: Colors.white.withOpacity(0.7),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
  );

  Widget _fieldLabel(String label) => Text(
    label,
    style: GoogleFonts.tajawal(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: const Color(0xFF4A2C24),
    ),
  );

  Future<void> _submit() async {
    if (_monumentNameController.text.trim().isEmpty ||
        _locationController.text.trim().isEmpty ||
        _selectedHeritageType == null ||
        _historicalPeriodController.text.trim().isEmpty ||
        _descriptionController.text.trim().isEmpty ||
        _totalPhotos == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _totalPhotos == 0
                ? 'Please add at least one photo'
                : 'Please fill in all fields',
            style: GoogleFonts.tajawal(),
          ),
          backgroundColor: const Color(0xFF4A2C24),
        ),
      );
      return;
    }

    setState(() => _uploading = true);
    try {
      final List<String> uploadedUrls = [];
      for (final photo in _newPhotos) {
        final url = await ApiService.uploadVisitImage(photo);
        if (url != null) uploadedUrls.add(url);
      }

      final allUrls = [..._existingUrls, ...uploadedUrls];

      if (widget.visitToEdit == null) {
        await ApiService.createVisit(
          monumentName: _monumentNameController.text.trim(),
          localisation: _locationController.text.trim(),
          description: _descriptionController.text.trim(),
          historicalPeriod: _historicalPeriodController.text.trim(),
          heritageType: _selectedHeritageType!,
          imageUrls: allUrls,
        );
      } else {
        await ApiService.updateVisit(
          visitId: widget.visitToEdit!.id,
          monumentName: _monumentNameController.text.trim(),
          localisation: _locationController.text.trim(),
          description: _descriptionController.text.trim(),
          historicalPeriod: _historicalPeriodController.text.trim(),
          heritageType: _selectedHeritageType!,
          imageUrls: allUrls,
        );
      }

      widget.onSaved();
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e', style: GoogleFonts.tajawal()),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.visitToEdit != null;
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
              isEditing ? 'Edit your Visit' : 'Share your Visit',
              style: GoogleFonts.tajawal(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF4A2C24),
              ),
            ),
            const SizedBox(height: 20),
            _fieldLabel('Monument Name *'),
            const SizedBox(height: 6),
            TextField(
              controller: _monumentNameController,
              style: GoogleFonts.tajawal(color: const Color(0xFF4A2C24)),
              decoration: _inputDecoration('e.g. Casbah of Algiers'),
            ),
            const SizedBox(height: 14),
            _fieldLabel('Location *'),
            const SizedBox(height: 6),
            TextField(
              controller: _locationController,
              style: GoogleFonts.tajawal(color: const Color(0xFF4A2C24)),
              decoration: _inputDecoration('e.g. Algiers, Algeria'),
            ),
            const SizedBox(height: 14),
            _fieldLabel('Heritage Type *'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _heritageTypes.map((type) {
                final isSelected = _selectedHeritageType == type;
                return GestureDetector(
                  onTap: () => setState(() => _selectedHeritageType = type),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF4A2C24)
                          : Colors.white.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFF4A2C24),
                        width: 1.5,
                      ),
                    ),
                    child: Text(
                      type,
                      style: GoogleFonts.tajawal(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? Colors.white
                            : const Color(0xFF4A2C24),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 14),
            _fieldLabel('Historical Period *'),
            const SizedBox(height: 6),
            TextField(
              controller: _historicalPeriodController,
              style: GoogleFonts.tajawal(color: const Color(0xFF4A2C24)),
              decoration: _inputDecoration(
                'e.g. Roman, Ottoman, Islamic, Prehistoric...',
              ),
            ),
            const SizedBox(height: 14),
            _fieldLabel('Description *'),
            const SizedBox(height: 6),
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              style: GoogleFonts.tajawal(color: const Color(0xFF4A2C24)),
              decoration: _inputDecoration(
                'Share your experience and impressions...',
              ),
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _fieldLabel('Photos * (required)'),
                Text(
                  '\$_totalPhotos/5',
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
                  if (_totalPhotos < 5)
                    GestureDetector(
                      onTap: _pickPhoto,
                      child: Container(
                        width: 90,
                        height: 90,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(12),
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
                  ..._existingUrls.asMap().entries.map(
                    (entry) => Stack(
                      children: [
                        Container(
                          width: 90,
                          height: 90,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          clipBehavior: Clip.hardEdge,
                          child: Image.network(entry.value, fit: BoxFit.cover),
                        ),
                        Positioned(
                          top: 2,
                          right: 10,
                          child: GestureDetector(
                            onTap: () => setState(
                              () => _existingUrls.removeAt(entry.key),
                            ),
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
                    ),
                  ),
                  ..._newPhotoBytes.asMap().entries.map(
                    (entry) => Stack(
                      children: [
                        Container(
                          width: 90,
                          height: 90,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          clipBehavior: Clip.hardEdge,
                          child: Image.memory(entry.value, fit: BoxFit.cover),
                        ),
                        Positioned(
                          top: 2,
                          right: 10,
                          child: GestureDetector(
                            onTap: () => setState(() {
                              _newPhotos.removeAt(entry.key);
                              _newPhotoBytes.removeAt(entry.key);
                            }),
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
                    ),
                  ),
                ],
              ),
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
                onPressed: _uploading ? null : _submit,
                child: _uploading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        isEditing ? 'Save Changes' : 'Post Visit',
                        style: GoogleFonts.tajawal(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
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
