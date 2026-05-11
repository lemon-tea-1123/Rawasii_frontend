import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:rawasii/globals.dart';
import 'package:rawasii/Classes/user.dart';
import 'package:rawasii/services/api.dart';
import 'package:rawasii/utils/user_data.dart';
import 'package:rawasii/navigation_notifier.dart';
import 'package:rawasii/pages/profile/addapost.dart';
import 'package:rawasii/Classes/post.dart';
import 'comments.dart';

class PostDesign extends StatefulWidget {
  const PostDesign({
    super.key,
    required this.id,
    required this.descr,
    required this.imagePaths,
    required this.creationDate,
    required this.period,
    required this.region,
    required this.title,
    required this.type,
    this.user,
    this.userId,
    this.name,
    this.likeCount = 0, // ← add
    this.commentCount = 0, // ← add
    this.isLiked = false, // ← add
    this.isBookmarked = false, // ← add
  });

  final List<String> imagePaths;
  final String id;
  final String descr;
  final String title;
  final String region;
  final String type;
  final String period;
  final String creationDate;
  final User? user;
  final String? userId;
  final String? name;
  final int likeCount; // ← from backend
  final int commentCount; // ← from backend
  final bool isLiked; // ← from backend (did current user like it?)
  final bool isBookmarked; // ← from backend

  @override
  State<PostDesign> createState() => _PostDesignState();
}

class _PostDesignState extends State<PostDesign> {
  User? _user;
  late bool _isLiked;
  late bool _isBookmarked;
  late int _likeCount;
  late int _commentCount;
  bool _isDeleted = false;
  bool _isLiking = false;
  int _currentImageIndex = 0;
  final PageController _pageController = PageController();

  String get _currentUserId => UserData.userOne?.id.toString() ?? '';
  bool get _isOwner => widget.userId == _currentUserId;

