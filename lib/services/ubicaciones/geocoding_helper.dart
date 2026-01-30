import 'package:geocoding/geocoding.dart';

class GeocodingHelper {
  static Future<void> obtenerCiudadDesdeCoordenadas({
    required double latitud,
    required double longitud,
    required Function(String ciudad, String calle , String estado) onResult,
  }) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latitud,
        longitud,
      );

      Placemark p = placemarks.first;

      String ciudad =
          p.locality ?? p.subAdministrativeArea ?? p.administrativeArea ?? '';

      String calle = p.street ?? p.thoroughfare ?? p.name ?? '';
      String estado = p.administrativeArea ?? '';
      onResult(ciudad, calle,estado);
    } catch (e) {
      print("Geocoding error: $e");
      onResult('', '','');
    }
  }
}
