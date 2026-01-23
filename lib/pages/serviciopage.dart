import 'dart:io';
import 'dart:math';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gixt/Componets/Indicador.dart';
import 'package:gixt/Componets/Nacimientoformatter.dart';
import 'package:gixt/Componets/alert.dart';
import 'package:gixt/Componets/cardsImage.dart';
import 'package:gixt/Componets/circleimage.dart';
import 'package:gixt/Componets/colors.dart';
import 'package:gixt/Componets/sketor/cardsImg.dart';
import 'package:gixt/Componets/sketor/cardsRestraurantes.dart';
import 'package:gixt/cache.dart';
import 'package:gixt/services/favoritos/favorite_servive.dart';
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
  final ApiServiciosById serviciosById = ApiServiciosById();
  final ScrollController _scrollController = ScrollController();
  final PreferencesService _preferencesService = PreferencesService();
  String? _genero;
  String? _imageUrl;
  File? _image;
  String? _img;
  String? _user;
  bool fav = false;

  Future<void> _updateUser(String user, String img) async {
    await _preferencesService.savePreferencesUser(img, user);
    setState(() {
      _img = img;
      _user = user;
    });
  }

  void initState() {
    super.initState();
    print("Entré a Mi Servicio");
    _initial();
  }

  Future<void> _initial() async {
    await serviciosById.fetchServicioData(widget.id_servicio);
    fav = serviciosById.servicios[0].fav;
  }

  Future<void> _onRefresh() async {
    setState(() {
      print('Actualizando datos...');
      serviciosById.fetchServicioData(widget.id_servicio);
      hasMore = true;
    });
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
        backgroundColor: colorfondo,
        body: FutureBuilder(
          future: Future.wait([
            serviciosById.fetchServicioData(widget.id_servicio),
          ]),
          builder: (context, snapshot) {
            if (serviciosById.servicios.isEmpty) {
              return Indicador();
            }
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
                          horizontal: 20,
                          vertical: 10,
                        ),
                        sliver: SliverList(
                          delegate: SliverChildListDelegate([
                            _buildTitle().animate().fade().slideX(begin: -0.2),
                            const SizedBox(height: 40),
                            _buildProfile()
                                .animate()
                                .fade(duration: 400.ms)
                                .scale(begin: const Offset(0.9, 0.9)),
                            const SizedBox(height: 40),
                            _buildopcions()
                                .animate()
                                .fade(duration: 400.ms)
                                .scale(begin: const Offset(0.9, 0.9)),
                            const SizedBox(height: 40),
                            _buildWork().animate().fade().slideX(begin: -0.2),
                            const SizedBox(height: 40),
                            _buildTitleIMG().animate().fade().slideX(
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
    backgroundColor: colorprimario,
    expandedHeight: 90,
    pinned: true,
    floating: false,
    snap: false,
    elevation: 0,
    toolbarHeight: 90,

   iconTheme: const IconThemeData(
        color: Colors.white, // 👈 color del ícono
      ),

    flexibleSpace: FlexibleSpaceBar(
      centerTitle: true,
      title: Text(
        'Mi Servicio',
        style: GoogleFonts.poppins(
          fontSize: 25,
          fontWeight: FontWeight.w600,
          color: colorsecundario,
        ),
      ),
    ),
  );
}

  Widget _buildTitle() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                serviciosById.servicios[0].nombreServicio,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: colorWhite,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProfile() {
    return Row(
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
                  color: colorWhite,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                serviciosById.servicios[0].desTrabajador,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 12, color: colorWhite),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWork() {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Descripción',
            style: TextStyle(
              fontSize: 21,
              color: colorWhite,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 20),
          Text(
            serviciosById.servicios[0].descripcion,
            style: TextStyle(fontSize: 15, color: colorWhite),
          ),
        ],
      ),
    );
  }

  Widget _buildopcions() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
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
                      color: colorWhite, // Fondo suave del mismo color
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: colorprimario.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.attach_money, // Tu icono original
                        size: 25,
                        color: colorprimario,
                      ),
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Precio',
                    style: TextStyle(fontSize: 13, color: colorWhite),
                  ),
                  SizedBox(height: 5),
                  Text(
                    '\$ ${serviciosById.servicios[0].precio}',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: colorWhite,
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
                      color: colorWhite, // Fondo suave del mismo color
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: colorprimario.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.schedule, // Tu icono original
                        size: 25,
                        color: colorprimario,
                      ),
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Duración',
                    style: TextStyle(fontSize: 13, color: colorWhite),
                  ),
                  SizedBox(height: 5),
                  Text(
                    '${serviciosById.servicios[0].precio}',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: colorWhite,
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
                      color: colorWhite, // Fondo suave del mismo color
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: colorprimario.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.star_rounded, // Tu icono original
                        size: 25,
                        color: colorprimario,
                      ),
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Estrellas',
                    style: TextStyle(fontSize: 13, color: colorWhite),
                  ),
                  SizedBox(height: 5),
                  Text(
                    '${serviciosById.servicios[0].calificacion}',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: colorWhite,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleIMG() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      child: Container(
        alignment: Alignment.topLeft,
        child: Row(
          children: [
            Text(
              'Mis Referencias ',
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

  Widget _buildImgServicios() {
    final isLoading1 = serviciosById.servicios[0].imagenes.isEmpty;
    return SizedBox(
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
            : serviciosById.servicios[0].imagenes.length,
        itemBuilder: (context, index) {
          if (isLoading1) {
            return const CardsImgSkeleton();
          }
          try {
            final servicio = serviciosById.servicios[0].imagenes[index];

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
                color: colorWhite,
              ),
            ),
            Spacer(),
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
                fixedSize: const Size(150, 45),
                backgroundColor: colorWhite,
                foregroundColor: colorBlack,
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
