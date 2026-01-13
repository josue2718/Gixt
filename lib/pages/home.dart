import 'dart:math';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  bool hasMore = true;
  final ApiServicios api = ApiServicios();
  final ApiCategorias apicategoria = ApiCategorias();
  final ScrollController _scrollController = ScrollController();
  int pageNumber = 1;
  String? img;
  String? username;

  void initState() {
    super.initState();

    // 👇 SE EJECUTA AL ENTRAR A LA PÁGINA
    print("Entré a Restaurantes");
    api.fetchEmpresaData(pageNumber);
    apicategoria.fetchEmpresaData(pageNumber);
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      img = prefs.getString('url_img');
      username = prefs.getString('username');
    });
  }

  Future<void> _onRefresh() async {
    setState(() {
      print('Actualizando datos...');

      api.updatedata(pageNumber);
      hasMore = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardDismisser(
      child: Scaffold(
        backgroundColor: colorfondo,
        body: FutureBuilder(
          future: Future.wait([
            api.fetchEmpresaData(pageNumber),
            apicategoria.fetchEmpresaData(pageNumber),
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
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 0,
                          vertical: 20,
                        ),
                        sliver: SliverList(
                          delegate: SliverChildListDelegate([
                            const SizedBox(height: 10),
                            _buildPromo(),
                            const SizedBox(height: 20),
                            _buildCategorias(),
                            const SizedBox(height: 20),
                            _buildCategoriaItem(),
                            const SizedBox(height: 20),
                            _buildTitle(),
                            const SizedBox(height: 20),
                            _buildRestaurantes(),
                            const SizedBox(height: 20),
                            _buildRestaurantes(),
                          ]),
                        ),
                      ),
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
      expandedHeight: 180,
      pinned: true, //  deja solo la barra pequeña visible
      floating: false, //  NO aparece al subir
      snap: false, // NO animación automática
      elevation: 0,
      toolbarHeight: 50, // 🔵 altura de la barrita azul
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(0)),
      ),
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: Text(
          'HOME',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: colortitulo2,
          ),
        ),
        background: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.only(top: 0),
          child: Flex(
            direction: Axis.horizontal,
            children: [
              const SizedBox(width: 40),
              Text(
                username ?? '',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  color: colortitulo,
                ),
              ),
              const Spacer(),
              img != null
                  ?
              Container(
                decoration: BoxDecoration(
                  color: colorfondo,
                  border: Border.all(
                    color: colorWhite,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(50),
                ),
                width: 70,
                height: 70,
                child: CircleAvatar(backgroundImage: NetworkImage(img ?? '')),
              ):
               Container(
                    decoration: BoxDecoration(
                    color:  Color.fromARGB(255, 177, 177, 177),
                    borderRadius: BorderRadius.circular(100)),
                    width: 70,
                    height: 70,
                   child:  IconButton(
                    onPressed: () {
                    },
                    icon: const Icon(Icons.person ), // Usa un icono de calendario
                    color: colorfondo,
                    iconSize: 45,
                  ),
               ),
              const SizedBox(width: 30),
            ],
          ),
        ),
      ),
    );
  }

  
  Widget _buildTitle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
      child: Container(
        alignment: Alignment.topLeft,
        child: Row(
          children: [
            Text(
              'Servicios Disponibles',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: colortitulo3,
              ),
            ),
            Spacer(),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CategoriasPage()),
                );
              },
              child: Icon(
                Icons.arrow_forward_ios,
                size: 20,
                color: colortitulo3,
              ),
            ),
          ],
        ),
      ).animate().fade().slideX(begin: -0.2),
    );
  }

  Widget _buildCategorias() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
      child: Container(
        alignment: Alignment.topLeft,
        child: Row(
          children: [
            Text(
              'Categorias Populares',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: colortitulo3,
              ),
            ),
            Spacer(),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CategoriasPage()),
                );
              },
              child: Icon(
                Icons.arrow_forward_ios,
                size: 20,
                color: colortitulo3,
              ),
            ),
          ],
        ),
      ).animate().fade().slideX(begin: -0.2),
    );
  }


  Widget _buildCategoriaItem() {
  final isLoading = apicategoria.categorias.isEmpty;

  return SizedBox(
    height: 100,
    child: GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      scrollDirection: Axis.horizontal,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 1,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.45,
      ),
      itemCount: isLoading
          ? 3 //  skeletons visibles
          : apicategoria.categorias.length,
          itemBuilder: (context, index) {
            if (isLoading) {
              return const OptionsSkeleton();
            }

        final categoria = apicategoria.categorias[index];
        return Options(nombre: categoria.nombre);
      },
    ),
  );
}
Widget _buildRestaurantes() {
  final isLoading1 = api.servicios.isEmpty;
  return SizedBox(
    height: 320,
    child: GridView.builder(
      controller: _scrollController,
      scrollDirection: Axis.horizontal,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 1,
        mainAxisSpacing: 16,
        childAspectRatio: 1.25,
      ),
     itemCount: isLoading1
          ? 3 //  skeletons visibles
          : api.servicios.length,
          itemBuilder: (context, index) {
            if (isLoading1) {
              return const CardsEmpresaSkeleton();
            }

        final empresa = api.servicios[index];

        return CardsEmpresa(
          url_img: empresa.img_servicio,
          nombre: empresa.nombre_servicio,
          id_servicio: empresa.id_servicio,
        )
            .animate()
            .fade(duration: 400.ms)
            .slideY(begin: 0.15)
            .scale(begin: const Offset(0.96, 0.96));
      },
    ),
  );
}


  Widget _buildPromo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
      child: Container(
        height: 150,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          image: const DecorationImage(
            image: AssetImage('assets/promo.png'),
            fit: BoxFit.cover,
          ),
        ),
      ).animate().fade().slideX(begin: -0.2),
    );
  }
}