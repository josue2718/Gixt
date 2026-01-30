
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http; // Importar el paquete http
import 'dart:convert'; // Para trabajar con JSON
class Ubicacion {
  String id_ubicacion;
  String calle;
  String colonia;
  String ncasa;
  String estado;
  String ciudad;
  String referencias;
  String urlImg;
  String direccionMaps;
  double latitud;
  double longitud;

  Ubicacion({
    required this.id_ubicacion,
    required this.calle,
    required this.colonia,
    required this.ncasa,
    required this.estado,
    required this.ciudad,
    required this.referencias,
    required this.urlImg,
    required this.direccionMaps,
    required this.latitud,
    required this.longitud,
  });

  factory Ubicacion.fromJson(Map<String, dynamic> json) {
    return Ubicacion(
      id_ubicacion: json['id_ubicacion'].toString(),
      calle: json['calle'] ?? '',
      colonia: json['colonia'] ?? '',
      ncasa: json['ncasa'] ?? '',
      estado: json['estado'] ?? '',
      ciudad: json['ciudad'] ?? '',
      referencias: json['referencias'] ?? '',
      urlImg: json['imagen'] ?? '',
      direccionMaps: json['direccion_maps'] ?? '',
      latitud: (json['latitud'] ?? 0).toDouble(),
      longitud: (json['longitud'] ?? 0).toDouble(),
    );
  }
}



class UbicacionesIdService {
  List<Ubicacion> ubicacion = []; // Lista de empresas
  int pageNumber = 1;
  bool isLoading = false;
  bool hasMore = true;

  set loading(bool loading) {}

  Future<bool> fetchData(String id,{bool forceRefresh = false}) async {
    print("fetch servicios");

    final prefs = await SharedPreferences.getInstance();
    print("🌐 Llamando API");
    final token = prefs.getString('token');
    final headers = {'Authorization': 'Bearer $token'};

    try {
      isLoading = true;

      final response = await http.get(
        Uri.parse('${dotenv.env['API_URL']}/api/Ubicacion/id/${id}'),
        headers: headers,
       ).timeout(const Duration(seconds: 15));;

      if (response.statusCode == 200) {

        final Map<String, dynamic> jsonResponse = json.decode(response.body);
      print( jsonResponse); 
      ubicacion
        ..clear()
        ..add(Ubicacion.fromJson(jsonResponse));
return true;
       
      } else {
       ubicacion.clear();
       return false;
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
