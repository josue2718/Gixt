import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gixt/cache.dart';
import 'package:gixt/components/Indicador.dart';
import 'package:gixt/components/alert.dart';
import 'package:gixt/components/colors.dart';
import 'package:gixt/components/inputs/Input_Description.dart';
import 'package:gixt/components/inputs/Input_Time.dart';
import 'package:gixt/components/inputs/UbicacionesInput.dart';
import 'package:gixt/components/inputs/calendar_dialog.dart';
import 'package:gixt/components/inputs/input.dart';
import 'package:gixt/components/inputs/pick_image.dart';
import 'package:gixt/components/inputs/time_picker_helper.dart';
import 'package:gixt/components/sketor/opciones.dart';
import 'package:gixt/roots/root.dart';
import 'package:gixt/services/reservas/Add_servicio_service.dart';
import 'package:gixt/services/ubicaciones/Ubicaciones_Service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:table_calendar/table_calendar.dart';

class ReservaPage extends StatefulWidget {
  const ReservaPage({
    super.key,
    required this.service_id,
    required this.name,
    required this.description,
  });

  final String service_id;
  final String name;
  final String description;
  @override
  State<ReservaPage> createState() => _ReservaPageState();
}

class _ReservaPageState extends State<ReservaPage> {
  final _formKey = GlobalKey<FormState>();
  final _formKeyinfo = GlobalKey<FormState>();
  final _formKeyImg = GlobalKey<FormState>();
  final _problemController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _timeController = TextEditingController();
  final _phoneController = TextEditingController();
  final _dateController = TextEditingController();

  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  bool _isObscured = true;
  bool _isObscured1 = true;
  final PageController _controller = PageController();
  final PreferencesService _preferencesService = PreferencesService();
  final UbicacionesService ubicaciones = UbicacionesService();
  String? _ubicacionSeleccionada;

  int _paginaActual = 0;
  List<File?> _images = List.generate(2, (_) => null);
  String? _payment;
  String? _token;
  String? _inicio;
  String? _id;
  String? _img;
  String? _user;
  String? ubicaciontext;
  bool terms = false;

  void _Crear() async {
    if (_payment == null) {
      mostrarAlerta(
        context,
        title: 'Se requieren un metodo de pago',
        message: 'Selecciona un metodo de pago',
        type: alert_type.advertencia,
      );
      return;
    }
    if (!terms!) {
      mostrarAlerta(
        context,
        title: 'Se requieren aceptar',
        message: 'Acepta los terminos y condiciones',
        type: alert_type.advertencia,
      );
      return;
    }
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Indicador(),
    );

    final result = await AddServicioService.Crear(
      service_id: widget.service_id,
      location_id: _ubicacionSeleccionada.toString(),
      job_date: _dateController.text,
      job_time: _timeController.text,
      problem: _problemController.text,
      description: _descriptionController.text,
      image_1: _images[0]!,
      image_2: _images[1]!,
      payment_method: _payment!,
      terms: terms!,
    );


    Navigator.pop(context);

