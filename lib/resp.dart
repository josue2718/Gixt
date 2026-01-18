import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gixt/Componets/Indicador.dart';
import 'package:gixt/Componets/cardsServicios.dart';
import 'package:gixt/Componets/colors.dart';
import 'package:gixt/Componets/sketor/cardsRestraurantes.dart';
import 'package:gixt/services/Auth/serviciosByCat_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';

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

  bool isLoading = false;
  bool hasMore = true;
  int pageNumber = 1;

  @override
  void initState() {
    super.initState();
    _loadInitialData();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        if (!isLoading && hasMore) {
          _loadMore();
        }
      }
    });
  }

  Future<void> _loadInitialData() async {
    setState(() {
      isLoading = true;
      pageNumber = 1;
      api.servicios.clear();
    });

    final more = await api.fetchServicioCatData(
      widget.id_categoria,
      pageNumber,
    );

    setState(() {
      isLoading = false;
      hasMore = more;
    });
  }

  Future<void> _loadMore() async {
    setState(() => isLoading = true);
    pageNumber++;

    final more = await api.fetchServicioCatData(
      widget.id_categoria,
      pageNumber,
    );

    setState(() {
      isLoading = false;
      hasMore = more;
    });
  }

  Future<void> _onRefresh() async {
    await _loadInitialData();
  }

  @override
  Widget build(BuildContext context) {
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
              const SliverToBoxAdapter(child: SizedBox(height: 20)),
              SliverToBoxAdapter(child: _buildTitle()),
              const SliverToBoxAdapter(child: SizedBox(height: 10)),
              _buildServicios(),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ),
      ),
    );
  }

  // ================= APP BAR =================
  SliverAppBar _buildSliverAppBar() {
    return SliverAppBar(
      backgroundColor: colorprimario,
      expandedHeight: 80,
      pinned: true,
      elevation: 0,
      toolbarHeight: 80,
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

  // ================= TITULO =================
  Widget _buildTitle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
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
          const Spacer(),
          Icon(
            Icons.arrow_forward_ios,
            size: 18,
            color: colortitulo,
          ),
        ],
      ),
    ).animate().fade().slideX(begin: -0.2);
  }

  // ================= SERVICIOS =================
  Widget _buildServicios() {
    // Skeleton inicial
    if (api.servicios.isEmpty && isLoading) {
      return SliverGrid(
        delegate: SliverChildBuilderDelegate(
          (context, index) => const CardsEmpresaSkeleton(),
          childCount: 3,
        ),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 1,
          mainAxisSpacing: 16,
          childAspectRatio: 1.2,
        ),
      );
    }

    return SliverGrid(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          if (index < api.servicios.length) {
            final servicio = api.servicios[index];

            return CardsServicios(
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
          }

          // Loader al final
          return const Padding(
            padding: EdgeInsets.all(20),
            child: Center(child: Indicador()),
          );
        },
        childCount: api.servicios.length + (hasMore ? 1 : 0),
      ),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 1,
        mainAxisSpacing: 16,
        childAspectRatio: 1.2,
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
