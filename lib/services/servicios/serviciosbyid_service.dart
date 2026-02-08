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
  bool fav;
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
    required this.desTrabajador,
    required this.fav
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
      fav : json['favorito'],
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
    return 'Serviciosss(fav ${fav})';
  }
  
}


class ServiciosById_service {
  List<Servicios> servicios = []; // Lista de empresas
  int pageNumber = 1;
  bool isLoading = false;
  bool hasMore = true;

  set loading(bool loading) {}

  Future<bool> fetchServicioData(String id, {bool forceRefresh = false}) async {

  print("fetch servicios by id");

  final prefs = await SharedPreferences.getInstance();
  String? id_user = prefs.getString('id');
  final token = prefs.getString('token');

  final headers = {
    'Authorization': 'Bearer $token',
  };

  try {

    isLoading = true;

    final response = await http
        .get(
          Uri.parse(
            '${dotenv.env['API_URL']}/api/Servicios/id/$id?iduser=$id_user',
          ),
          headers: headers,
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {

      final Map<String, dynamic> jsonResponse =
          json.decode(response.body);
     
      servicios
        ..clear()
        ..add(Servicios.fromJson(jsonResponse));
      return true;
    }

    return false; 
  }

  catch (e) {
    return false; 
  }

  finally {
    isLoading = false;
  }
}

  
}
