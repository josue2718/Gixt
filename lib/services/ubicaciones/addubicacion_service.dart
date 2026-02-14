import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AddUbicacionService {
  static Future<Map<String, dynamic>> Crear({
  required String street,
  required String neighborhood,
  required String house_number,
  required String state,
  required String city,
  required String reference,
  required File image,
  required String maps_address,
  required double latitude,
  required double longitude,

  }) async {
    
    int attempts = 0;
    const int maxAttempts = 2;
    final prefs = await SharedPreferences.getInstance();
    String? user_id = prefs.getString('id');
    final token = prefs.getString('token');
    final headers = {'Authorization': 'Bearer $token'};

    while (attempts < maxAttempts) {
      print("llamando a crear");
      try {
        final uri = Uri.parse('${dotenv.env['API_URL']}/api/Location');

        // Crear MultipartRequest
        var request = http.MultipartRequest('POST', uri);

        // Campos de texto
        request.fields['user_id'] = user_id!;
        request.fields['street'] = street;
        request.fields['neighborhood'] = neighborhood;
        request.fields['house_number'] = house_number;
        request.fields['state'] = state;
        request.fields['city'] = city;
        request.fields['reference'] = reference;
        request.fields['maps_address'] = maps_address;
        request.fields['longitude'] = longitude.toString();
        request.fields['latitude'] = latitude.toString();


        // Archivo
        request.files.add(
          await http.MultipartFile.fromPath(
            'image', // nombre del campo que espera el backend
            image.path,
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
            'message': jsonDecode(responseString)['message'],
          };
        }

        if(streamedResponse.statusCode == 400)
        {
          return {
            'success': false,
            'message': jsonDecode(responseString)['message'],
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
