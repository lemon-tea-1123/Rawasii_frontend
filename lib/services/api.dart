import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:rawasii/pages/Home/post.dart';
import 'package:rawasii/Classes/post.dart';
import 'package:rawasii/Classes/user.dart' as AppUser;

// final String baseUrl = String.fromEnvironment(
//   // I am talking about this baseUrl not the other in the main
//   'TARGET_IP',
//   defaultValue: kIsWeb
//       ? 'http://localhost:8080' // Chrome
//       : 'http://10.0.2.2:8080', // Android emulator
// );
const String baseUrl = 'https://rawasiibackend-production.up.railway.app';


class ApiService {
  static String? _token;
  static List<Post> posts = [];
  static List<AppUser.User> users = [];

  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    final data = jsonDecode(response.body);

    if (data.containsKey('access_token')) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', data['access_token']);
      await prefs.setString('refresh_token', data['refresh_token'] ?? '');
      final username = data['username'] ?? data['user']?['username'] ?? '';
      final userId = data['user']?['id']?.toString() ?? '';
      await prefs.setString('username', username);
      await prefs.setString('user_id', userId);
      print('SAVED user_id: $userId');
      print('SAVED token: ${data['access_token']}');
    }

    return data;
  }

  // ===== LOGOUT =====
  // ✅ Supprime tout ce qui est sauvegardé localement
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('refresh_token');
    await prefs.remove('username');
    await prefs.remove('user_id');
  }

  // ===== GET SAVED TOKEN =====
  // ✅ Récupère le token sauvegardé (pour les appels API protégés)
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // ===== GET SAVED USERNAME =====
  static Future<String?> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('username');
  }

  // ===== GET SAVED USER ID =====
  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_id');
  }

  static AppUser.User? getUserById(String idUser) {
    try {
      return users.firstWhere((u) => u.id.toString() == idUser);
    } catch (_) {
      return null;
    }
  }

  // fetches full profile and saves to users list
  // static Future<AppUser.User?> fetchUserProfile(String userId) async {
  //   try {
  //     final token = await getToken();
  //     final uri = Uri.parse('$baseUrl/profile?id_users=$userId');
  //     final res = await http.get(
  //       uri,
  //       headers: {
  //         'Content-Type': 'application/json',
  //         'Authorization': 'Bearer $token',
  //       },
  //     );

  //     print('Profile status: ${res.statusCode}');
  //     print('Profile body:   ${res.body}');

  //     if (res.statusCode == 200) {
  //       final json = jsonDecode(res.body) as Map<String, dynamic>;
  //       json['id_users'] = userId; // ← add id since endpoint doesn't return it
  //       final user = AppUser.User.fromJson(json);

  //       // save to users list for getUserById
  //       final i = users.indexWhere((u) => u.id.toString() == userId);
  //       if (i != -1)
  //         users[i] = user;
  //       else
  //         users.add(user);

  //       return user;
  //     }
  //     return null;
  //   } catch (e) {
  //     print('fetchUserProfile error: $e');

  //     return null;
  //   }
  // }

  // ===== CHECK IF LOGGED IN =====
  // ✅ Vérifie si l'user est déjà connecté (token existe)
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    return token != null && token.isNotEmpty;
  }

  // ===== REGISTER =====
  static Future<Map<String, dynamic>> register(
    String email,
    String password,
    String username,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
        'username': username,
      }),
    );
    return jsonDecode(response.body);
  }

  // ===== FORGOT PASSWORD =====
  static Future<Map<String, dynamic>> forgotPassword(String email) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/forgot_password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );
    return jsonDecode(response.body);
  }

  // ===== VERIFY OTP =====
  static Future<Map<String, dynamic>> verifyOtp(
    String email,
    String token,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/verify_otp'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'token': token}),
    );
    return jsonDecode(response.body);
  }

  // ===== RESET PASSWORD =====
  static Future<Map<String, dynamic>> resetPassword(
    String accessToken,
    String newPassword,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/reset_password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'access_token': accessToken,
        'new_password': newPassword,
      }),
    );
    return jsonDecode(response.body);
  }

  // ===== GET SAVED TOKEN =====
  // ✅ Récupère le token sauvegardé (pour les appels API protégés)

  // ===== GET SAVED USERNAME =====

  static Future<AppUser.User?> fetchUserProfile(String userId) async {
    try {
      final token = await getToken();
      final uri = Uri.parse(
        '$baseUrl/profile_with_posts',
      ).replace(queryParameters: {'id_users': userId});

      final res = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('fetchUserProfile status: ${res.statusCode}');
      print('fetchUserProfile body:   ${res.body}');

      if (res.statusCode == 200) {
        final json = jsonDecode(res.body) as Map<String, dynamic>;

        // ── handle both response formats ──────────────────────────────────
        // format 1: { user: {...}, posts: [...] }  ← profile_with_posts endpoint
        // format 2: { username: ..., ... }         ← plain profile endpoint

        Map<String, dynamic> userData;
        List<dynamic> postList;

        if (json.containsKey('user')) {
          // ← profile_with_posts response
          userData = Map<String, dynamic>.from(json['user'] as Map);
          postList = json['posts'] as List? ?? [];
        } else {
          // ← plain profile response
          userData = json;
          postList = [];
        }

        userData['id_users'] = userId;

        final user = AppUser.User.fromJson(userData);
        user.userPosts = postList
            .map((p) => Post.fromJson(p as Map<String, dynamic>))
            .toList();

        final i = users.indexWhere((u) => u.id.toString() == userId);
        if (i != -1)
          users[i] = user;
        else
          users.add(user);

        return user;
      }
      return null;
    } catch (e) {
      print('fetchUserProfile error: $e');
      return null;
    }
  }

  // fetches full profile and saves to users list
  // static Future<AppUser.User?> fetchUserProfile(String userId) async {
  //   try {
  //     final token = await getToken();
  //     final uri = Uri.parse('$baseUrl/profile?id_users=$userId');
  //     final res = await http.get(
  //       uri,
  //       headers: {
  //         'Content-Type': 'application/json',
  //         'Authorization': 'Bearer $token',
  //       },
  //     );

  //     print('Profile status: ${res.statusCode}');
  //     print('Profile body:   ${res.body}');

  //     if (res.statusCode == 200) {
  //       final json = jsonDecode(res.body) as Map<String, dynamic>;
  //       json['id_users'] = userId; // ← add id since endpoint doesn't return it
  //       final user = AppUser.User.fromJson(json);

  //       // save to users list for getUserById
  //       final i = users.indexWhere((u) => u.id.toString() == userId);
  //       if (i != -1)
  //         users[i] = user;
  //       else
  //         users.add(user);

  //       return user;
  //     }
  //     return null;
  //   } catch (e) {
  //     print('fetchUserProfile error: $e');

  //     return null;
  //   }
  // }

  // ===== CHECK IF LOGGED IN =====
  // ✅ Vérifie si l'user est déjà connecté (token existe)

  // ===== GET ALL VISITS =====
  static Future<Map<String, dynamic>> getVisits() async {
    final token = await getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/visits_page/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    return jsonDecode(response.body);
  }

  // ===== CREATE VISIT =====
  static Future<Map<String, dynamic>> createVisit({
    required String monumentName,
    required String localisation,
    required String description,
    required String historicalPeriod,
    required String heritageType,
    required List<String> imageUrls,
  }) async {
    final token = await getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/visits_page/create'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'monument_name': monumentName,
        'localisation': localisation,
        'description': description,
        'historical_period': historicalPeriod,
        'heritage_type': heritageType,
        'image_urls': imageUrls,
      }),
    );
    return jsonDecode(response.body);
  }

  // ===== UPDATE VISIT =====
  static Future<Map<String, dynamic>> updateVisit({
    required int visitId,
    String? monumentName,
    String? localisation,
    String? description,
    String? historicalPeriod,
    String? heritageType,
    List<String>? imageUrls,
  }) async {
    final token = await getToken();
    final body = <String, dynamic>{'visit_id': visitId};
    if (monumentName != null) body['monument_name'] = monumentName;
    if (localisation != null) body['localisation'] = localisation;
    if (description != null) body['description'] = description;
    if (historicalPeriod != null) body['historical_period'] = historicalPeriod;
    if (heritageType != null) body['heritage_type'] = heritageType;
    if (imageUrls != null) body['image_urls'] = imageUrls;

    final response = await http.put(
      Uri.parse('$baseUrl/visits_page/update'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );
    return jsonDecode(response.body);
  }

  // ===== DELETE VISIT =====
  static Future<Map<String, dynamic>> deleteVisit(int visitId) async {
    final token = await getToken();
    final response = await http.delete(
      Uri.parse('$baseUrl/visits_page/delete'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'visit_id': visitId}),
    );
    return jsonDecode(response.body);
  }

  // ===== UPLOAD IMAGE TO SUPABASE STORAGE =====
  static Future<String?> uploadVisitImage(XFile photo) async {
    final token = await getToken();
    final userId = await getUserId();
    final fileName = '${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final bytes = await photo.readAsBytes();

    final response = await http.post(
      Uri.parse(
        'https://ilqeknvefqtnvbcimfca.supabase.co/storage/v1/object/heritage_images/$fileName',
      ),
      headers: {'Authorization': 'Bearer $token', 'Content-Type': 'image/jpeg'},
      body: bytes,
    );

    print('UPLOAD STATUS: ${response.statusCode}');
    print('UPLOAD BODY: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      return 'https://ilqeknvefqtnvbcimfca.supabase.co/storage/v1/object/public/heritage_images/$fileName';
    }
    return null;
  }

  // ===== LIKE VISIT =====
  static Future<Map<String, dynamic>> likeVisit(int visitId) async {
    final token = await getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/visits_page/like'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'visit_id': visitId}),
    );
    return jsonDecode(response.body);
  }

  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (_token != null) 'Authorization': 'Bearer $_token',
  };

  // static get currentUserId => null;
  // // Get posts for a specific user with pagination
  // static Future<List<dynamic>> getUserPosts({
  //   required int userId,

  //   int page = 1,
  // }) async {
  //   final res = await http.get(
  //     Uri.parse(
  //       '$baseUrl/home_page/posts/display_user_posts?id_users=$userId&page=$page',
  //     ),
  //     headers: _headers,
  //   );
  //   return jsonDecode(res.body);
  // }
  static Future<AppUser.User?> fetchUser(String idUser) async {
    try {
      final token = await getToken();
      final uri = Uri.parse('$baseUrl/profile?id_users=$idUser');
      final res = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('fetchUser status: ${res.statusCode}');
      print('fetchUser body:   ${res.body}');

      if (res.statusCode == 200) {
        //
        final decode = jsonDecode(res.body);
        Map<String, dynamic> userData;
        if (decode is List) {
          if (decode.isEmpty) return null;
          userData = Map<String, dynamic>.from(decode.first);
        } else {
          userData = Map<String, dynamic>.from(decode);
        }
        userData['id_users'] = idUser;
        final user = AppUser.User.fromJson(userData);

        // final user = AppUser.User.fromJson(json); // ← explicit class

        final i = users.indexWhere((u) => u.id.toString() == idUser);
        if (i != -1)
          users[i] = user; // ← no cast
        else
          users.add(user); // ← no cast

        return user;
      }
      return null;
    } catch (e) {
      print('fetchUser error: here$e');
      return null;
    }
  }

  static Future<List<dynamic>> getPosts() async {
    try {
      final token = await getToken();
      print('Token: $token');
      print('URL: $baseUrl/home_page/posts/posts');
      final res = await http.get(
        Uri.parse('$baseUrl/home_page/posts/posts'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      print('Posts status:${res.statusCode}');
      print('Posts body: ${res.body}');

      if (res.statusCode == 200) {
        return jsonDecode(res.body) as List<dynamic>;
      } else {
        throw Exception('Failed to load posts: ${res.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // GET SAVED POSTS
  static Future<List<dynamic>> getSavedPosts({required String userId}) async {
    try {
      final token = await getToken();
      print('Token: $token');
      print('URL: $baseUrl/home_page/posts/display_sa(ved_post');
      final res = await http.get(
        Uri.parse(
          '$baseUrl/home_page/posts/display_saved_post?',
        ).replace(queryParameters: {'id_users': userId}),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      print(' Saved Posts status:${res.statusCode}');
      print(' Saved Posts body: ${res.body}');

      if (res.statusCode == 200) {
        return jsonDecode(res.body) as List<dynamic>;
      } else {
        throw Exception('Failed to load saved posts: ${res.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<List<dynamic>> getNotifications() async {
    try {
      final token = await getToken();
      final userId = await getUserId(); // ← get from SharedPreferences

      final uri = Uri.parse(
        '$baseUrl/notifications/get_notifications',
      ).replace(queryParameters: {'id_users': userId});

      final res = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Notifs status: ${res.statusCode}');
      print('Notifs body:   ${res.body}');

      if (res.statusCode == 200) {
        return jsonDecode(res.body) as List<dynamic>;
      }
      return [];
    } catch (e) {
      print('getNotifications error: $e');
      return [];
    }
  }

  // ===== GET ALL MONUMENTS IN DANGER =====
  static Future<List<dynamic>> getMonumentsInDanger() async {
    try {
      final token = await getToken();
      final res = await http.get(
        Uri.parse('$baseUrl/monuments/'), // ← adjust to your backend route
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      print('Monuments status: ${res.statusCode}');
      print('Monuments body: ${res.body}');

      if (res.statusCode == 200) {
        final json = jsonDecode(res.body);
        // handle both list and wrapped response
        if (json is List) return json;
        return json['monuments'] ?? json['data'] ?? [];
      }
      return [];
    } catch (e) {
      print('Error loading monuments: $e');
      return [];
    }
  }

  // ===== GET ALL VISITS =====
  // already exists but returns Map — update to return List
  static Future<List<dynamic>> getAllVisits() async {
    try {
      final token = await getToken();
      final res = await http.get(
        Uri.parse('$baseUrl/visits_page/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      print('Visits status: ${res.statusCode}');
      print('Visits body: ${res.body}');

      if (res.statusCode == 200) {
        final json = jsonDecode(res.body);
        // your backend wraps it: { success, count, visits: [...] }
        if (json is Map && json.containsKey('visits')) {
          return json['visits'] as List;
        }
        if (json is List) return json;
        return [];
      }
      return [];
    } catch (e) {
      print('Error loading visits: $e');
      return [];
    }
  }

  // ── fetch user posts ────────────────────────────────────────────────────
  static Future<List<Post>> fetchUserPosts(
    String idUser, {
    int page = 1,
  }) async {
    try {
      final token = await getToken(); // ← add token
      final uri = Uri.parse(
        '$baseUrl/display_user_posts?id_users=$idUser&page=$page',
      );
      final res = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // ← add header
        },
      );

      print('fetchUserPosts status: ${res.statusCode}'); // ← debug
      print('fetchUserPosts body:   ${res.body}'); // ← debug

      if (res.statusCode == 200) {
        final list = jsonDecode(res.body) as List;

        final fetched = list.map((p) => Post.fromJson(p)).toList();
        for (final post in fetched) {
          final i = posts.indexWhere((p) => p.id == post.id);
          if (i != -1)
            posts[i] = post;
          else
            posts.add(post);
        }

        // print('fetchUserPosts count: ${fetched.length}'); // ← debug
        return fetched;
      }
      return [];
    } catch (e) {
      print('fetchUserPosts error: $e'); // ← debug
      return [];
    }
  }

  // ── get from memory ─────────────────────────────────────────────────────
  static List<Post> getPostsByUser(String idUser) {
    print('getPostsByUser: total posts in memory: ${posts.length}');
    print('getPostsByUser: looking for userId: $idUser');
    print(
      'getPostsByUser: userIds in memory: ${posts.map((p) => p.userId).toList()}',
    );

    return posts.where((p) => p.userId == idUser).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  static Future<Map<String, dynamic>> createPost({
    required String title,
    required String description,
    required String localisation,
    required String historical_period,
    required String heritage_type,

    required List<String> imagesPaths,
  }) async {
    final token = await getToken();
    final userId = await getUserId();
    print('Posting as user : $userId');
    final res = await http.post(
      Uri.parse('$baseUrl/home_page/posts/add_post'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'title': title,
        'description': description,
        'localisation': localisation,
        'historical_period': historical_period,
        'heritage_type': heritage_type,
        'user_id': int.tryParse(userId ?? '0') ?? 0,
        'images_paths': imagesPaths,
      }),
    );
    print("SENDING TO THE BACKEND ");
    print(res.body);
    print("======================");
    print('Statu : ${res.statusCode}');
    print('Response: ${res.body}');
    return jsonDecode(res.body);
  }

  // Inside api.dart -> ApiService class
  static Future<String?> uploadProfilePicture(XFile file) async {
    try {
      final bytes = await file.readAsBytes();
      final ext = file.name.split('.').last;
      final userId = await getUserId();
      final fileName =
          'profiles/$userId/${DateTime.now().millisecondsSinceEpoch}.$ext';

      // ── use Supabase client directly for storage ─────────────────────
      final supabase = Supabase.instance.client;
      await supabase.storage
          .from('heritage_images')
          .uploadBinary(
            fileName,
            bytes,
            fileOptions: const FileOptions(
              upsert: true,
            ), // ← overwrite if exists
          );

      final url = supabase.storage
          .from('heritage_images')
          .getPublicUrl(fileName);

      print('Uploaded image URL: $url');
      return url;
    } catch (e) {
      print('uploadProfilePicture error: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>> updateProfile({
    String? fullName,
    String? biography,
    String? expertise,
    String? specialties,
    String? profileImageUrl,
    String? city,
  }) async {
    final token = await getToken();
    final body = <String, dynamic>{};

    if (fullName != null) body['full_name'] = fullName;
    if (biography != null) body['biography'] = biography;
    if (expertise != null) body['expertise'] = expertise;
    if (specialties != null) body['specialties'] = specialties;
    if (profileImageUrl != null) body['profile_image_url'] = profileImageUrl;
    if (city != null) body['city'] = city;

    final res = await http.put(
      Uri.parse('$baseUrl/profile/edit_profile'), // ← matches your backend file
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> addReaction({
    required String user_id,
    required String post_id,
  }) async {
    final token = await ApiService.getToken();
    final res = await http.post(
      Uri.parse('$baseUrl/home_page/posts/reaction'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'user_id': user_id, 'post_id': post_id}),
    );
    return jsonDecode(res.body);
  }

  // SAVE POST FUNCTION
  static Future<Map<String, dynamic>> savePost({
    required String user_id,
    required String post_id,
  }) async {
    final token = await ApiService.getToken();
    final res = await http.post(
      Uri.parse('$baseUrl/home_page/posts/save'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'id_users': user_id, 'id_post': post_id}),
    );
    return jsonDecode(res.body);
  }

  static Future<List<dynamic>> getFollowers({required String user_id}) async {
    final token = await getToken();
    final uri = Uri.parse(
      '$baseUrl/follows/display_followers',
    ).replace(queryParameters: {'user_id': user_id});
    final res = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return data['followers'] ?? [];
    }
    throw Exception('Failed to load followers: ${res.statusCode}');
  }

  static Future<List<dynamic>> getFollowing({required String user_id}) async {
    final token = await getToken();
    final uri = Uri.parse(
      '$baseUrl/follows/display_following',
    ).replace(queryParameters: {'user_id': user_id});
    final res = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return data['following'] ?? [];
    }
    throw Exception('Failed to load following: ${res.statusCode}');
  }

  // COMMENTS
  static Future<List<dynamic>> getComments(int postId) async {
    try {
      final token = await getToken();
      final res = await http.get(
        Uri.parse('$baseUrl/comments/get?post_id=$postId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // ← add token
        },
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return data['comments'] ?? [];
      }
      return [];
    } catch (e) {
      print('Get comments error: $e');
      return [];
    }
  }

  // in api.dart
  static Future<Map<String, dynamic>?> createComment({
    required int userId,
    required int postId,
    required String content,
    required String postOwnerId, // ← add this
  }) async {
    try {
      final token = await getToken();
      final res = await http.post(
        Uri.parse('$baseUrl/comments/create'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'id_users': userId.toString(),
          'id_post': postId.toString(),
          'content': content,
          'id_post_user': postOwnerId, // ← send post owner id
        }),
      );
      return jsonDecode(res.body);
    } catch (e) {
      print('Create comment error: $e');
      return null;
    }
  }

  static Future<bool> likeComment({
    required int commentId,
    required bool isLiking,
  }) async {
    try {
      final token = await getToken();
      final res = await http.post(
        Uri.parse('$baseUrl/comments/like'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'comment_id': commentId, 'is_liking': isLiking}),
      );
      return res.statusCode == 200;
    } catch (e) {
      print('Like comment error: $e');
      return false;
    }
  }

  static Future<bool> reportComment({
    required int commentId,
    required int userId,
  }) async {
    try {
      final token = await getToken();
      final res = await http.post(
        Uri.parse('$baseUrl/comments/report'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'comment_id': commentId, 'user_id': userId}),
      );
      return res.statusCode == 200;
    } catch (e) {
      print('Report comment error: $e');
      return false;
    }
  }

  static Future<Map<String, String>> getHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  static Future<List<Map<String, dynamic>>> getMonuments() async {
    final headers = await getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/monuments_in_danger_page'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data['monuments']);
    }
    throw Exception('Failed to load monuments');
  }

  static Future<bool> reportMonument({
    required String monumentName,
    required String region,
    required String description,
    required String urgenceLevel,
    required String dangerType,
    required List<String> imageUrls,
  }) async {
    final headers = await getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/monuments_in_danger_page/report'),
      headers: headers,
      body: jsonEncode({
        'monument_name': monumentName,
        'region': region,
        'description': description,
        'urgence_level': urgenceLevel,
        'danger_type': dangerType,
        'image_urls': imageUrls,
      }),
    );
    return response.statusCode == 201;
  }

  static Future<bool> updateStatus({
    required int monumentId,
    required String status,
  }) async {
    final headers = await getHeaders();
    final response = await http.put(
      Uri.parse('$baseUrl/monuments_in_danger_page/update_status'),
      headers: headers,
      body: jsonEncode({'monument_id': monumentId, 'status': status}),
    );
    return response.statusCode == 200;
  }

  static Future<bool> deleteMonument({required int monumentId}) async {
    final headers = await getHeaders();
    final response = await http.delete(
      Uri.parse('$baseUrl/monuments_in_danger_page/delete'),
      headers: headers,
      body: jsonEncode({'monument_id': monumentId}),
    );
    return response.statusCode == 200;
  }

  static Future<bool> deleteComment(int commentId) async {
    try {
      final token = await getToken();
      final res = await http.delete(
        Uri.parse('$baseUrl/comments/delete?comment_id=$commentId'),
        headers: {'Authorization': 'Bearer $token'},
      );
      return res.statusCode == 200;
    } catch (e) {
      print('Delete comment error: $e');
      return false;
    }
    // GROUP CHAT AND MESSAGES
  }

  static Future<bool> sendMessage({
    required String senderId,
    required String groupId,
    required String content,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/send_messages'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'sender_id': int.parse(senderId),
          'group_id': int.parse(groupId),
          'content': content,
        }),
      );

      final data = jsonDecode(response.body);
      return data['success'] == true;
    } catch (e) {
      print('Send message error: $e');
      return false;
    }
  }

  // Get all messages from a group
  static Future<List<dynamic>> getMessages(String groupId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/get_messages?group_id=$groupId'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['messages'] ?? [];
      }
      return [];
    } catch (e) {
      print('Get messages error: $e');
      return [];
    }
  }

  // Get all members of a group
  static Future<List<dynamic>> getGroupMembers(String groupId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/group_members?group_id=$groupId'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['members'] ?? [];
      }
      return [];
    } catch (e) {
      print('Get group members error: $e');
      return [];
    }
  }

  // SEARCH PAGE
  static Future<Map<String, List<dynamic>>> search(String word) async {
    try {
      final token = await getToken();
      final uri = Uri.parse(
        '$baseUrl/home_page/search',
      ).replace(queryParameters: {'word': word.trim()});

      final res = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        return {
          // ✅ List.from() safely converts JSArray → Dart List
          'posts': List<dynamic>.from(data['posts'] ?? []),
          'users': List<dynamic>.from(data['users'] ?? []),
        };
      }
      return {'posts': [], 'users': []};
    } catch (e) {
      print('search error: $e');
      return {'posts': [], 'users': []};
    }
  }

  // ═══════════════════════════════════════
  // ── ADMIN METHODS ──
  // ═══════════════════════════════════════

  static Map<String, String> _adminHeaders(String token) => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',
  };

  // Check if current user is admin
  static Future<bool> isAdmin() async {
    try {
      final token = await getToken();
      if (token == null) return false;
      final res = await http.get(
        Uri.parse('$baseUrl/admin/users'),
        headers: _adminHeaders(token),
      );
      return res.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // POSTS
  static Future<List<dynamic>> adminGetPosts() async {
    final token = await getToken();
    if (token == null) return [];
    final res = await http.get(
      Uri.parse('$baseUrl/admin/posts'),
      headers: _adminHeaders(token),
    );
    if (res.statusCode == 200) return jsonDecode(res.body)['posts'] ?? [];
    return [];
  }

  static Future<bool> adminDeletePost(int postId) async {
    final token = await getToken();
    if (token == null) return false;
    final res = await http.delete(
      Uri.parse('$baseUrl/admin/posts'),
      headers: _adminHeaders(token),
      body: jsonEncode({'post_id': postId}),
    );
    return res.statusCode == 200;
  }

  // VISITS
  static Future<List<dynamic>> adminGetVisits() async {
    final token = await getToken();
    if (token == null) return [];
    final res = await http.get(
      Uri.parse('$baseUrl/admin/visits'),
      headers: _adminHeaders(token),
    );
    if (res.statusCode == 200) return jsonDecode(res.body)['visits'] ?? [];
    return [];
  }

  static Future<bool> adminDeleteVisit(int visitId) async {
    final token = await getToken();
    if (token == null) return false;
    final res = await http.delete(
      Uri.parse('$baseUrl/admin/visits'),
      headers: _adminHeaders(token),
      body: jsonEncode({'visit_id': visitId}),
    );
    return res.statusCode == 200;
  }

  // MONUMENTS
  static Future<List<dynamic>> adminGetMonuments() async {
    final token = await getToken();
    if (token == null) return [];
    final res = await http.get(
      Uri.parse('$baseUrl/admin/monuments'),
      headers: _adminHeaders(token),
    );
    if (res.statusCode == 200) return jsonDecode(res.body)['monuments'] ?? [];
    return [];
  }

  static Future<bool> adminDeleteMonument(int monumentId) async {
    final token = await getToken();
    if (token == null) return false;
    final res = await http.delete(
      Uri.parse('$baseUrl/admin/monuments'),
      headers: _adminHeaders(token),
      body: jsonEncode({'monument_id': monumentId}),
    );
    return res.statusCode == 200;
  }

  static Future<bool> adminUpdateMonumentStatus(
    int monumentId,
    String status,
  ) async {
    final token = await getToken();
    if (token == null) return false;
    final res = await http.put(
      Uri.parse('$baseUrl/admin/monuments'),
      headers: _adminHeaders(token),
      body: jsonEncode({'monument_id': monumentId, 'status': status}),
    );
    return res.statusCode == 200;
  }

  // REPORTED POSTS
  static Future<List<dynamic>> adminGetReportedPosts() async {
    final token = await getToken();
    if (token == null) return [];
    final res = await http.get(
      Uri.parse('$baseUrl/admin/reported_posts'),
      headers: _adminHeaders(token),
    );
    if (res.statusCode == 200) return jsonDecode(res.body)['reports'] ?? [];
    return [];
  }

  static Future<bool> adminApprovePost(int postId) async {
    final token = await getToken();
    if (token == null) return false;
    final res = await http.put(
      Uri.parse('$baseUrl/admin/reported_posts'),
      headers: _adminHeaders(token),
      body: jsonEncode({'post_id': postId}),
    );
    return res.statusCode == 200;
  }

  static Future<bool> adminDeleteReportedPost(int postId) async {
    final token = await getToken();
    if (token == null) return false;
    final res = await http.delete(
      Uri.parse('$baseUrl/admin/reported_posts'),
      headers: _adminHeaders(token),
      body: jsonEncode({'post_id': postId}),
    );
    return res.statusCode == 200;
  }

  // COMMENTS
  static Future<bool> adminDeleteComment(int commentId) async {
    final token = await getToken();
    if (token == null) return false;
    final res = await http.delete(
      Uri.parse('$baseUrl/admin/reported_comments'),
      headers: _adminHeaders(token),
      body: jsonEncode({'comment_id': commentId}),
    );
    return res.statusCode == 200;
  }

  static Future<bool> adminApproveComment(int commentId) async {
    final token = await getToken();
    if (token == null) return false;
    final res = await http.put(
      Uri.parse('$baseUrl/admin/reported_comments'),
      headers: _adminHeaders(token),
      body: jsonEncode({'comment_id': commentId}),
    );
    return res.statusCode == 200;
  }

  // USERS
  static Future<Map<String, dynamic>> adminGetUsers() async {
    final token = await getToken();
    if (token == null) return {'error': 'No token'};
    try {
      final res = await http.get(
        Uri.parse('$baseUrl/admin/users'),
        headers: _adminHeaders(token),
      );
      if (res.statusCode == 200) return jsonDecode(res.body);
      return {'error': 'Status ${res.statusCode}'};
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> adminGetUserById(int userId) async {
    final token = await getToken();
    if (token == null) return {'error': 'No token'};
    try {
      final res = await http.get(
        Uri.parse('$baseUrl/admin/users/$userId'),
        headers: _adminHeaders(token),
      );
      if (res.statusCode == 200) return jsonDecode(res.body);
      return {'error': 'Status ${res.statusCode}'};
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> adminUpdateUserStatus({
    required int userId,
    required String action,
  }) async {
    final token = await getToken();
    if (token == null) return {'error': 'No token'};
    try {
      final res = await http.put(
        Uri.parse('$baseUrl/admin/users'),
        headers: _adminHeaders(token),
        body: jsonEncode({'user_id': userId, 'action': action}),
      );
      if (res.statusCode == 200) return jsonDecode(res.body);
      return {'error': 'Status ${res.statusCode}'};
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  // STATISTICS
  static Future<Map<String, dynamic>> adminGetOverview() async {
    final token = await getToken();
    if (token == null) return {'total_users': 0, 'total_posts': 0};
    try {
      final res = await http.get(
        Uri.parse('$baseUrl/admin/stats/overview'),
        headers: _adminHeaders(token),
      );
      if (res.statusCode == 200) {
        return jsonDecode(res.body)['data'] ??
            {'total_users': 0, 'total_posts': 0};
      }
      return {'total_users': 0, 'total_posts': 0};
    } catch (e) {
      return {'total_users': 0, 'total_posts': 0};
    }
  }

  static Future<List<Map<String, dynamic>>> adminGetUserStats() async {
    final token = await getToken();
    if (token == null) return [];
    try {
      final res = await http.get(
        Uri.parse('$baseUrl/admin/stats/users'),
        headers: _adminHeaders(token),
      );
      if (res.statusCode == 200) {
        return List<Map<String, dynamic>>.from(
          jsonDecode(res.body)['data'] ?? [],
        );
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> adminGetPostStats() async {
    final token = await getToken();
    if (token == null) return [];
    try {
      final res = await http.get(
        Uri.parse('$baseUrl/admin/stats/posts'),
        headers: _adminHeaders(token),
      );
      if (res.statusCode == 200) {
        return List<Map<String, dynamic>>.from(
          jsonDecode(res.body)['data'] ?? [],
        );
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // ── UPDATE POST ────────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> updatePost({
    required String postId,
    required String userId,
    String? title,
    String? description,
    String? localisation,
    String? historicalPeriod,
    String? heritageType,
  }) async {
    try {
      final token = await getToken();
      final res = await http.put(
        Uri.parse('$baseUrl/update_post'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'post_id': postId,
          'user_id': userId,
          if (title != null) 'title': title,
          if (description != null) 'description': description,
          if (localisation != null) 'localisation': localisation,
          if (historicalPeriod != null) 'historical_period': historicalPeriod,
          if (heritageType != null) 'heritage_type': heritageType,
        }),
      );
      return jsonDecode(res.body) as Map<String, dynamic>;
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  // ── DELETE POST ────────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> deletePost({
    required String postId,
    required String userId,
  }) async {
    try {
      final token = await getToken();
      final res = await http.delete(
        Uri.parse('$baseUrl/delete_post'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'post_id': postId, 'user_id': userId}),
      );
      return jsonDecode(res.body) as Map<String, dynamic>;
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  // ── REPORT POST ────────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> reportPost({
    required String userId,
    required String postId,
    required String reason,
    String? commentId,
  }) async {
    try {
      final token = await getToken();
      final res = await http.post(
        Uri.parse('$baseUrl/report_post'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'user_id': userId,
          'post_id': postId,
          'reason': reason,
          if (commentId != null) 'comment_id': commentId,
        }),
      );
      return jsonDecode(res.body) as Map<String, dynamic>;
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  // in api.dart
  static Future<Map<String, dynamic>> toggleFollow({
    required String followingUserId, // current user (who follows)
    required String followedUserId, // other user (who gets followed)
  }) async {
    try {
      final token = await getToken();
      final res = await http.post(
        Uri.parse(
          '$baseUrl/follows/follow_unfollow',
        ), // ← adjust to your route path
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'following_user_id': int.tryParse(followingUserId) ?? 0,
          'followed_user_id': int.tryParse(followedUserId) ?? 0,
        }),
      );

      print('toggleFollow status: ${res.statusCode}');
      print('toggleFollow body:   ${res.body}');

      if (res.statusCode == 200) {
        return jsonDecode(res.body) as Map<String, dynamic>;
      }
      return {'error': 'Failed: ${res.statusCode}'};
    } catch (e) {
      print('toggleFollow error: $e');
      return {'error': e.toString()};
    }
  }

  // check if current user follows another user
  static Future<bool> checkFollow({
    required String followingUserId,
    required String followedUserId,
  }) async {
    try {
      final token = await getToken();
      final uri = Uri.parse('$baseUrl/follows/check_follow').replace(
        queryParameters: {
          'following_user_id': followingUserId,
          'followed_user_id': followedUserId,
        },
      );

      final res = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        return data['is_following'] as bool? ?? false;
      }
      return false;
    } catch (e) {
      print('checkFollow error: $e');
      return false;
    }
  }
}
