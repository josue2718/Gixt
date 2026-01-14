import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  // Variables de almacenamiento
  static const String _tokenKey = 'token';
  static const String _inicioKey = 'inicio';
  static const String _idKey = 'id';
  // Cargar los valores desde SharedPreferences
  Future<Map<String, dynamic>> loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString(_tokenKey);
    bool? inicio = prefs.getBool(_inicioKey);
    String? id = prefs.getString(_idKey);
    return {
      'token': token,
      'inicio': inicio,
      'id': id,
    };
  }

  // Guardar los valores en SharedPreferences
  Future<void> savePreferences(String token, String inicio, String id ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_inicioKey, inicio);
    await prefs.setString(_idKey, id);

    print(id);
    print(token);
    print(inicio);
  }

   

  // Eliminar todos los datos de SharedPreferences (opcional)
  Future<void> clearPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_inicioKey);
    await prefs.remove(_idKey);
  }
}
