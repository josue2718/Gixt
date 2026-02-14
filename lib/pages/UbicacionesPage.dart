import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gixt/components/LocationsOptions.dart';
import 'package:gixt/components/alert.dart';
import 'package:gixt/components/colors.dart';
import 'package:gixt/components/sketor/LocationsOptions.dart';
import 'package:gixt/components/sketor/opciones.dart';
import 'package:gixt/pages/AddUbicacionPage.dart';
import 'package:gixt/services/ubicaciones/Ubicaciones_Service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';

class UbicacionesPage extends StatefulWidget {
  const UbicacionesPage({super.key});

  @override
  State<UbicacionesPage> createState() => _UbicacionesPageState();
}

class _UbicacionesPageState extends State<UbicacionesPage> {
  final ScrollController _scrollController = ScrollController();
  final UbicacionesService ubicaciones = UbicacionesService();
  bool isLoading = false;
  bool hasMore = true;
  bool timeout = false;
  
  Future<void> _onRefresh() async {
    setState(() {
      print('Actualizando datos...');
      _initial();
    });
  }

  void initState() {
    super.initState();
    print("Entré a Mis ubicaciones");
    _initial();
    
  }

  Future<void> _initial () async {
    setState(() {
      isLoading = true;
      timeout = false;
    });
    bool ok = await ubicaciones.fetchData();
    isLoading = true;
    if (!ok) {
      if (!mounted) return;
      Future.microtask(() async {
        await mostrarAlerta(
          context,
          title: "Error",
          message: "No se pudo obtener la información",
          type: alert_type.error,
        );

        Navigator.pop(context);
      });
    }
    _Validation();
  }

   Future<void> _Validation() async {
  print('empezando contador');
    Future.delayed(const Duration(seconds: 10), () {
      if (isLoading) {
        setState(() {
          timeout = true;
        });
        print('terminando contador');
      }
    });
    setState(() {
      if (ubicaciones.ubicacion.isNotEmpty) {
        isLoading = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardDismisser(
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: FutureBuilder(
          future: Future.wait([]),
          builder: (context, snapshot) {
            return KeyboardDismisser(
              child: Scaffold(
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                body: RefreshIndicator(
                  onRefresh: _onRefresh,
                  child: CustomScrollView(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      _buildSliverAppBar(),
                      const SliverToBoxAdapter(child: SizedBox(height: 50)),
                      SliverToBoxAdapter(child: _buildTitle()),
                      SliverToBoxAdapter(child: _buildUbicaciones()),
                      const SliverToBoxAdapter(child: SizedBox(height: 20)),
                      SliverToBoxAdapter(child: _buildAdd()),
                      const SliverToBoxAdapter(child: SizedBox(height: 100)),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  SliverAppBar _buildSliverAppBar() {
    return SliverAppBar(
      backgroundColor: colorprimario,
      expandedHeight: 80,
      pinned: true, //  deja solo la barra pequeña visible
      floating: false, //  NO aparece al subir
      snap: false, // NO animación automática
      elevation: 0,
      toolbarHeight: 80,
      iconTheme: const IconThemeData(color: Colors.white),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(0)),
      ),
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: Text(
          'Mis Ubicaciones',
          style: GoogleFonts.poppins(
            fontSize: 30,
            fontWeight: FontWeight.w600,
            color: colorsecundario,
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
      child: Container(
        alignment: Alignment.topLeft,
        child: Row(
          children: [
            Text(
              'Ubicaciones Disponibles',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.surface,
              ),
            ),
            Spacer(),
            InkWell(
              onTap: () {
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(builder: (context) => CategoriasPage()),
                // );
              },
              child: Icon(
                Icons.location_on,
                size: 20,
                color: colortitulo,
              ),
            ),
          ],
        ),
      ).animate().fade().slideX(begin: -0.2),
    );
  }

  Widget _buildUbicaciones() {
    final isLoading = ubicaciones.ubicacion.isEmpty;
    if (timeout) {
      return const ListTile(
        title: Text(
          "No tienes ubicaciones registradas",
          style: TextStyle(color: colorWhite),
        ),
        leading: Icon(Icons.location_off),
      );
    }
    return Padding(
      padding: const EdgeInsets.all(15),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 1,
          mainAxisSpacing: 16,
          childAspectRatio: 4,
        ),
        itemCount: isLoading ? 5 : ubicaciones.ubicacion.length,
        itemBuilder: (context, index) {
          if (isLoading && !timeout) {
            return const LocationsOptionsSkeleton();
          }

          final ubicacion = ubicaciones.ubicacion[index];
          return LocationsOptions(
            street: ubicacion.street,
            neighborhood: ubicacion.neighborhood,
            state: ubicacion.state,
            city: ubicacion.city,
            references: ubicacion.maps_address,
            id: ubicacion.location_id,
          );
        },
      ),
    ).animate().fade().slideX(begin: -0.2);
  }

  Widget _buildAdd() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddUbicacionPage()),
              );
            },
            style: ElevatedButton.styleFrom(
              fixedSize: const Size(300, 50),
              backgroundColor: colorsecundario,
              foregroundColor: colorprimario,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Añadir', style: TextStyle(fontSize: 18, color: colorWhite)),
          ),
        ],
      ),
    );
  }
}
