import 'dart:math';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gixt/Componets/Indicador.dart';
import 'package:gixt/Componets/cardoferta.dart';
import 'package:gixt/Componets/cardsCategoria.dart';
import 'package:gixt/Componets/cardsServicios.dart';
import 'package:gixt/Componets/circleimage.dart';
import 'package:gixt/Componets/colors.dart';
import 'package:gixt/Componets/opciones.dart';
import 'package:gixt/Componets/sketor/cardsCategoria.dart';
import 'package:gixt/Componets/sketor/cardsRestraurantes.dart';
import 'package:gixt/Componets/sketor/opciones.dart';
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
  final ApiServiciosByCat api = ApiServiciosByCat();
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

    final data = await api.fetchServicioCatData(
      widget.id_categoria,
      pageNumber,
    );

    setState(() => isLoading = false);
  }

  Future<void> _loadMore() async {
    if (isLoading || !hasMore) return;

       setState(() => isLoading = false);
    pageNumber++;

    final data = await api.fetchServicioCatData(
      widget.id_categoria,
      pageNumber,
    );
    setState(() => isLoading = false);
  }

  Future<void> _onRefresh() async {
    setState(() {
      print('Actualizando datos...');
      hasMore = true;
      pageNumber = 1;
      api.servicios.clear();
      isLoading = true;
      
    
    });
    await api.fetchServicioCatData( widget.id_categoria,pageNumber);
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardDismisser(
      child: Scaffold(
        backgroundColor: colorfondo,
        body: FutureBuilder(
          future: Future.wait([
            
          ]),
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
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: Text(
          widget.nombre,
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
              'Servicios Disponibles',
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

  Widget _buildServicios() {
    final isLoading1 = api.servicios.isEmpty;
    return GridView.builder(
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 1,
        mainAxisSpacing: 16,
        childAspectRatio: 2.0,
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
