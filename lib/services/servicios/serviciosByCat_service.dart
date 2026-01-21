import 'dart:ffi';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http; // Importar el paquete http
import 'dart:convert'; // Para trabajar con JSON

class ServiciosByCat {
  String nombre_servicio;
  String id_servicio;
  String trabajador;
  String img_trabajador;
  String categoria;
  double precio;
  String img_servicio;
  int calificacion;
  String descripcion;

  ServiciosByCat({
    required this.nombre_servicio,
    required this.categoria,
    required this.img_trabajador,
    required this.trabajador,
    required this.precio,
    required this.img_servicio,
    required this.id_servicio,
    required this.calificacion,
    required this.descripcion,
  });

  factory ServiciosByCat.fromJson(Map<String, dynamic> json) {
    return ServiciosByCat(
      nombre_servicio: json['nombre_servicio'],
      categoria: json['categoria'],
      trabajador: json['first_name'],
      precio: json['precio'],
      img_trabajador: json['imagenuser'],
      img_servicio: json['imagen'],
      descripcion: json['descripcion'],
      id_servicio: json['id_servicio'],
      calificacion: json['calificacion'],
    );
  }

  @override
  String toString() {
    return 'Empresa(nombre: $nombre_servicio, direccion: $categoria, url_img: $img_servicio)';
  }
}

class ApiServiciosByCat {
  List<ServiciosByCat> servicios = []; // Lista de empresas
  bool isLoading = false;
  bool hasMore = true;
  set loading(bool loading) {}

  Future<void> fetchServicioCatData(
    int id,
    int pageNumber, {
    bool forceRefresh = false,
  }) async {
    print("fetch servicios categoria ${id}, ${pageNumber}");

    final prefs = await SharedPreferences.getInstance();

    print("🌐 Llamando API");

    final token = prefs.getString('token');
    final headers = {'Authorization': 'Bearer $token'};

    try {
      isLoading = true;

      final response = await http.get(
        Uri.parse(
          '${dotenv.env['API_URL']}/api/Servicios/categoria/${id}?pageNumber=${pageNumber}',
        ),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final List<dynamic> data = jsonResponse['data'];
        print(data);
        servicios
          ..addAll(data.map((item) => ServiciosByCat.fromJson(item)).toList());
      } else {
      
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
