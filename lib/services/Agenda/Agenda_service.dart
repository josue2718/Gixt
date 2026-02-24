import 'dart:async';
import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http; // Importar el paquete http
import 'dart:convert'; // Para trabajar con JSON

class Agenda {
  String job_id;

  // worker
  String worker_user_id;
  String worker_first_name;
  String worker_username;
  String worker_image;

  // client
  String client_id;

  // location
  String maps_address;

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

  bool is_active;
  String job_status;
  double price;

  Agenda({
    required this.job_id,
    required this.worker_user_id,
    required this.worker_first_name,
    required this.worker_username,
    required this.worker_image,
    required this.client_id,
    required this.maps_address,
    required this.service_id,
    required this.service_name,
    required this.service_description,
    required this.service_image,
    required this.job_date,
    required this.job_time,
    required this.description,
    required this.problem,
    required this.is_active,
    required this.job_status,
    required this.price,
  });

  factory Agenda.fromJson(Map<String, dynamic> json) {
    return Agenda(
      job_id: json['job_id'] ?? '',

      worker_user_id: json['worker']?['user_id'] ?? '',
      worker_first_name: json['worker']?['first_name'] ?? '',
      worker_username: json['worker']?['username'] ?? '',
      worker_image: json['worker']?['image'] ?? '',

      client_id: json['client_id'] ?? '',

      maps_address: json['location']?['maps_address'] ?? '',

      service_id: json['service']?['service_id'] ?? '',
      service_name: json['service']?['service_name'] ?? '',
      service_description: json['service']?['description'] ?? '',
      service_image: json['service']?['image'] ?? '',

      job_date: json['job_date'] ?? '',
      job_time: json['job_time'] ?? '',
      description: json['description'] ?? '',
      problem: json['problem'] ?? '',

      is_active: json['is_active'] ?? false,
      job_status: json['job_status'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
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
  Future<void> updatedata() async {
    print("📦 actualizando agenda");
    await fetchFromApi();
  }

  Future<bool> fetchAgendaData() async {
    final prefs = await SharedPreferences.getInstance();

    // config cache
    const cacheDuration = Duration(days: 1);

    // leer cache
    final cachedData = prefs.getString(_cacheKey);
    final cachedTime = prefs.getInt(_cacheTimeKey);

    final now = DateTime.now();

    //  validar cache
    if (cachedData != null &&
        cachedTime != null &&
        now.difference(DateTime.fromMillisecondsSinceEpoch(cachedTime)) <
            cacheDuration) {
      print("📦 Usando cache agenda");

      final List<dynamic> jsonData = json.decode(cachedData);
      agenda
        ..clear()
        ..addAll(jsonData.map((e) => Agenda.fromJson(e)));

      return true;
    }

    print("🚫 Cache inválido → API agenda");
    return await fetchFromApi();
  }

  Future<bool> fetchFromApi() async {
    final prefs = await SharedPreferences.getInstance();

    print("🌐 Llamando API agenda");

    final token = prefs.getString('token');
    String? id_user = prefs.getString('id');

    final headers = {'Authorization': 'Bearer $token'};

    try {
      isLoading = true;

      final response = await http
          .get(
            Uri.parse('${dotenv.env['API_URL']}/api/Jobs/user/$id_user'),
            headers: headers,
          )
          .timeout(const Duration(seconds: 15));

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
