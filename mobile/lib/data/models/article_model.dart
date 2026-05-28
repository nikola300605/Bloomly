class ArticleModel {
  final String id;
  final String authorId;
  final String title;
  final String body;
  final String? coverPhoto;
  final List<String> tags;
  final List<String> linkedPlantIds;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final int likeCount;
  final int commentCount;
  final String? authorHandle;
  final String? authorAvatar;
  final bool isLiked;
  final bool isSaved;

  const ArticleModel({
    required this.id,
    required this.authorId,
    required this.title,
    required this.body,
    this.coverPhoto,
    required this.tags,
    required this.linkedPlantIds,
    required this.createdAt,
    this.updatedAt,
    required this.likeCount,
    required this.commentCount,
    this.authorHandle,
    this.authorAvatar,
    required this.isLiked,
    required this.isSaved,
  });

  factory ArticleModel.fromJson(Map<String, dynamic> j) => ArticleModel(
        id: j['id'] as String,
        authorId: j['author_id'] as String,
        title: j['title'] as String,
        body: j['body'] as String,
        coverPhoto: j['cover_photo'] as String?,
        tags: List<String>.from(j['tags'] as List? ?? []),
        linkedPlantIds: List<String>.from(j['linked_plant_ids'] as List? ?? []),
        createdAt: DateTime.parse(j['created_at'] as String),
        updatedAt: j['updated_at'] != null ? DateTime.parse(j['updated_at'] as String) : null,
        likeCount: j['like_count'] as int? ?? 0,
        commentCount: j['comment_count'] as int? ?? 0,
        authorHandle: j['author_handle'] as String?,
        authorAvatar: j['author_avatar'] as String?,
        isLiked: j['is_liked'] as bool? ?? false,
        isSaved: j['is_saved'] as bool? ?? false,
      );
}

class CommentModel {
  final String id;
  final String articleId;
  final String authorId;
  final String authorHandle;
  final String? authorAvatar;
  final String body;
  final DateTime createdAt;

  const CommentModel({
    required this.id,
    required this.articleId,
    required this.authorId,
    required this.authorHandle,
    this.authorAvatar,
    required this.body,
    required this.createdAt,
  });

  factory CommentModel.fromJson(Map<String, dynamic> j) => CommentModel(
        id: j['id'] as String,
        articleId: j['article_id'] as String,
        authorId: j['author_id'] as String,
        authorHandle: j['author_handle'] as String,
        authorAvatar: j['author_avatar'] as String?,
        body: j['body'] as String,
        createdAt: DateTime.parse(j['created_at'] as String),
      );
}
