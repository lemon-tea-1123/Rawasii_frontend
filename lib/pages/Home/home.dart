import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:rawasii/globals.dart';
import 'package:rawasii/services/api.dart';
import 'package:rawasii/pages/Home/parentSize.dart';
import 'package:rawasii/pages/Home/post.dart';
import 'package:rawasii/utils/user_data.dart';
import 'package:rawasii/navigation_notifier.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> posts = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    try {
      final data = await ApiService.getPosts();
      setState(() {
        posts = data;
        isLoading = false;
      });
    } catch (e) {
      print('error homePage: $e');
      setState(() {
        isLoading = false;
        errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.sizeOf(context).width > 1024; // ← moved here
    double scale = getScale(context);

    return SafeArea(
      child: ParentSized(
        builder: (width, height) {
          return ColoredBox(
            color: const Color(0xFFF2EDE6),
            child: Column(
              children: [
                const SizedBox(height: 15),

                // ── search bar — tappable, navigates to SearchPage ────────
                Row(
                  children: [
                    SizedBox(width: width * 0.03),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => shellNav.goTo(5),
                        child: Container(
                          height: 50,
                          padding: EdgeInsets.symmetric(horizontal: scale * 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFC9B29B),
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Row(
                            children: [
                              SvgPicture.asset(
                                'assets/Search.svg',
                                height: scale * 26,
                                width: scale * 26,
                              ),
                              SizedBox(width: scale * 10),
                              Text(
                                'Explore the roots of Algeria',
                                style: TextStyle(
                                  color: const Color(0xFF4A2C24),
                                  fontFamily: 'Tajawal-Bold',
                                  fontSize: scale * 15.5,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: scale),
                    SvgPicture.asset(
                      'assets/filter.svg',
                      height: 50,
                      fit: BoxFit.contain,
                    ),
                    SizedBox(width: width * 0.03),
                  ],
                ),

                const SizedBox(height: 15),

                // ── posts list ─────────────────────────────────────────────
                Expanded(
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : errorMessage != null
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Failed to load posts',
                                style: TextStyle(color: darkColor),
                              ),
                              const SizedBox(height: 12),
                              ElevatedButton(
                                onPressed: loadData,
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        )
                      : posts.isEmpty
                      ? Center(
                          child: Text(
                            'No posts yet',
                            style: TextStyle(color: darkColor),
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: loadData,
                          child: Row(
                            children: [
                              SizedBox(width: isDesktop ? width * 0.15 : 0),
                              Expanded(
                                child: ListView.builder(
                                  itemCount: posts.length,
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  itemBuilder: (context, index) {
                                    final post =
                                        posts[index] as Map<String, dynamic>;
                                    final rawImages =
                                        post['image'] as List? ?? [];
                                    final imagePaths = rawImages
                                        .map(
                                          (img) =>
                                              img['image_path'] as String? ??
                                              '',
                                        )
                                        .where((p) => p.isNotEmpty)
                                        .toList();

                                    final postUser =
                                        post['user'] as Map<String, dynamic>? ??
                                        {};
                                    final currentUserId =
                                        UserData.userOne?.id.toString() ?? '';
                                    final reactions =
                                        post['reaction'] as List? ?? [];
                                    final isLiked = reactions.any(
                                      (r) =>
                                          r['user_id']?.toString() ==
                                          currentUserId,
                                    );

                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      child: PostDesign(
                                        id: post['id_post']?.toString() ?? '',
                                        userId: post['user_id']?.toString(),
                                        title: post['title'] ?? '',
                                        descr: post['description'] ?? '',
                                        imagePaths: imagePaths,
                                        creationDate: post['created_at'] ?? '',
                                        period: post['historical_period'] ?? '',
                                        region: post['localisation'] ?? '',
                                        type: post['heritage_type'] ?? '',
                                        name: postUser['username'] ?? '',
                                        likeCount:
                                            post['reaction_count'] as int? ?? 0,
                                        commentCount:
                                            post['comment_count'] as int? ?? 0,
                                        isLiked: isLiked,
                                      ),
                                    );
                                  },
                                ),
                              ),
                              SizedBox(width: isDesktop ? width * 0.15 : 0),
                            ],
                          ),
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
