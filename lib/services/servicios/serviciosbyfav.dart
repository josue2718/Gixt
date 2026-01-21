import 'dart:ffi';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http; // Importar el paquete http
import 'dart:convert'; // Para trabajar con JSON

class ServiciosFav {
  String nombre_servicio;
  String id_servicio;
  String trabajador;
  String img_trabajador;
  String categoria;
  double precio;
  String img_servicio;
  int calificacion;
  String descripcion;

  ServiciosFav({
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

  factory ServiciosFav.fromJson(Map<String, dynamic> json) {
    return ServiciosFav(
      nombre_servicio: json['nombre_servicio'],
      categoria: json['categoria'],
      trabajador : json['first_name'],
      precio: json['precio'],
      img_trabajador : json['imagenuser'],
      img_servicio: json['imagen'],
      descripcion:  json['descripcion'],
      id_servicio: json['id_servicio'],
      calificacion: json['calificacion']
    );
  }

  @override
  String toString() {
    return 'Empresa(nombre: $nombre_servicio, direccion: $categoria, url_img: $img_servicio)';
  }
}

class ApiServiciosFav {
  List<ServiciosFav> servicios = []; // Lista de empresas
  int pageNumber = 1;
  bool isLoading = false;
  bool hasMore = true;

  set loading(bool loading) {}
 Future<void> updatedata(int id) async {
    await fetchServicioData(id, forceRefresh: true);
  }
  Future<void> fetchServicioData(int number, {bool forceRefresh = false}) async {
    print("fetch servicios");

    final prefs = await SharedPreferences.getInstance();

   
    print("🌐 Llamando API fav");

    final token = prefs.getString('token');
    final headers = {'Authorization': 'Bearer $token'};
    String? id = prefs.getString('id');

    try {
      isLoading = true;

      final response = await http.get(
        Uri.parse('${dotenv.env['API_URL']}/api/Favoritos/id/${id}'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse = json.decode(response.body);
        servicios.clear();
        servicios.addAll(
          jsonResponse.map((item) => ServiciosFav.fromJson(item)).toList(),
        );
        servicios
          ..clear()
          ..addAll(jsonResponse.map((e) => ServiciosFav.fromJson(e)));

       
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
