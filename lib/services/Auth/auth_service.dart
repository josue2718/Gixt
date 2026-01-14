import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class AuthService {
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    int attempts = 0;
    const int maxAttempts = 15;
    http.Response? response;

    while (attempts < maxAttempts) {
      print('llamando a login');
      try {
        response = await http
            .post(
              Uri.parse('${dotenv.env['API_URL']}/api/Auth/login'),
              headers: {'Content-Type': 'application/json'},
              body: json.encode({
                'email': email,
                'password': password,
              }),
            )
            .timeout(const Duration(seconds: 30));

        if (response.statusCode == 200) {
          return {
            'success': true,
            'data': jsonDecode(response.body),
          };
        }

        if (response.statusCode == 401) {
          return {
            'success': false,
            'message': jsonDecode(response.body)['message'],
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
      'message': 'No se pudo completar el login',
    };
  }
}
