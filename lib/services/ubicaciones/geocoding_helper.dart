import 'package:geocoding/geocoding.dart';

class GeocodingHelper {
  static Future<void> obtenerCiudadDesdeCoordenadas({
    required double latitud,
    required double longitud,
    required Function(String ciudad, String calle , String estado, String colonia, String pais) onResult,
  }) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latitud,
        longitud,
      );

      Placemark p = placemarks.first;


      String calle = p.street ?? p.thoroughfare ?? p.name ?? '';
      String colonia = p.administrativeArea ?? '';
      String ciudad = p.locality ?? '';
      String estado = p.administrativeArea ?? '';
      String pais = p.country ?? '';

      onResult(ciudad, calle,estado,colonia,pais);
    } catch (e) {
      print("Geocoding error: $e");
      onResult('', '','','','');
    }
  }
}
