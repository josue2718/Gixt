import 'dart:async';
import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http; // Importar el paquete http
import 'dart:convert'; // Para trabajar con JSON

class Anuncio {
  int advertisement_id;
  String image_url;

  Anuncio({required this.advertisement_id, required this.image_url});

  factory Anuncio.fromJson(Map<String, dynamic> json) {
    return Anuncio(advertisement_id: json['advertisement_id'], image_url: json['image_url']);
  }

  @override
  String toString() {
    return 'Empresa(nombre: $advertisement_id, url_img: $image_url)';
  }
}

class Anuncio_service {
  List<Anuncio> anuncio = [];
  bool isLoading = false;
  bool hasMore = true;
  static const String _cacheKey = 'anuncio_cache';
  static const String _cacheTimeKey = 'anuncio_cache_time';

  set loading(bool loading) {}

  Future<void> updatedata() async {
    print("📦 actualizando anuncios");
    await fetchFromApi();
  }

  Future<bool> fetchAnuncioData() async {
    final prefs = await SharedPreferences.getInstance();

    // config cache
    const cacheDuration = Duration(days: 1);

    // leer cache
    final cachedData = prefs.getString(_cacheKey);
    final cachedTime = prefs.getInt(_cacheTimeKey);

    final now = DateTime.now();

    //  validar cache
    if (cachedData != null &&
        cachedTime != null &&
        now.difference(DateTime.fromMillisecondsSinceEpoch(cachedTime)) <
            cacheDuration) {
      print("📦 Usando cache anuncios");

      final List<dynamic> jsonData = json.decode(cachedData);
      anuncio
        ..clear()
        ..addAll(jsonData.map((e) => Anuncio.fromJson(e)));

      return true;
    }

    print("🚫 Cache inválido → API anuncios");
    return await fetchFromApi();
  }

  Future<bool> fetchFromApi() async {
    final prefs = await SharedPreferences.getInstance();

    print("🌐 Llamando API anuncios");

    final token = prefs.getString('token');
    String? id = prefs.getString('id');

    final headers = {'Authorization': 'Bearer $token'};

    try {
      isLoading = true;

      final response = await http
          .get(
            Uri.parse('${dotenv.env['API_URL']}/api/Advertisements'),
            headers: headers,
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse = json.decode(response.body);
        anuncio
          ..clear()
          ..addAll(jsonResponse.map((e) => Anuncio.fromJson(e)));

        await prefs.setString(_cacheKey, response.body);
        await prefs.setInt(
          _cacheTimeKey,
          DateTime.now().millisecondsSinceEpoch,
        );
        return true;
      }

      print("❌ Error HTTP: ${response.statusCode}");
      return false;
    } on TimeoutException {
      print("⏱️ Timeout de la API");
      return false;
    } on SocketException {
      print("🌐 Sin conexión a internet");
      return false;
    } catch (e) {
      print("❌ Error inesperado: $e");
      return false;
    } finally {
      isLoading = false;
    }
  }
}
