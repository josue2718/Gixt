import 'dart:ffi';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http; // Importar el paquete http
import 'dart:convert'; // Para trabajar con JSON

class Servicios {
  String nombre_servicio;
  String id_servicio;
  String trabajador;
  String img_trabajador;
  String categoria;
  double precio;
  String img_servicio;

  Servicios({
    required this.nombre_servicio,
    required this.categoria,
    required this.img_trabajador,
    required this.trabajador,
    required this.precio,
    required this.img_servicio,
    required this.id_servicio,
  });

  factory Servicios.fromJson(Map<String, dynamic> json) {
    return Servicios(
      nombre_servicio: json['nombre_servicio'],
      categoria: json['categoria'],
      trabajador : json['first_name'],
      precio: json['precio'],
      img_trabajador : json['imagenuser'],
      img_servicio: json['imagen'],
      id_servicio: json['id_servicio'],
    );
  }

  @override
  String toString() {
    return 'Empresa(nombre: $nombre_servicio, direccion: $categoria, url_img: $img_servicio)';
  }
}

class ApiServicios {
  List<Servicios> servicios = []; // Lista de empresas
  int pageNumber = 1;
  bool isLoading = false;
  bool hasMore = true;
  static const String _cacheKey = 'servicios_cache';
  static const String _cacheTimeKey = 'servicios_cache_time';

  set loading(bool loading) {}
 Future<void> updatedata(int id) async {
    await fetchEmpresaData(id, forceRefresh: true);
  }
  Future<void> fetchEmpresaData(int number, {bool forceRefresh = false}) async {
    print("fetch servicios");

    final prefs = await SharedPreferences.getInstance();

    // cache config
    const cacheDuration = Duration(minutes: 10);

    // revisar cache
    final cachedData = prefs.getString(_cacheKey);
    final cachedTime = prefs.getInt(_cacheTimeKey);

    final now = DateTime.now();

    if (!forceRefresh &&
        cachedData != null &&
        cachedTime != null &&
        now.difference(DateTime.fromMillisecondsSinceEpoch(cachedTime)) < cacheDuration) {
          print("Usando cache");

          final List<dynamic> jsonData = json.decode(cachedData);
          servicios
            ..clear()
            ..addAll(jsonData.map((e) => Servicios.fromJson(e)));

          return;
      }

    print("🌐 Llamando API");

    final token = prefs.getString('token');
    final headers = {'Authorization': 'Bearer $token'};

    try {
      isLoading = true;

      final response = await http.get(
        Uri.parse('${dotenv.env['API_URL']}/api/Servicios'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse = json.decode(response.body);
        servicios.clear();
        servicios.addAll(
          jsonResponse.map((item) => Servicios.fromJson(item)).toList(),
        );
        servicios
          ..clear()
          ..addAll(jsonResponse.map((e) => Servicios.fromJson(e)));

        //  guardar cache
        await prefs.setString(_cacheKey, response.body);
        await prefs.setInt(
          _cacheTimeKey,
          DateTime.now().millisecondsSinceEpoch,
        );
      } else {
        servicios.clear();
      }
    } finally {
      isLoading = false;
    }
  }

  // Future<void> fetchEmpresatipo(int tipo, int Number) async {
  //   if (isLoading || !hasMore) return;
  //   final prefs = await SharedPreferences.getInstance();
  //   final token = prefs.getString('token');
  //   final headers = {'Authorization': 'Bearer $token'};

  //   try {
  //     isLoading = true;

  //     final response = await http.get(
  //       Uri.parse(
  //         'https://cateringmid.azurewebsites.net/api/Empresa/tipo/$tipo?pageNumber=$Number&pageSize=200&timestamp=${DateTime.now().millisecondsSinceEpoch}',
  //       ),
  //       headers: headers,
  //     );
  //     if (response.statusCode == 200) {
  //       final Map<String, dynamic> jsonResponse = json.decode(response.body);
  //       final List<dynamic> data = jsonResponse['data'];
  //       empresas.clear();
  //       empresas.addAll(data.map((item) => Empresas.fromJson(item)).toList());
  //     } else if (response.statusCode == 401) {
  //     } else {
  //       throw Exception('Error al cargar datos: ${response.statusCode}');
  //     }
  //   } catch (e) {
  //   } finally {
  //     isLoading = false;
  //   }
  // }
}
