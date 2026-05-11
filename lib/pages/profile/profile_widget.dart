import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:gallery_media_picker/gallery_media_picker.dart';
import 'package:rawasii/pages/profile/EditProfile.dart';

class ProfileWidget extends StatefulWidget {
  final String imagePath;
  final VoidCallback onClicked;
  final String whichpage;
  final bool isCurrentUser;

  ProfileWidget(
    this.imagePath,
    this.onClicked,
    this.whichpage, {
    super.key,
    this.isCurrentUser = true,
  });

  @override
  State<ProfileWidget> createState() => _ProfileWidgetState();
}

class _ProfileWidgetState extends State<ProfileWidget> {
  final _picker = ImagePicker();
  File? _image;
  List<PickedAssetModel> selectedFiles = [];
  List<XFile> webSelectedFiles = [];

  Future<void> pickImage() async {
    XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) setState(() => _image = File(image.path));
  }

  @override
  Widget build(BuildContext context) {
    String icon = widget.whichpage == 'MainProfile'
        ? 'editicon.svg'
        : 'camera.svg';

    return Center(
      child: Column(
        children: [
          const SizedBox(height: 25),
          Stack(
            children: [
              buildImage(),

              // ── only show edit button for current user ─────────────────
              if (widget.isCurrentUser)
                Positioned(
                  bottom: -1,
                  right: -14,
                  child: TextButton(
                    onPressed: () async {
                      if (widget.whichpage == 'MainProfile') {
                        final updated = await Navigator.pushNamed(
                          context,
                          '/editpage',
                        );
                        if (updated == true && context.mounted) {
                          widget.onClicked();
                          setState(() {});
                        }
                      } else {
                        if (kIsWeb) {
                          final images = await _picker.pickMultiImage(limit: 2);
                          setState(() => webSelectedFiles = images);
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => GalleryMediaPicker(
                                pathList: (List<PickedAssetModel> paths) {
                                  setState(() => selectedFiles = paths);
                                  Navigator.pop(context);
                                },
                                appBarLeadingWidget: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                ),
                                mediaPickerParams: MediaPickerParamsModel(
                                  maxPickImages: 1,
                                  singlePick: false,
                                  mediaType: GalleryMediaType.all,
                                  thumbnailQuality: ThumbnailQuality.high,
                                ),
                              ),
                            ),
                          );
                        }
                      }
                    },
                    child: SvgPicture.asset(
                      'assets/$icon',
                      width: 30,
                      height: 30,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildImage() {
    final path = widget.imagePath;
    final hasImage = path.isNotEmpty;
    final isNetwork = path.startsWith('http');

    ImageProvider? imageProvider;
    if (hasImage) {
      if (isNetwork) {
        imageProvider = NetworkImage(path);
      } else if (!kIsWeb) {
        imageProvider = FileImage(File(path)); // ← local file on mobile
      }
      // on web with local path → show person icon (blob URLs handled separately)
    }

    return ClipOval(
      child: Material(
        color: const Color(0xffC9B29B),
        child: imageProvider != null
            ? Ink.image(
                image: imageProvider,
                fit: BoxFit.cover,
                width: 120,
                height: 120,
                child: InkWell(onTap: widget.onClicked),
              )
            : InkWell(
                onTap: widget.onClicked,
                child: const SizedBox(
                  width: 120,
                  height: 120,
                  child: Icon(Icons.person, size: 60, color: Color(0xff2D1B15)),
                ),
              ),
      ),
    );
  }
}
