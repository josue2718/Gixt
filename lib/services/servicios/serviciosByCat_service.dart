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

  Future<bool> fetchServicioCatData(
    int id,
    int pageNumber, {
    bool forceRefresh = false,
  }) async {

    final prefs = await SharedPreferences.getInstance();

    final token = prefs.getString('token');
    final headers = {'Authorization': 'Bearer $token'};

    try {
      isLoading = true;

      final response = await http.get(
        Uri.parse(
          '${dotenv.env['API_URL']}/api/Servicios/categoria/${id}?pageNumber=${pageNumber}',
        ),
        headers: headers,
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final List<dynamic> data = jsonResponse['data'];
        print(data);
        servicios
          ..addAll(data.map((item) => ServiciosByCat.fromJson(item)).toList());
          return true;
      } else {
        return false;
      
      }
    } finally {
      isLoading = false;
    }
  }

 
}
