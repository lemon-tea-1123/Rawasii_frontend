import 'package:flutter/material.dart';
import 'package:rawasii/globals.dart';
import 'package:rawasii/services/api.dart';
import 'package:rawasii/utils/user_data.dart';

class CommentsSheet extends StatefulWidget {
  final int postId;
  final int postOwnerId;

  const CommentsSheet({
    super.key,
    required this.postId,
    required this.postOwnerId,
  });

  @override
  State<CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends State<CommentsSheet> {
  final TextEditingController _controller = TextEditingController();
  List<dynamic> _comments = [];
  bool _isLoading = true;
  bool _sending = false;

  // ── get current user id ──────────────────────────────────────────────
  int get _currentUserId => UserData.userOne?.id ?? 0;

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadComments() async {
    setState(() => _isLoading = true);
    final fetched = await ApiService.getComments(widget.postId);
    setState(() {
      _comments = fetched;
      _isLoading = false;
    });
  }

  Future<void> _sendComment() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _sending) return;

    setState(() => _sending = true);
    // in CommentsSheet.sendComment()
    final result = await ApiService.createComment(
      userId: _currentUserId,
      postId: widget.postId,
      content: text,
      postOwnerId: widget.postOwnerId.toString(), // ← pass post owner
    );

    if (result != null && result['success'] == true) {
      _controller.clear();
      await _loadComments();
    } else {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Failed to send comment')));
      }
    }
    setState(() => _sending = false);
  }

  Future<void> _toggleLike(int index) async {
    final comment = _comments[index];
    final commentId = comment['id_comments'] as int;
    final isLiked = comment['isLiked'] as bool? ?? false;

    final success = await ApiService.likeComment(
      commentId: commentId,
      isLiking: !isLiked,
    );

    if (success) {
      setState(() {
        _comments[index]['isLiked'] = !isLiked;
        _comments[index]['reaction_count'] =
            ((comment['reaction_count'] as int? ?? 0) + (!isLiked ? 1 : -1))
                .clamp(0, 999999);
      });
    }
  }

  Future<void> _reportComment(int index) async {
    final commentId = _comments[index]['id_comments'] as int;
    final success = await ApiService.reportComment(
      commentId: commentId,
      userId: _currentUserId,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Comment reported' : 'Already reported'),
        ),
      );
    }
  }

  String _timeAgo(String? dt) {
    if (dt == null) return '';
    final diff = DateTime.now().difference(DateTime.parse(dt));
    if (diff.inDays > 365) return '${diff.inDays ~/ 365}y ago';
    if (diff.inDays > 30) return '${diff.inDays ~/ 30}mo ago';
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}min ago';
    return 'just now';
  }

  @override
  Widget build(BuildContext context) {
    // ✅ no Scaffold — this is a bottom sheet widget
    return Container(
      decoration: const BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── drag handle ────────────────────────────────────────────────
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: darkColor.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // ── header ────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  'Comments',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: darkColor,
                    fontFamily: 'Tajawal-Bold',
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: secColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _comments.length.toString(),
                    style: TextStyle(color: darkColor),
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(Icons.close, color: darkColor),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          Divider(color: secColor),

          // ── comments list ─────────────────────────────────────────────
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.5,
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _comments.isEmpty
                ? Center(
                    child: Text(
                      'No comments yet.\nBe the first!',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: darkColor),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _comments.length,
                    itemBuilder: (context, index) {
                      final c = _comments[index];
                      final user = c['user'] as Map? ?? {};
                      return _CommentItem(
                        name: user['username'] ?? 'Unknown',
                        time: _timeAgo(c['created_at'] as String?),
                        comment: c['content'] ?? '',
                        likes: c['reaction_count'] as int? ?? 0,
                        isLiked: c['isLiked'] as bool? ?? false,
                        onLikeTap: () => _toggleLike(index),
                        onReportTap: () => _reportComment(index),
                      );
                    },
                  ),
          ),

          // ── input bar ─────────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 8,
              left: 10,
              right: 10,
              top: 8,
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: secColor,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      onSubmitted: (_) => _sendComment(),
                      decoration: InputDecoration(
                        hintText: 'Write a comment...',
                        hintStyle: TextStyle(color: darkColor.withOpacity(0.5)),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  _sending
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : IconButton(
                          icon: Icon(Icons.send, color: darkColor),
                          onPressed: _sendComment,
                        ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── single comment item ────────────────────────────────────────────────────
class _CommentItem extends StatelessWidget {
  final String name;
  final String time;
  final String comment;
  final int likes;
  final bool isLiked;
  final VoidCallback onLikeTap;
  final VoidCallback onReportTap;

  const _CommentItem({
    required this.name,
    required this.time,
    required this.comment,
    required this.likes,
    required this.isLiked,
    required this.onLikeTap,
    required this.onReportTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: thirdColor,
            child: const Icon(Icons.person, color: Colors.white),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: darkColor,
                        fontFamily: 'Tajawal-Bold',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      time,
                      style: TextStyle(
                        fontSize: 12,
                        color: darkColor.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(comment, style: TextStyle(color: darkColor)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    GestureDetector(
                      onTap: onReportTap,
                      child: Text(
                        'Report',
                        style: TextStyle(
                          color: darkColor.withOpacity(0.5),
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: onLikeTap,
                      child: Icon(
                        isLiked ? Icons.favorite : Icons.favorite_border,
                        size: 18,
                        color: isLiked ? Colors.red : darkColor,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$likes',
                      style: TextStyle(color: darkColor, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
