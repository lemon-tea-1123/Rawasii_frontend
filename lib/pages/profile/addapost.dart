import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:rawasii/globals.dart';
import 'package:rawasii/LinkedLabelRadio.dart';
import 'package:gallery_media_picker/gallery_media_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:rawasii/Classes/post.dart';
import 'package:rawasii/Classes/user.dart';
import 'package:rawasii/utils/user_data.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rawasii/services/api.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddPost extends ConsumerStatefulWidget {
  /// Pass this to enter edit mode — the page pre-fills all fields
  /// and calls updatePost instead of createPost on submit.
  final Post? postToEdit;

  const AddPost({super.key, this.postToEdit});

  @override
  ConsumerState<AddPost> createState() => _AddPostState();
}

class _AddPostState extends ConsumerState<AddPost> {
  // ── Is this an edit session? ──────────────────────────────────────────
  bool get _isEditing => widget.postToEdit != null;

  bool other1 = false;
  bool other2 = false;
  bool other3 = false;
  bool submitted = false;
  bool noImageSelected = false;
  final user = UserData.userOne;

  String selectedPeriod = '';
  String selectedType = '';
  String selectedRegion = '';
  List<PickedAssetModel> selectedFiles = [];
  List<XFile> webSelectedFiles = [];
  List<String> paths = [];
  final periodController  = TextEditingController();
  final typeController    = TextEditingController();
  final descrController   = TextEditingController();
  final titleController   = TextEditingController();
  final regionController  = TextEditingController();
  late DateTime now;
  int postNB  = 0;
  int itemCount = 0;
  bool loading  = false;

