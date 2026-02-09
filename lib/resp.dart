import 'dart:io';
import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gixt/cache.dart';
import 'package:gixt/components/Indicador.dart';
import 'package:gixt/components/alert.dart';
import 'package:gixt/components/circleimage.dart';
import 'package:gixt/components/colors.dart';
import 'package:gixt/services/reservas/Agenda_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';

class ViewAgendaPage extends StatefulWidget {
  const ViewAgendaPage({super.key, required this.id_trabajo});
  final String id_trabajo;
  @override
  State<ViewAgendaPage> createState() => _ViewAgendaPageState();
}

class _ViewAgendaPageState extends State<ViewAgendaPage> {
  bool isLoading = false;
  bool hasMore = true;
  final AgendaById_service agenda = AgendaById_service();
  final ScrollController _scrollController = ScrollController();
  final PreferencesService _preferencesService = PreferencesService();
  @override
  void initState() {
    super.initState();
    print("Entré a Mi Servicio");
    _initial();
  }

  Future<void> _initial() async {
    bool ok = await agenda.fetchServicioData(widget.id_trabajo);
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

  Future<void> _onRefresh() async {
    setState(() {
      print('Actualizando datos...');
      hasMore = true;
    });
    bool ok = await agenda.fetchServicioData(widget.id_trabajo);
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

  @override
  Widget build(BuildContext context) {
    return KeyboardDismisser(
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: FutureBuilder(
          future: Future.wait([]),
          builder: (context, snapshot) {
            if (agenda.agenda.isEmpty) {
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
                            _buildInformacion()
                                .animate()
                                .fade(duration: 400.ms)
                                .scale(begin: const Offset(0.9, 0.9)),
                            const SizedBox(height: 40),
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
          'Agenda',
          style: GoogleFonts.poppins(
            fontSize: 30,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.surface,
          ),
        ),
      ),
    );
  }

Widget _buildInformacion() {
  return Padding(
    padding: const EdgeInsets.all(16),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Título principal
        Text(
          'Información de la reserva',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.surface,
          ),
        ),
        const SizedBox(height: 24),

        // BARRA DE ESTATUS ESTILO MERCADO LIBRE
        _buildStatusBar(agenda.agenda[0].estadoTrabajo),
        
        const SizedBox(height: 32),

        // Sección Trabajador
        _buildSectionCard(
          icon: Icons.person,
          title: 'Trabajador',
          child: _buildProfile(),
        ),

        const SizedBox(height: 16),

        // Sección Servicio
        _buildSectionCard(
          icon: Icons.home_repair_service,
          title: 'Servicio',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${agenda.agenda[0].nombreServicio}',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.surface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${agenda.agenda[0].descripcionServicio}',
                style: TextStyle(
                  fontSize: 15,
                  color: Theme.of(context).colorScheme.surface.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Sección Descripción
        _buildSectionCard(
          icon: Icons.description,
          title: 'Descripción',
          child: Text(
            '${agenda.agenda[0].descripcion}',
            style: TextStyle(
              fontSize: 15,
              color: Theme.of(context).colorScheme.surface.withOpacity(0.8),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Sección Fecha y Hora
        _buildSectionCard(
          icon: Icons.calendar_today,
          title: 'Fecha del servicio',
          child: Row(
            children: [
              Icon(
                Icons.event,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '${agenda.agenda[0].fechaTrabajo}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.surface,
                ),
              ),
              const SizedBox(width: 16),
              Icon(
                Icons.access_time,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '${agenda.agenda[0].horaTrabajo}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.surface,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Sección Ubicación
        _buildSectionCard(
          icon: Icons.location_on,
          title: 'Ubicación',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${agenda.agenda[0].direccionMaps}',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.surface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${agenda.agenda[0].calle}, ${agenda.agenda[0].colonia}',
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.surface.withOpacity(0.7),
                ),
              ),
              Text(
                '${agenda.agenda[0].estadoUbicacion}',
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.surface.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: imageBox1(agenda.agenda[0].ubicacionImagen),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Sección Imágenes
        _buildSectionCard(
          icon: Icons.photo_library,
          title: 'Imágenes',
          child: _buildImg(),
        ),

        const SizedBox(height: 16),

        // Sección Pago
        _buildSectionCard(
          icon: Icons.payment,
          title: 'Información de pago',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Tipo de pago:',
                    style: TextStyle(
                      fontSize: 15,
                      color: Theme.of(context).colorScheme.surface.withOpacity(0.7),
                    ),
                  ),
                  Text(
                    '${agenda.agenda[0].tipoPago}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.surface,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.surface,
                      ),
                    ),
                    Text(
                      '\$${agenda.agenda[0].precio}',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),
      ],
    ),
  );
}

// WIDGET DE BARRA DE ESTATUS ESTILO MERCADO LIBRE
Widget _buildStatusBar(String estadoTrabajo) {
  final estados = ['Pendiente', 'En proceso', 'Completado', 'Cancelado'];
  
  // Determinar el índice del estado actual
  int currentIndex = 0;
  if (estadoTrabajo.toLowerCase().contains('proceso')) {
    currentIndex = 1;
  } else if (estadoTrabajo.toLowerCase().contains('completado') || 
             estadoTrabajo.toLowerCase().contains('finalizado')) {
    currentIndex = 2;
  } else if (estadoTrabajo.toLowerCase().contains('cancelado')) {
    currentIndex = 3;
  }

  return Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Estado del servicio',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 20),
        
        // Barra de progreso
        Row(
          children: List.generate(estados.length * 2 - 1, (index) {
            if (index.isEven) {
              // Es un círculo de estado
              final stateIndex = index ~/ 2;
              final isActive = stateIndex <= currentIndex;
              final isCanceled = currentIndex == 3;
              
              return _buildStatusCircle(
                isActive: isActive,
                isCurrent: stateIndex == currentIndex,
                isCanceled: isCanceled && stateIndex == 3,
              );
            } else {
              // Es una línea conectora
              final lineIndex = index ~/ 2;
              final isActive = lineIndex < currentIndex;
              
              return Expanded(
                child: Container(
                  height: 3,
                  color: isActive 
                      ? (currentIndex == 3 ? Colors.red : Theme.of(context).colorScheme.primary)
                      : Colors.grey[300],
                ),
              );
            }
          }),
        ),
        
        const SizedBox(height: 12),
        
        // Etiquetas de estados
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(estados.length, (index) {
            if (index < 3) {
              return Expanded(
                child: Text(
                  estados[index],
                  textAlign: index == 0 ? TextAlign.start : 
                           index == 1 ? TextAlign.center : 
                           TextAlign.end,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: index == currentIndex ? FontWeight.bold : FontWeight.normal,
                    color: index <= currentIndex 
                        ? Theme.of(context).colorScheme.surface
                        : Colors.grey[400],
                  ),
                ),
              );
            } else {
              // Estado cancelado en línea separada si está activo
              return const SizedBox.shrink();
            }
          }),
        ),
        
        // Mostrar cancelado si aplica
        if (currentIndex == 3) ...[
          const SizedBox(height: 8),
          Center(
            child: Text(
              'Cancelado',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
          ),
        ],
        
        const SizedBox(height: 16),
        
        // Chip con el estado actual
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: _getStatusColor(currentIndex).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _getStatusColor(currentIndex),
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _getStatusIcon(currentIndex),
                  size: 18,
                  color: _getStatusColor(currentIndex),
                ),
                const SizedBox(width: 8),
                Text(
                  estadoTrabajo,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: _getStatusColor(currentIndex),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _buildStatusCircle({
  required bool isActive,
  required bool isCurrent,
  required bool isCanceled,
}) {
  return Container(
    width: 28,
    height: 28,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: isCanceled 
          ? Colors.red 
          : isActive 
              ? Theme.of(context).colorScheme.primary 
              : Colors.grey[300],
      border: Border.all(
        color: isCanceled 
            ? Colors.red 
            : isActive 
                ? Theme.of(context).colorScheme.primary 
                : Colors.grey[300]!,
        width: isCurrent ? 3 : 2,
      ),
    ),
    child: isActive
        ? Icon(
            isCanceled ? Icons.close : Icons.check,
            size: 16,
            color: Colors.white,
          )
        : null,
  );
}

Color _getStatusColor(int statusIndex) {
  switch (statusIndex) {
    case 0:
      return Colors.orange;
    case 1:
      return Colors.blue;
    case 2:
      return Colors.green;
    case 3:
      return Colors.red;
    default:
      return Colors.grey;
  }
}

IconData _getStatusIcon(int statusIndex) {
  switch (statusIndex) {
    case 0:
      return Icons.schedule;
    case 1:
      return Icons.autorenew;
    case 2:
      return Icons.check_circle;
    case 3:
      return Icons.cancel;
    default:
      return Icons.info;
  }
}

// WIDGET DE TARJETA DE SECCIÓN
Widget _buildSectionCard({
  required IconData icon,
  required String title,
  required Widget child,
}) {
  return Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: 24,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.surface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        child,
      ],
    ),
  );
}

Widget _buildImg() {
  return SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: Row(
      children: [
        imageBox1(agenda.agenda[0].imagen1),
        const SizedBox(width: 16),
        imageBox1(agenda.agenda[0].imagen2),
      ],
    ),
  );
}

Widget imageBox1(String? imagen) {
  return Container(
    width: 150,
    height: 150,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: imagen == null
        ? Container(
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.image_not_supported,
              color: Colors.grey,
              size: 50,
            ),
          )
        : ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CachedNetworkImage(
              imageUrl: imagen,
              fit: BoxFit.cover,
              placeholder: (context, url) => Center(child: Indicador()),
              errorWidget: (context, url, error) =>
                  const Icon(Icons.broken_image, size: 50),
            ),
          ),
  );
}

Widget _buildProfile() {
  return Row(
    children: [
      Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Circleimage(
          w: 70,
          h: 70,
          link_imagen: agenda.agenda[0].trabajadorImagen,
        ),
      ),
      const SizedBox(width: 16),
      Expanded(
        child: Text(
          '${agenda.agenda[0].trabajadorNombre}',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.surface,
          ),
        ),
      ),
    ],
  );
}

}
