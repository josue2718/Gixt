import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http; // Importar el paquete http
import 'dart:convert'; // Para trabajar con JSON

class User {
  
  String id_user;
  String username;
  String first_name;
  String last_name;
  String phone;
  String url_img;
  String email;
  String fecnac;
  String genero;
  
  User({
    required this.id_user,
    required this.username,
    required this.url_img,
    required this.first_name,
    required this.last_name,
    required this.phone,
    required this.email,
    required this.fecnac,
    required this.genero

  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id_user: json['id_user'],
      username: json['username'],
      url_img: json['imagen'],
      first_name: json['first_name'],
      last_name: json['last_name'],
      phone: json['phone'],
      email: json['email'],
      fecnac : json['fecha_nacimiento'],
      genero : json['genero']
     
    );
  }

  @override
  String toString() {
    return 'Empresa(nombre: $username, url_img: $url_img)';
  }
}

class ApiUser {
  List<User> user = []; // Lista de empresas
  bool isLoading = false;
  bool hasMore = true;
  static const String _cacheKey = 'user_cache';
  static const String _cacheTimeKey = 'user_cache_time';

  set loading(bool loading) {}
 
  Future<void> updatedata() async {
    await fetchData(forceRefresh: true);
  }


 Future<void> fetchData( {bool forceRefresh = false}) async {
  print("fetch user");

  final prefs = await SharedPreferences.getInstance();
  String? id_user = prefs.getString('id');
  // ⏱ cache config
  const cacheDuration = Duration(minutes: 10);

  // 🔍 revisar cache
  final cachedData = prefs.getString(_cacheKey);
  final cachedTime = prefs.getInt(_cacheTimeKey);

  final now = DateTime.now();

  if (!forceRefresh &&
      cachedData != null &&
      cachedTime != null &&
      now.difference(DateTime.fromMillisecondsSinceEpoch(cachedTime)) <
          cacheDuration) {

    print("✔ Usando cache");
    print("datos cache: " + cachedData);
    
    final Map<String, dynamic> jsonData =
    json.decode(cachedData);
    user
      ..clear()
        ..add(User.fromJson(jsonData));

    return;
  }

  print("🌐 Llamando API");

  final token = prefs.getString('token');
  final headers = {'Authorization': 'Bearer $token'};

  try {
    isLoading = true;

    final response = await http.get(
      Uri.parse('${dotenv.env['API_URL']}/api/Users/id/${id_user}'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      print( jsonResponse); 
      user
        ..clear()
        ..add(User.fromJson(jsonResponse));

      // 💾 guardar cache
      await prefs.setString(_cacheKey, response.body);
      await prefs.setInt(
        _cacheTimeKey,
        DateTime.now().millisecondsSinceEpoch,
      );
    } else {
      print('Error en la solicitud: ${response.statusCode}');
    }
  } finally {
    isLoading = false;
  }
}

}