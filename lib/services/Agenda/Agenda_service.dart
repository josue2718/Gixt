import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http; // Importar el paquete http
import 'dart:convert'; // Para trabajar con JSON

class Agenda {
  String idTrabajo;

  // Trabajador
  String idTrabajador;
  String trabajador;
  String usernameTrabajador;
  String imgTrabajador;

  // Cliente
  String idCliente;

  // Ubicación
  String direccion;

  // Servicio
  String idServicio;
  String nombreServicio;
  String descripcionServicio;
  String imgServicio;

  // Trabajo
  String fechaTrabajo;
  String horaTrabajo;
  String descripcionTrabajo;
  String problema;

  bool activo;
  String estado;
  double precio;

  Agenda({
    required this.idTrabajo,
    required this.idTrabajador,
    required this.trabajador,
    required this.usernameTrabajador,
    required this.imgTrabajador,
    required this.idCliente,
    required this.direccion,
    required this.idServicio,
    required this.nombreServicio,
    required this.descripcionServicio,
    required this.imgServicio,
    required this.fechaTrabajo,
    required this.horaTrabajo,
    required this.descripcionTrabajo,
    required this.problema,
    required this.activo,
    required this.estado,
    required this.precio,
  });

  factory Agenda.fromJson(Map<String, dynamic> json) {
    return Agenda(
      idTrabajo: json['id_trabajo'],

      // trabajador
      idTrabajador: json['trabajador']['id_user'],
      trabajador: json['trabajador']['first_name'],
      usernameTrabajador: json['trabajador']['username'],
      imgTrabajador: json['trabajador']['imagen'],

      // cliente
      idCliente: json['id_cliente'],

      // ubicacion
      direccion: json['ubicacion']['direccion_maps'],

      // servicio
      idServicio: json['servicio']['id_servicio'],
      nombreServicio: json['servicio']['nombre_servicio'],
      descripcionServicio: json['servicio']['descripcion'],
      imgServicio: json['servicio']['imagen'],

      // trabajo
      fechaTrabajo: json['fecha_trabajo'],
      horaTrabajo: json['hora_trabajo'],
      descripcionTrabajo: json['descripcion'],
      problema: json['problema'],
      
      precio : json['precio'],
      activo: json['activo'],
      estado: json['estado'],
    );
  }
}
class Agenda_service {
  List<Agenda> agenda = []; // Lista de empresas
  int pageNumber = 1;
  bool isLoading = false;
  bool hasMore = true;
  static const String _cacheKey = 'agenda_cache';
  static const String _cacheTimeKey = 'agenda_cache_time';

  set loading(bool loading) {}
  Future<bool> updatedata() async {
    return await fetchData(forceRefresh: true);
  }

  Future<bool> fetchData({
    bool forceRefresh = false,
  }) async {

    print("fetch servicios");

    final prefs = await SharedPreferences.getInstance();
    String? id_user = prefs.getString('id'); 
    // cache config
    const cacheDuration = Duration(minutes: 10);

    // revisar cache
    final cachedData = prefs.getString(_cacheKey);
    final cachedTime = prefs.getInt(_cacheTimeKey);

    final now = DateTime.now();

    if (!forceRefresh &&
        cachedData != null &&
        cachedTime != null &&
        now.difference(DateTime.fromMillisecondsSinceEpoch(cachedTime)) <
            cacheDuration) {
      print("Usando cache");

      final List<dynamic> jsonData = json.decode(cachedData);
      agenda
        ..clear()
        ..addAll(jsonData.map((e) => Agenda.fromJson(e)));

      return true;
    }

    print("🌐 Llamando API");

    final token = prefs.getString('token');
    final headers = {'Authorization': 'Bearer $token'};

    try {
      isLoading = true;

      final response = await http.get(
        Uri.parse('${dotenv.env['API_URL']}/api/Trabajos/iduser/$id_user'),
        headers: headers,
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse = json.decode(response.body);
        agenda
          ..clear()
          ..addAll(jsonResponse.map((e) => Agenda.fromJson(e)));

        await prefs.setString(_cacheKey, response.body);
        await prefs.setInt(
          _cacheTimeKey,
          DateTime.now().millisecondsSinceEpoch,
        );
        return true;
      } else {
        agenda.clear();
        return false;
      }
    } finally {
      isLoading = false;
    }
  }

 
}
