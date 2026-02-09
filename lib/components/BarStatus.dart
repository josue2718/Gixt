import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:gixt/components/colors.dart';

class Barstatus extends StatelessWidget {
  const Barstatus({super.key, required this.estadoTrabajo});

  final String estadoTrabajo;

  @override
  Widget build(BuildContext context) {
    final estados = ['Pendiente', 'en_proceso', 'finalizado', 'cancelado'];

    // Determinar el índice del estado actual
    int currentIndex = 0;
    if (estadoTrabajo.toLowerCase().contains('proceso')) {
      currentIndex = 1;
    } else if (estadoTrabajo.toLowerCase().contains('finalizado') ||
        estadoTrabajo.toLowerCase().contains('finalizado')) {
      currentIndex = 2;
    } else if (estadoTrabajo.toLowerCase().contains('cancelado')) {
      currentIndex = 3;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 15,
            offset: const Offset(0, 4),
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
              color: Theme.of(context).colorScheme.surface,
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
                        ? (currentIndex == 3
                              ? Colors.red
                              : Theme.of(context).colorScheme.primary)
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
                    textAlign: index == 0
                        ? TextAlign.start
                        : index == 1
                        ? TextAlign.center
                        : TextAlign.end,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: index == currentIndex
                          ? FontWeight.bold
                          : FontWeight.normal,
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
            ? colorsecundario
            : Colors.grey[300],
        border: Border.all(
          color: isCanceled
              ? Colors.red
              : isActive
              ? colorsecundario
              : Colors.grey[300]!,
          width: isCurrent ? 3 : 2,
        ),
      ),
      child: isActive
          ? Icon(
              isCanceled ? Icons.close : Icons.check,
              size: 16,
              color: colorWhite,
            )
          : null,
    );
  }
}