    if (result['success'] == true) {
      Future.microtask(() async {
        await mostrarAlerta(
          context,
          title: "Creado Correctamente",
          message: 'Espera que el trabajador confime para segir con el proceso',
          type: alert_type.exito,
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => RootPage()),
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

  Future<void> _pickImage(int index) async {
    final File? image = await pickAndCropImage(context);

    if (image != null) {
      setState(() {
        _images[index] = image;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
    ubicaciones.fetchData();
  }

  Future<void> _onRefresh() async {
    setState(() {
      print('Actualizando datos...');
      ubicaciones.fetchData();
    });
  }

  void initState() {
    super.initState();
    // 👇 SE EJECUTA AL ENTRR A LA PÁGINA
    print("Entré a Restaurantes");
    ubicaciones.fetchData();
  }

  bool salir() {
    if (_paginaActual != 0) {
      setState(() {
        _paginaActual--; // vuelve al formulario
      });
      return false;
    } else {
      Navigator.pop(context);
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return salir();
      },
      child: KeyboardDismisser(
        child: Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: RefreshIndicator(
            onRefresh: _onRefresh,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                _buildSliverAppBar(),
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      if (_paginaActual == 0) _buildFormularioInfo(),
                      if (_paginaActual == 1) _buildFormularioUbicacion(),
                      if (_paginaActual == 2) _buildConfirmacion(),

                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(3, (i) => _dot(i)),
                      ),
                      const SizedBox(height: 150),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  SliverAppBar _buildSliverAppBar() {
    return SliverAppBar(
      backgroundColor: colorprimario,
      expandedHeight: 90,
      pinned: true, //  deja solo la barra pequeña visible
      floating: false, //  NO aparece al subir
      snap: false, // NO animación automática
      elevation: 0,
      toolbarHeight: 90,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(0)),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        color: Colors.white,
        onPressed: () {
          salir();
        },
      ),
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: Text(
          'Mi reserva',
          style: GoogleFonts.poppins(
            fontSize: 30,
            fontWeight: FontWeight.w600,
            color: colorsecundario,
          ),
        ),
      ),
    );
  }

  Widget _dot(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: _paginaActual == index ? 12 : 8,
      height: _paginaActual == index ? 12 : 8,
      decoration: BoxDecoration(
        color: _paginaActual == index
            ? colorsecundario
            : Theme.of(context).colorScheme.surface.withOpacity(0.4),
        shape: BoxShape.circle,
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
    VoidCallback? onIconTap,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: colorWhite),
      focusedBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: colorWhite),
      ),
      suffixIcon: onIconTap == null
          ? Icon(icon, color: colorWhite)
          : IconButton(
              icon: Icon(icon, color: colorWhite),
              onPressed: onIconTap,
            ),
    );
  }

  Widget _buildFormularioInfo() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Informacion del servicio',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.surface,
              ),
            ),

            const SizedBox(height: 30),

