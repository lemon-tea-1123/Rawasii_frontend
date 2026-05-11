class Post {
  String id; // ← add (id_post from backend)
  String userId; // ← add (user_id from backend)
  String description;
  List<String> imagePaths;
  String localisation;
  String historicalPer;
  String monumentType;
  String createdAt;
  String updatedAt;
  String title;
  String viewsCount; // ← add
  String reactionCount; // ← add
  String commentCount; // ← add
  String statu;

  Post.create({
    required this.title,
    required this.description,
    required this.localisation,
    required this.historicalPer,
    required this.monumentType,
    required this.imagePaths,
    this.id = '',
    this.userId = '',
    this.createdAt = '',
    this.updatedAt = '',
    this.viewsCount = '0',
    this.reactionCount = '0',
    this.commentCount = '0',
    this.statu = 'Active',
  });

  Post({
    this.id = '',
    this.userId = '',
    this.description = '',
    this.imagePaths = const [],
    this.localisation = '',
    this.historicalPer = '',
    this.monumentType = '',
    this.createdAt = '',
    this.updatedAt = '',
    this.title = '',
    this.viewsCount = '0',
    this.reactionCount = '0',
    this.commentCount = '0',
    this.statu = 'Active',
  });

  // ── existing setters — untouched ───────────────────────────────────────
  void setDescription(String desc) => description = desc;

  // ── add this — maps backend JSON to your Post class ───────────────────
  factory Post.fromJson(Map<String, dynamic> json) {
    // extract image paths from nested image list
    final imageList = json['image'] as List? ?? [];
    final paths = imageList
        .map((img) => img['image_path'] as String? ?? '')
        .where((path) => path.isNotEmpty)
        .toList();

    return Post(
      id: json['id_post']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      localisation: json['localisation']?.toString() ?? '',
      historicalPer: json['historical_period']?.toString() ?? '',
      monumentType: json['heritage_type']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
      imagePaths: paths, // ← extracted from nested image
      viewsCount: (json['views_count'] ?? 0).toString(),
      reactionCount: (json['reaction_count'] ?? 0).toString(),
      commentCount: (json['comment_count'] ?? 0).toString(),
    );
  }
}
