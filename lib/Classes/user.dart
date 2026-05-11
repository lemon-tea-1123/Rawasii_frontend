import 'package:rawasii/Classes/post.dart';
import 'package:rawasii/services/api.dart';

class User {
  String imagePath;
  String name;
  String email;
  String bio;
  String job;
  String city;
  String interest;
  String creationDate;
  List<Post> userPosts;
  int id;
  int followersCount;
  int followingCount;
  String statu;
  bool isAdmin;

  User({
    this.name = '',
    this.email = '',
    this.bio = '',
    this.imagePath = '',
    this.job = '',
    this.city = '',
    this.interest = '',
    this.creationDate = '',
    this.id = 36,
    this.userPosts = const [],
    this.followersCount = 0,
    this.followingCount = 0,
    this.statu = 'Active',
    this.isAdmin = false,
  });

  static Future<void> init() async {
    final name = await ApiService.getUsername();
    final id = await ApiService.getUserId();
  }

  void setJob(String job) => this.job = job;
  void setBio(String bio) => this.bio = bio;
  void setInterest(String interest) => this.interest = interest;
  void setCreationDate(String date) => creationDate = date;
  String imageGetter() => imagePath;

  // ── add this — maps backend JSON to your User class ───────────────────
  factory User.fromJson(Map<String, dynamic> json) {
    // ── handle user_profile as List or Map ──────────────────────────────
    final profileRaw = json['user_profile'];
    final Map<String, dynamic> profile;

    if (profileRaw is List && profileRaw.isNotEmpty) {
      profile = Map<String, dynamic>.from(profileRaw.first as Map);
    } else if (profileRaw is Map) {
      profile = Map<String, dynamic>.from(profileRaw);
    } else {
      profile = {};
    }

    return User(
      id: int.tryParse(json['id_users']?.toString() ?? '') ?? 0,
      name: json['username'] ?? profile['full_name'] ?? '',
      email: json['email'] ?? '',
      followersCount: json['followers_count'] ?? 0,
      followingCount: json['following_count'] ?? 0,
      job: profile['expertise'] ?? '',
      bio: profile['biography'] ?? '',
      imagePath: profile['profile_image_url'] ?? '',
      interest: profile['specialties'] ?? '',
    );
  }
}
