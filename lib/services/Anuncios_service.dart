import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http; // Importar el paquete http
import 'dart:convert'; // Para trabajar con JSON

class Anuncio {
  
  int id_anuncio;
  String img;
  
  Anuncio({
    required this.id_anuncio,
    required this.img,

  });

  factory Anuncio.fromJson(Map<String, dynamic> json) {
    return Anuncio(
      id_anuncio: json['id_anuncio'],
      img: json['img'],
    );
  }

  @override
  String toString() {
    return 'Empresa(nombre: $id_anuncio, url_img: $img)';
  }
}

class Anuncio_service {
  List<Anuncio> anuncio = []; // Lista de empresas
  bool isLoading = false;
  bool hasMore = true;
  static const String _cacheKey = 'anuncio_cache';
  static const String _cacheTimeKey = 'anuncio_cache_time';

  set loading(bool loading) {}
 
  Future<void> updatedata() async {
    await fetchData(forceRefresh: true);
  }


 Future<void> fetchData( {bool forceRefresh = false}) async {
  print("fetch anuncio");

  final prefs = await SharedPreferences.getInstance();
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
    
    final List<dynamic> jsonData = json.decode(cachedData);
    anuncio
      ..clear()
      ..addAll(jsonData.map((e) => Anuncio.fromJson(e)));

    return;
  }

  print("🌐 Llamando API");

  final token = prefs.getString('token');
  final headers = {'Authorization': 'Bearer $token'};

  try {
    isLoading = true;

    final response = await http.get(
      Uri.parse('${dotenv.env['API_URL']}/api/Anuncios'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonResponse = json.decode(response.body);
      print( jsonResponse); 
      anuncio
        ..clear()
        ..addAll(jsonResponse.map((e) => Anuncio.fromJson(e)));

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