            /// PROBLEMA
            CustomTextFormField(
              controller: _problemController,
              label: '¿Qué problema tienes?',
              icon: Icons.person,
              readOnly: false,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingrese el problema';
                }
                return null;
              },
            ),

            const SizedBox(height: 40),

            /// DESCRIPCIÓN (multiline, se deja normal)
            CustomDescriptionFormField(
              controller: _descriptionController,
              minLines: 4,
              maxLines: 6,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor descripcion';
                }
                return null;
              },
            ),

            const SizedBox(height: 20),

            /// FECHA
            CustomTextFormFieldTime(
              controller: _dateController,
              label: 'Fecha de reserva',
              icon: Icons.calendar_month,
              readOnly: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor seleccione una fecha';
                }
                return null;
              },
              onTap: () {
                showCalendarDialog(
                  context: context,
                  controller: _dateController,
                  focusedDay: DateTime.now(),
                  onDateSelected: (date) {
                    setState(() {
                      _selectedDay = date;
                    });
                  },
                );
              },
            ),

            const SizedBox(height: 20),

            /// HORA
            CustomTextFormFieldTime(
              controller: _timeController,
              label: 'Hora de reserva',
              icon: Icons.access_time,
              readOnly: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor seleccione una hora';
                }
                return null;
              },
              onTap: () {
                selectTime(context: context, controller: _timeController);
              },
            ),

            const SizedBox(height: 30),

            Text(
              'Archivos adjuntos',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.surface,
              ),
            ),

            const SizedBox(height: 20),
            _buildFormularioImg(),
            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {
                if (!(_formKey.currentState?.validate() ?? false)) return;
                print(_images.length);
                final imagenesValidas = _images
                    .where((img) => img != null)
                    .toList();

                if (imagenesValidas.length != 2) {
                  mostrarAlerta(
                    context,
                    title: 'Se requieren 2 imágenes',
                    message: 'Debes subir exactamente 2 imágenes de evidencia',
                    type: alert_type.advertencia,
                  );
                  return;
                }

                setState(() {
                  _paginaActual++;
                });
              },
              style: ElevatedButton.styleFrom(
                fixedSize: const Size(300, 50),
                backgroundColor: colorsecundario,
                foregroundColor: colorWhite,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Siguiente', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormularioUbicacion() {
    final screenHeight = MediaQuery.of(context).size.height;
    return Padding(
      padding: const EdgeInsets.all(15),
      child: Form(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Ubicacion del servicio Express',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.surface,
                  ),
                ),
                SizedBox(height: 10),
                _buildUbicacionItem(),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_ubicacionSeleccionada == null) {
                  mostrarAlerta(
                    context,
                    title: 'Se requieren una ubicacion',
                    message: 'Selecciona una ubicacion',
                    type: alert_type.advertencia,
                  );
                  return;
                }
                setState(() {
                  _paginaActual++;
                });
              },
              style: ElevatedButton.styleFrom(
                fixedSize: const Size(300, 50),
                backgroundColor: colorsecundario,
                foregroundColor: colorWhite,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Siguiente', style: TextStyle(fontSize: 18)),
            ),

            const SizedBox(height: 20),
            TextButton(
              onPressed: () {
                salir();
              },
              style: TextButton.styleFrom(foregroundColor: colorWhite),
              child: const Text('Regresar'),
            ),
            SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _buildUbicacionItem() {
    final isLoading = ubicaciones.ubicacion.isEmpty;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 1,
        mainAxisSpacing: 16,
        childAspectRatio: 4,
      ),
      itemCount: isLoading ? 6 : ubicaciones.ubicacion.length,
      itemBuilder: (context, index) {
        if (isLoading) {
          return const OptionsSkeleton();
        }
        final ubicacion = ubicaciones.ubicacion[index];
        return UbicacionesInput(
          calle: ubicacion.street,
          colonia: ubicacion.neighborhood,
          estado: ubicacion.state,
          ciudad: ubicacion.city,
          descripcion: ubicacion.maps_address,
          id: ubicacion.location_id,
          selectedId: _ubicacionSeleccionada,
          onSelected: (id) {
            setState(() {
              _ubicacionSeleccionada = id;
              ubicaciontext = ubicacion.maps_address;
            });
          },
        );

      },
    ).animate().fade().slideX(begin: -0.2);
  }

  Widget _buildFormularioImg() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            imageBox(0),
            const SizedBox(width: 30),
            imageBox(1),
            const SizedBox(width: 30),
          ],
        ),
      ),
    );
  }

  Widget imageBox(int index) {
    return SizedBox(
      width: 150,
      height: 150,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          _images[index] == null
              ? Container(
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 177, 177, 177),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 65,
                  ),
                )
              : ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.file(
                    _images[index]!,
                    width: 130,
                    height: 130,
                    fit: BoxFit.cover,
                  ),
                ),

          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: colorsecundario,
                borderRadius: BorderRadius.circular(20),
              ),
              child: IconButton(
                onPressed: () => _pickImage(index),
                icon: const Icon(Icons.add_a_photo_outlined),
                color: colorWhite,
                iconSize: 25,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget imageBox1(int index) {
    return SizedBox(
      width: 150,
      height: 150,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          _images[index] == null
              ? Container(
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 177, 177, 177),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 65,
                  ),
                )
              : ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.file(
                    _images[index]!,
                    width: 130,
                    height: 130,
                    fit: BoxFit.cover,
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildConfirmacion() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                '¡Informacion de la reserva!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.surface,
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20),
                  _buildServicio(),
                  SizedBox(height: 20),
                  _buildTrabajo(),
                  SizedBox(height: 20),
                  _buildUbicacion(),
                  SizedBox(height: 20),
                  _buildImg(),
                  SizedBox(height: 20),
                  _buildPrecio(),
                  SizedBox(height: 20),
                  _buildterms(),
                  SizedBox(height: 20),
                ],
              ),

              SizedBox(height: 10),
            ],
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              _Crear();
            },
            style: ElevatedButton.styleFrom(
              fixedSize: const Size(300, 50),
              backgroundColor: colorsecundario,
              foregroundColor: colorWhite,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Crear', style: TextStyle(fontSize: 18)),
          ),
        ],
      ),
    );
  }

  Widget _buildImg() {
    return Column(
      children: [
        Row(
          children: [
            SizedBox(height: 20),
            Text(
              'Imagenes',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.surface,
              ),
            ),
            Spacer(),
            Icon(
              Icons.photo,
              size: 25,
              color: Theme.of(context).colorScheme.surface,
            ),
          ],
        ),
        SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
            children: [
              imageBox1(0),
              const SizedBox(width: 10),
              imageBox1(1),
              const SizedBox(width: 10),
            ],
          ),
          )
        ),
      ],
    );
  }

  Widget _buildServicio() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Servicio',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.surface,
              ),
            ),
            Spacer(),
            Icon(
              Icons.home_repair_service,
              size: 25,
              color: Theme.of(context).colorScheme.surface,
            ),
          ],
        ),
        SizedBox(height: 30),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                '${widget.name}',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.surface,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '${widget.description}',
                style: TextStyle(
                  fontSize: 15,
                  color: Theme.of(context).colorScheme.surface.withOpacity(0.8),
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
        Row(
          children: [
            Text(
              'Trabajo',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.surface,
              ),
            ),
            Spacer(),
            Icon(
              Icons.home_repair_service,
              size: 25,
              color: Theme.of(context).colorScheme.surface,
            ),
          ],
        ),
        SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Descripcion ',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.surface,
                ),
              ),

              Text(
                '${_descriptionController.text}',
                style: TextStyle(
                  fontSize: 15,
                  color: Theme.of(context).colorScheme.surface,
                ),
              ),
              SizedBox(height: 20),

              Text(
                'Fecha del servicio',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.surface,
                ),
              ),

              SizedBox(height: 20),
              Row(
                children: [
                  Icon(
                    Icons.event,
                    color: Theme.of(context).colorScheme.surface,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${_dateController.text}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.surface,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.access_time,
                    color: Theme.of(context).colorScheme.surface,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${_timeController.text}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.surface,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUbicacion() {
    return Column(
      children: [
        Row(
          children: [
            SizedBox(height: 20),
            Text(
              'Ubicacion',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.surface,
              ),
            ),
            Spacer(),
            Icon(
              Icons.location_on,
              size: 25,
              color: Theme.of(context).colorScheme.surface,
            ),
          ],
        ),
        SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${ubicaciontext}',
                style: TextStyle(
                  fontSize: 15,
                  color: Theme.of(context).colorScheme.surface,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPrecio() {
    return Column(
      children: [
        Row(
          children: [
            SizedBox(height: 20),
            Text(
              'Pago y Metodo',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.surface,
              ),
            ),
            Spacer(),
            Icon(
              Icons.payment,
              size: 25,
              color: Theme.of(context).colorScheme.surface,
            ),
          ],
        ),
        SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Text(
                      'Precio',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.surface,
                      ),
                    ),
                    Spacer(),
                    Icon(
                      Icons.credit_card,
                      size: 25,
                      color: Theme.of(context).colorScheme.surface,
                    ),
                  ],
                ),

                SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: colorsecundario,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    'Pendiente',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: colorWhite,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  children: [
                    Text(
                      'Tipó de pago',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.surface,
                      ),
                    ),
                    Spacer(),
                    Icon(
                      Icons.credit_card,
                      size: 25,
                      color: Theme.of(context).colorScheme.surface,
                    ),
                  ],
                ),

                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<String>(
                        value: 'cash',
                        groupValue: _payment,
                        fillColor: MaterialStateProperty.resolveWith<Color>((
                          states,
                        ) {
                          if (states.contains(MaterialState.selected)) {
                            return colorsecundario;
                          }
                          return Theme.of(context).colorScheme.surface;
                        }),
                        title: Text(
                          'Efectivo',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.surface,
                          ),
                        ),
                        onChanged: (value) {
                          setState(() => _payment = value);
                        },
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<String>(
                        value: 'card',
                        groupValue: _payment,
                        fillColor: MaterialStateProperty.resolveWith<Color>((
                          states,
                        ) {
                          if (states.contains(MaterialState.selected)) {
                            return colorsecundario;
                          }
                          return Theme.of(context).colorScheme.surface;
                        }),
                        title: Text(
                          'Tarjeta',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.surface,
                          ),
                        ),
                        onChanged: (value) {
                          setState(() => _payment = value);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildterms() {
    return Column(
      children: [
        Row(
          children: [
            SizedBox(height: 20),
            Text(
              'Terminos y condiciones',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.surface,
              ),
            ),
            Spacer(),
            Icon(
              Icons.description,
              size: 25,
              color: Theme.of(context).colorScheme.surface,
            ),
          ],
        ),
        SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<bool>(
                        value: true,
                        fillColor: MaterialStateProperty.resolveWith<Color>((
                          states,
                        ) {
                          if (states.contains(MaterialState.selected)) {
                            return colorsecundario;
                          }
                          return Theme.of(context).colorScheme.surface;
                        }),
                        groupValue: terms,
                        activeColor: Theme.of(context).colorScheme.surface,
                        title: Text(
                          'Acepto los terminos y condiciones',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.surface,
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            terms = value!;
                          });
                        },
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(
                        foregroundColor: Theme.of(context).colorScheme.surface,
                      ),
                      child: const Text('Leer'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
