import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http; // Importar el paquete http
import 'dart:convert'; // Para trabajar con JSON

class Categorias {
  String nombre;
  int id_categoria;

  Categorias({
    required this.nombre,
    required this.id_categoria
  });

  factory Categorias.fromJson(Map<String, dynamic> json) {
    return Categorias(
      nombre: json['nombre'],
      id_categoria: json['id_categoria'],
    );
  }

  @override
  String toString() {
    return 'Empresa(nombre: $nombre,)';
  }
}

class ApiCategorias {
  List<Categorias> categorias = []; // Lista de empresas
  int pageNumber = 1;
  bool isLoading = false;
  bool hasMore = true;
  static const String _cacheKey = 'categorias_cache';
  static const String _cacheTimeKey = 'categorias_cache_time';

  set loading(bool loading) {}

  Future<void> fetchEmpresaData(int Number, {bool forceRefresh = false}) async {
    print("llamando empresas");
    if (isLoading || !hasMore) return;

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    //  cache config
    const cacheDuration = Duration(minutes: 1);
    //  revisar cache
    final cachedData = prefs.getString(_cacheKey);
    final cachedTime = prefs.getInt(_cacheTimeKey);
    final now = DateTime.now();

   if (!forceRefresh &&
    cachedData != null &&
    cachedTime != null &&

    now.difference(DateTime.fromMillisecondsSinceEpoch(cachedTime)) < cacheDuration) {
      print("✔ Usando cache");
      final List<dynamic> jsonData = json.decode(cachedData);
      categorias
        ..clear()
        ..addAll(jsonData.map((e) => Categorias.fromJson(e)));

      return;
    }

    if (token == null || token.isEmpty) {}

      final headers = {'Authorization': 'Bearer $token'};
      final response = await http.get(
        Uri.parse(
          '${dotenv.env['API_URL']}/api/Categorias',
        ),
        headers: headers,
      );
        if (response.statusCode == 200) {
          
          final List<dynamic> jsonResponse = json.decode(response.body); // Decodifica como una lista
          categorias.clear();
          categorias.addAll(jsonResponse.map((item) => Categorias.fromJson(item)).toList());
          categorias
            ..clear()
            ..addAll(jsonResponse.map((e) => Categorias.fromJson(e)));

          //  guardar cache
          await prefs.setString(_cacheKey, response.body);
          await prefs.setInt(
            _cacheTimeKey,
            DateTime.now().millisecondsSinceEpoch,
          );

        } 
        else if (response.statusCode == 401) 
        {
          print("No autorizado");
        } 

      else 
      {
        print("Error en la solicitud: ${response.statusCode}");
      }
    } 

  }
