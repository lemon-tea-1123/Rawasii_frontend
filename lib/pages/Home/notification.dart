import 'package:flutter/material.dart';
import 'package:rawasii/globals.dart';
import 'package:rawasii/pages/Home/parentSize.dart';
import 'package:rawasii/services/api.dart';
import 'package:rawasii/utils/user_data.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  List<dynamic> _notifs = [];
  bool _loading = true;
  final user = UserData.userOne;
  @override
  void initState() {
    super.initState();
    _loadNotifs();
  }

  Future<void> _loadNotifs() async {
    try {
      final data = await ApiService.getNotifications();
      print('Notifs count : ${data.length}');
      if (data.isNotEmpty) print('First notif : ${data.first}');
      setState(() {
        _loading = false;
        for (int i = 0; i < data.length; i++) {
          if (data[i]['sender_id'] != user?.id) {
            _notifs.add(data[i]);
          }
        }
        print('Notif count after filtering : ${_notifs.length}');
      });
    } catch (e) {
      print('Notifs error: $e');
      setState(() => _loading = false);
    }
  }

  // ── split by time ──────────────────────────────────────────────────────
  List<dynamic> _filterByHours(List<dynamic> list, int minH, int maxH) {
    return list.where((n) {
      final created = DateTime.tryParse(n['created_at'] ?? '');
      if (created == null) return false;
      final diff = DateTime.now().difference(created).inHours;
      return diff >= minH && diff < maxH;
    }).toList();
  }

  List<dynamic> get _newNotifs => _filterByHours(_notifs, 0, 1);
  List<dynamic> get _todayNotifs => _filterByHours(_notifs, 1, 24);
  List<dynamic> get _weekNotifs => _filterByHours(_notifs, 24, 168);

  // ── format time ───────────────────────────────────────────────────────
  String _timeAgo(String? createdAt) {
    if (createdAt == null) return '';
    final created = DateTime.tryParse(createdAt);
    if (created == null) return '';
    final diff = DateTime.now().difference(created);
    if (diff.inMinutes < 60) return '· ${diff.inMinutes}min ago';
    if (diff.inHours < 24) return '· ${diff.inHours}h ago';
    if (diff.inDays < 7) return '· ${diff.inDays}d ago';
    return '· ${created.day} ${_month(created.month)}';
  }

  String _month(int m) => [
    '',
    'january',
    'february',
    'march',
    'april',
    'may',
    'june',
    'july',
    'august',
    'september',
    'october',
    'november',
    'december',
  ][m];

  // ── message from type ─────────────────────────────────────────────────
  String _message(String? type) {
    switch (type) {
      case 'like':
        return 'liked your post';
      case 'comment':
        return 'commented on your post';
      case 'follow':
        return 'started following you';
      case 'mention':
        return 'mentioned you in a comment';
      case 'like_visit':
        return 'liked your visit';
      default:
        return 'interacted with you';
    }
  }

  @override
  Widget build(BuildContext context) {
    return ParentSized(
      builder: (double width, double height) {
        return Container(
          color: bgColor,
          width: width,
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: _loadNotifs,
                  child: ListView(
                    padding: EdgeInsets.symmetric(
                      horizontal: width * 0.04,
                      vertical: 20,
                    ),
                    children: [
                      // ── title ──────────────────────────────────────────
                      Text(
                        'Notifications',
                        style: TextStyle(
                          color: darkColor,
                          fontFamily: 'Tajawal-Bold',
                          fontSize: width * 0.06,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Divider(color: darkColor.withOpacity(0.15)),

                      if (_newNotifs.isNotEmpty) ...[
                        _sectionLabel('New', width),
                        ..._newNotifs.map(
                          (n) => _buildItem(n as Map<String, dynamic>, width),
                        ),
                        const SizedBox(height: 12),
                      ],

                      if (_todayNotifs.isNotEmpty) ...[
                        _sectionLabel('Today', width),
                        ..._todayNotifs.map((n) => _buildItem(n, width)),
                        const SizedBox(height: 12),
                      ],

                      if (_weekNotifs.isNotEmpty) ...[
                        _sectionLabel('This week', width),
                        ..._weekNotifs.map((n) => _buildItem(n, width)),
                      ],

                      if (_notifs.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(40),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.notifications_none,
                                  size: 48,
                                  color: darkColor.withOpacity(0.3),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'No notifications yet',
                                  style: TextStyle(
                                    color: darkColor.withOpacity(0.5),
                                    fontFamily: 'Tajawal-Bold',
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
        );
      },
    );
  }

  // ── single notification item ───────────────────────────────────────────
  Widget _buildItem(Map<String, dynamic> n, double width) {
    // ── handle user as List or Map ─────────────────────────────────────────
    final userRaw = n['user'];
    final Map<String, dynamic> sender;
    if (userRaw is List && userRaw.isNotEmpty) {
      sender = Map<String, dynamic>.from(userRaw.first);
    } else if (userRaw is Map) {
      sender = Map<String, dynamic>.from(userRaw);
    } else {
      sender = {};
    }

    // ── handle user_profile as List or Map ────────────────────────────────
    final profileRaw = sender['user_profile'];
    final Map<String, dynamic> profile;
    if (profileRaw is List && profileRaw.isNotEmpty) {
      profile = Map<String, dynamic>.from(profileRaw.first);
    } else if (profileRaw is Map) {
      profile = Map<String, dynamic>.from(profileRaw);
    } else {
      profile = {};
    }

    final name = sender['username'] as String? ?? 'Unknown';
    final image = profile['profile_image_url'] as String? ?? '';
    final isRead = n['is_read'] as bool? ?? true;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          // ── unread dot ──────────────────────────────────────────────────
          SizedBox(
            width: 16,
            child: !isRead
                ? Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: thirdColor,
                      shape: BoxShape.circle,
                    ),
                  )
                : null,
          ),

          // ── avatar ──────────────────────────────────────────────────────
          CircleAvatar(
            radius: width * 0.06,
            backgroundColor: secColor,
            backgroundImage: image.isNotEmpty ? NetworkImage(image) : null,
            child: image.isEmpty
                ? Text(
                    name.isNotEmpty ? name[0].toUpperCase() : '?',
                    style: TextStyle(
                      color: darkColor,
                      fontFamily: 'Tajawal-Bold',
                      fontWeight: FontWeight.bold,
                      fontSize: width * 0.04,
                    ),
                  )
                : null,
          ),

          SizedBox(width: width * 0.03),

          // ── text ────────────────────────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '$name ',
                        style: TextStyle(
                          color: thirdColor,
                          fontFamily: 'Tajawal-Bold',
                          fontWeight: FontWeight.bold,
                          fontSize: width * 0.035,
                        ),
                      ),
                      TextSpan(
                        text: _message(n['type'] as String?),
                        style: TextStyle(
                          color: darkColor,
                          fontFamily: 'Tajawal-Bold',
                          fontSize: width * 0.035,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  _timeAgo(n['created_at'] as String?),
                  style: TextStyle(
                    color: darkColor.withOpacity(0.5),
                    fontFamily: 'Tajawal-Bold',
                    fontSize: width * 0.028,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String label, double width) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      label,
      style: TextStyle(
        color: darkColor.withOpacity(0.5),
        fontFamily: 'Tajawal-Bold',
        fontWeight: FontWeight.bold,
        fontSize: width * 0.032,
        letterSpacing: 0.5,
      ),
    ),
  );
}
