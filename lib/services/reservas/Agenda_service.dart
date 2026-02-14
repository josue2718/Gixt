import 'dart:async';
import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http; // Importar el paquete http
import 'dart:convert'; // Para trabajar con JSON

class Agenda {
  // IDs
  String job_id;
  String client_id;

  // worker
  String worker_first_name;
  String worker_username;
  String worker_image;
  int worker_rating;
  String worker_description;

  // location
  String location_id;
  String street;
  String neighborhood;
  String house_number;
  String state;
  String maps_address;
  String reference;
  String location_image;
  double latitude;
  double longitude;

  // service
  String service_id;
  String service_name;
  String service_description;
  String service_image;

  // job
  String job_date;
  String job_time;
  String description;
  String problem;
  double price;
  String payment_method;
  bool terms;
  bool is_active;
  String job_status;
  String payment_status;

  // images
  String? image_1;
  String? image_2;

  Agenda({
    required this.job_id,
    required this.client_id,
    required this.worker_first_name,
    required this.worker_username,
    required this.worker_image,
    required this.worker_description,
    required this.worker_rating,
    required this.location_id,
    required this.street,
    required this.neighborhood,
    required this.house_number,
    required this.state,
    required this.maps_address,
    required this.reference,
    required this.location_image,
    required this.latitude,
    required this.longitude,
    required this.service_id,
    required this.service_name,
    required this.service_description,
    required this.service_image,
    required this.job_date,
    required this.job_time,
    required this.description,
    required this.problem,
    required this.price,
    required this.payment_method,
    required this.terms,
    required this.is_active,
    required this.job_status,
    required this.payment_status,
    this.image_1,
    this.image_2,
  });

  factory Agenda.fromJson(Map<String, dynamic> json) {
    final worker = json['worker'] ?? {};
    final location = json['location'] ?? {};
    final service = json['service'] ?? {};

    return Agenda(
      job_id: json['job_id'] ?? '',
      client_id: json['client_id'] ?? '',

      // worker
      worker_first_name: worker['first_name'] ?? '',
      worker_username: worker['username'] ?? '',
      worker_image: worker['image'] ?? '',
      worker_description: worker['description'] ?? '',
      worker_rating : worker['rating']?? 0,

      // location
      location_id: location['location_id'] ?? '',
      street: location['street'] ?? '',
      neighborhood: location['neighborhood'] ?? '',
      house_number: location['house_number'] ?? '',
      state: location['state'] ?? '',
      latitude:  location['latitude'] ?? 0,
      longitude: location['longitude'] ??0 ,
      maps_address: location['maps_address'] ?? '',
      reference: location['reference'] ?? '',
      location_image: location['image'] ?? '',

      // service
      service_id: service['service_id'] ?? '',
      service_name: service['service_name'] ?? '',
      service_description: service['description'] ?? '',
      service_image: service['image'] ?? '',

      // job
      job_date: json['job_date'] ?? '',
      job_time: json['job_time'] ?? '',
      description: json['description'] ?? '',
      problem: json['problem'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      payment_method: json['payment_method'] ?? '',
      terms: json['terms'] ?? false,
      is_active: json['is_active'] ?? false,
      job_status: json['job_status'] ?? '',
      payment_status: json['payment_status'] ?? '',

      image_1: json['image_1'],
      image_2: json['image_2'],
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

    final headers = {'Authorization': 'Bearer $token'};

    try {
      isLoading = true;

      final response = await http
          .get(
            Uri.parse('${dotenv.env['API_URL']}/api/Jobs/id/${id}'),
            headers: headers,
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        agenda
          ..clear()
          ..add(Agenda.fromJson(jsonResponse));
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
