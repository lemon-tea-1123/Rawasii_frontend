import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/api.dart';

class PostItem {
  final int id;
  final String author;
  final String email;
  final String title;
  final String desc;
  final int likes;
  final int comments;
  final String time;
  final List<String> imageUrls;
  final List<Map<String, dynamic>> commentsList;
  final List<String> likedBy;

  PostItem({
    required this.id,
    required this.author,
    required this.email,
    required this.title,
    required this.desc,
    required this.likes,
    required this.comments,
    required this.time,
    required this.imageUrls,
    required this.commentsList,
    required this.likedBy,
  });

  factory PostItem.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>? ?? {};
    final images = json['image'] as List<dynamic>? ?? [];
    final commentsList = json['comment'] as List<dynamic>? ?? [];
    final reactions = json['reaction'] as List<dynamic>? ?? [];
    return PostItem(
      id: json['id_post'] as int,
      author: user['username'] ?? 'Unknown',
      email: user['email'] ?? '',
      title: json['title'] ?? '',
      desc: json['description'] ?? '',
      likes: json['reaction_count'] ?? 0,
      comments: commentsList.length,
      time: json['created_at'] ?? '',
      imageUrls: images
          .map((img) => img['image_path'] as String? ?? '')
          .where((url) => url.isNotEmpty)
          .toList(),
      commentsList: commentsList.map((c) => c as Map<String, dynamic>).toList(),
      likedBy: reactions.map((r) {
        final u = r['user'] as Map<String, dynamic>? ?? {};
        return u['username'] as String? ?? '';
      }).toList(),
    );
  }
}

class VisitItem {
  final int id;
  final String author;
  final String email;
  final String title;
  final String desc;
  final int likes;
  final String time;
  final List<String> imageUrls;

  VisitItem({
    required this.id,
    required this.author,
    required this.email,
    required this.title,
    required this.desc,
    required this.likes,
    required this.time,
    required this.imageUrls,
  });

  factory VisitItem.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>? ?? {};
    final images = json['image'] as List<dynamic>? ?? [];
    return VisitItem(
      id: json['id_visit'] as int,
      author: user['username'] ?? 'Unknown',
      email: user['email'] ?? '',
      title: json['monument_name'] ?? '',
      desc: json['description'] ?? '',
      likes: json['reaction_count'] ?? 0,
      time: json['created_at'] ?? '',
      imageUrls: images
          .map((img) => img['image_path'] as String? ?? '')
          .where((url) => url.isNotEmpty)
          .toList(),
    );
  }
}

class MonumentItem {
  final int id;
  final String author;
  final String email;
  final String title;
  final String desc;
  final String location;
  final String dangerType;
  final String urgency;
  String status;
  final String date;
  final List<String> imageUrls;

  MonumentItem({
    required this.id,
    required this.author,
    required this.email,
    required this.title,
    required this.desc,
    required this.location,
    required this.dangerType,
    required this.urgency,
    required this.status,
    required this.date,
    required this.imageUrls,
  });

  factory MonumentItem.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>? ?? {};
    final images = json['image'] as List<dynamic>? ?? [];
    return MonumentItem(
      id: json['monument_in_danger_id'] as int,
      author: user['username'] ?? 'Unknown',
      email: user['email'] ?? '',
      title: json['monument_name'] ?? '',
      desc: json['description'] ?? '',
      location: json['region'] ?? '',
      dangerType: json['danger_type'] ?? '',
      urgency: json['urgence_level'] ?? 'Low',
      status: json['status'] ?? 'Reported',
      date: json['created_at'] ?? '',
      imageUrls: images
          .map((img) => img['image_path'] as String? ?? '')
          .where((url) => url.isNotEmpty)
          .toList(),
    );
  }
}

class ReportedItem {
  final int postId;
  final String author;
  final String email;
  final String title;
  final String desc;
  final int reports;
  final String time;
  final List<String> imageUrls;
  final List<Map<String, dynamic>> commentsList;
  final List<String> likedBy;
  final int likes;
  final List<Map<String, dynamic>> reporters;

  ReportedItem({
    required this.postId,
    required this.author,
    required this.email,
    required this.title,
    required this.desc,
    required this.reports,
    required this.time,
    required this.imageUrls,
    required this.commentsList,
    required this.likedBy,
    required this.likes,
    required this.reporters,
  });

