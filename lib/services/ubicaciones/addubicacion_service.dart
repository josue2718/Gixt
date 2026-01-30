import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AddUbicacionService {
  static Future<Map<String, dynamic>> Crear({
    required String calle,
    required String colonia,
    required String ncasa,
    required String estado,
    required String ciudad,
    required String referencias,
    required File image,
    required double latitud,
    required double longitud,
    required String direccion_maps

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
        final uri = Uri.parse('${dotenv.env['API_URL']}/api/Ubicacion');

        // Crear MultipartRequest
        var request = http.MultipartRequest('POST', uri);

        // Campos de texto
        request.fields['id_user'] = id_user!;
        request.fields['calle'] = calle;
        request.fields['colonia'] = colonia;
        request.fields['ncasa'] = ncasa;
        request.fields['estado'] = estado;
        request.fields['ciudad'] = ciudad;
        request.fields['referencias'] = referencias;
        request.fields['direccion_maps'] = direccion_maps;
        request.fields['longitud'] = longitud.toString();
        request.fields['latitud'] = latitud.toString();

        // Archivo
        request.files.add(
          await http.MultipartFile.fromPath(
            'imagen', // nombre del campo que espera el backend
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
