class AuthSession {
  const AuthSession({
    required this.access,
    required this.refresh,
    required this.email,
  });

  final String access;
  final String refresh;
  final String email;
}

/// Mock auth provider.
///
/// Titik ganti ke Firebase Auth: cukup ubah isi [login] menjadi
/// `FirebaseAuth.instance.signInWithEmailAndPassword(...)` lalu ambil ID token
/// dengan `getIdToken()`. Pola repository dan refresh token tetap sama.
class AuthRepository {
  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (!email.contains('@') || password.length < 6) {
      throw Exception('Email atau kata sandi tidak valid');
    }
    // Simulasi JWT: header.payload.signature.
    // Di produksi JWT tidak boleh di-parse manual; verifikasi dilakukan server.
    return AuthSession(
      access: 'mock-access-for-$email',
      refresh: 'mock-refresh-for-$email',
      email: email,
    );
  }

  Future<String> refresh(String refreshToken) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    if (refreshToken.isEmpty) {
      throw Exception('Refresh token hilang');
    }
    return 'mock-access-renewed-${DateTime.now().millisecondsSinceEpoch}';
  }
}
