import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:gixt/cache.dart';
import 'package:gixt/components/BarStatus.dart';
import 'package:gixt/components/Indicador.dart';
import 'package:gixt/components/alert.dart';
import 'package:gixt/components/circleimage.dart';
import 'package:gixt/components/colors.dart';
import 'package:gixt/services/reservas/Agenda_service.dart';
import 'package:gixt/services/ubicaciones/geocoding_helper.dart';
import 'package:gixt/services/ubicaciones/location_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signalr_netcore/hub_connection.dart';
import 'package:signalr_netcore/hub_connection_builder.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

class ViewLocationTimePage extends StatefulWidget {
  const ViewLocationTimePage({
    super.key,
    required this.job_id,
    required this.latitude,
    required this.longitude,
  });
  final String job_id;
  final double latitude;
  final double longitude;
  @override
  State<ViewLocationTimePage> createState() => _ViewLocationTimePageState();
}

class _ViewLocationTimePageState extends State<ViewLocationTimePage> {
  bool isLoading = false;
  bool hasMore = true;
  final AgendaById_service agenda = AgendaById_service();
  final ScrollController _scrollController = ScrollController();
  final PreferencesService _preferencesService = PreferencesService();
  final PageController _controller = PageController();

  GoogleMapController? _mapController;
  HubConnection? hubConnection;

  bool onlocation = false;
  GoogleMapController? mapController;
  Set<Polyline> polylines = {};
  LatLng? get posicion => LatLng(widget.latitude, widget.longitude);
  LatLng? posicionworker = LatLng(20.9674, -89.5926);
  BitmapDescriptor? iconoUsuario;
  BitmapDescriptor? iconoWorker;
  @override
  void initState() {
    super.initState();
    print("Entré a Mi Servicio");
    _initial();
    _cargarIconos();
  }

  Future<void> _initial() async {
    await connectGps();
  }

  // Future<void> connectGps() async {
  //   hubConnection = HubConnectionBuilder()
  //       .withUrl("${dotenv.env['API_URL']}/gpsHub")
  //       .withAutomaticReconnect()
  //       .build();
  //   try {
  //     await hubConnection!.start();
  //     print("SignalR conectado");
  //   } catch (e) {
  //     print("Error conectando SignalR: $e");
  //     return;
  //   }

  //   hubConnection!.on("ReceiveLocationId", (data) {
  //     if (data == null || data.length < 3) return;
  //     try {
  //       String userId = data[0].toString();

  //       double lat = (data[1] as num).toDouble();
  //       double lng = (data[2] as num).toDouble();

  //       posicionworker = LatLng(lat, lng);

  //       print("Trabajador: $userId");
  //       print("Lat: $lat");
  //       print("Lng: $lng");
  //       if (!onlocation) {
  //         print('genrado');
  //         _irAMiUbicacion();
  //         getRoute();
  //       }
  //       onlocation = true;
  //       setState(() {});
  //     } catch (e) {
  //       print("Error parsing GPS: $e");
  //     }
  //   });
  // }

  Future<void> connectGps() async {
    hubConnection = HubConnectionBuilder()
        .withUrl("${dotenv.env['API_URL']}/gpsHub")
        .withAutomaticReconnect()
        .build();
    String workerId =
        "b77a9a22-1c96-4a36-9e40-910debac224d"; // ID único para el worker
    /// Escuchar ubicación del worker
    hubConnection!.on("ReceiveLocationId", (data) {
      if (data == null || data.length < 3) return;

      try {
        String userId = data[0].toString();

        double lat = (data[1] as num).toDouble();
        double lng = (data[2] as num).toDouble();

        posicionworker = LatLng(lat, lng);

        print("Trabajador: $userId");
        print("Lat: $lat");
        print("Lng: $lng");

        if (!onlocation) {
          print('Generando ruta...');
          _irAMiUbicacion();
          getRoute();
        }

        onlocation = true;

        if (mounted) setState(() {});
      } catch (e) {
        print("Error parsing GPS: $e");
      }
    });

    try {
      /// Conectar al Hub
      await hubConnection!.start();
      print("✅ SignalR conectado");

      /// Unirse al grupo del worker
      await hubConnection!.invoke("JoinGroup", args: [workerId]);

      print("✅ Unido al grupo: $workerId");
    } catch (e) {
      print("❌ Error conectando SignalR: $e");
    }
  }