  factory ReportedItem.fromJson(Map<String, dynamic> json) {
    final post = json['post'] as Map<String, dynamic>? ?? {};
    final postUser = post['user'] as Map<String, dynamic>? ?? {};
    final images = post['image'] as List<dynamic>? ?? [];
    final commentsList = post['comment'] as List<dynamic>? ?? [];
    final reactions = post['reaction'] as List<dynamic>? ?? [];
    final reportersList = json['reporters'] as List<dynamic>? ?? [];

    return ReportedItem(
      postId: json['post_id'] as int? ?? 0,
      author: postUser['username'] ?? 'Unknown',
      email: postUser['email'] ?? '',
      title: post['title'] ?? '',
      desc: post['description'] ?? '',
      reports: json['signalements_count'] as int? ?? 1,
      time: json['created_at'] ?? '',
      imageUrls: images
          .map((img) => img['image_path'] as String? ?? '')
          .where((url) => url.isNotEmpty)
          .toList(),
      commentsList: commentsList.map((c) => c as Map<String, dynamic>).toList(),
      likedBy: reactions.map((r) {
        final u = r['user'] as Map<String, dynamic>? ?? {};
        return u['username'] as String? ?? '';
      }).toList(),
      likes: post['reaction_count'] ?? 0,
      reporters: reportersList.map((r) => r as Map<String, dynamic>).toList(),
    );
  }
}

class ManagePostsPage extends StatefulWidget {
  const ManagePostsPage({super.key});

  @override
  State<ManagePostsPage> createState() => _ManagePostsPageState();
}

