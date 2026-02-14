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
import 'package:gixt/services/servicios/categorias_service.dart';
import 'package:gixt/services/servicios/serviciosByCat_service.dart';
import 'package:gixt/services/servicios/servicios_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

class CategoriaPage extends StatefulWidget {
  final int category_id;
  final String name;
  const CategoriaPage({
    super.key,
    required this.category_id,
    required this.name,
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
  bool timeout = false;
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
      timeout = false;
      pageNumber = 1;
      api.servicios.clear();
    });

    bool ok = await api.fetchServicioCatData(widget.category_id, pageNumber);

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

  Future<void> _loadMore() async {
    if (isLoading || !hasMore) return;
    isLoading = true;
    pageNumber++;
    bool ok = await api.fetchServicioCatData(widget.category_id, pageNumber);
    setState(() => isLoading = false);
  }

  Future<void> _onRefresh() async {

    setState(() {
      isLoading = true;
      timeout = false;
      pageNumber = 1;
      api.servicios.clear();
    });

    bool ok = await api.fetchServicioCatData(widget.category_id, pageNumber);

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
      if (api.servicios.isNotEmpty) {
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
          widget.name,
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
                Icons.arrow_forward_ios,
                size: 20,
                color: Theme.of(context).colorScheme.surface,
              ),
            ),
          ],
        ),
      ).animate().fade().slideX(begin: -0.2),
    );
  }

  Widget _buildServicios() {
    final isLoading1 = api.servicios.isEmpty;
    if (timeout) {
      return const ListTile(
        title: Text(
          "No tienes servicios sercanos",
          style: TextStyle(color: colorWhite),
        ),
        leading: Icon(Icons.location_off),
      );
    }
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
                image_url: servicio.image,
                name: servicio.service_name,
                worker_image: servicio.userImage,
                service_id: servicio.service_id,
                worker: servicio.first_name,
                category: servicio.category,
                stars: servicio.rating,
                price: servicio.price,
                description: servicio.description,
              );
               
        } catch (e) {
          return const SizedBox(); // widget vacío
        }
      },
    );
  }
}
