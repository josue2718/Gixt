import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gixt/Componets/alert.dart';
import 'package:gixt/Componets/colors.dart';
import 'package:gixt/Componets/sketor/opciones.dart';
import 'package:gixt/Componets/ubicacionesoption.dart';
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
  bool timeoutUbicaciones = false;
  Future<void> _onRefresh() async {
    
    setState(() {
      timeoutUbicaciones = false;
    });
    setState(() => isLoading = false);
    setState(() {
      print('Actualizando datos...');
      _initial();
    });
  }

  void initState() {
    super.initState();
    print("Entré a Mis ubicaciones");
    _initial();
    Future.delayed(const Duration(seconds: 10), () {
      if (isLoading) {
        setState(() {
          timeoutUbicaciones = true;
        });
        print('empezando contadorf');
      }
    });
  }

  Future<void> _initial() async {
    bool ok = await ubicaciones.fetchData();
    isLoading = true;
    if (!ok) {
      if (!mounted) return;
      Future.microtask(() async {
        await mostrarAlerta(
          context,
          titulo: "Error",
          mensaje: "No se pudo obtener la información",
          tipo: TipoAlerta.error,
        );

        Navigator.pop(context);
      });
    }
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
        backgroundColor: colorfondo,
        body: FutureBuilder(
          future: Future.wait([]),
          builder: (context, snapshot) {
            return KeyboardDismisser(
              child: Scaffold(
                backgroundColor: colorfondo,
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
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: Text(
          'Mis Ubicaciones',
          style: GoogleFonts.poppins(
            fontSize: 20,
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
                color: colortitulo,
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
                Icons.arrow_forward_ios,
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
    if (timeoutUbicaciones) {
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
          if (isLoading && !timeoutUbicaciones) {
            return const OptionsSkeleton();
          }

          final ubicacion = ubicaciones.ubicacion[index];
          return UbicacionesOpciones(
            calle: ubicacion.calle,
            colonia: ubicacion.colonia,
            estado: ubicacion.estado,
            ciudad: ubicacion.ciudad,
            descripcion: ubicacion.direccionMaps,
            id: ubicacion.id_ubicacion,
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
              backgroundColor: colorWhite,
              foregroundColor: colorprimario,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Añadir', style: TextStyle(fontSize: 18)),
          ),
        ],
      ),
    );
  }
}
