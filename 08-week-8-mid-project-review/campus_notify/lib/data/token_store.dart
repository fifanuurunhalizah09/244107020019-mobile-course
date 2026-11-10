import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStore {
  TokenStore({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(
                encryptedSharedPreferences: true,
              ),
            );

  final FlutterSecureStorage _storage;

  static const _accessKey = 'access_token';
  static const _refreshKey = 'refresh_token';

  Future<void> save({
    required String access,
    required String refresh,
  }) async {
    try {
      await _storage.write(key: _accessKey, value: access);
      await _storage.write(key: _refreshKey, value: refresh);
    } catch (e) {
      debugPrint('[TokenStore] save gagal: $e');
    }
  }

  Future<String?> readAccess() async {
    try {
      return await _storage.read(key: _accessKey);
    } catch (e) {
      debugPrint('[TokenStore] readAccess gagal: $e');
      await clear();
      return null;
    }
  }

  Future<String?> readRefresh() async {
    try {
      return await _storage.read(key: _refreshKey);
    } catch (e) {
      debugPrint('[TokenStore] readRefresh gagal: $e');
      await clear();
      return null;
    }
  }

  Future<void> clear() async {
    try {
      await _storage.deleteAll();
    } catch (e) {
      debugPrint('[TokenStore] clear gagal: $e');
    }
  }
}