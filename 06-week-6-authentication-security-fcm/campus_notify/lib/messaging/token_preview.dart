/// Menampilkan token secara terpotong untuk halaman Debug.
///
/// Token penuh tidak pernah ditampilkan di layar, log, maupun screenshot.
String previewToken(String token) {
  if (token.length <= 12) return '$token...';
  return '${token.substring(0, 12)}...';
}
