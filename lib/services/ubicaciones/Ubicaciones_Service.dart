import 'dart:async';
import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http; // Importar el paquete http
import 'dart:convert'; // Para trabajar con JSON
class Ubicacion {
  String user_id;
  String location_id;
  String street;
  String neighborhood;
  String house_number;
  String state;
  String city;
  String reference;
  String image;
  String maps_address;
  double latitude;
  double longitude;

  Ubicacion({
    required this.user_id,
    required this.location_id,
    required this.street,
    required this.neighborhood,
    required this.house_number,
    required this.state,
    required this.city,
    required this.reference,
    required this.image,
    required this.maps_address,
    required this.latitude,
    required this.longitude,
  });

  factory Ubicacion.fromJson(Map<String, dynamic> json) {
    return Ubicacion(
      user_id: json['user_id'] ?? '',
      location_id: json['location_id'] ?? '',
      street: json['street'] ?? '',
      neighborhood: json['neighborhood'] ?? '',
      house_number: json['house_number'] ?? '',
      state: json['state'] ?? '',
      city: json['city'] ?? '',
      reference: json['reference'] ?? '',
      image: json['image'] ?? '',
      maps_address: json['maps_address'] ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
    );
  }
}


class UbicacionesService {
  List<Ubicacion> ubicacion = []; // Lista de empresas
  int pageNumber = 1;
  bool isLoading = false;
  bool hasMore = true;

  set loading(bool loading) {}

  Future<bool> fetchData({bool forceRefresh = false}) async {
    print("fetch servicios");

    final prefs = await SharedPreferences.getInstance();
    print("🌐 Llamando API");
    String? id_user = prefs.getString('id');
    final token = prefs.getString('token');
    final headers = {'Authorization': 'Bearer $token'};

    try {
      isLoading = true;

      final response = await http
          .get(
            Uri.parse(
              '${dotenv.env['API_URL']}/api/Location/user/${id_user}',
            ),
            headers: headers,
          )
          .timeout(const Duration(seconds: 15));
      ;

      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse = json.decode(response.body);
        print(jsonResponse);
        ubicacion
          ..clear()
          ..addAll(jsonResponse.map((e) => Ubicacion.fromJson(e)));

        return true;
      }
      print("❌ Error HTTP: ${response.statusCode}");
      return false;
    } on TimeoutException {
      print("⏱️ Timeout de la API");
      return false;
    } on SocketException {
      print("🌐 Sin conexión a internet");
      return false;
    } catch (e) {
      print("❌ Error inesperado: $e");
      return false;
    } finally {
      isLoading = false;
    }
  }
}
