import 'package:flutter/material.dart';
import 'package:rawasii/globals.dart';
import 'package:rawasii/pages/Home/parentSize.dart';

enum NotifType { like, comment, follow}

enum PostType { post, visit }

class NotificationItem extends StatelessWidget {
  final String senderId;
  final String senderName;
  final String? senderImage;
  final String? postThumbUrl;
  final NotifType type;
  final PostType postType;
  final String timeAgo;
  final bool isRead;

  const NotificationItem({
    super.key,
    required this.senderId,
    required this.senderName,
    required this.type,
    required this.postType,
    required this.timeAgo,
    this.senderImage,
    this.postThumbUrl,
    this.isRead = false,
  });

  // ── message based on type ──────────────────────────────────────────────
  String get _message {
    switch (type) {
      case NotifType.like:
        return 'liked your ${postType == PostType.visit ? 'visit' : 'post'}';
      case NotifType.comment:
        return 'commented on your ${postType == PostType.visit ? 'visit' : 'post'}';
      
      case NotifType.follow:
        return 'started following you';
    }
  }

  @override
  Widget build(BuildContext context) {
    return ParentSized(
      builder: (width, height) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              // ── unread dot ─────────────────────────────────────────────
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

              // ── avatar ─────────────────────────────────────────────────
              _buildAvatar(width),
              SizedBox(width: width * 0.03),

              // ── text ───────────────────────────────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '$senderName ',
                            style: TextStyle(
                              color: thirdColor,
                              fontFamily: 'Tajawal-Bold',
                              fontWeight: FontWeight.bold,
                              fontSize: width * 0.035,
                            ),
                          ),
                          TextSpan(
                            text: _message,
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
                      timeAgo,
                      style: TextStyle(
                        color: darkColor.withOpacity(0.5),
                        fontFamily: 'Tajawal-Bold',
                        fontSize: width * 0.028,
                      ),
                    ),
                  ],
                ),
              ),

              // ── post thumbnail (not for follow notifs) ─────────────────
              if (type != NotifType.follow && postThumbUrl != null) ...[
                SizedBox(width: width * 0.02),
                _buildThumb(),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildAvatar(double width) {
    final radius = width * 0.06;
    return CircleAvatar(
      radius: radius,
      backgroundColor: secColor,
      backgroundImage: (senderImage != null && senderImage!.isNotEmpty)
          ? NetworkImage(senderImage!)
          : null,
      child: (senderImage == null || senderImage!.isEmpty)
          ? Text(
              senderName.isNotEmpty ? senderName[0].toUpperCase() : '?',
              style: TextStyle(
                color: darkColor,
                fontFamily: 'Tajawal-Bold',
                fontWeight: FontWeight.bold,
                fontSize: radius,
              ),
            )
          : null,
    );
  }

  Widget _buildThumb() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        postThumbUrl!,
        width: 44,
        height: 44,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          width: 44,
          height: 44,
          color: secColor,
          child: Icon(Icons.image_outlined, color: darkColor, size: 20),
        ),
      ),
    );
  }
}
