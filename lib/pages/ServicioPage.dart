import 'dart:io';
import 'dart:math';
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
  const ServicioPage({super.key, required this.id_servicio});
  final String id_servicio;
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
    bool ok = await serviciosById.fetchServicioData(widget.id_servicio);
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
    fav = serviciosById.servicios[0].fav;
    setState(() {});
  }

  Future<void> _onRefresh() async {
    setState(() {
      print('Actualizando datos...');
      hasMore = true;
    });
    bool ok = await serviciosById.fetchServicioData(widget.id_servicio);
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
    setState(() {});
  }

  void _fav() async {
    setState(() {
      fav = !fav;
    });
    final result = await FavoritoService.Crear(id_servicio: widget.id_servicio);
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
                            _buildTitle().animate().fade().slideX(begin: -0.2),
                            const SizedBox(height: 20),
                            _buildTrabajador()
                                .animate()
                                .fade(duration: 400.ms)
                                .scale(begin: const Offset(0.9, 0.9)),
                            const SizedBox(height: 20),
                            _buildopcions()
                                .animate()
                                .fade(duration: 400.ms)
                                .scale(begin: const Offset(0.9, 0.9)),
                            const SizedBox(height: 20),
                            _buildServicio().animate().fade().slideX(
                              begin: -0.2,
                            ),
                            const SizedBox(height: 10),
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      expandedHeight: 90,
      pinned: false,
      floating: true,
      snap: true,
      elevation: 0,
      toolbarHeight: 90,

      iconTheme: IconThemeData(
        color: Theme.of(context).colorScheme.surface, // 👈 color del ícono
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(0)),
      ),
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: Text(
          'Mi Servicio',
          style: GoogleFonts.poppins(
            fontSize: 30,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.surface,
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Expanded(
      child: Text(
        serviciosById.servicios[0].nombreServicio,
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
                link_imagen: serviciosById.servicios[0].imgTrabajador,
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      serviciosById.servicios[0].trabajador,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.surface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      serviciosById.servicios[0].desTrabajador,
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
                      '\$ ${serviciosById.servicios[0].precio}',
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
                      '${serviciosById.servicios[0].precio}',
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
                      '${serviciosById.servicios[0].calificacion}',
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
    final isLoading1 = serviciosById.servicios[0].imagenes.isEmpty;
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
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 1,
                          mainAxisSpacing: 16,
                          childAspectRatio: 1.5,
                        ),
                    itemCount: isLoading1
                        ? 3 //  skeletons visibles
                        : serviciosById.servicios[0].imagenes.length,
                    itemBuilder: (context, index) {
                      if (isLoading1) {
                        return const CardsImgSkeleton();
                      }
                      try {
                        final servicio =
                            serviciosById.servicios[0].imagenes[index];

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
            serviciosById.servicios[0].descripcion,
            style: TextStyle(
              fontSize: 15,
              color: Theme.of(context).colorScheme.surface,
            ),
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _bottomBar(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 0, 0, 0), // Margen para que flote
      height: 90,
      decoration: BoxDecoration(
        color: colorprimario,
        borderRadius: BorderRadius.circular(0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            ElevatedButton(
              onPressed: _fav,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                elevation: 0,
              ),
              child: Icon(
                Icons.favorite, // Tu icono original
                size: 40,
                color: !fav ? colorWhite : colorError,
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // Navigator.push(
                //     context,
                //     MaterialPageRoute(
                //       builder: (context) =>
                //           MenuSelectPage(id_empresa: widget.id_empresa),
                //     ));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                elevation: 0,
              ),
              child: Icon(
                Icons.share, // Tu icono original
                size: 40,
                color: colorsecundario,
              ),
            ),
            Spacer(),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ReservaPage(
                      id_servicio: serviciosById.servicios[0].idServicio,
                      nombre: serviciosById.servicios[0].nombreServicio,
                      descripcion : serviciosById.servicios[0].descripcion
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                fixedSize: const Size(150, 45),
                backgroundColor: colorsecundario,
                foregroundColor: colorWhite,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [Text('Reserva')],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
