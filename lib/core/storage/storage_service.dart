import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();


  static const _keyToken = 'auth_token';


  /// save Token
  Future<void> saveToken(String token) async {
    await _storage.write(key: _keyToken, value: token);
  }

  Future<void> clearToken() async {
    await _storage.delete(key: 'auth_token');
    // Clear other user data if needed
    await _storage.deleteAll(); // Or be selective
  }


  /// this is Get Token
  Future<String?> getToken() async {
    return await _storage.read(key: _keyToken);
  }




  /// ---------------------- Clear all Storage Data Clear ------------------
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}