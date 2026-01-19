import 'dart:ffi';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http; // Importar el paquete http
import 'dart:convert'; // Para trabajar con JSON
class Servicios {
  String nombreServicio;
  String idServicio;
  String trabajador;
  String imgTrabajador;
  String categoria;
  double precio;
  String imgServicio;
  int calificacion;
  String descripcion;
  String desTrabajador;
  List<String> imagenes;

  Servicios({
    required this.nombreServicio,
    required this.idServicio,
    required this.trabajador,
    required this.imgTrabajador,
    required this.categoria,
    required this.precio,
    required this.imgServicio,
    required this.calificacion,
    required this.descripcion,
    required this.imagenes,
    required this.desTrabajador
  });

  factory Servicios.fromJson(Map<String, dynamic> json) {
    // Primero obtenemos el objeto Trabajador si existe
    final trabajadorJson = json['trabajador'];

    return Servicios(
      idServicio: json['id_servicio'].toString(),
      nombreServicio: json['nombre_servicio'] ?? '',
      categoria: json['categoria'] ?? '',
      precio: json['precio'],
      imgServicio: json['imagen'] ?? '',
      descripcion: json['descripcion'] ?? '',
      calificacion: json['calificacion'] ?? 0,
      
      // Extraemos del objeto Trabajador
      trabajador: trabajadorJson != null ? trabajadorJson['username'] ?? '' : '',
      imgTrabajador: trabajadorJson != null ? trabajadorJson['imagen'] ?? '' : '',
      desTrabajador: trabajadorJson != null ? trabajadorJson['descripcion'] ?? '' : '',
      // Lista de imágenes (puede venir vacía)
      imagenes: List<String>.from(json['imagenes'] ?? []),
    );
  }

  @override
  String toString() {
    return 'Servicios(nombre: $nombreServicio, categoria: $categoria, trabajador: $trabajador)';
  }
}


class ApiServiciosById {
  List<Servicios> servicios = []; // Lista de empresas
  int pageNumber = 1;
  bool isLoading = false;
  bool hasMore = true;

  set loading(bool loading) {}

  Future<void> fetchServicioData(String id, {bool forceRefresh = false}) async {
    print("fetch servicios");

    final prefs = await SharedPreferences.getInstance();
    print("🌐 Llamando API");

    final token = prefs.getString('token');
    final headers = {'Authorization': 'Bearer $token'};

    try {
      isLoading = true;

      final response = await http.get(
        Uri.parse('${dotenv.env['API_URL']}/api/Servicios/id/${id}'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
      print( jsonResponse); 
      servicios
        ..clear()
        ..add(Servicios.fromJson(jsonResponse));

       
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
