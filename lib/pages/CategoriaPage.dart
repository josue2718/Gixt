import 'dart:math';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gixt/components/Indicador.dart';
import 'package:gixt/components/alert.dart';
import 'package:gixt/components/cards/cardsCategoria.dart';
import 'package:gixt/components/colors.dart';
import 'package:gixt/components/sketor/cardsCategoria.dart';
import 'package:gixt/services/Anuncios_service.dart';
import 'package:gixt/services/Auth/categorias_service.dart';
import 'package:gixt/services/servicios/serviciosByCat_service.dart';
import 'package:gixt/services/servicios/servicios_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

class CategoriaPage extends StatefulWidget {
  final int id_categoria;
  final String nombre;
  const CategoriaPage({
    super.key,
    required this.id_categoria,
    required this.nombre,
  });

  @override
  State<CategoriaPage> createState() => _CategoriaPageState();
}

class _CategoriaPageState extends State<CategoriaPage> {
  final ServiciosByCat_service api = ServiciosByCat_service();
  final ScrollController _scrollController = ScrollController();
  final ValueNotifier<int> _currentIndexNotifier = ValueNotifier<int>(0);
  bool isLoading = false;
  bool hasMore = true;
  int pageNumber = 1;
  String? img;
  String? username;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 150) {
        _loadMore();
      }
    });
  }

  Future<void> _loadInitialData() async {
    setState(() {
      isLoading = true;
      pageNumber = 1;
      hasMore = true;
      api.servicios.clear();
    });

    bool ok = await api.fetchServicioCatData(
      widget.id_categoria,
      pageNumber,
    );

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

    setState(() => isLoading = false);
  }

  Future<void> _loadMore() async {
    if (isLoading || !hasMore) return;

       setState(() => isLoading = false);
    pageNumber++;

   bool ok = await api.fetchServicioCatData(
      widget.id_categoria,
      pageNumber,
    );

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
    setState(() => isLoading = false);
  }

  Future<void> _onRefresh() async {
    setState(() {
    
      hasMore = true;
      pageNumber = 1;
      api.servicios.clear();
      isLoading = true;
    });

    print('Actualizando datos...');
    bool ok = await api.fetchServicioCatData(
      widget.id_categoria,
      pageNumber,
    );

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
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardDismisser(
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: FutureBuilder(
          future: Future.wait([
            
          ]),
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
                      const SliverToBoxAdapter(child: SizedBox(height: 20)),
                      SliverToBoxAdapter(child: _buildTitle()),
                      SliverToBoxAdapter(child: _buildServicios()),
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
      iconTheme: const IconThemeData(
        color: Colors.white, // 👈 color del ícono
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(0)),
      ),
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: Text(
          widget.nombre,
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
              'Servicios Disponibles',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color:  Theme.of(context).colorScheme.surface,
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
                color:  Theme.of(context).colorScheme.surface,
              ),
            ),
          ],
        ),
      ).animate().fade().slideX(begin: -0.2),
    );
  }

  Widget _buildServicios() {
    final isLoading1 = api.servicios.isEmpty;
    return GridView.builder(
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 20),
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 1,
        mainAxisSpacing: 20,
        childAspectRatio: 2.3,
      ),
      itemCount: isLoading
          ? 3 //  skeletons visibles
          : api.servicios.length + (hasMore ? 1 : 0), // 👈 loader extra
      itemBuilder: (context, index) {
        if (isLoading) {
          return const CardsCategoriaSkeleton();
        }
        if (index >= api.servicios.length && !isLoading) {
          return Indicador();
        }
        try {
          final servicio = api.servicios[index];

          return CardsServiciosCategoria(
                url_img: servicio.img_servicio,
                nombre: servicio.nombre_servicio,
                img_trabajador: servicio.img_trabajador,
                id_servicio: servicio.id_servicio,
                trabajador: servicio.trabajador,
                categoria: servicio.categoria,
                estrellas: servicio.calificacion,
                precio: servicio.precio,
                descripcion: servicio.descripcion,
              )
              .animate()
              .fade(duration: 400.ms)
              .slideY(begin: 0.15)
              .scale(begin: const Offset(0.96, 0.96));
        } catch (e) {
          return const SizedBox(); // widget vacío
        }
      },
    );
  }
}
