/// Model immutable; field yang hilang/null memakai 0 atau string kosong.
class Comment {
  const Comment({
    required this.postId,
    required this.id,
    required this.name,
    required this.email,
    required this.body,
  });

  final int postId;
  final int id;
  final String name;
  final String email;
  final String body;

  factory Comment.fromJson(Map<String, dynamic> json) => Comment(
    // Pemeriksaan tipe juga mencegah crash jika server mengirim tipe keliru.
    postId: json['postId'] is int ? json['postId'] as int : 0,
    id: json['id'] is int ? json['id'] as int : 0,
    name: json['name'] is String ? json['name'] as String : '',
    email: json['email'] is String ? json['email'] as String : '',
    body: json['body'] is String ? json['body'] as String : '',
  );
}