class _ManagePostsPageState extends State<ManagePostsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List<PostItem> _posts = [];
  List<VisitItem> _visits = [];
  List<MonumentItem> _monuments = [];
  List<ReportedItem> _reported = [];
  bool _loading = true;

  static const Color kBrown = Color(0xFF4A2C24);
  static const Color kBg = Color(0xFFF2EDE6);
  static const Color kTabBg = Color(0xFFE0D5C8);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() => setState(() {}));
    _loadAll();
  }

  Future<void> _loadAll() async {
    setState(() => _loading = true);
    final results = await Future.wait([
      ApiService.adminGetPosts(),
      ApiService.adminGetVisits(),
      ApiService.adminGetMonuments(),
      ApiService.adminGetReportedPosts(),
    ]);
    setState(() {
      _posts = results[0].map((e) => PostItem.fromJson(e)).toList();
      _visits = results[1].map((e) => VisitItem.fromJson(e)).toList();
      _monuments = results[2].map((e) => MonumentItem.fromJson(e)).toList();
      _reported = results[3].map((e) => ReportedItem.fromJson(e)).toList();
      _loading = false;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: GoogleFonts.tajawal(color: Colors.white)),
        backgroundColor: kBrown,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Color _urgencyColor(String u) {
    switch (u.toLowerCase()) {
      case 'critical':
        return const Color(0xFFB71C1C);
      case 'high':
        return const Color(0xFFE65100);
      case 'medium':
        return const Color(0xFFF9A825);
      default:
        return const Color(0xFF2E7D32);
    }
  }

  Color _statusColor(String s) {
    switch (s.toLowerCase()) {
      case 'saved':
        return const Color(0xFF2E7D32);
      case 'under intervention':
        return const Color(0xFF1565C0);
      case 'lost':
        return const Color(0xFF4A148C);
      default:
        return kBrown;
    }
  }

  void _openImageViewer(List<String> urls, int initialIndex) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            _ImageViewerPage(urls: urls, initialIndex: initialIndex),
      ),
    );
  }

  void _showLikers(List<String> likers) {
    showModalBottomSheet(
      context: context,
      backgroundColor: kBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: _dragHandle()),
            Text(
              '${likers.length} people liked this',
              style: GoogleFonts.tajawal(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: kBrown,
              ),
            ),
            const SizedBox(height: 12),
            likers.isEmpty
                ? Text(
                    'No likes yet',
                    style: GoogleFonts.tajawal(color: kBrown.withOpacity(0.5)),
                  )
                : Column(
                    children: likers
                        .map(
                          (username) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 16,
                                  backgroundColor: kBrown.withOpacity(0.15),
                                  child: Text(
                                    username.isNotEmpty
                                        ? username[0].toUpperCase()
                                        : '?',
                                    style: GoogleFonts.tajawal(
                                      color: kBrown,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  username,
                                  style: GoogleFonts.tajawal(color: kBrown),
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                  ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showComments(List<Map<String, dynamic>> comments) {
    showModalBottomSheet(
      context: context,
      backgroundColor: kBg,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.5,
        maxChildSize: 0.9,
        minChildSize: 0.3,
        builder: (_, scrollController) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: _dragHandle()),
              Text(
                '${comments.length} comments',
                style: GoogleFonts.tajawal(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: kBrown,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: comments.isEmpty
                    ? Center(
                        child: Text(
                          'No comments yet',
                          style: GoogleFonts.tajawal(
                            color: kBrown.withOpacity(0.5),
                          ),
                        ),
                      )
                    : ListView.separated(
                        controller: scrollController,
                        itemCount: comments.length,
                        separatorBuilder: (_, __) =>
                            Divider(color: kBrown.withOpacity(0.1)),
                        itemBuilder: (_, i) {
                          final c = comments[i];
                          final u = c['user'] as Map<String, dynamic>? ?? {};
                          final username = u['username'] ?? 'Unknown';
                          final content = c['content'] ?? '';
                          final date = c['created_at'] ?? '';
                          final commentId = c['id_comments'] as int?;
                          final reportList =
                              c['report'] as List<dynamic>? ?? [];
                          final pendingReports = reportList
                              .where((r) => (r['status'] ?? '') == 'pending')
                              .toList();
                          final isReported = pendingReports.isNotEmpty;
                          final reportReason = isReported
                              ? (pendingReports.first['reason'] ??
                                    'Not specified')
                              : null;

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CircleAvatar(
                                      radius: 18,
                                      backgroundColor: isReported
                                          ? Colors.red.withOpacity(0.15)
                                          : kBrown.withOpacity(0.15),
                                      child: Text(
                                        username.isNotEmpty
                                            ? username[0].toUpperCase()
                                            : '?',
                                        style: GoogleFonts.tajawal(
                                          color: isReported
                                              ? Colors.red
                                              : kBrown,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                username,
                                                style: GoogleFonts.tajawal(
                                                  fontWeight: FontWeight.w700,
                                                  color: kBrown,
                                                  fontSize: 13,
                                                ),
                                              ),
                                              if (isReported) ...[
                                                const SizedBox(width: 6),
                                                Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 6,
                                                        vertical: 2,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.red
                                                        .withOpacity(0.1),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          6,
                                                        ),
                                                    border: Border.all(
                                                      color: Colors.red
                                                          .withOpacity(0.3),
                                                    ),
                                                  ),
                                                  child: Text(
                                                    '🚩 Reported',
                                                    style: GoogleFonts.tajawal(
                                                      fontSize: 9,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color:
                                                          Colors.red.shade700,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                          Text(
                                            content,
                                            style: GoogleFonts.tajawal(
                                              color: kBrown.withOpacity(0.75),
                                              fontSize: 12,
                                            ),
                                          ),
                                          if (isReported &&
                                              reportReason != null)
                                            Container(
                                              margin: const EdgeInsets.only(
                                                top: 4,
                                              ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 4,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: Colors.red.withOpacity(
                                                  0.07,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                'Reason: $reportReason',
                                                style: GoogleFonts.tajawal(
                                                  fontSize: 10,
                                                  color: Colors.red.shade800,
                                                  fontStyle: FontStyle.italic,
                                                ),
                                              ),
                                            ),
                                          Text(
                                            date,
                                            style: GoogleFonts.tajawal(
                                              color: kBrown.withOpacity(0.4),
                                              fontSize: 10,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                if (commentId != null)
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      left: 46,
                                      top: 6,
                                    ),
                                    child: Row(
                                      children: [
                                        if (isReported) ...[
                                          _commentActionBtn(
                                            label: 'Approve',
                                            icon: Icons.check_circle_outline,
                                            color: const Color(0xFF2E7D32),
                                            onTap: () async {
                                              final ok =
                                                  await ApiService.adminApproveComment(
                                                    commentId,
                                                  );
                                              if (ok) {
                                                Navigator.pop(context);
                                                _showSnack('Comment approved');
                                                _loadAll();
                                              } else {
                                                _showSnack(
                                                  'Error approving comment',
                                                );
                                              }
                                            },
                                          ),
                                          const SizedBox(width: 8),
                                        ],
                                        _commentActionBtn(
                                          label: 'Delete',
                                          icon: Icons.delete_outline,
                                          color: Colors.red,
                                          onTap: () async {
                                            final ok =
                                                await ApiService.adminDeleteComment(
                                                  commentId,
                                                );
                                            if (ok) {
                                              Navigator.pop(context);
                                              _showSnack('Comment deleted');
                                              _loadAll();
                                            } else {
                                              _showSnack(
                                                'Error deleting comment',
                                              );
                                            }
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showReporters(List<Map<String, dynamic>> reporters) {
    showModalBottomSheet(
      context: context,
      backgroundColor: kBg,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.5,
        maxChildSize: 0.85,
        minChildSize: 0.3,
        builder: (_, scrollController) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: _dragHandle()),
              Row(
                children: [
                  const Icon(Icons.flag, color: Colors.red, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    '${reporters.length} report(s)',
                    style: GoogleFonts.tajawal(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: kBrown,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: reporters.isEmpty
                    ? Center(
                        child: Text(
                          'No reports',
                          style: GoogleFonts.tajawal(
                            color: kBrown.withOpacity(0.5),
                          ),
                        ),
                      )
                    : ListView.separated(
                        controller: scrollController,
                        itemCount: reporters.length,
                        separatorBuilder: (_, __) =>
                            Divider(color: kBrown.withOpacity(0.1)),
                        itemBuilder: (_, i) {
                          final rep = reporters[i];
                          final username =
                              rep['username'] as String? ?? 'Unknown';
                          final reason =
                              rep['reason'] as String? ?? 'Not specified';
                          final date = rep['date'] as String? ?? '';
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundColor: Colors.red.withOpacity(0.1),
                                  child: Text(
                                    username.isNotEmpty
                                        ? username[0].toUpperCase()
                                        : '?',
                                    style: GoogleFonts.tajawal(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        username,
                                        style: GoogleFonts.tajawal(
                                          fontWeight: FontWeight.w700,
                                          color: kBrown,
                                          fontSize: 13,
                                        ),
                                      ),
                                      Container(
                                        margin: const EdgeInsets.only(top: 4),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 5,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.red.withOpacity(0.08),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          border: Border.all(
                                            color: Colors.red.withOpacity(0.2),
                                          ),
                                        ),
                                        child: Text(
                                          '🚩 $reason',
                                          style: GoogleFonts.tajawal(
                                            color: Colors.red.shade800,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                      if (date.isNotEmpty)
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            top: 3,
                                          ),
                                          child: Text(
                                            date,
                                            style: GoogleFonts.tajawal(
                                              color: kBrown.withOpacity(0.4),
                                              fontSize: 10,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPostOptions({
    required String author,
    required String email,
    required VoidCallback onDelete,
    VoidCallback? onApprove,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: kBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _dragHandle(),
            _bsUserRow(author, email),
            const SizedBox(height: 16),
            Divider(color: kBrown.withOpacity(0.15)),
            if (onApprove != null)
              _bsActionTile(
                icon: Icons.check_circle_outline,
                label: 'Approve post',
                color: const Color(0xFF2E7D32),
                onTap: () {
                  Navigator.pop(context);
                  onApprove();
                },
              ),
            _bsActionTile(
              icon: Icons.delete_outline,
              label: 'Delete post',
              color: Colors.red,
              onTap: () {
                Navigator.pop(context);
                onDelete();
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showMonumentOptions(MonumentItem m, int index) {
    String tempStatus = m.status;
    const statuses = ['Reported', 'Under intervention', 'Saved', 'Lost'];

    showModalBottomSheet(
      context: context,
      backgroundColor: kBg,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setLocal) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: _dragHandle()),
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: kBrown.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.account_balance,
                      color: kBrown,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          m.title,
                          style: GoogleFonts.tajawal(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: kBrown,
                          ),
                        ),
                        Text(
                          'by ${m.author}',
                          style: GoogleFonts.tajawal(
                            fontSize: 12,
                            color: kBrown.withOpacity(0.55),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Divider(color: kBrown.withOpacity(0.15)),
              Text(
                'Change status',
                style: GoogleFonts.tajawal(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: kBrown.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: statuses.map((s) {
                  final selected = tempStatus == s;
                  return GestureDetector(
                    onTap: () => setLocal(() => tempStatus = s),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: selected
                            ? kBrown
                            : Colors.white.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: kBrown.withOpacity(0.35),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        s,
                        style: GoogleFonts.tajawal(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: selected ? Colors.white : kBrown,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kBrown,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () async {
                    Navigator.pop(context);
                    final ok = await ApiService.adminUpdateMonumentStatus(
                      m.id,
                      tempStatus,
                    );
                    if (ok) {
                      setState(() => _monuments[index].status = tempStatus);
                      _showSnack('Status updated to $tempStatus');
                    } else {
                      _showSnack('Error updating status');
                    }
                  },
                  child: Text(
                    'Confirm status',
                    style: GoogleFonts.tajawal(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Divider(color: kBrown.withOpacity(0.15)),
              _bsActionTile(
                icon: Icons.delete_outline,
                label: 'Delete monument',
                color: Colors.red,
                onTap: () async {
                  Navigator.pop(context);
                  final ok = await ApiService.adminDeleteMonument(m.id);
                  if (ok) {
                    setState(() => _monuments.removeAt(index));
                    _showSnack('Monument deleted');
                  } else {
                    _showSnack('Error deleting monument');
                  }
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dragHandle() => Container(
    width: 40,
    height: 4,
    margin: const EdgeInsets.only(bottom: 18),
    decoration: BoxDecoration(
      color: kBrown.withOpacity(0.3),
      borderRadius: BorderRadius.circular(2),
    ),
  );

  Widget _bsUserRow(String name, String email) => Row(
    children: [
      CircleAvatar(
        radius: 22,
        backgroundColor: kBrown.withOpacity(0.15),
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : '?',
          style: GoogleFonts.tajawal(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: kBrown,
          ),
        ),
      ),
      const SizedBox(width: 12),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: GoogleFonts.tajawal(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: kBrown,
            ),
          ),
          Text(
            email,
            style: GoogleFonts.tajawal(
              fontSize: 11,
              color: kBrown.withOpacity(0.55),
            ),
          ),
        ],
      ),
    ],
  );

  Widget _bsActionTile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    final c = color ?? kBrown;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: c.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: c, size: 20),
      ),
      title: Text(
        label,
        style: GoogleFonts.tajawal(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: c,
        ),
      ),
      onTap: onTap,
    );
  }

  Widget _commentActionBtn({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.tajawal(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imageSection(List<String> urls, String emoji) {
    if (urls.isEmpty) {
      return ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
        child: Container(
          height: 220,
          width: double.infinity,
          color: const Color(0xFFD9CFC5),
          child: Center(
            child: Text(emoji, style: const TextStyle(fontSize: 48)),
          ),
        ),
      );
    }
    if (urls.length == 1) {
      return ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
        child: GestureDetector(
          onTap: () => _openImageViewer(urls, 0),
          child: SizedBox(
            width: double.infinity,
            height: 220,
            child: Image.network(
              urls[0],
              width: double.infinity,
              height: 220,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) {
                return Container(
                  height: 220,
                  width: double.infinity,
                  color: const Color(0xFFD9CFC5),
                  child: Center(
                    child: Text(emoji, style: const TextStyle(fontSize: 48)),
                  ),
                );
              },
            ),
          ),
        ),
      );
    }
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
      child: SizedBox(
        height: 220,
        width: double.infinity,
        child: urls.length == 2
            ? Row(
                children: [
                  Expanded(child: _gridImageTile(urls[0], urls, 0)),
                  const SizedBox(width: 2),
                  Expanded(child: _gridImageTile(urls[1], urls, 1)),
                ],
              )
            : Row(
                children: [
                  Expanded(child: _gridImageTile(urls[0], urls, 0)),
                  const SizedBox(width: 2),
                  Expanded(
                    child: Column(
                      children: [
                        Expanded(child: _gridImageTile(urls[1], urls, 1)),
                        const SizedBox(height: 2),
                        Expanded(
                          child: urls.length > 3
                              ? Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    _gridImageTile(urls[2], urls, 2),
                                    Container(
                                      color: Colors.black45,
                                      child: Center(
                                        child: Text(
                                          '+${urls.length - 2}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : _gridImageTile(urls[2], urls, 2),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _gridImageTile(String url, List<String> allUrls, int index) {
    return GestureDetector(
      onTap: () => _openImageViewer(allUrls, index),
      child: Image.network(
        url,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (_, __, ___) {
          return Container(
            color: const Color(0xFFD9CFC5),
            child: const Center(
              child: Icon(Icons.broken_image, color: Colors.grey),
            ),
          );
        },
      ),
    );
  }

  Widget _postCard(PostItem p, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.62),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _imageSection(p.imageUrls, '🕌'),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  p.title,
                  style: GoogleFonts.tajawal(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: kBrown,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  p.desc,
                  style: GoogleFonts.tajawal(
                    fontSize: 12,
                    color: kBrown.withOpacity(0.7),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => _showLikers(p.likedBy),
                      child: _stat('❤️', '${p.likes}'),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: () => _showComments(p.commentsList),
                      child: _stat('💬', '${p.commentsList.length}'),
                    ),
                    const Spacer(),
                    _tagWidget(
                      'Post',
                      const Color(0xFF534AB7),
                      const Color(0xFFEEEDFE),
                    ),
                    _moreBtn(
                      () => _showPostOptions(
                        author: p.author,
                        email: p.email,
                        onDelete: () async {
                          final ok = await ApiService.adminDeletePost(p.id);
                          if (ok) {
                            setState(() => _posts.removeAt(index));
                            _showSnack('Post deleted');
                          } else {
                            _showSnack('Error deleting post');
                          }
                        },
                      ),
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

  Widget _visitCard(VisitItem v, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.62),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _imageSection(v.imageUrls, '🏛'),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  v.title,
                  style: GoogleFonts.tajawal(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: kBrown,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  v.desc,
                  style: GoogleFonts.tajawal(
                    fontSize: 12,
                    color: kBrown.withOpacity(0.7),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _stat('❤️', '${v.likes}'),
                    const Spacer(),
                    _tagWidget(
                      'Visit',
                      const Color(0xFF0F6E56),
                      const Color(0xFFE1F5EE),
                    ),
                    _moreBtn(
                      () => _showPostOptions(
                        author: v.author,
                        email: v.email,
                        onDelete: () async {
                          final ok = await ApiService.adminDeleteVisit(v.id);
                          if (ok) {
                            setState(() => _visits.removeAt(index));
                            _showSnack('Visit deleted');
                          } else {
                            _showSnack('Error deleting visit');
                          }
                        },
                      ),
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

  Widget _monumentCard(MonumentItem m, int index) {
    final uc = _urgencyColor(m.urgency);
    final sc = _statusColor(m.status);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.62),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _imageSection(m.imageUrls, '🏛'),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  m.title,
                  style: GoogleFonts.tajawal(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: kBrown,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '📍 ${m.location} · ${m.date}',
                  style: GoogleFonts.tajawal(
                    fontSize: 11,
                    color: kBrown.withOpacity(0.55),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  m.dangerType,
                  style: GoogleFonts.tajawal(
                    fontSize: 12,
                    color: kBrown.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  m.desc,
                  style: GoogleFonts.tajawal(
                    fontSize: 12,
                    color: kBrown.withOpacity(0.7),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: uc.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: uc, width: 1),
                      ),
                      child: Text(
                        m.urgency,
                        style: GoogleFonts.tajawal(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: uc,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: sc.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        m.status,
                        style: GoogleFonts.tajawal(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: sc,
                        ),
                      ),
                    ),
                    const Spacer(),
                    _moreBtn(() => _showMonumentOptions(m, index)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _reportedCard(ReportedItem r, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.62),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _imageSection(r.imageUrls, '⚠️'),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  r.title,
                  style: GoogleFonts.tajawal(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: kBrown,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  r.desc,
                  style: GoogleFonts.tajawal(
                    fontSize: 12,
                    color: kBrown.withOpacity(0.7),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => _showLikers(r.likedBy),
                      child: _stat('❤️', '${r.likes}'),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: () => _showComments(r.commentsList),
                      child: _stat('💬', '${r.commentsList.length}'),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: () => _showReporters(r.reporters),
                      child: _stat('🚩', '${r.reports}'),
                    ),
                    const Spacer(),
                    _tagWidget(
                      'Reported',
                      const Color(0xFFA32D2D),
                      const Color(0xFFFCEBEB),
                    ),
                    _moreBtn(
                      () => _showPostOptions(
                        author: r.author,
                        email: r.email,
                        onDelete: () async {
                          final ok = await ApiService.adminDeleteReportedPost(
                            r.postId,
                          );
                          if (ok) {
                            setState(() => _reported.removeAt(index));
                            _showSnack('Post deleted');
                          } else {
                            _showSnack('Error deleting post');
                          }
                        },
                        onApprove: () async {
                          final ok = await ApiService.adminApprovePost(
                            r.postId,
                          );
                          if (ok) {
                            setState(() => _reported.removeAt(index));
                            _showSnack('Post approved ✓');
                          } else {
                            _showSnack('Error approving post');
                          }
                        },
                      ),
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

  Widget _stat(String icon, String value) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(icon, style: const TextStyle(fontSize: 13)),
      const SizedBox(width: 3),
      Text(
        value,
        style: GoogleFonts.tajawal(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: kBrown.withOpacity(0.65),
        ),
      ),
    ],
  );

  Widget _tagWidget(String label, Color color, Color bgColor) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    margin: const EdgeInsets.only(right: 4),
    decoration: BoxDecoration(
      color: bgColor,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(
      label,
      style: GoogleFonts.tajawal(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        color: color,
      ),
    ),
  );

  Widget _moreBtn(VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: const Icon(Icons.more_vert, color: kBrown, size: 22),
  );

  Widget _emptyState() => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.inbox_outlined, size: 52, color: kBrown.withOpacity(0.3)),
        const SizedBox(height: 12),
        Text(
          'Nothing here yet',
          style: GoogleFonts.tajawal(
            fontSize: 15,
            color: kBrown.withOpacity(0.55),
          ),
        ),
      ],
    ),
  );

  Tab _buildTab(String label, int count) => Tab(
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label),
        if (count > 0) ...[
          const SizedBox(width: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$count',
              style: GoogleFonts.tajawal(
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: kBrown))
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Icon(
                            Icons.arrow_back,
                            color: kBrown,
                            size: 24,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'Manage Posts',
                          style: GoogleFonts.tajawal(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: kBrown,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.refresh, color: kBrown),
                          onPressed: _loadAll,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: kTabBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      indicator: BoxDecoration(
                        color: kBrown,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      indicatorSize: TabBarIndicatorSize.tab,
                      labelColor: Colors.white,
                      unselectedLabelColor: kBrown,
                      labelStyle: GoogleFonts.tajawal(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                      unselectedLabelStyle: GoogleFonts.tajawal(fontSize: 12),
                      tabs: [
                        _buildTab('Posts', _posts.length),
                        _buildTab('Visits', _visits.length),
                        _buildTab('Monuments', _monuments.length),
                        _buildTab('Reported', _reported.length),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _posts.isEmpty
                            ? _emptyState()
                            : ListView.builder(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                itemCount: _posts.length,
                                itemBuilder: (_, i) => _postCard(_posts[i], i),
                              ),
                        _visits.isEmpty
                            ? _emptyState()
                            : ListView.builder(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                itemCount: _visits.length,
                                itemBuilder: (_, i) =>
                                    _visitCard(_visits[i], i),
                              ),
                        _monuments.isEmpty
                            ? _emptyState()
                            : ListView.builder(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                itemCount: _monuments.length,
                                itemBuilder: (_, i) =>
                                    _monumentCard(_monuments[i], i),
                              ),
                        _reported.isEmpty
                            ? _emptyState()
                            : ListView.builder(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                itemCount: _reported.length,
                                itemBuilder: (_, i) =>
                                    _reportedCard(_reported[i], i),
                              ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _ImageViewerPage extends StatefulWidget {
  final List<String> urls;
  final int initialIndex;
  const _ImageViewerPage({required this.urls, required this.initialIndex});

  @override
  State<_ImageViewerPage> createState() => _ImageViewerPageState();
}

class _ImageViewerPageState extends State<_ImageViewerPage> {
  late PageController _pageController;
  late int _current;

  @override
  void initState() {
    super.initState();
    _current = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          '${_current + 1} / ${widget.urls.length}',
          style: const TextStyle(color: Colors.white, fontSize: 14),
        ),
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.urls.length,
        onPageChanged: (i) => setState(() => _current = i),
        itemBuilder: (_, i) => InteractiveViewer(
          child: Center(
            child: Image.network(
              widget.urls[i],
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) =>
                  const Icon(Icons.broken_image, color: Colors.grey, size: 80),
            ),
          ),
        ),
      ),
    );
  }
}
