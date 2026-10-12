/// Fungsi murni: mengubah `data` payload FCM menjadi rute GoRouter.
///
/// Dipisahkan dari Firebase agar bisa di-unit-test tanpa plugin native.
String routeFromMessage(Map<String, dynamic> data) {
  final raw = (data['route'] ?? '/').toString().trim();
  if (raw.isEmpty) return '/';
  return raw.startsWith('/') ? raw : '/$raw';
}
