import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AddServicioService {
  static Future<Map<String, dynamic>> Crear({
    required String id_servicio,
    required String id_ubicacion,
    required String fecha_trabajo,
    required String hora_trabajo,
    required String problema,
    required String descripcion,
    required File image_1,
    required File image_2,
    required bool tyc,
    required String tipo_pago

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
        final uri = Uri.parse('${dotenv.env['API_URL']}/api/Trabajos');

        // Crear MultipartRequest
        var request = http.MultipartRequest('POST', uri);

        // Campos de texto
        request.fields['id_cliente'] = id_user!;
        request.fields['id_servicio'] = id_servicio;
        request.fields['id_ubicacion'] = id_ubicacion;
        request.fields['fecha_trabajo'] = fecha_trabajo;
        request.fields['hora_trabajo'] = hora_trabajo;
        request.fields['problema'] = problema;
        request.fields['descripcion'] = descripcion;
        request.fields['tipo_pago'] = tipo_pago;
        request.fields['tyc'] = tyc.toString();

        // Archivo
        request.files.add(
          await http.MultipartFile.fromPath(
            'imagen_1', // nombre del campo que espera el backend
            image_1.path,
          ),
        );
        request.files.add(
          await http.MultipartFile.fromPath(
            'imagen_2', // nombre del campo que espera el backend
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