  Future<void> _irAMiUbicacion() async {
    // 🔥 MOVER CÁMARA
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: posicionworker!, zoom: 17),
      ),
    );
  }

  List<LatLng> polylineCoordinates = [];

  Future<void> getRoute() async {
    PolylinePoints polylinePoints = PolylinePoints(
      apiKey: "AIzaSyAjcb5WA1kNYLE5Gchmx1sNnpZM31vzXF8",
    );

    PolylineRequest request = PolylineRequest(
      origin: PointLatLng(posicionworker!.latitude, posicionworker!.longitude),
      destination: PointLatLng(posicion!.latitude, posicion!.longitude),
      mode: TravelMode.driving,
    );

    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      request: request,
    );

    if (result.points.isNotEmpty) {
      polylineCoordinates.clear();

      for (var point in result.points) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      }
      if (!mounted) return;
      setState(() {
        createPolyline();
      });
    }
  }

  void createPolyline() {
    polylines.add(
      Polyline(
        polylineId: PolylineId("ruta"),
        points: polylineCoordinates,
        width: 5,
      ),
    );
  }
  // Future<void> _cargarIconos() async {
  // final prefs = await SharedPreferences.getInstance();
  // String? img = prefs.getString('img');
  //   iconoUsuario = await BitmapDescriptor.fromAssetImage(
  //    ImageConfiguration(size: Size(48, 48)),
  //     img! ,
  //   );
  //   iconoWorker = await BitmapDescriptor.fromAssetImage(
  //     const ImageConfiguration(size: Size(48, 48)),
  //     img!,
  //   );
  //   setState(() {});
  // }

  Future<void> _cargarIconos() async {
    final prefs = await SharedPreferences.getInstance();
    String? img = prefs.getString('img');

    if (img != null) {
      final response = await http.get(Uri.parse(img));
      final bytes = response.bodyBytes;

      final codec = await ui.instantiateImageCodec(bytes, targetWidth: 80);
      final frame = await codec.getNextFrame();
      final data = await frame.image.toByteData(format: ui.ImageByteFormat.png);

      iconoUsuario = BitmapDescriptor.fromBytes(data!.buffer.asUint8List());
      iconoWorker = BitmapDescriptor.fromBytes(data.buffer.asUint8List());
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardDismisser(
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: CustomScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            _buildSliverAppBar(),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buidUbicacion(),
                  const SizedBox(height: 40),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  SliverAppBar _buildSliverAppBar() {
    return SliverAppBar(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      expandedHeight: 90,
      pinned: false,
      floating: true,
      snap: true,
      elevation: 0,
      toolbarHeight: 90,

      iconTheme: IconThemeData(
        color: Theme.of(context).colorScheme.surface, // 👈 color del ícono
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(0)),
      ),
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: Text(
          'Ubicacion En Tiempo Real',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.surface,
          ),
        ),
      ),
    );
  }

  Widget _buidUbicacion() {
    final h = MediaQuery.of(context).size.height;
    return SizedBox(
      height: h,
      child: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(target: posicion!, zoom: 16),
            polylines: polylines,
            myLocationEnabled: false,
            myLocationButtonEnabled: false,
            onMapCreated: (controller) {
              _mapController = controller;
            },
            gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
              Factory<OneSequenceGestureRecognizer>(
                () => EagerGestureRecognizer(),
              ),
            },

            markers: {
              Marker(
                markerId: MarkerId("ubicacion"),
                position: posicion!,
                icon: iconoUsuario ?? BitmapDescriptor.defaultMarker,
                infoWindow: const InfoWindow(title: "Tú"),
              ),
              if (onlocation) ...[
                Marker(
                  markerId: MarkerId("worker"),
                  position: posicionworker!,
                  icon: iconoWorker ?? BitmapDescriptor.defaultMarker,
                  infoWindow: const InfoWindow(title: "Worker"),
                ),
              ],
            },
          ),
          Positioned(
            bottom: 150,
            right: 15,
            child: FloatingActionButton(
              heroTag: "ubicacion",
              backgroundColor: colorsecundario,
              onPressed: _irAMiUbicacion,
              child: Icon(Icons.my_location, color: colorWhite),
            ),
          ),
        ],
      ),
    );
  }
}