  @override
  void initState() {
    super.initState();
    // ── initialize from widget props — persists across scrolling ──────
    _isLiked = widget.isLiked;
    _isBookmarked = widget.isBookmarked;
    _likeCount = widget.likeCount;
    _commentCount = widget.commentCount;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // ── toggle like ────────────────────────────────────────────────────────
  Future<void> _toggleLike() async {
    if (_isLiked) return; // ← prevent double like (matches backend behavior)

    setState(() {
      _isLiked = true;
      _likeCount = _likeCount + 1;
    });

    await ApiService.addReaction(
      user_id: _currentUserId, // ← use current user not post owner
      post_id: widget.id,
    );
  }

  // ── toggle bookmark ────────────────────────────────────────────────────
  Future<void> _toggleBookmark() async {
    if (_isBookmarked) return; // ← prevent double save

    setState(() => _isBookmarked = true);

    await ApiService.savePost(
      user_id: _currentUserId, // ← use current user
      post_id: widget.id,
    );
  }

  // ── Menu ─────────────────────────────────────────────────────────────
  void _showMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: darkColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            if (_isOwner) ...[
              _menuItem(
                icon: Icons.edit_outlined,
                label: 'Edit post',
                onTap: () {
                  Navigator.pop(context);
                  _openEditPage(context);
                },
              ),
              _menuItem(
                icon: Icons.delete_outline,
                label: 'Delete post',
                color: darkColor,
                onTap: () {
                  Navigator.pop(context);
                  _confirmDelete(context);
                },
              ),
            ] else
              _menuItem(
                icon: Icons.flag_outlined,
                label: 'Report post',
                color: darkColor,
                onTap: () {
                  Navigator.pop(context);
                  _showReportDialog(context);
                },
              ),
            _menuItem(
              icon: Icons.close,
              label: 'Cancel',
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _menuItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    final c = color ?? darkColor;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: c, size: 22),
            const SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(color: c, fontSize: 15, fontFamily: 'Tajawal'),
            ),
          ],
        ),
      ),
    );
  }

  void _openEditPage(BuildContext context) {
    final postData = Post(
      id: widget.id,
      title: widget.title,
      description: widget.descr,
      localisation: widget.region,
      historicalPer: widget.period,
      monumentType: widget.type,
      imagePaths: widget.imagePaths,
      createdAt: widget.creationDate,
    );
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddPost(postToEdit: postData)),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: bgColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Delete this post?',
          style: TextStyle(
            color: darkColor,
            fontFamily: 'Outfit',
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          'This action cannot be undone.',
          style: TextStyle(
            color: darkColor.withOpacity(0.6),
            fontFamily: 'Outfit',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Cancel',
              style: TextStyle(color: darkColor.withOpacity(0.6)),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: darkColor, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    final result = await ApiService.deletePost(
      postId: widget.id,
      userId: _currentUserId,
    );
    if (!mounted) return;
    if (result.containsKey('message')) setState(() => _isDeleted = true);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result['message'] ?? result['error'] ?? 'Done')),
    );
  }

  Future<void> _showReportDialog(BuildContext context) async {
    const reasons = [
      'Spam or misleading',
      'Hate speech',
      'Violence or dangerous content',
      'Harassment or bullying',
      'False historical information',
      'Other',
    ];
    String? selected;
    bool sending = false;
    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, set) => AlertDialog(
          backgroundColor: bgColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Report post',
            style: TextStyle(
              color: darkColor,
              fontFamily: 'Outfit',
              fontWeight: FontWeight.w700,
              fontSize: 17,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Why are you reporting this post?',
                style: TextStyle(
                  color: darkColor.withOpacity(0.65),
                  fontFamily: 'Outfit',
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 12),
              ...reasons.map(
                (r) => RadioListTile<String>(
                  value: r,
                  groupValue: selected,
                  activeColor: darkColor,
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    r,
                    style: TextStyle(
                      color: darkColor,
                      fontFamily: 'Outfit',
                      fontSize: 13,
                    ),
                  ),
                  onChanged: (v) => set(() => selected = v),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                'Cancel',
                style: TextStyle(color: darkColor.withOpacity(0.6)),
              ),
            ),
            TextButton(
              onPressed: (selected == null || sending)
                  ? null
                  : () async {
                      set(() => sending = true);
                      final result = await ApiService.reportPost(
                        userId: _currentUserId,
                        postId: widget.id,
                        reason: selected!,
                      );
                      if (!ctx.mounted) return;
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            result['message'] ?? result['error'] ?? 'Done',
                          ),
                        ),
                      );
                    },
              child: sending
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text(
                      'Submit',
                      style: TextStyle(
                        color: darkColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isDeleted) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: darkColor.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 10, 10),
            child: Row(
              children: [
                _buildAvatar(),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextButton(
                        onPressed: () async {
                          final postOwnerId = widget.userId ?? '';
                          final currentUserId =
                              UserData.userOne?.id.toString() ?? '';
                          if (postOwnerId == currentUserId) {
                            shellNav.goToProfile(null); // own profile
                            return;
                          }
                          // fetch full profile with posts then navigate
                          final user = await ApiService.fetchUserProfile(
                            postOwnerId,
                          );
                          if (user != null) shellNav.goToProfile(user);
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          widget.name ?? 'Unknown',
                          style: TextStyle(
                            fontFamily: 'Tajawal-Bold',
                            color: darkColor,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        widget.creationDate,
                        style: const TextStyle(
                          color: Color(0xFF888888),
                          fontSize: 11,
                          fontFamily: 'Tajawal',
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.more_vert, size: 20),
                  color: const Color(0xFF888888),
                  onPressed: () => _showMenu(context),
                ),
              ],
            ),
          ),

          // ── Image Carousel ────────────────────────────────────────────
          if (widget.imagePaths.isNotEmpty) _buildImageCarousel(),

          // ── Action Bar ────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
            child: Row(
              children: [
                // ── like button + count ──────────────────────────────────
                GestureDetector(
                  onTap: _toggleLike,
                  child: Icon(
                    _isLiked ? Icons.favorite : Icons.favorite_border,
                    size: 24,
                    color: _isLiked ? darkColor : const Color(0xFF888888),
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '$_likeCount',
                  style: TextStyle(
                    color: darkColor.withOpacity(0.7),
                    fontSize: 13,
                  ),
                ),

                const SizedBox(width: 16),

                // ── comment button + count ───────────────────────────────
                GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) => CommentsSheet(
                        postId: int.tryParse(widget.id) ?? 0,
                        postOwnerId: int.tryParse(_currentUserId) ?? 0,
                      ),
                    );
                  },
                  child: const Icon(
                    Icons.chat_bubble_outline,
                    size: 22,
                    color: Color(0xFF888888),
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '$_commentCount',
                  style: TextStyle(
                    color: darkColor.withOpacity(0.7),
                    fontSize: 13,
                  ),
                ),

                const SizedBox(width: 16),

                // ── share button ─────────────────────────────────────────
                GestureDetector(
                  onTap: () {},
                  child: const Icon(
                    Icons.near_me_outlined,
                    size: 22,
                    color: Color(0xFF888888),
                  ),
                ),

                const Spacer(),

                // ── bookmark button ──────────────────────────────────────
                GestureDetector(
                  onTap: _toggleBookmark,
                  child: Icon(
                    _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                    size: 24,
                    color: _isBookmarked ? darkColor : const Color(0xFF888888),
                  ),
                ),
              ],
            ),
          ),

          // ── Title & Description ───────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: TextStyle(
                    fontFamily: 'Tajawal-Bold',
                    color: darkColor,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.descr,
                  style: const TextStyle(
                    color: Color(0xFF555555),
                    fontSize: 13,
                    fontFamily: 'Tajawal',
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),

          // ── Tags ──────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 4, 14, 14),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (widget.period.isNotEmpty)
                  _buildTag(widget.period, _TagColor.primary),
                if (widget.region.isNotEmpty)
                  _buildTag(widget.region, _TagColor.secondary),
                if (widget.type.isNotEmpty)
                  _buildTag(widget.type, _TagColor.accent),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    final imagePath = _user?.imagePath ?? '';
    return CircleAvatar(
      radius: 20,
      backgroundColor: Colors.grey[300],
      backgroundImage: imagePath.isNotEmpty ? NetworkImage(imagePath) : null,
      child: imagePath.isEmpty
          ? Icon(Icons.person, color: darkColor, size: 20)
          : null,
    );
  }

  Widget _buildImageCarousel() {
    final bool hasMultiple = widget.imagePaths.length > 1;
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.zero,
          child: SizedBox(
            height: 240,
            child: hasMultiple
                ? PageView.builder(
                    controller: _pageController,
                    itemCount: widget.imagePaths.length,
                    onPageChanged: (i) =>
                        setState(() => _currentImageIndex = i),
                    itemBuilder: (ctx, i) => _buildImageItem(i),
                  )
                : _buildImageItem(0),
          ),
        ),
        if (hasMultiple) ...[
          Positioned(
            bottom: 10,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                widget.imagePaths.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: _currentImageIndex == i ? 18 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: _currentImageIndex == i
                        ? Colors.white
                        : Colors.white.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 10,
            right: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${_currentImageIndex + 1} / ${widget.imagePaths.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildImageItem(int index) {
    return GestureDetector(
      onTap: () => _openFullScreen(index),
      child: Container(
        color: Colors.grey[200],
        child: Image.network(
          widget.imagePaths[index],
          fit: BoxFit.cover,
          width: double.infinity,
          errorBuilder: (_, __, ___) =>
              const Center(child: Icon(Icons.broken_image, size: 40)),
        ),
      ),
    );
  }

  Widget _buildTag(String label, _TagColor tagColor) {
    final Color bg;
    final Color textClr;
    final Color dotClr;
    switch (tagColor) {
      case _TagColor.primary:
        bg = const Color(0xFF536872);
        textClr = Colors.white;
        dotClr = Colors.white.withOpacity(0.75);
        break;
      case _TagColor.secondary:
        bg = const Color(0xFF674A3A);
        textClr = Colors.white;
        dotClr = Colors.white.withOpacity(0.75);
        break;
      case _TagColor.accent:
        bg = const Color(0xFF29150C);
        textClr = Colors.white;
        dotClr = Colors.white.withOpacity(0.75);
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: dotClr, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: textClr,
              fontSize: 12,
              fontFamily: 'Tajawal-Bold',
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _openFullScreen(int startIndex) {
    showDialog(
      context: context,
      barrierColor: Colors.black,
      builder: (_) => _FullScreenGallery(
        imagePaths: widget.imagePaths,
        initialIndex: startIndex,
      ),
    );
  }
}

enum _TagColor { primary, secondary, accent }

class _FullScreenGallery extends StatefulWidget {
  const _FullScreenGallery({
    required this.imagePaths,
    required this.initialIndex,
  });
  final List<String> imagePaths;
  final int initialIndex;

  @override
  State<_FullScreenGallery> createState() => _FullScreenGalleryState();
}

class _FullScreenGalleryState extends State<_FullScreenGallery> {
  late int _current;
  late PageController _controller;

  @override
  void initState() {
    super.initState();
    _current = widget.initialIndex;
    _controller = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          '${_current + 1} / ${widget.imagePaths.length}',
          style: const TextStyle(color: Colors.white, fontSize: 14),
        ),
      ),
      body: PageView.builder(
        controller: _controller,
        itemCount: widget.imagePaths.length,
        onPageChanged: (i) => setState(() => _current = i),
        itemBuilder: (ctx, i) => InteractiveViewer(
          child: Center(
            child: Image.network(
              widget.imagePaths[i],
              errorBuilder: (_, __, ___) => const Icon(
                Icons.broken_image,
                color: Color.fromARGB(255, 164, 150, 130),
                size: 60,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
