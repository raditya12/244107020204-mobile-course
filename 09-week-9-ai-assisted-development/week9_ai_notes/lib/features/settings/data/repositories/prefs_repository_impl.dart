import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/failures.dart';
import '../../domain/repositories/prefs_repository.dart';

/// Implementasi [PrefsRepository] memakai SharedPreferences.
class PrefsRepositoryImpl implements PrefsRepository {
  static const _darkModeKey = 'dark_mode';
  static const _lastOpenedKey = 'last_opened_at';

  @override
  Future<({bool darkMode, Failure? failure})> getDarkMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return (darkMode: prefs.getBool(_darkModeKey) ?? false, failure: null);
    } catch (e) {
      return (darkMode: false, failure: LocalFailure('Gagal membaca tema: $e'));
    }
  }

  @override
  Future<({bool ok, Failure? failure})> setDarkMode(bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_darkModeKey, value);
      return (ok: true, failure: null);
    } catch (e) {
      return (ok: false, failure: LocalFailure('Gagal menyimpan tema: $e'));
    }
  }

  @override
  Future<({String? lastOpened, Failure? failure})> getLastOpened() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return (lastOpened: prefs.getString(_lastOpenedKey), failure: null);
    } catch (e) {
      return (
        lastOpened: null,
        failure: LocalFailure('Gagal membaca waktu buka: $e'),
      );
    }
  }

  @override
  Future<({bool ok, Failure? failure})> markOpenedNow() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_lastOpenedKey, DateTime.now().toIso8601String());
      return (ok: true, failure: null);
    } catch (e) {
      return (
        ok: false,
        failure: LocalFailure('Gagal menyimpan waktu buka: $e'),
      );
    }
  }
}
