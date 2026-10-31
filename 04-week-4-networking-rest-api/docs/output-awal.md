# Output awal AI (sebelum verifikasi)

Snapshot rancangan awal yang dibuat pada sesi ini:

- `Comment`: immutable, pemeriksaan `is int`/`is String` sebelum cast;
  default ID `0` dan teks `''`.
- `CommentRepository`: menerima Dio, memanggil `/comments` dengan
  `queryParameters: {'postId': postId}`.
- `commentsProvider`: `AsyncNotifierProvider.autoDispose.family`, terpisah per
  postId; `build()` meneruskan Future repository dan retry otomatis dimatikan.
- Test awal: `Comment.fromJson({})`, memeriksa kelima default field.

Bagian repository awal yang perlu dievaluasi:

```dart
final response = await _dio.get<List<dynamic>>(
  '/comments',
  queryParameters: {'postId': postId},
);
return (response.data ?? [])
    .whereType<Map<String, dynamic>>()
    .map(Comment.fromJson)
    .toList();
```

Snapshot ini belum diverifikasi. Ia memakai client dan helper pesan error yang
sudah ada. Client awal hanya mengatur connect/receive timeout; helper memakai
default untuk sebagian jenis error dan menampilkan detail exception non-Dio.
Test widget bawaan masih menguji counter yang sudah tidak ada.
