import 'dart:math';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gixt/components/alert.dart';
import 'package:gixt/components/cards/cardsAgenda.dart';
import 'package:gixt/components/colors.dart';
import 'package:gixt/components/sketor/cardsCategoria.dart';
import 'package:gixt/services/Agenda/Agenda_service.dart';
import 'package:gixt/services/Anuncios_service.dart';
import 'package:gixt/services/Auth/categorias_service.dart';
import 'package:gixt/services/servicios/serviciosByCat_service.dart';
import 'package:gixt/services/servicios/servicios_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

class AgendaPage extends StatefulWidget {

  const AgendaPage({
    super.key,
 
  });

  @override
  State<AgendaPage> createState() => _AgendaPageState();
}

class _AgendaPageState extends State<AgendaPage> {
  final Agenda_service api = Agenda_service();
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

  }

  Future<void> _loadInitialData() async {
    setState(() {
      isLoading = true;
      hasMore = true;
      api.agenda.clear();
    });

    bool ok = await api.fetchData(
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
      api.agenda.clear();
      isLoading = true;
    });

    print('Actualizando datos...');
    bool ok = await api.updatedata();

    if (!ok) {
      if (!mounted) return;
      Future.microtask(() async {
      await mostrarAlerta(
        context,
        titulo: "Error",
        mensaje: "No se pudo obtener la información",
        tipo: TipoAlerta.error,
      );
      
      ;
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
                      SliverToBoxAdapter(child: _buildTitle1()),
                      SliverToBoxAdapter(child: _buildServicios("en_proceso")),
                      SliverToBoxAdapter(child: _buildTitle()),
                      SliverToBoxAdapter(child: _buildServicios("pendiente")),
                      SliverToBoxAdapter(child: _buildTitle2()),
                      SliverToBoxAdapter(child: _buildServicios("aceptado")),
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
          'Agenda',
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
              'Trabajos Pendientes',
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

  Widget _buildTitle1() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
      child: Container(
        alignment: Alignment.topLeft,
        child: Row(
          children: [
            Text(
              'Trabajos En proceso',
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
                color:  Theme.of(context).colorScheme.surface,
              ),
            ),
          ],
        ),
      ).animate().fade().slideX(begin: -0.2),
    );
  }

  Widget _buildTitle2() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
      child: Container(
        alignment: Alignment.topLeft,
        child: Row(
          children: [
            Text(
              'Trabajos Finalizados',
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

 Widget _buildServicios(String tipo) {
  // Filtrar por estado
  final List<Agenda> filtrados =
      api.agenda.where((a) => a.estado == tipo).toList();

  final bool isLoading1 = filtrados.isEmpty;

  return GridView.builder(
    scrollDirection: Axis.vertical,
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 20),
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 1,
          mainAxisSpacing: 20,
          childAspectRatio: 2.5,
    ),
    itemCount: isLoading
        ? 3
        : filtrados.length,
    itemBuilder: (context, index) {
      if (isLoading) {
        return const CardsCategoriaSkeleton();
      }

      final agenda = filtrados[index];

      return CardsAgenda(
        url_img: agenda.imgServicio,
        nombre: agenda.nombreServicio,
        img_trabajador: agenda.imgTrabajador,
        id_servicio: agenda.idServicio,
        trabajador: agenda.trabajador,
        fecha: agenda.fechaTrabajo,
        hora: agenda.horaTrabajo,
        precio: agenda.precio,
        descripcion: agenda.descripcionServicio,
        direccion: agenda.direccion,
        status: agenda.estado,
      )
          .animate()
          .fade(duration: 400.ms)
          .slideY(begin: 0.15)
          .scale(begin: const Offset(0.96, 0.96));
    },
  );
}
}
