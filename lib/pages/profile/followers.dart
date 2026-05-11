import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rawasii/globals.dart';
import 'package:rawasii/navigation_notifier.dart';
import 'package:rawasii/services/api.dart';

// ─────────────────────────────────────────────
// WIDGET PRINCIPAL — à appeler depuis le profil
// ─────────────────────────────────────────────
// Exemple d'utilisation :
//   FollowListPanel(userId: '42', type: FollowType.followers)
//   FollowListPanel(userId: '42', type: FollowType.following)

enum FollowType { followers, following }

class FollowListPanel extends StatefulWidget {
  final String userId;
  final FollowType type;

  const FollowListPanel({super.key, required this.userId, required this.type});

  @override
  State<FollowListPanel> createState() => _FollowListPanelState();
}

class _FollowListPanelState extends State<FollowListPanel> {
  List<dynamic> _list = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final data = widget.type == FollowType.followers
          ? await ApiService.getFollowers(user_id: widget.userId)
          : await ApiService.getFollowing(user_id: widget.userId);
      setState(() {
        _list = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF2EDE6),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 14, bottom: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF4A2C24).withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Title
          Text(
            widget.type == FollowType.followers ? 'Followers' : 'Following',
            style: GoogleFonts.tajawal(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: darkColor,
            ),
          ),
          const SizedBox(height: 12),

          // Content
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(color: Color(0xFF4A2C24)),
            )
          else if (_error != null)
            Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Erreur : $_error',
                style: GoogleFonts.tajawal(color: Colors.red),
              ),
            )
          else if (_list.isEmpty)
            Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 48,
                    color: const Color(0xFF4A2C24).withOpacity(0.3),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.type == FollowType.followers
                        ? 'No followers for the moment'
                        : 'Didn\'t follow any person ',
                    style: GoogleFonts.tajawal(
                      color: const Color(0xFF4A2C24).withOpacity(0.6),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            )
          else
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.6,
              ),
              child: ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                itemCount: _list.length,
                separatorBuilder: (_, __) => Divider(
                  color: const Color(0xFF4A2C24).withOpacity(0.1),
                  height: 1,
                ),
                itemBuilder: (context, index) {
                  final user = _list[index] as Map<String, dynamic>;
                  print('USER DATA: $user'); // ← ajoute ça
                  return _UserTile(user: user);
                },
              ),
            ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// TILE — une ligne = un utilisateur
// ─────────────────────────────────────────────
class _UserTile extends StatelessWidget {
  final Map<String, dynamic> user;

  const _UserTile({required this.user});

  @override
  Widget build(BuildContext context) {
    final userMap = user['user'] as Map<String, dynamic>?;
    final username = userMap?['username']?.toString() ?? 'Utilisateur';
    final userId = userMap?['id_users']?.toString() ?? '';
    final userProfile = userMap?['user_profile'];
    final avatarUrl = userProfile is List && userProfile.isNotEmpty
        ? userProfile.first['profile_image_url']?.toString()
        : null;

    return InkWell(
      onTap: () async {
        Navigator.pop(context); // ferme le bottom sheet
        if (userId.isNotEmpty) {
          final user = await ApiService.fetchUserProfile(userId);
          if (user != null) shellNav.goToProfile(user);
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 24,
              backgroundColor: const Color(0xFF4A2C24).withOpacity(0.15),
              backgroundImage: avatarUrl != null && avatarUrl.isNotEmpty
                  ? NetworkImage(avatarUrl)
                  : null,
              child: avatarUrl == null || avatarUrl.isEmpty
                  ? const Icon(Icons.person, color: Color(0xFF4A2C24), size: 24)
                  : null,
            ),
            const SizedBox(width: 12),

            // Username
            Expanded(
              child: Text(
                username,
                style: GoogleFonts.tajawal(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF4A2C24),
                ),
              ),
            ),

            // Flèche
            Icon(
              Icons.chevron_right,
              color: const Color(0xFF4A2C24).withOpacity(0.4),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// BOUTONS à mettre dans la page profil
// ─────────────────────────────────────────────
// Copie ces deux fonctions dans ta page profil
// et appelle-les depuis les boutons Followers / Following

void showFollowers(BuildContext context, String userId) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => FollowListPanel(userId: userId, type: FollowType.followers),
  );
}

void showFollowing(BuildContext context, String userId) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => FollowListPanel(userId: userId, type: FollowType.following),
  );
}
