import '../../../../core/failures.dart';

/// Kontrak repository preferensi aplikasi (tema, waktu terakhir dibuka).
abstract class PrefsRepository {
  Future<({bool darkMode, Failure? failure})> getDarkMode();

  Future<({bool ok, Failure? failure})> setDarkMode(bool value);

  Future<({String? lastOpened, Failure? failure})> getLastOpened();

  Future<({bool ok, Failure? failure})> markOpenedNow();

  /// Membaca API key layanan AI yang disimpan lokal per perangkat.
  Future<({String? apiKey, Failure? failure})> getApiKey();

  /// Menyimpan API key layanan AI di penyimpanan lokal per perangkat.
  Future<({bool ok, Failure? failure})> setApiKey(String value);
}
