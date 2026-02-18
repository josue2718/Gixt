import 'dart:io';
import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gixt/cache.dart';
import 'package:gixt/components/Indicador.dart';
import 'package:gixt/components/alert.dart';
import 'package:gixt/components/cards/cardsImage.dart';
import 'package:gixt/components/circleimage.dart';
import 'package:gixt/components/colors.dart';
import 'package:gixt/components/sketor/cardsImg.dart';
import 'package:gixt/pages/reservapage.dart';
import 'package:gixt/services/servicios/favorite_service.dart';
import 'package:gixt/services/servicios/serviciosbyid_service.dart';
import 'package:gixt/services/user/update_service.dart';
import 'package:gixt/services/user/User_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

class ServicioPage extends StatefulWidget {
  const ServicioPage({super.key, required this.service_id});
  final String service_id;
  @override
  State<ServicioPage> createState() => _ServicioPageState();
}

class _ServicioPageState extends State<ServicioPage> {
  bool isLoading = false;
  bool hasMore = true;
  final ServiciosById_service serviciosById = ServiciosById_service();
  final ScrollController _scrollController = ScrollController();
  bool fav = false;

  @override
  void initState() {
    super.initState();
    print("Entré a Mi Servicio");
    _initial();
  }

  Future<void> _initial() async {
    bool ok = await serviciosById.fetchServicioData(widget.service_id);
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

    setState(() {
      fav = serviciosById.servicios[0].favorite;
    });
  }

  Future<void> _onRefresh() async {
    setState(() {
      print('Actualizando datos...');
      hasMore = true;
    });
    bool ok = await serviciosById.fetchServicioData(widget.service_id);
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
    setState(() {});
  }

