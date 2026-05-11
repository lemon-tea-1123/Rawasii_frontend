import 'package:cross_file/src/types/interface.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:rawasii/Classes/user.dart';
//import 'package:rawasii/pages/Home/monuments.dart' hide ApiService;
import 'package:rawasii/utils/user_data.dart';
import 'package:rawasii/pages/profile/profile_widget.dart';
import 'package:rawasii/globals.dart';
import 'package:rawasii/pages/Home/post.dart';
import 'package:rawasii/Classes/post.dart';
import 'package:rawasii/pages/Home/parentSize.dart';
import 'package:rawasii/services/api.dart';
import 'followers.dart';

class Profilepage extends StatefulWidget {
  final User? otherUser; // ← pass another user to show their profile
  //    leave null for current user

  const Profilepage({super.key, this.otherUser});

  @override
  State<Profilepage> createState() => _ProfilepageState();
}

class _ProfilepageState extends State<Profilepage> {
  // ── state variables — defined at class level ───────────────────────────
  bool _isFollowing = false;
  bool _loadingFollow = true;

  void _onEditReturn() => setState(() {});

  // ── ONE initState at class level ───────────────────────────────────────
  @override
  void initState() {
    super.initState();
    if (widget.otherUser != null) {
      _checkFollowStatus();
    } else {
      _loadingFollow = false;
    }
  }

  // ── class level method ─────────────────────────────────────────────────
  Future<void> _checkFollowStatus() async {
    final currentUserId = UserData.userOne?.id.toString() ?? '';
    final otherUserId = widget.otherUser?.id.toString() ?? '';

    if (currentUserId.isEmpty ||
        otherUserId.isEmpty ||
        currentUserId == '0' ||
        otherUserId == '0') {
      if (mounted) setState(() => _loadingFollow = false);
      return;
    }

    try {
      final isFollowing = await ApiService.checkFollow(
        followingUserId: currentUserId,
        followedUserId: otherUserId,
      ).timeout(const Duration(seconds: 5), onTimeout: () => false);

      if (mounted)
        setState(() {
          _isFollowing = isFollowing;
          _loadingFollow = false;
        });
    } catch (e) {
      print('_checkFollowStatus error: $e');
      if (mounted) setState(() => _loadingFollow = false);
    }
  }

