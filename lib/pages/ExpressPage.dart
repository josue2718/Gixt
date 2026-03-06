import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:gixt/components/BarStatus.dart';
import 'package:gixt/components/CircleImage.dart';
import 'package:gixt/components/Indicador.dart';
import 'package:gixt/components/Radar.dart';
import 'package:gixt/components/alert.dart';
import 'package:gixt/components/alertExpress.dart';
import 'package:gixt/components/categoriasoption.dart';
import 'package:gixt/components/colors.dart';
import 'package:gixt/components/inputs/Input.dart';
import 'package:gixt/components/inputs/InputTap.dart';
import 'package:gixt/components/inputs/Input_Description.dart';
import 'package:gixt/components/inputs/Input_Price.dart';
import 'package:gixt/components/inputs/Pick_Image.dart';
import 'package:gixt/components/sketor/opciones.dart';
import 'package:gixt/config/Notifiers/express_notifiers.dart'
    hide expressNotifier;
import 'package:gixt/services/Express/ExpressCache.dart';
import 'package:gixt/services/Express/Express_Id_service.dart';
import 'package:gixt/services/Express/add_express_Service.dart';
import 'package:gixt/services/servicios/categorias_service.dart';
import 'package:gixt/services/ubicaciones/geocoding_helper.dart';
import 'package:gixt/services/ubicaciones/location_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:signalr_netcore/hub_connection.dart';
import 'package:signalr_netcore/hub_connection_builder.dart';

class ExpressPage extends StatefulWidget {
  const ExpressPage({super.key});
  static bool tieneDatos = false;
  @override
  State<ExpressPage> createState() => _ExpressPageState();
}

