import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http; // Importar el paquete http
import 'dart:convert'; // Para trabajar con JSON

class Agenda {
  // IDs
  String idTrabajo;
  String idCliente;

  // Trabajador
  String trabajadorNombre;
  String trabajadorUsername;
  String trabajadorImagen;

  // Ubicación
  String idUbicacion;
  String calle;
  String colonia;
  String ncasa;
  String estadoUbicacion;
  String direccionMaps;
  String referencias;
  String ubicacionImagen;

  // Servicio
  String idServicio;
  String nombreServicio;
  String descripcionServicio;
  String imagenServicio;

  // Trabajo
  String fechaTrabajo;
  String horaTrabajo;
  String descripcion;
  String problema;
  double precio;
  String tipoPago;
  bool tyc;
  bool activo;
  String estadoTrabajo;
  String pagado;

  // Imágenes del trabajo
  String? imagen1;
  String? imagen2;

  Agenda({
    required this.idTrabajo,
    required this.idCliente,
    required this.trabajadorNombre,
    required this.trabajadorUsername,
    required this.trabajadorImagen,
    required this.idUbicacion,
    required this.calle,
    required this.colonia,
    required this.ncasa,
    required this.estadoUbicacion,
    required this.direccionMaps,
    required this.referencias,
    required this.ubicacionImagen,
    required this.idServicio,
    required this.nombreServicio,
    required this.descripcionServicio,
    required this.imagenServicio,
    required this.fechaTrabajo,
    required this.horaTrabajo,
    required this.descripcion,
    required this.problema,
    required this.precio,
    required this.tipoPago,
    required this.tyc,
    required this.activo,
    required this.estadoTrabajo,
    required this.pagado,
    this.imagen1,
    this.imagen2,
  });

  factory Agenda.fromJson(Map<String, dynamic> json) {
    final trabajador = json['trabajador'] ?? {};
    final ubicacion = json['ubicacion'] ?? {};
    final servicio = json['servicio'] ?? {};

    return Agenda(
      idTrabajo: json['id_trabajo'],
      idCliente: json['id_cliente'],

      // Trabajador
      trabajadorNombre: trabajador['first_name'] ?? '',
      trabajadorUsername: trabajador['username'] ?? '',
      trabajadorImagen: trabajador['imagen'] ?? '',

      // Ubicación
      idUbicacion: ubicacion['id_ubicacion'] ?? '',
      calle: ubicacion['calle'] ?? '',
      colonia: ubicacion['colonia'] ?? '',
      ncasa: ubicacion['ncasa'] ?? '',
      estadoUbicacion: ubicacion['estado'] ?? '',
      direccionMaps: ubicacion['direccion_maps'] ?? '',
      referencias: ubicacion['referencias'] ?? '',
      ubicacionImagen: ubicacion['imagen'] ?? '',

      // Servicio
      idServicio: servicio['id_servicio'] ?? '',
      nombreServicio: servicio['nombre_servicio'] ?? '',
      descripcionServicio: servicio['descripcion'] ?? '',
      imagenServicio: servicio['imagen'] ?? '',

      // Trabajo
      fechaTrabajo: json['fecha_trabajo'],
      horaTrabajo: json['hora_trabajo'],
      descripcion: json['descripcion'] ?? '',
      problema: json['problema'] ?? '',
      precio: (json['precio'] ?? 0).toDouble(),
      tipoPago: json['tipo_pago'] ?? '',
      tyc: json['tyc'] ?? false,
      activo: json['activo'] ?? false,
      estadoTrabajo: json['estado'] ?? '',
      pagado: json['pagado'] ?? '',

      // Imágenes
      imagen1: json['imagen_1'],
      imagen2: json['imagen_2'],
    );
  }
}


class AgendaById_service {
  List<Agenda> agenda = []; // Lista de empresas
  int pageNumber = 1;
  bool isLoading = false;
  bool hasMore = true;

  set loading(bool loading) {}

  Future<bool> fetchServicioData(String id, {bool forceRefresh = false}) async {

  print("fetch agenda by id");

  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');

  final headers = {
    'Authorization': 'Bearer $token',
  };

  try {

    isLoading = true;

    final response = await http
        .get(
          Uri.parse(
            '${dotenv.env['API_URL']}/api/Trabajos/id/${id}',
          ),
          headers: headers,
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {

      final Map<String, dynamic> jsonResponse =
          json.decode(response.body);
     
      agenda
        ..clear()
        ..add(Agenda.fromJson(jsonResponse));
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