  // ── class level method ─────────────────────────────────────────────────
  Future<void> _handleFollowTap() async {
    final currentUserId = UserData.userOne?.id.toString() ?? '';
    final otherUserId = widget.otherUser?.id.toString() ?? '';

    if (_isFollowing) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: bgColor,
          title: Text(
            'Unfollow ${widget.otherUser?.name ?? ''}?',
            style: TextStyle(color: darkColor, fontFamily: 'Tajawal-Bold'),
          ),
          content: Text(
            'Are you sure you want to unfollow this account?',
            style: TextStyle(color: darkColor.withOpacity(0.7)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                'Cancel',
                style: TextStyle(color: darkColor.withOpacity(0.6)),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(backgroundColor: darkColor),
              child: const Text(
                'Unfollow',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      );
      if (confirm != true) return;
    }

    final result = await ApiService.toggleFollow(
      followingUserId: currentUserId,
      followedUserId: otherUserId,
    );

    if (result.containsKey('message')) {
      final nowFollowing = result['message'] == 'Followed successfully';
      setState(() {
        _isFollowing = nowFollowing;
        if (nowFollowing) {
          widget.otherUser?.followersCount =
              (widget.otherUser?.followersCount ?? 0) + 1;
        } else {
          widget.otherUser?.followersCount =
              ((widget.otherUser?.followersCount ?? 1) - 1).clamp(0, 999999);
        }
      });
    }
  }

  // ── build — only UI, no logic ──────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final user = widget.otherUser ?? UserData.userOne;
    final isCurrentUser = widget.otherUser == null;
    final isDesktop = MediaQuery.sizeOf(context).width > 1024;
    final isTablet = MediaQuery.sizeOf(context).width > 600 && !isDesktop;

    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    double scale = MediaQuery.sizeOf(context).width;
    List<Post> posts = user.userPosts;
    String city = user.city ?? 'Not specified';
    String interest = user.interest ?? 'Not specified';
    String creationDate = user.creationDate ?? 'Unknown';

    return SafeArea(
      child: ParentSized(
        builder: (double width, double height) {
          return ColoredBox(
            color: bgColor,
            child: SafeArea(
              child: ListView(
                children: [
                  // ── profile image — edit button only for current user ──
                  ProfileWidget(
                    user.imagePath,
                    _onEditReturn,
                    'MainProfile',
                    isCurrentUser: isCurrentUser, // ← pass flag
                  ),
                  const SizedBox(height: 20),

                  Padding(
                    padding: EdgeInsets.only(left: width * 0.28),
                    child: Text(
                      user.name ?? '',
                      style: TextStyle(
                        color: darkColor,
                        fontFamily: 'Outfit',
                        fontSize: 25,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(width: width * 0.06),
                      OutlinedButton(
                        onPressed: () {
                          showFollowers(context, (user?.id ?? 0).toString());
                        },
                        style: OutlinedButton.styleFrom(
                          backgroundColor: secColor,
                          fixedSize: Size(width * 0.33, 46),
                          side: BorderSide(color: secColor),
                        ),
                        child: Text(
                          'Followers',
                          style: TextStyle(
                            fontFamily: 'Outfit',
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                            color: darkColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 64),
                      OutlinedButton(
                        onPressed: () async {
                          // WE NEED TO MAKE A LIST VIEW TO DISPLAY THE FOLLOWERS
                          // final res = await ApiService.getFollowers(
                          //   user_id: (user?.id ?? 0).toString() ?? '0',
                          // );
                          // showFollowers(context, (user?.id ?? 0).toString());
                          showFollowing(context, (user?.id ?? 0).toString());
                        },
                        style: OutlinedButton.styleFrom(
                          backgroundColor: secColor,
                          fixedSize: Size(width * 0.33, 46),
                          side: BorderSide(color: secColor),
                        ),
                        child: Text(
                          'Following',
                          style: TextStyle(
                            fontFamily: 'Outfit',
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                            color: darkColor,
                            letterSpacing: 0,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const SizedBox(width: 10),
                      SizedBox(
                        width: width * 0.7,
                        child: Text(
                          UserData.userOne?.bio ?? '',
                          softWrap: true,
                          maxLines: null,
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            color: darkColor,
                            fontFamily: 'Outfit',
                            fontWeight: FontWeight.w400,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // ── action button — different per user type ────────────
                  Row(
                    children: [
                      SizedBox(width: width * 0.08),
                      Align(
                        alignment: Alignment.center,
                        child: isCurrentUser
                            // ── current user → Post About Heritage ────────
                            ? OutlinedButton(
                                onPressed: () =>
                                    Navigator.pushNamed(context, '/addapost'),
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: secColor,
                                  fixedSize: Size(width * 0.8, 59),
                                  side: BorderSide(color: secColor),
                                ),
                                child: Row(
                                  children: [
                                    SvgPicture.asset(
                                      'assets/addicon.svg',
                                      width: 35,
                                      height: 35,
                                    ),
                                    const SizedBox(width: 15),
                                    Text(
                                      'Post About Heritage',
                                      style: TextStyle(
                                        fontFamily: 'Outfit',
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16,
                                        letterSpacing: 0,
                                        color: darkColor,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            // ── other user → Follow button ─────────────────
                            : // ── other user → Follow / Following button ─────────────────────────────
                              _loadingFollow
                            ? const CircularProgressIndicator()
                            : GestureDetector(
                                onTap: _handleFollowTap,
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 250),
                                  width: width * 0.8,
                                  height: 59,
                                  decoration: BoxDecoration(
                                    // ── inverts colors when following ──────────────────────────
                                    color: _isFollowing ? darkColor : secColor,
                                    borderRadius: BorderRadius.circular(20),
                                    // border: Border.all(
                                    //   color: darkColor,
                                    //   width: 1.5,
                                    // ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      _isFollowing ? 'Following' : 'Follow',
                                      style: TextStyle(
                                        fontFamily: 'Outfit',
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16,
                                        color: _isFollowing
                                            ? bgColor
                                            : darkColor, // ← inverted
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                      ),
                    ],
                  ),

                  // ── About section — unchanged ──────────────────────────
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.only(left: 15),
                    child: Align(
                      alignment: Alignment.center,
                      child: Container(
                        width: scale * 0.94,
                        height: 197,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: secColor,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 20, top: 9),
                              child: Text(
                                'About',
                                style: TextStyle(
                                  fontFamily: 'Outfit',
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                  letterSpacing: 0,
                                  color: darkColor,
                                ),
                              ),
                            ),
                            Divider(color: darkColor, endIndent: 20),
                            Padding(
                              padding: const EdgeInsets.only(left: 20, top: 9),
                              child: Row(
                                children: [
                                  SvgPicture.asset(
                                    'assets/location.svg',
                                    width: 25,
                                    height: 25,
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    'City: ${UserData.userOne?.city ?? ''}',
                                    style: TextStyle(
                                      fontFamily: 'Outfit',
                                      fontWeight: FontWeight.w400,
                                      fontSize: 16,
                                      color: darkColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Divider(color: darkColor, endIndent: 20),
                            Padding(
                              padding: const EdgeInsets.only(left: 20, top: 9),
                              child: Row(
                                children: [
                                  SvgPicture.asset(
                                    'assets/heart.svg',
                                    width: 25,
                                    height: 25,
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    'Interest: ${UserData.userOne?.interest ?? ''}',
                                    style: TextStyle(
                                      fontFamily: 'Outfit',
                                      fontWeight: FontWeight.w400,
                                      fontSize: 16,
                                      color: darkColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Divider(color: darkColor, endIndent: 20),
                            Padding(
                              padding: const EdgeInsets.only(left: 20, top: 9),
                              child: Row(
                                children: [
                                  SvgPicture.asset(
                                    'assets/calendar.svg',
                                    width: 25,
                                    height: 25,
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    'Member since $creationDate',
                                    style: TextStyle(
                                      fontFamily: 'Outfit',
                                      fontWeight: FontWeight.w400,
                                      fontSize: 16,
                                      color: darkColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 13),
                  Padding(
                    padding: const EdgeInsets.only(left: 21),
                    child: Text(
                      isCurrentUser
                          ? 'My publications'
                          : '${user.name}\'s publications',
                      style: TextStyle(
                        fontFamily: 'Tajawal-Bold',
                        fontWeight: FontWeight.w800,
                        fontSize: 25,
                        letterSpacing: 0,
                        color: darkColor,
                      ),
                    ),
                  ),

                  // ── posts ──────────────────────────────────────────────
                  Row(
                    children: [
                      SizedBox(
                        width: isDesktop
                            ? width * 0.15
                            : (isTablet ? width * 0.07 : 5),
                      ),
                      Expanded(
                        child: Align(
                          alignment: Alignment.center,
                          child: ListView.builder(
                            itemCount: posts.length,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              return PostDesign(
                                descr: posts[index].description,
                                imagePaths: posts[index].imagePaths,
                                creationDate: posts[index].createdAt,
                                period: posts[index].historicalPer,
                                region: posts[index].localisation,
                                title: posts[index].title,
                                user: user,
                                name: user.name,
                                type: posts[index].monumentType,
                                id: posts[index].id,
                              );
                            },
                          ),
                        ),
                      ),
                      SizedBox(
                        width: isDesktop
                            ? width * 0.15
                            : (isTablet ? width * 0.07 : 5),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