  @override
  void initState() {
    super.initState();
    // ── Pre-fill fields when editing ─────────────────────────────────
    final p = widget.postToEdit;
    if (p != null) {
      titleController.text = p.title;
      descrController.text = p.description;

      // Period — check if value matches a preset, else set as "Other"
      const presetPeriods = ['Ottoman', 'Islamic', 'Roman', 'French Colonial'];
      if (presetPeriods.contains(p.historicalPer)) {
        selectedPeriod = p.historicalPer;
      } else if (p.historicalPer.isNotEmpty) {
        selectedPeriod = 'Other';
        periodController.text = p.historicalPer;
        other1 = true;
      }

      // Type
      const presetTypes = [
        'Religious', 'Ancient Ruins', 'Palacaes & Castles',
        'Landmarks'
      ];
      if (presetTypes.contains(p.monumentType)) {
        selectedType = p.monumentType;
      } else if (p.monumentType.isNotEmpty) {
        selectedType = 'Other';
        typeController.text = p.monumentType;
        other2 = true;
      }

      // Region
      const presetRegions = [
        'Algiers', 'Constantine', 'Oran', 'Ghardaia', 'Telemcen'
      ];
      if (presetRegions.contains(p.localisation)) {
        selectedRegion = p.localisation;
      } else if (p.localisation.isNotEmpty) {
        selectedRegion = 'Other';
        regionController.text = p.localisation;
        other3 = true;
      }
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    descrController.dispose();
    periodController.dispose();
    typeController.dispose();
    regionController.dispose();
    super.dispose();
  }

  // ── Upload images (create mode only) ──────────────────────────────────
  Future<List<String>> _uploadImages() async {
    final supabase = Supabase.instance.client;
    List<String> imageUrls = [];

    final filesToUpload = kIsWeb
        ? webSelectedFiles
        : selectedFiles.map((f) => XFile(f.path)).toList();

    for (final file in filesToUpload) {
      final bytes    = await file.readAsBytes();
      final ext      = file.name.split('.').last;
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.$ext';
      await supabase.storage
          .from('heritage_images')
          .uploadBinary(fileName, bytes);
      final url = supabase.storage
          .from('heritage_images')
          .getPublicUrl(fileName);
      imageUrls.add(url);
    }
    return imageUrls;
  }

  // ── Submit: create or update ──────────────────────────────────────────
  Future<void> _handleSubmit() async {
    setState(() => loading = true);
    try {
      final finalPeriod = selectedPeriod == 'Other'
          ? periodController.text
          : selectedPeriod;
      final finalType = selectedType == 'Other'
          ? typeController.text
          : selectedType;
      final finalRegion = selectedRegion == 'Other'
          ? regionController.text
          : selectedRegion;

      if (_isEditing) {
        // ── EDIT MODE ─────────────────────────────────────────────────
        final result = await ApiService.updatePost(
          postId:           widget.postToEdit!.id,
          userId:           UserData.userOne?.id.toString() ?? '',
          title:            titleController.text.trim(),
          description:      descrController.text.trim(),
          localisation:     finalRegion,
          historicalPeriod: finalPeriod,
          heritageType:     finalType,
        );

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(result['message'] ?? result['error'] ?? 'Done'),
        ));
        Navigator.pop(context, true); // ← true = updated

      } else {
        // ── CREATE MODE ───────────────────────────────────────────────
        final imageUrls = await _uploadImages();
        await ApiService.createPost(
          title:             titleController.text,
          description:       descrController.text,
          localisation:      finalRegion,
          historical_period: finalPeriod,
          heritage_type:     finalType,
          imagesPaths:       imageUrls,
        );

        if (!mounted) return;
        Navigator.pop(context);
      }
    } catch (e) {
      print('Submit error: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed: $e')),
      );
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          title: Text(
            _isEditing ? 'Edit Post' : 'Post About Heritage',
            style: TextStyle(
              color: darkColor,
              fontFamily: 'Tajawal-Bold',
              fontWeight: FontWeight.w800,
              fontSize: 24,
            ),
          ),
          backgroundColor: bgColor,
          centerTitle: true,
          elevation: 0.25,
          shadowColor: darkColor,
          iconTheme: IconThemeData(color: darkColor),
        ),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: Form(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 5),

                      // ── Title ────────────────────────────────────────────
                      Padding(
                        padding: const EdgeInsets.only(left: 7, right: 7),
                        child: SizedBox(
                          height: 60,
                          child: TextField(
                            maxLines: 2,
                            controller: titleController,
                            textAlignVertical: TextAlignVertical.top,
                            decoration: InputDecoration(
                              hintText: ' The post title ',
                              hintStyle: TextStyle(
                                color: darkColor,
                                fontFamily: 'Tajawal-Bold',
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                              fillColor: secColor,
                              filled: true,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide.none,
                              ),
                              isDense: false,
                              contentPadding: const EdgeInsets.only(
                                bottom: 8, top: 10, left: 10,
                              ),
                            ),
                            style: TextStyle(
                              color: verydarkcolor,
                              fontFamily: 'Tajawal-Bold',
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                            ),
                            keyboardType: TextInputType.multiline,
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),

                      // ── Description ──────────────────────────────────────
                      Padding(
                        padding: const EdgeInsets.only(left: 7, right: 7),
                        child: SizedBox(
                          height: 140,
                          child: TextField(
                            maxLines: null,
                            controller: descrController,
                            textAlignVertical: TextAlignVertical.top,
                            decoration: InputDecoration(
                              hintText:
                                  'What are you sharing today ?\nMonument Name:\nLocation:\nBrief History:\n',
                              hintStyle: TextStyle(
                                color: darkColor,
                                fontFamily: 'Tajawal-Bold',
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                              fillColor: secColor,
                              filled: true,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide.none,
                              ),
                              isDense: false,
                              contentPadding: const EdgeInsets.only(
                                bottom: 8, top: 10, left: 10,
                              ),
                            ),
                            style: TextStyle(
                              color: verydarkcolor,
                              fontFamily: 'Tajawal-Bold',
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                            ),
                            keyboardType: TextInputType.multiline,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // ── Image picker — hidden in edit mode ───────────────
                      if (!_isEditing) ...[
                        Padding(
                          padding: const EdgeInsets.only(left: 7, right: 7),
                          child: OutlinedButton(
                            onPressed: () async {
                              if (kIsWeb) {
                                final picker = ImagePicker();
                                final images = await picker.pickMultiImage(
                                    limit: 5);
                                setState(() {
                                  webSelectedFiles = images;
                                  paths = webSelectedFiles
                                      .map((f) => f.path)
                                      .toList();
                                  itemCount = webSelectedFiles.length;
                                });
                              } else {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => GalleryMediaPicker(
                                      pathList: (List<PickedAssetModel> p) {
                                        setState(() {
                                          selectedFiles = p;
                                          itemCount = p.length;
                                        });
                                        Navigator.pop(context);
                                      },
                                      appBarLeadingWidget: const Icon(
                                          Icons.close, color: Colors.white),
                                      mediaPickerParams: MediaPickerParamsModel(
                                        maxPickImages: 5,
                                        singlePick: false,
                                        mediaType: GalleryMediaType.all,
                                        thumbnailQuality:
                                            ThumbnailQuality.high,
                                      ),
                                    ),
                                  ),
                                );
                              }
                            },
                            style: OutlinedButton.styleFrom(
                              backgroundColor: const Color(0xFFd9cab9),
                              foregroundColor: verydarkcolor,
                              side: BorderSide.none,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 13, horizontal: 10),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SvgPicture.asset(
                                  'assets/Camera2.svg',
                                  colorFilter: ColorFilter.mode(
                                      darkColor, BlendMode.srcIn),
                                ),
                                const SizedBox(width: 7),
                                Padding(
                                  padding: const EdgeInsets.only(top: 9),
                                  child: Text(
                                    itemCount > 0
                                        ? '$itemCount image${itemCount > 1 ? 's' : ''} selected'
                                        : 'Add a picture',
                                    style: TextStyle(
                                      color: const Color.fromARGB(
                                          255, 95, 73, 60),
                                      fontFamily: 'Tajawal-Bold',
                                      fontWeight: FontWeight.w800,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (itemCount == 0 && submitted)
                          const Align(
                            alignment: AlignmentDirectional.bottomStart,
                            child: Padding(
                              padding: EdgeInsets.only(left: 20),
                              child: Text(
                                'No media selected!',
                                style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                      ],

                      // ── Edit mode note about images ───────────────────────
                      if (_isEditing)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          child: Row(
                            children: [
                              Icon(Icons.info_outline,
                                  size: 16,
                                  color: darkColor.withOpacity(0.5)),
                              const SizedBox(width: 6),
                              Text(
                                'Images cannot be changed when editing a post.',
                                style: TextStyle(
                                  color: darkColor.withOpacity(0.5),
                                  fontFamily: 'Tajawal',
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),

                      // ── Tag the legacy label ─────────────────────────────
                      Align(
                        alignment: Alignment.topLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 9, top: 4),
                          child: Text(
                            'Tag the legacy',
                            style: TextStyle(
                              color: darkColor,
                              fontFamily: 'Tajawal-Bold',
                              fontWeight: FontWeight.bold,
                              fontSize: 24,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 3),

                      // ── Historical Period ─────────────────────────────────
                      Container(
                        height: 180,
                        width: MediaQuery.sizeOf(context).width * 0.97,
                        decoration: BoxDecoration(
                          color: const Color(0xFFd9cab9),
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: Column(
                          children: [
                            Align(
                              alignment: Alignment.topLeft,
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    left: 7, top: 7),
                                child: Text(
                                  'Historical Period',
                                  style: TextStyle(
                                    color: const Color.fromARGB(
                                        255, 95, 73, 60),
                                    fontFamily: 'Tajawal-Bold',
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            RadioGroup<String>(
                              groupValue: selectedPeriod,
                              onChanged: (period) => setState(() {
                                selectedPeriod = period!;
                                other1 = (period == 'Other');
                              }),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      LinkedLabelRadio(
                                        label: 'Ottoman',
                                        value: 'Ottoman',
                                        groupValue: selectedPeriod,
                                        onChanged: (v) => setState(() {
                                          selectedPeriod = v!;
                                          other1 = false;
                                        }),
                                      ),
                                      const SizedBox(width: 5),
                                      LinkedLabelRadio(
                                        label: 'Islamic',
                                        value: 'Islamic',
                                        groupValue: selectedPeriod,
                                        onChanged: (v) => setState(() {
                                          selectedPeriod = v!;
                                          other1 = false;
                                        }),
                                      ),
                                      const SizedBox(width: 5),
                                      LinkedLabelRadio(
                                        label: 'Roman',
                                        value: 'Roman',
                                        groupValue: selectedPeriod,
                                        onChanged: (v) => setState(() {
                                          selectedPeriod = v!;
                                          other1 = false;
                                        }),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 1),
                                  Row(
                                    children: [
                                      LinkedLabelRadio(
                                        label: 'Frensh Colonial',
                                        value: 'French Colonial',
                                        groupValue: selectedPeriod,
                                        onChanged: (v) => setState(() {
                                          selectedPeriod = v!;
                                          other1 = false;
                                        }),
                                      ),
                                      const SizedBox(width: 5),
                                      LinkedLabelRadio(
                                        label: 'Other',
                                        value: 'Other',
                                        groupValue: selectedPeriod,
                                        onChanged: (v) => setState(() {
                                          selectedPeriod = v!;
                                          other1 = true;
                                        }),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 9),
                      if (other1)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 12),
                          child: TextField(
                            controller: periodController,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide.none,
                              ),
                              hintText: 'Please specify the period...',
                              hintStyle: TextStyle(
                                  color: darkColor,
                                  fontFamily: 'Tajawal-Bold'),
                              filled: true,
                              fillColor: const Color(0xFFd9cab9),
                            ),
                          ),
                        ),
                      const SizedBox(height: 9),

                      // ── Type of Monument ──────────────────────────────────
                      Container(
                        height: 230,
                        width: MediaQuery.sizeOf(context).width * 0.97,
                        decoration: BoxDecoration(
                          color: const Color(0xFFd9cab9),
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: Column(
                          children: [
                            Align(
                              alignment: Alignment.topLeft,
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    left: 7, top: 7),
                                child: Text(
                                  'Type of Monument ',
                                  style: TextStyle(
                                    color: const Color.fromARGB(
                                        255, 95, 73, 60),
                                    fontFamily: 'Tajawal-Bold',
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            RadioGroup<String>(
                              groupValue: selectedType,
                              onChanged: (type) => setState(() {
                                selectedType = type!;
                                other2 = (type == 'Other');
                              }),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      LinkedLabelRadio(
                                        label: 'Religious',
                                        value: 'Religious',
                                        groupValue: selectedType,
                                        onChanged: (v) => setState(() {
                                          selectedType = v!;
                                          other2 = false;
                                        }),
                                      ),
                                      const SizedBox(width: 68),
                                      LinkedLabelRadio(
                                        label: 'Ancient Ruins',
                                        value: 'Ancient Ruins',
                                        groupValue: selectedType,
                                        onChanged: (v) => setState(() {
                                          selectedType = v!;
                                          other2 = false;
                                        }),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      LinkedLabelRadio(
                                        label: 'Palaces & Castles',
                                        value: 'Palacaes & Castles',
                                        groupValue: selectedType,
                                        onChanged: (v) => setState(() {
                                          selectedType = v!;
                                          other2 = false;
                                        }),
                                      ),
                                      const SizedBox(width: 4),
                                      LinkedLabelRadio(
                                        label: 'Landmarks',
                                        value: 'Landmarks',
                                        groupValue: selectedType,
                                        onChanged: (v) => setState(() {
                                          selectedType = v!;
                                          other2 = false;
                                        }),
                                      ),
                                    ],
                                  ),
                                  LinkedLabelRadio(
                                    label: 'Other',
                                    value: 'Other',
                                    groupValue: selectedType,
                                    onChanged: (v) => setState(() {
                                      selectedType = v!;
                                      other2 = true;
                                    }),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (other2)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 12),
                          child: TextField(
                            controller: typeController,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide.none,
                              ),
                              hintText: 'Please specify the type...',
                              hintStyle: TextStyle(
                                  color: darkColor,
                                  fontFamily: 'Tajawal-Bold'),
                              filled: true,
                              fillColor: const Color(0xFFd9cab9),
                            ),
                          ),
                        ),
                      const SizedBox(height: 9),

                      // ── Region ────────────────────────────────────────────
                      Container(
                        height: 180,
                        width: MediaQuery.sizeOf(context).width * 0.97,
                        decoration: BoxDecoration(
                          color: const Color(0xFFd9cab9),
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: Column(
                          children: [
                            Align(
                              alignment: Alignment.topLeft,
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    left: 7, top: 7),
                                child: Text(
                                  'Region ',
                                  style: TextStyle(
                                    color: const Color.fromARGB(
                                        255, 95, 73, 60),
                                    fontFamily: 'Tajawal-Bold',
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            RadioGroup<String>(
                              groupValue: selectedRegion,
                              onChanged: (region) => setState(() {
                                selectedRegion = region!;
                                other3 = (region == 'Other');
                              }),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      LinkedLabelRadio(
                                        label: 'Algiers',
                                        value: 'Algiers',
                                        groupValue: selectedRegion,
                                        onChanged: (v) => setState(() {
                                          selectedRegion = v!;
                                          other3 = false;
                                        }),
                                      ),
                                      const SizedBox(width: 3),
                                      LinkedLabelRadio(
                                        label: 'Constantine',
                                        value: 'Constantine',
                                        groupValue: selectedRegion,
                                        onChanged: (v) => setState(() {
                                          selectedRegion = v!;
                                          other3 = false;
                                        }),
                                      ),
                                      const SizedBox(width: 3),
                                      LinkedLabelRadio(
                                        label: 'Oran',
                                        value: 'Oran',
                                        groupValue: selectedRegion,
                                        onChanged: (v) => setState(() {
                                          selectedRegion = v!;
                                          other3 = false;
                                        }),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      LinkedLabelRadio(
                                        label: 'Ghardaia',
                                        value: 'Ghardaia',
                                        groupValue: selectedRegion,
                                        onChanged: (v) => setState(() {
                                          selectedRegion = v!;
                                          other3 = false;
                                        }),
                                      ),
                                      LinkedLabelRadio(
                                        label: 'Telemcen',
                                        value: 'Telemcen',
                                        groupValue: selectedRegion,
                                        onChanged: (v) => setState(() {
                                          selectedRegion = v!;
                                          other3 = false;
                                        }),
                                      ),
                                      LinkedLabelRadio(
                                        label: 'Other',
                                        value: 'Other',
                                        groupValue: selectedRegion,
                                        onChanged: (v) => setState(() {
                                          selectedRegion = v!;
                                          other3 = true;
                                        }),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 9),
                      if (other3)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 12),
                          child: TextField(
                            controller: regionController,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide.none,
                              ),
                              hintText: 'Please specify the region...',
                              hintStyle: TextStyle(
                                  color: darkColor,
                                  fontFamily: 'Tajawal-Bold'),
                              filled: true,
                              fillColor: const Color(0xFFd9cab9),
                            ),
                          ),
                        ),
                      const SizedBox(height: 8),

                      // ── Submit / Save button ──────────────────────────────
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: thirdColor,
                              backgroundColor: _isEditing
                                  ? darkColor
                                  : Colors.transparent,
                              side: _isEditing
                                  ? BorderSide.none
                                  : BorderSide(color: darkColor),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 10),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                            onPressed: loading
                                ? null
                                : () {
                                    if (!_isEditing && itemCount == 0) {
                                      setState(() {
                                        noImageSelected = true;
                                        submitted = true;
                                      });
                                      return;
                                    }
                                    setState(() => submitted = true);
                                    if (!_isEditing) {
                                      now = DateTime.now();
                                      user?.userPosts.add(Post.create(
                                        description: descrController.text,
                                        historicalPer:
                                            selectedPeriod.isEmpty
                                                ? periodController.text
                                                : selectedPeriod,
                                        imagePaths: paths,
                                        localisation:
                                            selectedRegion.isEmpty
                                                ? regionController.text
                                                : selectedRegion,
                                        monumentType:
                                            selectedType.isEmpty
                                                ? typeController.text
                                                : selectedType,
                                        title: titleController.text,
                                      ));
                                    }
                                    _handleSubmit();
                                  },
                            child: loading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2),
                                  )
                                : Text(
                                    _isEditing ? 'Save changes' : 'Submit',
                                    style: TextStyle(
                                      fontFamily: 'Tajawal-Bold',
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: _isEditing
                                          ? bgColor
                                          : darkColor,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                      if (!_isEditing) Text('$postNB'),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}