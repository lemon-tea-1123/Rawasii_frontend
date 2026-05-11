import 'package:flutter/material.dart';
import 'package:rawasii/globals.dart';
import 'package:rawasii/pages/Home/parentSize.dart';
import 'package:rawasii/pages/Home/post.dart';
import 'package:rawasii/services/api.dart';
import 'package:rawasii/utils/user_data.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _controller = TextEditingController();

  List<dynamic> _posts = [];
  List<dynamic> _users = [];
  List<String> _recentSearches = [];
  bool _loading = false;
  bool _hasSearched = false;

  Future<void> _search(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _posts = [];
        _users = [];
        _hasSearched = false;
      });
      return;
    }

    setState(() => _loading = true);

    final results = await ApiService.search(query.trim());

    setState(() {
      // ✅ List.from() on every assignment — kills the JSArray cast error
      _posts = List<dynamic>.from(results['posts'] ?? []);
      _users = List<dynamic>.from(results['users'] ?? []);
      _loading = false;
      _hasSearched = true;
    });
  }

  void _addToRecent(String value) {
    if (value.trim().isEmpty) return;
    setState(() {
      _recentSearches.remove(value);
      _recentSearches.insert(0, value);
      if (_recentSearches.length > 10) _recentSearches.removeLast();
    });
  }

  void _clearHistory() => setState(() => _recentSearches.clear());

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // reset search when page becomes visible again
    if (_hasSearched && _controller.text.isEmpty) {
      setState(() {
        _hasSearched = false;
        _posts = [];
        _users = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ParentSized(
      builder: (width, height) {
        return ColoredBox(
          color: bgColor,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Search TextField ───────────────────────────────────────
              Padding(
                padding: EdgeInsets.fromLTRB(width * 0.04, 16, width * 0.04, 8),
                child: TextField(
                  controller: _controller,
                  autofocus: true,
                  onChanged: _search,
                  onSubmitted: (v) {
                    _addToRecent(v);
                    _search(v);
                  },
                  style: TextStyle(color: darkColor),
                  decoration: InputDecoration(
                    hintText: 'Search posts, users, regions...',
                    hintStyle: TextStyle(color: darkColor.withOpacity(0.5)),
                    prefixIcon: Icon(Icons.search, color: darkColor),
                    suffixIcon: _controller.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.close, color: darkColor),
                            onPressed: () {
                              _controller.clear();
                              _search('');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: secColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),

              // ── Body ──────────────────────────────────────────────────
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : !_hasSearched
                    ? _buildRecentSearches(width)
                    : _buildResults(width),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Recent searches ────────────────────────────────────────────────────
  Widget _buildRecentSearches(double width) {
    if (_recentSearches.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search, size: 48, color: darkColor.withOpacity(0.3)),
            const SizedBox(height: 12),
            Text(
              'Search for posts, users, monuments...',
              style: TextStyle(
                color: darkColor.withOpacity(0.5),
                fontFamily: 'Tajawal-Bold',
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: EdgeInsets.symmetric(horizontal: width * 0.04),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: darkColor,
                fontFamily: 'Tajawal-Bold',
                fontSize: 16,
              ),
            ),
            TextButton(
              onPressed: _clearHistory,
              child: Text(
                'Clear',
                style: TextStyle(color: darkColor.withOpacity(0.6)),
              ),
            ),
          ],
        ),
        ..._recentSearches.map(
          (e) => ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.history, color: darkColor.withOpacity(0.5)),
            title: Text(e, style: TextStyle(color: darkColor)),
            onTap: () {
              _controller.text = e;
              _search(e);
            },
            trailing: IconButton(
              icon: Icon(
                Icons.close,
                size: 16,
                color: darkColor.withOpacity(0.4),
              ),
              onPressed: () => setState(() => _recentSearches.remove(e)),
            ),
          ),
        ),
      ],
    );
  }

  // ── Results: users strip + posts ───────────────────────────────────────
  Widget _buildResults(double width) {
    final bool noResults = _users.isEmpty && _posts.isEmpty;

    if (noResults) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off, size: 48, color: darkColor.withOpacity(0.3)),
            const SizedBox(height: 12),
            Text(
              'No results for "${_controller.text}"',
              style: TextStyle(
                color: darkColor.withOpacity(0.6),
                fontFamily: 'Tajawal-Bold',
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    final currentUserId = UserData.userOne?.id.toString() ?? '';

    return CustomScrollView(
      slivers: [
        // ── People horizontal strip ────────────────────────────────────
        if (_users.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(width * 0.04, 12, 0, 4),
              child: Text(
                'People',
                style: TextStyle(
                  color: darkColor,
                  fontFamily: 'Tajawal-Bold',
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: width * 0.04),
                itemCount: _users.length,
                itemBuilder: (context, i) {
                  // ✅ Safe cast per item
                  final user = Map<String, dynamic>.from(_users[i] as Map);
                  return _buildUserAvatar(user);
                },
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Divider(
              color: darkColor.withOpacity(0.1),
              thickness: 1,
              height: 20,
            ),
          ),
        ],

        // ── Posts label ────────────────────────────────────────────────
        if (_posts.isNotEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(width * 0.04, 4, 0, 4),
              child: Text(
                'Posts',
                style: TextStyle(
                  color: darkColor,
                  fontFamily: 'Tajawal-Bold',
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

        // ── Posts list ─────────────────────────────────────────────────
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: width * 0.02),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              // ✅ Safe cast per item
              final post = Map<String, dynamic>.from(_posts[index] as Map);
              final rawImages = post['image'] as List? ?? [];
              final imagePaths = List<dynamic>.from(rawImages)
                  .map((img) => (img as Map)['image_path'] as String? ?? '')
                  .where((p) => p.isNotEmpty)
                  .toList();

              final postUser = post['user'] != null
                  ? Map<String, dynamic>.from(post['user'] as Map)
                  : <String, dynamic>{};
              final reactions = post['reaction'] != null
                  ? List<dynamic>.from(post['reaction'] as List)
                  : <dynamic>[];
              final isLiked = reactions.any(
                (r) => (r as Map)['user_id']?.toString() == currentUserId,
              );

              return PostDesign(
                id: post['id_post']?.toString() ?? '',
                userId: post['user_id']?.toString(),
                title: post['title'] as String? ?? '',
                descr: post['description'] as String? ?? '',
                imagePaths: imagePaths,
                creationDate: post['created_at'] as String? ?? '',
                period: post['historical_period'] as String? ?? '',
                region: post['localisation'] as String? ?? '',
                type: post['heritage_type'] as String? ?? '',
                name: postUser['username'] as String? ?? '',
                isLiked: isLiked,
                likeCount: post['reaction_count'] as int? ?? 0,
                commentCount: post['comment_count'] as int? ?? 0,
              );
            }, childCount: _posts.length),
          ),
        ),
      ],
    );
  }

  // ── User avatar card ───────────────────────────────────────────────────
  Widget _buildUserAvatar(Map<String, dynamic> user) {
    final username = user['username'] as String? ?? '';
    final imageUrl = user['profile_image_url'] as String? ?? '';

    return GestureDetector(
      onTap: () {
        // TODO: navigate to user profile
      },
      child: Container(
        width: 72,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.grey[300],
              backgroundImage: imageUrl.isNotEmpty
                  ? NetworkImage(imageUrl)
                  : null,
              child: imageUrl.isEmpty
                  ? Icon(Icons.person, color: darkColor, size: 28)
                  : null,
            ),
            const SizedBox(height: 6),
            Text(
              username,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: darkColor,
                fontSize: 11,
                fontFamily: 'Tajawal',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
