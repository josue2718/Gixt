import 'dart:math';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gixt/Componets/cardoferta.dart';
import 'package:gixt/Componets/cardsServicios.dart';
import 'package:gixt/Componets/circleimage.dart';
import 'package:gixt/Componets/colors.dart';
import 'package:gixt/Componets/opciones.dart';
import 'package:gixt/Componets/sketor/cardsRestraurantes.dart';
import 'package:gixt/Componets/sketor/opciones.dart';
import 'package:gixt/services/Anuncios_service.dart';
import 'package:gixt/services/Auth/categorias_service.dart';
import 'package:gixt/services/Auth/servicios_service.dart';
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
  final Anuncio_service anuncio = Anuncio_service();
  final ScrollController _scrollController = ScrollController();
  final ValueNotifier<int> _currentIndexNotifier = ValueNotifier<int>(0);
  int pageNumber = 1;
  String? img;
  String? username;

  void initState() {
    super.initState();

    // 👇 SE EJECUTA AL ENTRAR A LA PÁGINA
    print("Entré a Restaurantes");
    api.fetchServicioData(pageNumber);
    apicategoria.fetchEmpresaData(pageNumber);
    anuncio.fetchData();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      img = prefs.getString('img');
      username = prefs.getString('user');
    });
  }

  Future<void> _onRefresh() async {
    setState(() {
      print('Actualizando datos...');
      anuncio.updatedata();
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
            api.fetchServicioData(pageNumber),
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
                            const SizedBox(height: 0),
                            _buildTitle(),
                            const SizedBox(height: 20),
                            _buildServicios(),
                            const SizedBox(height: 100),
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
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: Text(
          'HOME',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: colorsecundario,
          ),
        ),
        background: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.only(top: 0),
          child: Flex(
            direction: Axis.horizontal,
            children: [
              const SizedBox(width: 40),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    username ?? '',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      color: colortitulo,
                    ),
                  ),
                  Row(
                 children: [
                  Text(
                     'Uman Yuc',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: colortitulo,
                    ),
                  ),  
                  const SizedBox(width: 15),
                  const Icon(
                    Icons.location_on,
                    color: colortitulo,
                    size: 20,
                  ),
                               
                  ]
                  )
                ]
              ),
              const Spacer(),
              Row(
                children: [
                  const Icon(
                    Icons.notifications,
                    color: colortitulo,
                    size: 30,
                  ),
                  const SizedBox(width: 15),
                  Circleimage(w : 65, h :65 ,link_imagen:  img,)
                ]
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

  Widget _buildCategorias() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
      child: Container(
        alignment: Alignment.topLeft,
        child: Row(
          children: [
            Text(
              'Categorias Populares',
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

  Widget _buildCategoriaItem() {
  final isLoading = apicategoria.categorias.isEmpty;
  return SizedBox(
    height: 150,
    child: GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      scrollDirection: Axis.horizontal,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 1,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 1.5,
      ),
      itemCount: isLoading
          ? 3 //  skeletons visibles
          : apicategoria.categorias.length,
          itemBuilder: (context, index) {
            if (isLoading) {
              return const OptionsSkeleton();
            }
        final categoria = apicategoria.categorias[index];
        return Options(nombre: categoria.nombre, id: categoria.id_categoria);
      },
    ).animate().fade().slideX(begin: -0.2),
  );
}

  Widget _buildServicios() {
    final isLoading1 = api.servicios.isEmpty;
    return SizedBox(
      height: 320,
      child: GridView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 1,
          mainAxisSpacing: 16,
          childAspectRatio: 1.2,
        ),
        itemCount: isLoading1
            ? 3 //  skeletons visibles
            : api.servicios.length,
            itemBuilder: (context, index) {
              if (isLoading1) {
                return const CardsEmpresaSkeleton();
              }
              try {
          final servicio = api.servicios[index];

          return CardsServicios(
            url_img: servicio.img_servicio,
            nombre: servicio.nombre_servicio,
            img_trabajador: servicio.img_trabajador,
            id_servicio: servicio.id_servicio,
            trabajador: servicio.trabajador,
            categoria: servicio.categoria,
            estrellas:  servicio.calificacion,
            precio:  servicio.precio,
            descripcion:  servicio.descripcion,
          )
              .animate()
              .fade(duration: 400.ms)
              .slideY(begin: 0.15)
              .scale(begin: const Offset(0.96, 0.96));

              } catch (e) {
                return const SizedBox(); // widget vacío
              }
        },


      ),
    );
  }

  Widget _buildPromo() {
    return SizedBox(
      width: 400,
      child: Column(
        children: [
          if (anuncio.anuncio.isNotEmpty)
            CarouselSlider.builder(
              itemCount: anuncio.anuncio.length,
              itemBuilder: (context, index, realIndex) {
                final descuento = anuncio.anuncio[index];
                return Container(
                  width: 360,
                  child: cardsofertas( link_imagen: descuento.img),
                );
              },
              options: CarouselOptions(
                height: 150,
                viewportFraction: 1.0,
                enlargeCenterPage: true,
                enableInfiniteScroll: true,
                autoPlay: true,
                autoPlayInterval:
                    const Duration(seconds: 2),
                autoPlayAnimationDuration:
                    const Duration(milliseconds: 800),
                scrollDirection: Axis.horizontal,
                onPageChanged: (index, reason) {
                  _currentIndexNotifier.value = index;
                },
              ),
            ),
          const SizedBox(height: 30),
          ValueListenableBuilder<int>(
            valueListenable: _currentIndexNotifier,
            builder: (context, currentIndex, child) {
              return Row(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: List.generate(
                  anuncio.anuncio.length,
                  (index) => AnimatedContainer(
                    duration:
                        const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(
                        horizontal: 2),
                    width: currentIndex == index ? 16 : 8,
                    height:
                        currentIndex == index ? 16 : 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: currentIndex == index
                          ? colorWhite
                          : colorprimario
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    ).animate().fade().slideX(begin: -0.2);
  }

}