class _ExpressPageState extends State<ExpressPage>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _categoryController = TextEditingController();
  final Categorias_service category = Categorias_service();
  int? _categoriaSeleccionada;
  String? _categoriaSelec;
  GoogleMapController? _mapController;
  final ExpressById_service express = ExpressById_service();
  final prefsService = PreferencesExpressService();
  int _paginaActual = 0;
  bool isLoading = false; //Carga de datos de categoiras
  bool isactive = false; // si esta activo la busqueda de trabajadores
  bool isaccept = false; // si un trabajador ya acepto
  bool isSearch =
      false; // si esta buscando trabajador esto es lo que muestra el radar
  bool timeout = false; // si esta fuera de tiempo
  bool follow = false; // para seguir al trabajador en el mapa
  Set<Polyline> polylines = {};
  HubConnection? hubConnection;
  List<LatLng> polylineCoordinates = [];
  double longitude = 0;
  double latitude = 0;
  File? _image;
  String? calle;
  String? ciudad;
  String? estado;
  String? pais;
  String? _payment;
  String? colonia;
  LatLng posicionActual = const LatLng(20.9674, -89.5926);
  LatLng? posicionworker = LatLng(20.9674, -89.5926);
  Timer? _radarTimer;
  double _radarSize = 120; // tamaño inicial
  double _currentZoom = 17;
  bool onlocation = false; 
  String status = 'pending';

  @override
  void initState() {
    super.initState();
    print("Entré a crear servicio");
    _Initial();
    expressNotifier.addListener(_onRefresh);
    expressStatusNotifier.addListener(_reload);
  }

  Future<void> _Initial() async {
    final prefs = await SharedPreferences.getInstance();
    bool? is_accpet = prefs.getBool('express_is_accept');
    setState(() {
      isLoading = true;
      timeout = false;
      isaccept = is_accpet!;
      isactive = is_accpet!;
    });
    if (is_accpet!) {
      _reload();
    } else {
      obtenerCoordenadas();
    }
    bool okData = await category.fetchCategoriasData();
    if (!okData) {
      if (!mounted) return;
      mostrarAlerta(
        context,
        title: "Error",
        message: "No se pudo obtener la información",
        type: alert_type.error,
      );
    }
    _Validation();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _reload() async {
    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    String? id_user = prefs.getString('express_id');

    if (id_user == null) {
      print("❌ id_user null");
      return;
    }

    try {
      /// 🔥 timeout para que no se congele si la API no responde
      bool ok = await express
          .fetchServicioData(id_user)
          .timeout(const Duration(seconds: 10));

      if (!mounted) return;

      /// si la API falló
      if (!ok || express.express.isEmpty) {
        await mostrarAlerta(
          context,
          title: "Error",
          message: "No se pudo obtener la información",
          type: alert_type.error,
        );

        return;
      }

      /// conectar GPS
      await connectGps();

      /// obtener datos seguros
      final data = express.express[0];
      status = data.job_status;
      final nuevaPos = LatLng(data.latitude, data.longitude);

      if (!mounted) return;

      setState(() {
        isaccept = true;
        isSearch = false;

        posicionActual = nuevaPos;
        latitude = data.latitude;
        longitude = data.longitude;
      });
      _mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: nuevaPos, zoom: 17),
        ),
      );
    } catch (e) {
      print("❌ Error API: $e");

      if (!mounted) return;

      await mostrarAlerta(
        context,
        title: "Error",
        message: "No se pudo conectar con el servidor. Intenta más tarde.",
        type: alert_type.error,
      );
    }
  }

  void getcalle() {
    GeocodingHelper.obtenerCiudadDesdeCoordenadas(
      latitud: latitude,
      longitud: longitude,
      onResult:
          (ciudadResult, calleResult, estadoResult, paisResult, coloniaResult) {
            setState(() {
              ciudad = ciudadResult;
              calle = calleResult;
              estado = estadoResult;
              colonia = coloniaResult;
              pais = paisResult;
            });
          },
    );
  }

  void obtenerCoordenadas() async {
    try {
      Position pos = await LocationService.obtenerUbicacion();
      latitude = pos.latitude;
      longitude = pos.longitude;
      posicionActual = LatLng(pos.latitude, pos.longitude);
      setState(() {
        _mapController?.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: posicionActual, zoom: 17),
          ),
        );
      });
      getcalle();
    } catch (e) {
      print(e);
    }
  }

  void radar() {
    _radarTimer?.cancel();

    _radarTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!isSearch) {
        timer.cancel();
        return;
      }

      setState(() {
        posicionActual = LatLng(latitude, longitude);

        // 🔥 Aumenta tamaño del radar
        _radarSize += 10;

        // 🔥 Se aleja el zoom poco a poco
        _currentZoom -= 0.1;

        if (_radarSize > 250) {
          _radarSize = 120; // reinicia tamaño
          _currentZoom = 17; // reinicia zoom
        }

        _mapController?.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: posicionActual, zoom: _currentZoom),
          ),
        );
      });
    });
  }

  Future<void> _pickImage(int index) async {
    final File? image = await pickAndCropImage(context);
    if (image != null) setState(() => _image = image);
  }

  Future<void> _Validation() async {
    Future.delayed(const Duration(seconds: 5), () {
      if (!mounted) return;
      if (isLoading) setState(() => timeout = true);
    });
    if (!mounted) return;
    setState(() {
      if (category.categorias.isNotEmpty) isLoading = false;
    });
  }

  bool salir() {
    if (_paginaActual != 0) {
      setState(() => _paginaActual--);
      return false;
    } else {
      Navigator.pop(context);
      return true;
    }
  }

  Future<void> _onRefresh() async {
    final id = expressNotifier.id;

    if (id != null) {
      print("Nuevo ID recibido: $id");
    }
    if (!mounted) return;
    setState(() {
      print('Actualizando datos... $id');
    });
    bool ok = await express.fetchServicioData(id!);
    await connectGps();
    setState(() {
      isaccept = true;
      isSearch = false;
    });
    if (!ok) {
      if (!mounted) return;
      Future.microtask(() async {
        await mostrarAlerta(
          context,
          title: "Error",
          message: "No se pudo obtener la información",
          type: alert_type.error,
        );
      });
    }
    await prefsService.savePreferences(
      id: id!,
      status: express.express[0].job_status,
      isaccept: isaccept,
    );
    setState(() {
      expressNotifier.clear();
    });
  }

  Future<void> connectGps() async {
    hubConnection = HubConnectionBuilder()
        .withUrl("${dotenv.env['API_URL']}/gpsHub")
        .withAutomaticReconnect()
        .build();
    String workerId = "26bb5b13-bbe7-4c6e-a5bb-33cb6881bbb7"; // ID único para el worker
    hubConnection!.on("ReceiveLocationId", (data) {
      if (data == null || data.length < 3) return;

      try {
        String userId = data[0].toString();

        double lat = (data[1] as num).toDouble();
        double lng = (data[2] as num).toDouble();

        posicionworker = LatLng(lat, lng);
        onlocation = true;
        print("Trabajador: $userId");
        print("Lat: $lat");
        print("Lng: $lng");

        if (!onlocation) {
          print('Generando ruta...');
          _mapController?.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(target: posicionworker!, zoom: 17),
            ),
          );
          getRoute();
        }
        if (follow) {
          print('siguient');
          _mapController?.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(target: posicionworker!, zoom: 17),
            ),
          );
        }

        

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

  Future<void> disconnectGps() async {
    try {
      if (hubConnection != null) {
        await hubConnection!.stop();
        hubConnection = null;
        print("🛑 SignalR desconectado");
      }
    } catch (e) {
      print("❌ Error al desconectar SignalR: $e");
    }
  }

  Future<void> getRoute() async {
    PolylinePoints polylinePoints = PolylinePoints(
      apiKey: "AIzaSyAjcb5WA1kNYLE5Gchmx1sNnpZM31vzXF8",
    );

    PolylineRequest request = PolylineRequest(
      origin: PointLatLng(posicionworker!.latitude, posicionworker!.longitude),
      destination: PointLatLng(
        posicionActual!.latitude,
        posicionActual!.longitude,
      ),
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

  // para boton de mi ubicacion
  Future<void> _GoMyLocation() async {
    if (!isactive) {
      final position = await Geolocator.getCurrentPosition();
      final nuevaPos = LatLng(position.latitude, position.longitude);
      setState(() {
        posicionActual = nuevaPos;
        latitude = position.latitude;
        longitude = position.longitude;
      });
      _mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: nuevaPos, zoom: 17),
        ),
      );
    }

    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: posicionActual, zoom: 17),
      ),
    );
    getcalle();
  }

  void _Cancelar() async {
    bool? ok = await mostrarAlerta(
      context,
      title: 'Cancelar Solicitud',
      message: '¿Estás seguro de cancelar esta solicitud?',
      type: alert_type.advertencia,
    );
    if (ok!) {
      if (!mounted) return;
      disconnectGps();
      setState(() {
        isactive = false;
        isaccept = false;
        isSearch = false;
        prefsService.clearPreferences();
      });
    }
  }

  void _Crear() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_image == null) {
      mostrarAlerta(
        context,
        title: 'Imagen requerida',
        message: 'Por favor ingresa una imagen',
        type: alert_type.advertencia,
      );
      return;
    }
    if (_payment == null) {
      mostrarAlerta(
        context,
        title: 'Método de pago requerido',
        message: 'Selecciona un método de pago',
        type: alert_type.advertencia,
      );
      return;
    }
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Indicador(),
    );

    final result = await AddExpressService.Crear(
      problem: _nameController.text,
      description: _descriptionController.text,
      price: double.parse(_priceController.text),
      category_id: _categoriaSeleccionada!,
      image: _image!,
      latitude: latitude,
      longitude: longitude,
      maps_address: "$calle, $ciudad",
      payment_method: _payment!,
    );

    Navigator.pop(context);

    if (result['success'] == true) {
      setState(() => isactive = true);
      setState(() => isSearch = true);
      radar();
      Future.microtask(() async {
        await mostrarAlerta(
          context,
          title: "Solicitud Enviada",
          message: "Espera que alguien te acepte",
          type: alert_type.exito,
        );
      });
    } else {
      mostrarAlerta(
        context,
        title: "Error",
        message: result['message'],
        type: alert_type.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => salir(),
      child: KeyboardDismisser(
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: Stack(
            children: [
              // 🗺️ MAPA DE FONDO
              Positioned.fill(child: _buildMap()),

              // 📋 PANEL ARRASTRABLE
              if (_paginaActual == 0)
                DraggableScrollableSheet(
                  initialChildSize: 0.45,
                  minChildSize: 0.40,
                  maxChildSize: 0.92,
                  expand: true,
                  snap: true,
                  snapSizes: const [0.45, 0.92],
                  builder: (context, scrollController) {
                    return Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(24),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.25),
                            blurRadius: 24,
                            offset: const Offset(0, -4),
                          ),
                        ],
                      ),
                      child: SingleChildScrollView(
                        controller: scrollController,
                        child: _buildFormularioInfo(),
                      ),
                    );
                  },
                ),

              // 📂 CATEGORÍAS (página 1)
              if (_paginaActual == 1)
                Container(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  child: _buidFormularioCategoria(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormularioInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // título o estado activo
            isactive ? _buildEstadoActivo() : _buildTituloFormulario(),

            const SizedBox(height: 20),

            // campos del formulario (se ocultan cuando está activo)
            if (!isactive) ...[
              CustomTextFormFieldTap(
                controller: _categoryController,
                label: 'Tipo de ayuda que necesitas',
                icon: Icons.category_outlined,
                readOnly: true,
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'Selecciona una categoría';
                  return null;
                },
                tap: () => setState(() => _paginaActual++),
              ),
              const SizedBox(height: 16),

              CustomTextFormField(
                controller: _nameController,
                label: 'Qué problema tienes',
                icon: Icons.report_problem_outlined,
                readOnly: false,
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'Por favor ingresa el problema';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              CustomDescriptionFormField(
                controller: _descriptionController,
                minLines: 2,
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'Por favor agrega una descripción';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: CustomTextFormFieldPrice(
                      controller: _priceController,
                      label: 'Precio a proponer',
                      validator: (value) {
                        if (value == null || value.isEmpty)
                          return 'Ingresa el precio';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  imageBox(0),
                ],
              ),
              const SizedBox(height: 20),

              // método de pago
              Text(
                'Método de pago',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.surface,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _paymentChip(
                      value: 'cash',
                      label: 'Efectivo',
                      icon: Icons.payments_outlined,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _paymentChip(
                      value: 'card',
                      label: 'Tarjeta',
                      icon: Icons.credit_card_outlined,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],

            // botón crear / cancelar
            _buildbottom()
                .animate()
                .fade(duration: 450.ms, delay: 60.ms)
                .slideX(begin: -0.2),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildTituloFormulario() {
    return Column(
      children: [
        Text(
          'Servicio Express',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.surface,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Llena la información y sube una imagen de referencia',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 12,
            height: 1.6,
            color: Theme.of(context).colorScheme.surface.withOpacity(0.45),
          ),
        ),
      ],
    );
  }

  Widget _buildEstadoActivo() {
    if (isaccept && express.express.isEmpty) {
      return const SizedBox(height: 120, child: Center(child: Indicador()));
    }
    return Column(
      children: [
        if (!isaccept) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Buscando técnico...',
                style: GoogleFonts.poppins(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.surface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'El radar está activo en el mapa. Espera a que alguien acepte.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 12,
              height: 1.5,
              color: Theme.of(context).colorScheme.surface.withOpacity(0.45),
            ),
          ),
        ],
        const SizedBox(height: 14),

        if (isaccept) ...[
          Barstatus(
            estadoTrabajo: express.express[0].job_status.isEmpty
                ? ''
                : express.express[0].job_status,
          ),
        ],

        SizedBox(height: 20),
        _buildTrabajo()
            .animate()
            .fade(duration: 450.ms, delay: 60.ms)
            .slideX(begin: -0.2),
        SizedBox(height: 20),
        if (isaccept) ...[
          _buildWorker()
              .animate()
              .fade(duration: 450.ms, delay: 60.ms)
              .slideX(begin: -0.2),
          const SizedBox(height: 16),
        ],
      ],
    );
  }

  Widget _buildMap() {
    final h = MediaQuery.of(context).size.height;
    return Stack(
      children: [
        SizedBox(
          height: h,
          child: GoogleMap(
            initialCameraPosition: CameraPosition(
              target: posicionActual,
              zoom: 16,
            ),
            scrollGesturesEnabled: !isSearch,
            zoomGesturesEnabled: !isSearch,
            rotateGesturesEnabled: !isactive,
            tiltGesturesEnabled: !isactive,
            onMapCreated: (controller) => _mapController = controller,
            gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
              Factory<OneSequenceGestureRecognizer>(
                () => EagerGestureRecognizer(),
              ),
            },
            onTap: (pos) {
              if (!isactive) {
                setState(() {
                  posicionActual = pos;
                  latitude = pos.latitude;
                  longitude = pos.longitude;
                });
                getcalle();
              }
            },
            markers: {
              Marker(
                markerId: const MarkerId("ubicacion"),
                position: posicionActual,
                icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueBlue,
                ),
              ),
              if (onlocation && isaccept) ...[
                Marker(
                  markerId: const MarkerId("Trabajador"),
                  position: posicionworker!,
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueOrange,
                  ),
                ),
              ],

              // Marker trabajador 2 (agregar si tienes posicionworker2)
            },
          ),
        ),

        // botón mi ubicación
        Positioned(
          top: MediaQuery.of(context).padding.top + 12,
          right: 12,
          child: GestureDetector(
            onTap: _GoMyLocation,
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Icon(
                Icons.my_location_rounded,
                color: colorsecundario,
                size: 20,
              ),
            ),
          ),
        ),

        // ✅ NUEVO — botón seguir trabajador 1
        Positioned(
          top: MediaQuery.of(context).padding.top + 60,
          right: 12,
          child: GestureDetector(
            onTap: () {
              setState(() {
                follow = true;
              });
              if (posicionworker != null) {
                _mapController?.animateCamera(
                  CameraUpdate.newLatLng(posicionworker!),
                );
              }
            },
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Icon(
                follow ? Icons.directions_run_rounded : Icons.location_disabled,
                color: colorsecundario,
                size: 20,
              ),
            ),
          ),
        ),

        // ✅ NUEVO — botón ver ubicación trabajador 2
        Positioned(
          top: MediaQuery.of(context).padding.top + 110,
          right: 12,
          child: GestureDetector(
            onTap: () {
              if (posicionworker != null) {
                _mapController?.animateCamera(
                  CameraUpdate.newLatLng(posicionworker!),
                );
              }
            },
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Icon(
                Icons.person_pin_circle_rounded,
                color: Colors.deepOrange,
                size: 20,
              ),
            ),
          ),
        ),

        // chip de dirección
        if (calle != null)
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: 12,
            right: 64,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.location_on_rounded,
                    color: colorsecundario,
                    size: 14,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '$calle, $ciudad',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: Colors.white70,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ).animate().fadeIn(delay: 300.ms).slideY(begin: -0.2),

        // 🔥 RADAR EN EL MAPA — solo cuando isactive
        if (isSearch) Positioned.fill(child: Center(child: Radar())),
      ],
    );
  }

  Widget _buidFormularioCategoria() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 80),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Categoría del servicio',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.surface,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Selecciona la categoría que mejor describa tu servicio',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 12,
                height: 1.6,
                color: Theme.of(context).colorScheme.surface.withOpacity(0.45),
              ),
            ),
            const SizedBox(height: 20),
            _buildCategoriaItem(),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoriaItem() {
    final isLoadingCats = category.categorias.isEmpty;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 1,
        mainAxisSpacing: 12,
        childAspectRatio: 4,
      ),
      itemCount: isLoadingCats ? 3 : category.categorias.length,
      itemBuilder: (context, index) {
        if (isLoadingCats) return const OptionsSkeleton();
        final categoria = category.categorias[index];
        return OptionsCategorias(
          nombre: categoria.name,
          img: categoria.image_url,
          id: categoria.category_id,
          selectedId: _categoriaSeleccionada,
          onSelected: (id) {
            setState(() {
              _categoriaSeleccionada = id;
              _categoryController.text = categoria.name;
              _paginaActual--;
            });
          },
        ).animate(delay: (index * 50).ms).fade().slideX(begin: -0.15);
      },
    );
  }

  Widget imageBox(int index) {
    return GestureDetector(
      onTap: () => _pickImage(index),
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface.withOpacity(0.05),
          border: Border.all(
            color: _image != null
                ? colorsecundario.withOpacity(0.5)
                : Theme.of(context).colorScheme.surface.withOpacity(0.12),
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: _image == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_photo_alternate_outlined,
                    size: 28,
                    color: Theme.of(
                      context,
                    ).colorScheme.surface.withOpacity(0.25),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Foto',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: Theme.of(
                        context,
                      ).colorScheme.surface.withOpacity(0.3),
                    ),
                  ),
                ],
              )
            : ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.file(
                  _image!,
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                ),
              ),
      ),
    );
  }

  Widget _paymentChip({
    required String value,
    required String label,
    required IconData icon,
  }) {
    final isSelected = _payment == value;
    return GestureDetector(
      onTap: () => setState(() => _payment = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? colorsecundario.withOpacity(0.08)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? colorsecundario
                : Theme.of(context).colorScheme.surface.withOpacity(0.12),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected
                  ? colorsecundario
                  : Theme.of(context).colorScheme.surface.withOpacity(0.4),
            ),
            const SizedBox(width: 7),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected
                    ? colorsecundario
                    : Theme.of(context).colorScheme.surface.withOpacity(0.55),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Trabajador',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.surface,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(context).colorScheme.surface.withOpacity(0.06),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Circleimage(
                w: 56,
                h: 56,
                image_url: '${express.express[0].worker_image}',
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            '${express.express[0].worker_username}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.surface,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(Icons.star_rounded, color: Colors.amber, size: 15),
                        const SizedBox(width: 3),
                        Text(
                          '${express.express[0].worker_rating}',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(
                              context,
                            ).colorScheme.surface.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${express.express[0].worker_description}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        height: 1.6,
                        color: Theme.of(
                          context,
                        ).colorScheme.surface.withOpacity(0.45),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTrabajo() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Problema a resolver',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.surface,
            letterSpacing: -0.2,
          ),
        ),
        SizedBox(height: 10),
        Text(
          '${_nameController.text == '' ? express.express[0].problem : _nameController.text}',
          style: GoogleFonts.poppins(
            fontSize: 13,
            height: 1.75,
            color: Theme.of(context).colorScheme.surface.withOpacity(0.55),
          ),
        ),

        SizedBox(height: 20),
        Text(
          'Descripción',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.surface,
            letterSpacing: -0.2,
          ),
        ),
        SizedBox(height: 10),
        Text(
          '${_descriptionController.text == '' ? express.express[0].description : _descriptionController.text}',
          style: GoogleFonts.poppins(
            fontSize: 13,
            height: 1.75,
            color: Theme.of(context).colorScheme.surface.withOpacity(0.55),
          ),
        ),
        SizedBox(height: 20),

        Text(
          'Pago y Metodo',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.surface,
            letterSpacing: -0.2,
          ),
        ),

        SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Precio',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Theme.of(
                        context,
                      ).colorScheme.surface.withOpacity(0.55),
                    ),
                  ),

                  SizedBox(height: 10),
                  Text(
                    '${isaccept ? express.express[0].price : _priceController.text}',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,

                      color: Theme.of(context).colorScheme.surface,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Container(
              width: 1,
              height: 40,
              color: Theme.of(context).colorScheme.surface.withOpacity(0.1),
            ),
            SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Metodo',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Theme.of(
                        context,
                      ).colorScheme.surface.withOpacity(0.55),
                    ),
                  ),

                  SizedBox(height: 10),
                  Text(
                    '${_payment}',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,

                      color: Theme.of(context).colorScheme.surface,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 20),
          ],
        ),
      ],
    );
  }

  Widget _buildbottom() {
    IconData icon = Icons.info;
    String text = '';
    VoidCallback? action;
    Color bgColor = colorsecundario;
    if (isactive) {
      final jobStatus = status.toLowerCase();
      switch (jobStatus) {
        case 'pending':
        case 'accepted':
        case 'going':
        case 'arrived':
        case 'in_progress':
          icon = Icons.cancel_outlined;
          bgColor = Colors.red;
          text = 'Cancelar solicitud';
          action = () {
            _Cancelar();
          };
          break;

        case 'finalized':
          icon = Icons.payment;
          text = 'Pagar';
          action = () {
            print('pagar');
          };
          break;
        case 'completed':
          icon = Icons.payment;
          text = 'ver registro de pago';
          action = () {
            print('pagar');
          };
          break;
        default:
          icon = Icons.help;
          text = jobStatus;
          action = null;
          bgColor = Theme.of(context).colorScheme.surface.withOpacity(0.6);
      }
    } else {
      icon = Icons.flash_on_rounded;
      text = 'Enviar solicitud';
      action = () {
        _Crear();
      };
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: action,
        icon: Icon(icon, color: colorWhite),
        label: Text(
          text,
          style: const TextStyle(fontSize: 18, color: colorWhite),
        ),
        style: ElevatedButton.styleFrom(
          fixedSize: const Size(300, 50),
          backgroundColor: bgColor,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}
