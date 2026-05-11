import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/api.dart';

class ManageUsersPage extends StatefulWidget {
  const ManageUsersPage({super.key});
  @override
  State<ManageUsersPage> createState() => _ManageUsersPageState();
}

class _ManageUsersPageState extends State<ManageUsersPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> _allUsers = [];
  List<Map<String, dynamic>> _suspendedUsers = [];
  List<Map<String, dynamic>> _bannedUsers = [];
  bool _isLoading = true;
  String? _errorMsg;

  static const Color kBrown = Color(0xFF4A2C24);
  static const Color kBg = Color(0xFFF2EDE6);
  static const Color kTabBg = Color(0xFFE0D5C8);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadUsers();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
      _errorMsg = null;
    });
    final result = await ApiService.adminGetUsers(); // ← adminGetUsers
    if (!mounted) return;
    if (result.containsKey('error')) {
      setState(() {
        _isLoading = false;
        _errorMsg = result['error'];
      });
      return;
    }
    final List<dynamic> raw = result['users'] ?? [];
    final users = raw.cast<Map<String, dynamic>>();
    setState(() {
      _isLoading = false;
      _allUsers = users.where((u) => u['status'] == 'active').toList();
      _suspendedUsers = users.where((u) => u['status'] == 'suspended').toList();
      _bannedUsers = users.where((u) => u['status'] == 'banned').toList();
    });
  }

  Future<void> _updateStatus(
    Map<String, dynamic> user,
    String action,
    String fromTab,
  ) async {
    final userId = user['id_users'] as int;
    final name = user['username'] ?? '';
    final result = await ApiService.adminUpdateUserStatus(
      userId: userId,
      action: action,
    ); // ← adminUpdateUserStatus
    if (!mounted) return;
    if (result.containsKey('error')) {
      _showSnack('Error: ${result['error']}');
      return;
    }
    setState(() {
      if (fromTab == 'all')
        _allUsers.removeWhere((u) => u['id_users'] == userId);
      if (fromTab == 'suspended')
        _suspendedUsers.removeWhere((u) => u['id_users'] == userId);
      if (fromTab == 'banned')
        _bannedUsers.removeWhere((u) => u['id_users'] == userId);
      final updated = {
        ...user,
        'status': action == 'suspend'
            ? 'suspended'
            : action == 'ban'
            ? 'banned'
            : 'active',
      };
      if (action == 'suspend') _suspendedUsers.add(updated);
      if (action == 'ban') _bannedUsers.add(updated);
      if (action == 'activate') _allUsers.add(updated);
    });
    final actionLabel = action == 'activate'
        ? 'reactivated'
        : action == 'suspend'
        ? 'suspended'
        : 'banned';
    _showSnack('$name $actionLabel ✓');
  }

  void _showUserOptions(Map<String, dynamic> user, String tab) {
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
            _bsUserRow(user['username'] ?? '', user['email'] ?? ''),
            const SizedBox(height: 20),
            Divider(color: kBrown.withOpacity(0.15)),
            const SizedBox(height: 8),
            _actionTile(
              icon: Icons.person_outline,
              label: 'View Profile',
              onTap: () {
                Navigator.pop(context);
                _showUserProfile(user);
              },
            ),
            if (tab == 'all') ...[
              _actionTile(
                icon: Icons.pause_circle_outline,
                label: 'Suspend User',
                onTap: () {
                  Navigator.pop(context);
                  _updateStatus(user, 'suspend', 'all');
                },
              ),
              _actionTile(
                icon: Icons.block_outlined,
                label: 'Ban User',
                color: Colors.red,
                onTap: () {
                  Navigator.pop(context);
                  _updateStatus(user, 'ban', 'all');
                },
              ),
            ],
            if (tab == 'suspended') ...[
              _actionTile(
                icon: Icons.check_circle_outline,
                label: 'Reactivate User',
                color: const Color(0xFF2E7D32),
                onTap: () {
                  Navigator.pop(context);
                  _updateStatus(user, 'activate', 'suspended');
                },
              ),
              _actionTile(
                icon: Icons.block_outlined,
                label: 'Ban User',
                color: Colors.red,
                onTap: () {
                  Navigator.pop(context);
                  _updateStatus(user, 'ban', 'suspended');
                },
              ),
            ],
            // if (tab == 'banned')
            //   _actionTile(
            //     icon: Icons.check_circle_outline,
            //     label: 'Reactivate User',
            //     color: const Color(0xFF2E7D32),
            //     onTap: () {
            //       Navigator.pop(context);
            //       _updateStatus(user, 'activate', 'banned');
            //     },
            //   ),
            // const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showUserProfile(Map<String, dynamic> user) async {
    final userId = user['id_users'] as int;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) =>
          const Center(child: CircularProgressIndicator(color: kBrown)),
    );
    final result = await ApiService.adminGetUserById(
      userId,
    ); // ← adminGetUserById
    if (!mounted) return;
    Navigator.pop(context);
    if (result.containsKey('error')) {
      _showSnack('Error: ${result['error']}');
      return;
    }
    final u = result['user'] as Map<String, dynamic>;
    final profile = u['profile'] as Map<String, dynamic>?;
    final stats = u['stats'] as Map<String, dynamic>?;
    showModalBottomSheet(
      context: context,
      backgroundColor: kBg,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: _dragHandle()),
            Center(
              child: CircleAvatar(
                radius: 36,
                backgroundColor: kBrown.withOpacity(0.15),
                backgroundImage: profile?['profile_image_url'] != null
                    ? NetworkImage(profile!['profile_image_url'])
                    : null,
                child: profile?['profile_image_url'] == null
                    ? Text(
                        (u['username'] ?? '?')[0].toUpperCase(),
                        style: GoogleFonts.tajawal(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: kBrown,
                        ),
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: Text(
                u['username'] ?? '',
                style: GoogleFonts.tajawal(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: kBrown,
                ),
              ),
            ),
            Center(
              child: Text(
                u['email'] ?? '',
                style: GoogleFonts.tajawal(
                  fontSize: 12,
                  color: kBrown.withOpacity(0.6),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(child: _statusBadge(u['status'] ?? 'active')),
            if (profile?['biography'] != null) ...[
              const SizedBox(height: 10),
              Center(
                child: Text(
                  profile!['biography'],
                  style: GoogleFonts.tajawal(
                    fontSize: 13,
                    color: kBrown.withOpacity(0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
            if (profile?['expertise'] != null) ...[
              const SizedBox(height: 6),
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: kBrown.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    profile!['expertise'],
                    style: GoogleFonts.tajawal(
                      fontSize: 11,
                      color: kBrown.withOpacity(0.7),
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
            Divider(color: kBrown.withOpacity(0.15)),
            if (stats != null) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _statChip('Posts', '${stats['posts_count'] ?? 0}'),
                  _statChip('Comments', '${stats['comments_count'] ?? 0}'),
                  _statChip('Visits', '${stats['visits_count'] ?? 0}'),
                ],
              ),
              const SizedBox(height: 12),
            ],
            _infoRow(
              Icons.calendar_today_outlined,
              'Joined',
              _formatDate(u['created_at']),
            ),
            _infoRow(
              Icons.people_outline,
              'Followers',
              '${u['followers_count'] ?? 0}',
            ),
            _infoRow(
              Icons.person_add_outlined,
              'Following',
              '${u['following_count'] ?? 0}',
            ),
            _infoRow(
              Icons.verified_outlined,
              'Validated',
              u['validation']?.toString() == 'true' ? '✅ Yes' : '❌ No',
            ),
            const SizedBox(height: 8),
          ],
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

  Widget _statusBadge(String status) {
    final colors = {
      'active': (const Color(0xFF2E7D32), const Color(0xFFE8F5E9)),
      'suspended': (const Color(0xFFE65100), const Color(0xFFFFF3E0)),
      'banned': (const Color(0xFFB71C1C), const Color(0xFFFFEBEE)),
    };
    final pair = colors[status] ?? (kBrown, kBg);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: pair.$2,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: pair.$1.withOpacity(0.4)),
      ),
      child: Text(
        status.toUpperCase(),
        style: GoogleFonts.tajawal(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: pair.$1,
        ),
      ),
    );
  }

  Widget _statChip(String label, String value) => Column(
    children: [
      Text(
        value,
        style: GoogleFonts.tajawal(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: kBrown,
        ),
      ),
      Text(
        label,
        style: GoogleFonts.tajawal(
          fontSize: 11,
          color: kBrown.withOpacity(0.6),
        ),
      ),
    ],
  );

  Widget _infoRow(IconData icon, String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(
      children: [
        Icon(icon, size: 16, color: kBrown.withOpacity(0.5)),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: GoogleFonts.tajawal(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: kBrown,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.tajawal(
            fontSize: 13,
            color: kBrown.withOpacity(0.7),
          ),
        ),
      ],
    ),
  );

  Widget _actionTile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    final c = color ?? kBrown;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: c.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: c, size: 20),
      ),
      title: Text(
        label,
        style: GoogleFonts.tajawal(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: c,
        ),
      ),
      onTap: onTap,
    );
  }

  String _formatDate(dynamic raw) {
    if (raw == null) return '-';
    try {
      final dt = DateTime.parse(raw.toString());
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return raw.toString();
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                    'Manage Users',
                    style: GoogleFonts.tajawal(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: kBrown,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: _loadUsers,
                    child: const Icon(Icons.refresh, color: kBrown, size: 22),
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
                  fontSize: 13,
                ),
                unselectedLabelStyle: GoogleFonts.tajawal(fontSize: 13),
                tabs: [
                  _buildTab('All users', _allUsers.length),
                  _buildTab('Suspended', _suspendedUsers.length),
                  _buildTab('Banned', _bannedUsers.length),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: kBrown),
                    )
                  : _errorMsg != null
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 48,
                            color: kBrown.withOpacity(0.4),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            _errorMsg!,
                            style: GoogleFonts.tajawal(color: kBrown),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 10),
                          TextButton(
                            onPressed: _loadUsers,
                            child: Text(
                              'Retry',
                              style: GoogleFonts.tajawal(
                                color: kBrown,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        _buildUserList(_allUsers, 'all'),
                        _buildUserList(_suspendedUsers, 'suspended'),
                        _buildUserList(_bannedUsers, 'banned'),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

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

  Widget _buildUserList(List<Map<String, dynamic>> users, String tab) {
    if (users.isEmpty)
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.people_outline,
              size: 56,
              color: kBrown.withOpacity(0.3),
            ),
            const SizedBox(height: 12),
            Text(
              'No users here',
              style: GoogleFonts.tajawal(
                fontSize: 15,
                color: kBrown.withOpacity(0.6),
              ),
            ),
          ],
        ),
      );
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        final status = user['status'] ?? 'active';
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.6),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: kBrown.withOpacity(0.15),
                child: Text(
                  (user['username'] ?? '?')[0].toUpperCase(),
                  style: GoogleFonts.tajawal(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: kBrown,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user['username'] ?? '',
                      style: GoogleFonts.tajawal(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: kBrown,
                      ),
                    ),
                    Text(
                      user['email'] ?? '',
                      style: GoogleFonts.tajawal(
                        fontSize: 12,
                        color: kBrown.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              if (status != 'active')
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: status == 'suspended'
                        ? const Color(0xFFFFF3E0)
                        : const Color(0xFFFFEBEE),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    status == 'suspended' ? '⏸ Suspended' : '🚫 Banned',
                    style: GoogleFonts.tajawal(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: status == 'suspended'
                          ? const Color(0xFFE65100)
                          : const Color(0xFFB71C1C),
                    ),
                  ),
                ),
              GestureDetector(
                onTap: () => _showUserOptions(user, tab),
                child: const Icon(Icons.more_vert, color: kBrown, size: 22),
              ),
            ],
          ),
        );
      },
    );
  }
}
