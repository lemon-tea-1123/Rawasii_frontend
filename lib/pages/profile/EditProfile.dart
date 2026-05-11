import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rawasii/Classes/user.dart';
import 'package:rawasii/utils/user_data.dart';
import 'package:rawasii/pages/profile/profile_widget.dart';
import 'package:rawasii/services/api.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  // ── controllers defined in state — not in build() ─────────────────────
  late final TextEditingController _nameController;
  late final TextEditingController _cityController;
  late final TextEditingController _jobController;
  late final TextEditingController _bioController;
  late final TextEditingController _interestController;

  XFile? _pickedImage; // ← picked image before upload
  bool _saving = false;

  // ── colors ─────────────────────────────────────────────────────────────
  static const color1 = Color(0xFFF2EDE6);
  static const color2 = Color(0xFFC9B29B);
  static const color3 = Color(0xFF9C6B3F);
  static const color4 = Color(0xFF2D1B15);
  static const color5 = Color(0xFF4A2C24);

  @override
  void initState() {
    super.initState();
    final user = UserData.userOne;
    // ── pre-fill with current values ──────────────────────────────────
    _nameController = TextEditingController(text: user?.name ?? '');
    _jobController = TextEditingController(text: user?.job ?? '');
    _bioController = TextEditingController(text: user?.bio ?? '');
    _cityController = TextEditingController(text: user?.city ?? '');
    _interestController = TextEditingController(text: user?.interest ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cityController.dispose();
    _jobController.dispose();
    _bioController.dispose();
    _interestController.dispose();
    super.dispose();
  }

  // ── save to backend ────────────────────────────────────────────────────
  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      // upload image if picked
      String? imageUrl;
      if (_pickedImage != null) {
        imageUrl = await ApiService.uploadProfilePicture(_pickedImage!);
      }

      // call backend
      final result = await ApiService.updateProfile(
        fullName: _nameController.text.trim().isEmpty
            ? null
            : _nameController.text.trim(),
        biography: _bioController.text.trim().isEmpty
            ? null
            : _bioController.text.trim(),
        expertise: _jobController.text.trim().isEmpty
            ? null
            : _jobController.text.trim(),
        specialties: _interestController.text.trim().isEmpty
            ? null
            : _interestController.text.trim(),
        profileImageUrl: imageUrl,
        city: _cityController.text.trim().isEmpty
            ? null
            : _cityController.text.trim(),
      );

      print('Update result: $result');

      // update local UserData so profile page reflects changes immediately
      if (_nameController.text.trim().isNotEmpty)
        UserData.userOne?.name = _nameController.text.trim();
      if (_jobController.text.trim().isNotEmpty)
        UserData.userOne?.job = _jobController.text.trim();
      if (_bioController.text.trim().isNotEmpty)
        UserData.userOne?.bio = _bioController.text.trim();
      if (_cityController.text.trim().isNotEmpty)
        UserData.userOne?.city = _cityController.text.trim();
      if (_interestController.text.trim().isNotEmpty)
        UserData.userOne?.interest = _interestController.text.trim();
      if (imageUrl != null) UserData.userOne?.imagePath = imageUrl;

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
        Navigator.pop(context, true); // ← go back to profile page
      }
    } catch (e) {
      print('Save error: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
    setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) {
    //initState();
    final user = UserData.userOne;
    final dimension = MediaQuery.of(context).size.width;

    // ── current image path — show picked image or existing ─────────────
    final imagePath = _pickedImage?.path ?? user?.imagePath ?? '';

    return Scaffold(
      body: ColoredBox(
        // ← no Scaffold, no ProviderScope
        color: color1,
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 840),
              child: ListView(
                children: [
                  // ── profile picture ──────────────────────────────────────
                  ProfileWidget(imagePath, () async {
                    // pick image when avatar tapped
                    final picker = ImagePicker();
                    if (kIsWeb) {
                      final images = await picker.pickMultiImage(limit: 1);
                      if (images.isNotEmpty) {
                        setState(() => _pickedImage = images.first);
                      }
                    } else {
                      final image = await picker.pickImage(
                        source: ImageSource.gallery,
                      );
                      if (image != null) {
                        setState(() => _pickedImage = image);
                      }
                    }
                  }, 'editpage'),
                  const SizedBox(height: 20),

                  // ── Full Name ────────────────────────────────────────────
                  _label('Full Name', color5),
                  const SizedBox(height: 5),
                  _field(
                    controller: _nameController,
                    hint: 'e.g., Meriem El-Djazaïri',
                    dimension: dimension,
                  ),
                  const SizedBox(height: 5),

                  // ── Job ──────────────────────────────────────────────────
                  _label('Job', color5),
                  const SizedBox(height: 5),
                  _field(
                    controller: _jobController,
                    hint: 'e.g., Casbah Architecture Historian',
                    dimension: dimension,
                  ),
                  const SizedBox(height: 5),

                  // ── Bio ──────────────────────────────────────────────────
                  _label('About you', color5),
                  const SizedBox(height: 5),
                  _field(
                    controller: _bioController,
                    hint:
                        'e.g., Passionate about the hidden stories of the Casbah...',
                    dimension: dimension,
                    maxLines: 5,
                  ),
                  const SizedBox(height: 5),

                  // ── City ─────────────────────────────────────────────────
                  _label('City', color5),
                  const SizedBox(height: 5),
                  _field(
                    controller: _cityController,
                    hint: 'e.g., Algiers',
                    dimension: dimension,
                  ),
                  const SizedBox(height: 5),

                  // ── Interest ─────────────────────────────────────────────
                  _label('Interest', color5),
                  const SizedBox(height: 5),
                  _field(
                    controller: _interestController,
                    hint: 'e.g., Algerian Architecture',
                    dimension: dimension,
                  ),
                  const SizedBox(height: 8),

                  // ── Save button ──────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.only(right: 15),
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: OutlinedButton(
                        onPressed: _saving ? null : _save, // ← calls API
                        style: OutlinedButton.styleFrom(
                          backgroundColor: color3,
                          fixedSize: const Size(110, 45),
                          side: BorderSide.none,
                        ),
                        child: _saving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                'Save',
                                style: TextStyle(
                                  color: color4,
                                  fontFamily: 'Tajawal-Bold',
                                  fontSize: 20,
                                ),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── reusable label ────────────────────────────────────────────────────
  Widget _label(String text, Color color) => Padding(
    padding: const EdgeInsets.only(left: 26),
    child: Text(
      text,
      style: TextStyle(
        color: color,
        fontFamily: 'Tajawal-Bold',
        fontWeight: FontWeight.w700,
        fontSize: 20,
        letterSpacing: 0,
      ),
    ),
  );

  // ── reusable text field ───────────────────────────────────────────────
  Widget _field({
    required TextEditingController controller,
    required String hint,
    required double dimension,
    int maxLines = 1,
  }) => Center(
    child: SizedBox(
      width: dimension * 0.95,
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
            color: Color(0xFF896F5F),
            fontFamily: 'Tajawal-Bold',
            fontSize: 18,
          ),
          fillColor: color2,
          filled: true,
          isDense: maxLines > 1,
          contentPadding: maxLines > 1
              ? const EdgeInsets.symmetric(vertical: 20, horizontal: 16)
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    ),
  );
}
