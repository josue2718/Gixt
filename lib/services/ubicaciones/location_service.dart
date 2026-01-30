import 'package:geolocator/geolocator.dart';

class LocationService {

  static Future<Position> obtenerUbicacion() async {

    bool servicioHabilitado;
    LocationPermission permiso;

    // Verificar servicio GPS
    servicioHabilitado = await Geolocator.isLocationServiceEnabled();
    if (!servicioHabilitado) {
      return Future.error('El GPS está desactivado');
    }

    // Verificar permisos
    permiso = await Geolocator.checkPermission();

    if (permiso == LocationPermission.denied) {
      permiso = await Geolocator.requestPermission();
      if (permiso == LocationPermission.denied) {
        return Future.error('Permisos de ubicación denegados');
      }
    }

    if (permiso == LocationPermission.deniedForever) {
      return Future.error('Permisos permanentemente denegados');
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }
}
