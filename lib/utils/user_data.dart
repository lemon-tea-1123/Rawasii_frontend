import 'package:rawasii/Classes/user.dart';
import 'package:rawasii/services/api.dart';
import 'package:rawasii/Classes/post.dart';

class UserData {
  static User? userOne;

  // user_data.dart
  static Future<void> init() async {
    print('UserData.init called');
    try {
      final name = await ApiService.getUsername();
      final userId = await ApiService.getUserId();
      print('Got userId: $userId, name: $name');

      // step 1 — basic user from cache
      userOne = User(name: name ?? '', id: int.tryParse(userId ?? '0') ?? 0);

      // step 2 — fetch full profile from DB ← THIS IS THE KEY
      if (userId != null && userId.isNotEmpty && userId != '0') {
        final fullUser = await ApiService.fetchUserProfile(userId).timeout(
          const Duration(seconds: 8),
          onTimeout: () {
            print('fetchUserProfile timed out');
            return null;
          },
        );

        if (fullUser != null) {
          // preserve userPosts if already loaded
          final existingPosts = userOne?.userPosts ?? [];
          userOne = fullUser;
          if (userOne!.userPosts.isEmpty && existingPosts.isNotEmpty) {
            userOne!.userPosts = existingPosts;
          }
          print('User loaded from DB: ${userOne?.name}');
          print('Bio: ${userOne?.bio}');
          print('Image: ${userOne?.imagePath}');
        }
      }
    } catch (e) {
      print('UserData.init error: $e');
    }
  }

  // ── refresh after edit profile ──────────────────────────────────────
  static Future<void> refresh() async {
    final userId = await ApiService.getUserId();
    if (userId != null) {
      final response = await ApiService.fetchUser(userId);
      if (response != null) userOne = response;
    }
  }
}
