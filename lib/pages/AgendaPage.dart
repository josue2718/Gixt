import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gixt/components/alert.dart';
import 'package:gixt/components/cards/cardsAgenda.dart';
import 'package:gixt/components/colors.dart';
import 'package:gixt/components/sketor/cardsCategoria.dart';
import 'package:gixt/services/Agenda/Agenda_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';

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

    bool ok = await api.fetchAgendaData();
    print(ok);
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

    setState(() => isLoading = false);
  }

  
  Future<void> _onRefresh() async {
     await api.updatedata();
     setState(() {
       
     });
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
                      SliverToBoxAdapter(child: _buildServicios("in_progress")),
                      SliverToBoxAdapter(child: _buildTitle()),
                      SliverToBoxAdapter(child: _buildServicios("pending")),
                      SliverToBoxAdapter(child: _buildTitle2()),
                      SliverToBoxAdapter(child: _buildServicios("completed")),
                      SliverToBoxAdapter(child: _buildTitle3()),
                      SliverToBoxAdapter(child: _buildServicios("canceled")),
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
      automaticallyImplyLeading: false,
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

  Widget _buildTitle3() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
      child: Container(
        alignment: Alignment.topLeft,
        child: Row(
          children: [
            Text(
              'Trabajos Cancelado',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color:  Theme.of(context).colorScheme.surface,
              ),
            ),
            Spacer(),
            InkWell(
              onTap: () {

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
      api.agenda.where((a) => a.job_status == tipo).toList();

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
        image_url: agenda.service_image,
        name: agenda.service_name,
        worker_image: agenda.worker_image,
        job_id: agenda.job_id,
        worker: agenda.worker_first_name,
        date: agenda.job_date,
        time: agenda.job_time,
        price: agenda.price,
        description: agenda.service_description,
        address: agenda.maps_address,
        status: agenda.job_status,
      )
          .animate()
          .fade(duration: 400.ms)
          .slideY(begin: 0.15)
          .scale(begin: const Offset(0.96, 0.96));
    },
  );
}
}
