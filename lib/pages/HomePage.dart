import 'dart:math';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:geolocator/geolocator.dart';
import 'package:gixt/components/alert.dart';
import 'package:gixt/components/cards/CardsOfertaas.dart';
import 'package:gixt/components/cards/cardsServicios.dart';
import 'package:gixt/components/circleimage.dart';
import 'package:gixt/components/colors.dart';
import 'package:gixt/components/opciones.dart';
import 'package:gixt/components/sketor/cardsRestraurantes.dart';
import 'package:gixt/components/sketor/opciones.dart';
import 'package:gixt/services/Anuncios_service.dart';
import 'package:gixt/services/Auth/categorias_service.dart';
import 'package:gixt/services/servicios/servicios_service.dart';
import 'package:gixt/services/servicios/serviciosbyfav.dart';
import 'package:gixt/services/ubicaciones/geocoding_helper.dart';
import 'package:gixt/services/ubicaciones/location_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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
  final Servicios_service api = Servicios_service();
  final ServiciosFav_service fav = ServiciosFav_service();
  final Categorias_service categorias = Categorias_service();
  final Anuncio_service anuncio = Anuncio_service();
  final ScrollController _scrollController = ScrollController();
  final ValueNotifier<int> _currentIndexNotifier = ValueNotifier<int>(0);
  int pageNumber = 1;
  String? img;
  String? username;
  String? calle;
  String ciudad = "";
  String estado = "";
  double longitud = 0;
  double latitud = 0;
  GoogleMapController? mapController;
  LatLng posicionActual = LatLng(20.9674, -89.5926);
  bool isnot = false;

  void initState() {
    super.initState();
    // 👇 SE EJECUTA AL ENTRAR A LA PÁGINA
    print("Entré a Restaurantes");
    obtenerCoordenadas();
    getcalle();
    _loadUserId();
    _Initial();

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
      api.updatedata();
      fav.fetchServicioData();
      hasMore = true;
    });
  }

  Future<void> _Initial() async {
    bool ok = await api.fetchServicioData();
    bool okfav = await fav.fetchServicioData();
    bool okData =  await categorias.fetchEmpresaData();
    bool okAnc = await anuncio.fetchData();
    if (!okData || !okfav || !ok|| !okAnc) {
      if (!mounted) return;
      mostrarAlerta(
        context,
        titulo: "Error",
        mensaje: "No se pudo obtener la información",
        tipo: TipoAlerta.error,
      );
    }

    setState(() {
      print('Iniciando home');
      hasMore = true;
    });
  }
  
  void obtenerCoordenadas() async {
    try {
      Position pos = await LocationService.obtenerUbicacion();
      latitud = pos.latitude;
      longitud = pos.longitude;
      setState(() {
        posicionActual = LatLng(pos.latitude, pos.longitude);
      });
      getcalle();
    } catch (e) {
      print(e);
    }
  }

  void getcalle()
  {
     GeocodingHelper.obtenerCiudadDesdeCoordenadas(
        latitud: latitud,
        longitud: longitud,
        onResult: (ciudadResult, calleResult,estadoResult) {
          setState(() {
            ciudad = ciudadResult;
            calle = calleResult;
            estado =estadoResult;
            print(calle);
          });
        },
      );
  }
  
  
  @override
  Widget build(BuildContext context) {
    return KeyboardDismisser(
      child: Scaffold(
        backgroundColor:  Theme.of(context).scaffoldBackgroundColor,
        body: FutureBuilder(
          future: Future.wait([
          ]),
          builder: (context, snapshot) {
            return KeyboardDismisser(
              child: Scaffold(
                backgroundColor:  Theme.of(context).scaffoldBackgroundColor,
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
                            const SizedBox(height: 10),
                            _buildCategorias(),
                            const SizedBox(height: 20),
                            _buildCategoriaItem(),
                            _buildTitle(),
                            _buildServicios(),
                            if (fav.servicios.isNotEmpty) ...[
                              _buildTitleFav(),
                              _buildServiciosFav(),
                            ],
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
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    expandedHeight: 140,
    elevation: 0,

    // 👉 Permite que suba y baje con el scroll
    floating: true,
    snap: true,
    pinned: false,

    flexibleSpace: FlexibleSpaceBar(
      collapseMode: CollapseMode.parallax,

      titlePadding: const EdgeInsets.only(left: 20, bottom: 16),

      title: Text(
        'Hola, ${username ?? ''}',
        style: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: colorsecundario,
        ),
      ),

      background: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor
        ),

        child: SafeArea(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [

              // Info usuario
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),

                  Row(
                    children:  [
                      Icon(Icons.location_on, size: 16, color: Theme.of(context).colorScheme.surface),
                      SizedBox(width: 4),
                      Text(
                        '${ciudad ?? ''} ${estado ?? ''}',
                        style: TextStyle(fontSize: 15 , color:Theme.of(context).colorScheme.surface ),
                      )
                    ],
                  )
                ],
              ),

              const Spacer(),

              // Notificaciones
              IconButton(
                icon: const Icon(Icons.notifications_none),
                color: Theme.of(context).colorScheme.surface,
                iconSize: 28,
                onPressed: () {},
              ),

              // Avatar
              Circleimage(
                w: 48,
                h: 48,
                link_imagen: img,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

  Widget _circle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
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

  Widget _buildCategoriaItem() {
    final isLoading = categorias.categorias.isEmpty;
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
            : categorias.categorias.length,
        itemBuilder: (context, index) {
          if (isLoading) {
            return const OptionsSkeleton();
          }
          final categoria = categorias.categorias[index];
          return Options(nombre: categoria.nombre, id: categoria.id_categoria);
        },
      ).animate().fade().slideX(begin: -0.2),
    );
  }

  Widget _buildServicios() {
    final isLoading = api.servicios.isEmpty;

    return SizedBox(
      height: 400,
      child: GridView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 1,
          mainAxisSpacing: 30,
          childAspectRatio: 1.5,
        ),
        itemCount: isLoading
            ? 3 //  skeletons visibles
            : api.servicios.length,
        itemBuilder: (context, index) {
          if (isLoading) {
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
                  estrellas: servicio.calificacion,
                  precio: servicio.precio,
                  descripcion: servicio.descripcion,
                  favorito: false,
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
                  child: cardsofertas(link_imagen: descuento.img),
                );
              },
              options: CarouselOptions(
                height: 150,
                viewportFraction: 1.0,
                enlargeCenterPage: true,
                enableInfiniteScroll: true,
                autoPlay: true,
                autoPlayInterval: const Duration(seconds: 2),
                autoPlayAnimationDuration: const Duration(milliseconds: 800),
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
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  anuncio.anuncio.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    width: currentIndex == index ? 10 : 8,
                    height: currentIndex == index ? 10 : 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: currentIndex == index ? colorsecundario : Theme.of(context).colorScheme.surface,
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

  Widget _buildTitleFav() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
      child: Container(
        alignment: Alignment.topLeft,
        child: Row(
          children: [
            Text(
              'Servicios Favoritos',
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

  Widget _buildServiciosFav() {
    final isLoading1 = fav.servicios.isEmpty;
    return SizedBox(
      height: 400,
      child: GridView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 1,
          mainAxisSpacing: 30,
          childAspectRatio: 1.5,
        ),
        itemCount: isLoading1
            ? 3 //  skeletons visibles
            : fav.servicios.length,
        itemBuilder: (context, index) {
          if (isLoading1) {
            return const CardsEmpresaSkeleton();
          }
          try {
            final servicio = fav.servicios[index];

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
                  favorito: true,
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
}
