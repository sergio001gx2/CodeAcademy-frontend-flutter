class DiscussionForum {
  final int id;
  final String title;
  final String? description;
  final int course;

  DiscussionForum({
    required this.id,
    required this.title,
    this.description,
    required this.course,
  });

  factory DiscussionForum.fromJson(Map<String, dynamic> json) {
    return DiscussionForum(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      course: json['course'] as int,
    );
  }
}

class ForumPost {
  final int id;
  final String title;
  final String content;
  final DateTime createdAt;
  final int forum;
  final int author;
  final String? authorEmail;

  ForumPost({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.forum,
    required this.author,
    this.authorEmail,
  });

  factory ForumPost.fromJson(Map<String, dynamic> json) {
    return ForumPost(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now(),
      forum: json['forum'] as int,
      author: json['author'] as int? ?? 0,
      authorEmail: json['author_email'] as String?,
    );
  }
}

class ForumComment {
  final int id;
  final String content;
  final DateTime createdAt;
  final int post;
  final int author;
  final String? authorEmail;

  ForumComment({
    required this.id,
    required this.content,
    required this.createdAt,
    required this.post,
    required this.author,
    this.authorEmail,
  });

  factory ForumComment.fromJson(Map<String, dynamic> json) {
    return ForumComment(
      id: json['id'] as int,
      content: json['content'] as String? ?? '',
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now(),
      post: json['post'] as int,
      author: json['author'] as int? ?? 0,
      authorEmail: json['author_email'] as String?,
    );
  }
}
