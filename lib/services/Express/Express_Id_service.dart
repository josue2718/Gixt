import 'dart:async';
import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http; // Importar el paquete http
import 'dart:convert'; // Para trabajar con JSON

class Express {
  // IDs
  String express_id;

  // worker
  String worker_first_name;
  String worker_username;
  String worker_image;
  String worker_description;
  int worker_rating;

  String maps_address;
  double latitude;
  double longitude;


  // job
  String job_date;
  String job_time;
  String description;
  String problem;
  double price;
  String payment_method;
  bool is_active;
  String job_status;
  String payment_status;

  // images
  String? image;

  Express({
    required this.express_id,
    required this.worker_first_name,
    required this.worker_username,
    required this.worker_description,
    required this.worker_rating,
    required this.worker_image,
    required this.maps_address,
    required this.latitude,
    required this.longitude,
    required this.job_date,
    required this.job_time,
    required this.description,
    required this.problem,
    required this.price,
    required this.payment_method,
    required this.is_active,
    required this.job_status,
    required this.payment_status,
    this.image,
  });

  factory Express.fromJson(Map<String, dynamic> json) {


    return Express(
      express_id: json['express_id'] ?? '',

      // client
      worker_first_name: json['worker']?['first_name'] ?? '',
      worker_username: json['worker']?['username'] ?? '',
      worker_image: json['worker']?['image'] ?? '',
      worker_description: json['worker']?['description'] ?? '',
      worker_rating: json['worker']?['rating'] ?? '',
      // location
     
      latitude:  json['latitude'],
      longitude:json['longitude'],
      maps_address: json['maps_address'],


      // job
      job_date: json['job_date'] ?? '',
      job_time: json['job_time'] ?? '',
      description: json['description'] ?? '',
      problem: json['problem'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      payment_method: json['payment_method'] ?? '',
      is_active: json['is_active'] ?? false,
      job_status: json['job_status'] ?? '',
      payment_status: json['payment_status'] ?? '',

      image: json['image'],
    );
  }
}


class ExpressById_service {
  List<Express> express = []; // Lista de empresas
  int pageNumber = 1;
  bool isLoading = false;
  bool hasMore = true;

  set loading(bool loading) {}

  Future<bool> fetchServicioData(String id, {bool forceRefresh = false}) async {
    print("fetch Job by id");

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final headers = {'Authorization': 'Bearer $token'};

    try {
      isLoading = true;

      final response = await http
          .get(
            Uri.parse('${dotenv.env['API_URL']}/api/Expresss/id/${id}'),
            headers: headers,
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        express
          ..clear()
          ..add(Express.fromJson(jsonResponse));
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
