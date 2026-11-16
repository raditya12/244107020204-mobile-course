import '../../domain/entities/post.dart';

/// Model representasi data luar (JSON API/SQLite) untuk bacaan.
class PostModel extends Post {
  const PostModel({
    required super.id,
    required super.title,
    required super.body,
  });

  Map<String, dynamic> toMap() => {'id': id, 'title': title, 'body': body};

  factory PostModel.fromMap(Map<String, dynamic> map) => PostModel(
    id: (map['id'] as num).toInt(),
    title: map['title'] as String,
    body: map['body'] as String,
  );

  Post toEntity() => Post(id: id, title: title, body: body);
}
