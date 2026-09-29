# Prompt yang digunakan

Buatkan repository layer Flutter untuk endpoint GET /comments?postId={id}
dari JSONPlaceholder menggunakan Dio + flutter_riverpod.
Requirements:
- Model Comment dengan fromJson aman null (postId, id, name, email, body).
- CommentRepository dengan method fetchComments(postId) + timeout 10 detik.
- AsyncNotifierProvider dengan penanganan error otomatis (AsyncError)
  dan fungsi pesan error ramah pengguna untuk timeout, connection error, 404, dan 500.
- Satu unit test untuk fromJson dengan field yang hilang.
- Jelaskan setiap bagian kode dalam komentar.

Verifikasi tambahan: UI lewat repository; parsing aman; seluruh DioExceptionType
dipetakan; konfigurasi client terpusat; tambahkan edge case; jalankan
`flutter analyze` dan `flutter test`. Simpan output awal, koreksi, dan hasilnya.