  void _fav() async {
    setState(() {
      fav = !fav;
    });
    final result = await FavoritoService.Crear(service_id: widget.service_id);
    print(result);
    if (result['success'] == true) {
      setState(() {
        fav = fav;
      });
    } else {
      setState(() {
        fav = fav;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardDismisser(
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: FutureBuilder(
          future: Future.wait([]),
          builder: (context, snapshot) {
            if (serviciosById.servicios.isEmpty) {
              return Indicador();
            }
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
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        sliver: SliverList(
                          delegate: SliverChildListDelegate([
                            const SizedBox(height: 20),
                            _buildServicio().animate().fade().slideX(
                              begin: -0.2,
                            ),
                            const SizedBox(height: 10),
                            _buildTrabajador()
                                .animate()
                                .fade(duration: 400.ms)
                                .scale(begin: const Offset(0.9, 0.9)),
                            const SizedBox(height: 20),
                            _buildImgServicios(),
                          ]),
                        ),
                      ),
                    ],
                  ),
                ),
                bottomNavigationBar: _bottomBar(context),
              ),
            );
          },
        ),
      ),
    );
  }

  SliverAppBar _buildSliverAppBar() {
    return SliverAppBar(
      backgroundColor: const Color.fromRGBO(0, 0, 0, 0),
      expandedHeight: 200,
      pinned: false,
      floating: false, //  sin efecto raro
      snap: false, //  sin delay
      elevation: 0,
      toolbarHeight: 90,

      iconTheme: IconThemeData(color: colorWhite),

      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title:
            const SizedBox(), //  quitamos title para evitar desplazamientos

        background: Stack(
          fit: StackFit.expand,
          children: [
            ///  IMAGEN
            CachedNetworkImage(
              imageUrl: serviciosById.servicios[0].image,
              fit: BoxFit.cover,
              placeholder: (context, url) => const Center(child: Indicador()),
              errorWidget: (context, url, error) =>
                  const Icon(Icons.broken_image),
            ),

            /// GRADIENTE
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black.withOpacity(0.6), Colors.transparent],
                ),
              ),
            ),

            ///  NOMBRE + BOTONES
            Positioned(
              bottom: 5,
              left: 16,
              right: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// NOMBRE
                  Text(
                    serviciosById.servicios[0].service_name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 0),

                  /// BOTONES PEGADOS A LA DERECHA
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        onPressed: _fav,
                        icon: Icon(
                          Icons.favorite,
                          size: 32,
                          color: !fav ? colorWhite : colorError,
                        ),
                      ),

                      const SizedBox(width: 10), // separación

                      IconButton(
                        onPressed: () {},
                        icon: Icon(Icons.share, size: 32, color: colorWhite),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Expanded(
      child: Text(
        serviciosById.servicios[0].service_name,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 25,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.surface,
        ),
      ),
    );
  }

  Widget _buildTrabajador() {
    return Column(
      children: [
        SizedBox(height: 20),
        Row(
          children: [
            SizedBox(height: 20),
            Text(
              'Trabajador',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.surface,
              ),
            ),
            Spacer(),
            Icon(
              Icons.home_repair_service,
              size: 25,
              color: Theme.of(context).colorScheme.surface,
            ),
          ],
        ),
        SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Circleimage(
                w: 80,
                h: 80,
                image_url: serviciosById.servicios[0].worker_img,
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            serviciosById.servicios[0].worker_name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.surface,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: colorWhite.withOpacity(0.95),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                color: Colors.amber,
                                size: 18,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${serviciosById.servicios[0].worker_rating}',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: colorBlack,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      serviciosById.servicios[0].des_trabajador,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.surface,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildopcions() {
    return Column(
      children: [
        Row(
          children: [
            Text(
              'Descripción',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.surface,
              ),
            ),
            Spacer(),
            Icon(
              Icons.home_repair_service,
              size: 25,
              color: Theme.of(context).colorScheme.surface,
            ),
          ],
        ),
        SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                        color: colorsecundario, // Fondo suave del mismo color
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Icon(
                          Icons.attach_money, // Tu icono original
                          size: 25,
                          color: colorWhite,
                        ),
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Precio',
                      style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(context).colorScheme.surface,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      '\$ ${serviciosById.servicios[0].price}',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.surface,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                        color: colorsecundario, // Fondo suave del mismo color
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Icon(
                          Icons.schedule, // Tu icono original
                          size: 25,
                          color: colorWhite,
                        ),
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Duración',
                      style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(context).colorScheme.surface,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      '${serviciosById.servicios[0].price}',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.surface,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                        color: colorsecundario, // Fondo suave del mismo color
                        shape: BoxShape.circle,
                        // border: Border.all(
                        //   color: colorprimario.withOpacity(0.2),
                        //   width: 1,
                        // ),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.star_rounded, // Tu icono original
                          size: 25,
                          color: colorWhite,
                        ),
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Estrellas',
                      style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(context).colorScheme.surface,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      '${serviciosById.servicios[0].rating}',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.surface,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImgServicios() {
    final isLoading1 = serviciosById.servicios[0].images.isEmpty;
    return Column(
      children: [
        Row(
          children: [
            Text(
              'Mis Referencias ',
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
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 200,
                child: GridView.builder(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 1,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.5,
                  ),
                  itemCount: isLoading1
                      ? 3 //  skeletons visibles
                      : serviciosById.servicios[0].images.length,
                  itemBuilder: (context, index) {
                    if (isLoading1) {
                      return const CardsImgSkeleton();
                    }
                    try {
                      final servicio = serviciosById.servicios[0].images[index];

                      return CardsImage(url_img: servicio)
                          .animate()
                          .fade(duration: 400.ms)
                          .slideY(begin: 0.15)
                          .scale(begin: const Offset(0.96, 0.96));
                    } catch (e) {
                      return const SizedBox(); // widget vacío
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildServicio() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SizedBox(height: 20),
            Text(
              'Descripción',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.surface,
              ),
            ),
            Spacer(),
            Icon(
              Icons.home_repair_service,
              size: 25,
              color: Theme.of(context).colorScheme.surface,
            ),
          ],
        ),
        SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            serviciosById.servicios[0].description,
            style: TextStyle(
              fontSize: 15,
              color: Theme.of(context).colorScheme.surface,
            ),
          ),
        ),

        SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  crossAxisAlignment: CrossAxisAlignment.center,
  children: [
    _InfoCard(
      icon: Icons.monetization_on_outlined,
      label: 'Precio',
      value: '\$ ${serviciosById.servicios[0].price}',
      context: context,
    ),
    _VerticalDivider(),
    _InfoCard(
      icon: Icons.hourglass_top_rounded,
      label: 'Duración',
      value: '${serviciosById.servicios[0].price}',
      context: context,
    ),
    _VerticalDivider(),
    _InfoCard(
      icon: Icons.auto_awesome_outlined,
      label: 'Rating',
      value: '${serviciosById.servicios[0].rating}',
      context: context,
    ),
  ],
),
        ),
      ],
    );
  }

  

Widget _bottomBar(BuildContext context) {
  return SizedBox(
    height: 90,
    child: Center(
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ReservaPage(
                service_id: serviciosById.servicios[0].service_id,
                name: serviciosById.servicios[0].service_name,
                description: serviciosById.servicios[0].description,
              ),
            ),
          );
        },

        /// 🔥 ESTILO
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: colorsecundario,
          foregroundColor: colorWhite,
          padding: const EdgeInsets.symmetric(
            horizontal: 50,
            vertical: 14,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),

        icon: const Icon(
          Icons.calendar_month,
          size: 22,
        ),
        label: const Text(
          'Reservar',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    ),
  );
}

}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final BuildContext context;

  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.context,
  });

  @override
  Widget build(BuildContext ctx) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 48,
          width: 48,
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: colorsecundario.withOpacity(0.35),
              width: 1.4,
            ),
          ),
          child: Icon(
            icon,
            size: 22,
            color: colorsecundario,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            letterSpacing: 0.8,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.surface.withOpacity(0.55),
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
            color: Theme.of(context).colorScheme.surface,
          ),
        ),
      ],
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      width: 1,
      color: Colors.grey.withOpacity(0.2),
    );
  }
}