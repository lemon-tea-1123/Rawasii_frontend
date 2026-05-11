import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:rawasii/globals.dart';
import 'package:rawasii/pages/Home/parentSize.dart';
import 'package:rawasii/pages/Home/post.dart';
import 'package:rawasii/services/api.dart';
import 'package:rawasii/utils/user_data.dart';

class SavedPosts extends StatefulWidget {
  const SavedPosts({super.key});

  @override
  State<SavedPosts> createState() => _SavedPostsState();
}

class _SavedPostsState extends State<SavedPosts> {
  List<dynamic> Savedposts = [];
  bool isLoading = true;
  final user = UserData.userOne;

  late bool isDesktop = MediaQuery.sizeOf(context).width > 1024;
  //final User? user = UserData.userOne;

  void loadData() async {
    try {
      final data = await ApiService.getSavedPosts(
        userId: (user?.id ?? '').toString(),
      );
      print('First post:${data.first}');
      setState(() {
        Savedposts = data;
        isLoading = false;
      });
    } catch (e) {
      print('error homePage ${e.toString()}');
      // Handle errors (e.g., show a snackbar)
      setState(() => isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    //double scale = getScale(context);

    return SafeArea(
      child: ParentSized(
        builder: (width, height) {
          return ColoredBox(
            color: Color(0xFFF2EDE6),

            child: Column(
              children: [
                SizedBox(height: 20),
                Row(
                  children: [
                    SizedBox(width: width * 0.05),
                    SizedBox(
                      child: SvgPicture.asset(
                        'assets/SavePost.svg',
                        height: width * 0.05,
                        width: width * 0.05,
                        color: darkColor,
                      ),
                    ),
                    SizedBox(width: width * 0.05),
                    Text(
                      'Saved Posts ',
                      style: TextStyle(
                        fontFamily: 'Tajawal-Bold',
                        fontWeight: FontWeight.bold,
                        color: darkColor,
                        fontSize: width * 0.05,
                      ),
                    ),
                  ],
                ),
                Divider(),

                SizedBox(height: 15),

                Expanded(
                  child: Row(
                    children: [
                      SizedBox(width: isDesktop ? width * 0.15 : 0),
                      Expanded(
                        child: ListView.builder(
                          itemCount: Savedposts.length,
                          shrinkWrap: false,

                          physics: const AlwaysScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            // ── extract nested post object ────────────────────────────────────
                            final item =
                                Savedposts[index] as Map<String, dynamic>;
                            final post =
                                item['post'] as Map<String, dynamic>? ?? item;

                            final rawImages = post['image'] as List? ?? [];
                            final imagePaths = rawImages
                                .map(
                                  (img) => img['image_path'] as String? ?? '',
                                )
                                .where((p) => p.isNotEmpty)
                                .toList();

                            final postUser =
                                post['user'] as Map<String, dynamic>? ?? {};

                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: PostDesign(
                                userId: post['user_id']?.toString(),
                                title: post['title'] ?? '',
                                descr: post['description'] ?? '',
                                imagePaths: imagePaths,
                                creationDate: post['created_at'] ?? '',
                                period: post['historical_period'] ?? '',
                                region: post['localisation'] ?? '',
                                type: post['heritage_type'] ?? '',
                                name: postUser['username'] ?? '',
                                id: post['id_post']?.toString() ?? '',
                              ),
                            );
                          },
                        ),
                      ),
                      SizedBox(width: isDesktop ? width * 0.15 : 0),
                    ],
                  ),
                ),

                // INFINIT SCROLL
              ],
            ),
          );
        },
      ),
    );
  }
}
