import 'package:shared_preferences/shared_preferences.dart';

class PreferencesExpressService {
  // 🔑 Keys reales y coherentes
  static const String _expressIdKey = 'express_id';
  static const String _statusKey = 'express_status';
  static const String _isAcceptKey = 'express_is_accept';

  /// 🔥 Cargar datos
  Future<Map<String, dynamic>> loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();

    return {
      'idexpress': prefs.getString(_expressIdKey),
      'status': prefs.getString(_statusKey),
      'isaccept': prefs.getBool(_isAcceptKey) ?? false,
    };
  }

  /// 🔥 Guardar todo
  Future<void> savePreferences({
    required String id,
    required String status,
    required bool isaccept,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(_expressIdKey, id);
    await prefs.setString(_statusKey, status);
    await prefs.setBool(_isAcceptKey, isaccept);

   
  }

  /// 🔥 Limpiar todo
  Future<void> clearPreferences() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_expressIdKey);
    await prefs.remove(_statusKey);
    await prefs.setBool(_isAcceptKey, false);
  }

}