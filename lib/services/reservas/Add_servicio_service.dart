import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AddServicioService {
  static Future<Map<String, dynamic>> Crear({
    required String service_id,
    required String location_id,
    required String job_date,
    required String job_time,
    required String problem,
    required String description,
    required File image_1,
    required File image_2,
    required String payment_method,
    required bool terms,


  }) async {
    
    int attempts = 0;
    const int maxAttempts = 2;
    final prefs = await SharedPreferences.getInstance();
    String? id_user = prefs.getString('id');
    final token = prefs.getString('token');
    final headers = {'Authorization': 'Bearer $token'};

    while (attempts < maxAttempts) {
      print("llamando a crear");
      try {
        final uri = Uri.parse('${dotenv.env['API_URL']}/api/Jobs');

        // Crear MultipartRequest
        var request = http.MultipartRequest('POST', uri);

        // Campos de texto
        request.fields['client_id'] = id_user!;
        request.fields['service_id'] = service_id;
        request.fields['location_id'] = location_id;
        request.fields['job_date'] = job_date;
        request.fields['job_time'] = job_time;
        request.fields['problem'] = problem;
        request.fields['description'] = description;
        request.fields['payment_method'] = payment_method;
        request.fields['terms'] = true.toString();


        // Archivo
        request.files.add(
          await http.MultipartFile.fromPath(
            'image_1', // nombre del campo que espera el backend
            image_1.path,
          ),
        );
        request.files.add(
          await http.MultipartFile.fromPath(
            'image_2', // nombre del campo que espera el backend
            image_2.path,
          ),
        );
        // Enviar request
        var streamedResponse = await request.send().timeout(const Duration(seconds: 30));

        // Convertir la respuesta a String
        final responseString = await streamedResponse.stream.bytesToString();

        print(responseString);

        if (streamedResponse.statusCode == 200) {
            return {
              'success': true,
              'message': 'creado correctamente',
            };
        }
        if (streamedResponse.statusCode == 401) {
          return {
            'success': false,
            'message': 'error al crear servicio',
          };
        }

        if(streamedResponse.statusCode == 400)
        {
          return {
            'success': false,
            'message': 'error al crear servicio',
          };
        }
      } on TimeoutException {
        return {
          'success': false,
          'message': 'Tiempo de espera agotado',
        };
      } on SocketException {
        return {
          'success': false,
          'message': 'No hay conexión a Internet',
        };
      } catch (e) {
        print(e);
        return {
          'success': false,
          'message': 'Error inesperado',
        };
      }

      attempts++;
      if (attempts < maxAttempts) {
        await Future.delayed(const Duration(seconds: 2));
      }
    }

    return {
      'success': false,
      'message': 'No se pudo completar el registro',
    };
  }
}
