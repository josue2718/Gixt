import 'package:flutter/material.dart';
import 'package:gixt/components/colors.dart';

class Barstatus extends StatelessWidget {
  const Barstatus({super.key, required this.estadoTrabajo});

  final String estadoTrabajo;

  @override
  Widget build(BuildContext context) {
    Color color = colorWhite;
    IconData icon = Icons.info;
    String label = estadoTrabajo;

    // Usando switch para determinar color e ícono
    switch (estadoTrabajo.toLowerCase()) {
      case 'pending':
        color = Colors.purple;
        icon = Icons.schedule;
        break;
      case 'accepted':
        color = Colors.blue;
        icon = Icons.check;
        break;
      case 'in_progress':
        color = Colors.orange;
        icon = Icons.autorenew;
        break;
      case 'completed':
        color = Colors.green;
        icon = Icons.check_circle;
        break;
      case 'canceled':
        color = Colors.red;
        icon = Icons.cancel;
        break;
      default:
        color = Colors.grey;
        icon = Icons.info;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Estado del servicio',
            style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold, color:  Theme.of(context).colorScheme.surface),
          ),
          const SizedBox(height: 20),

          // Barra simple
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _statusCircle('pending', estadoTrabajo),
              _line(estadoTrabajo),
              _statusCircle('accepted', estadoTrabajo),
              _line(estadoTrabajo),
              _statusCircle('in_progress', estadoTrabajo),
              _line(estadoTrabajo),
              _statusCircle('completed', estadoTrabajo),
              if (estadoTrabajo.toLowerCase() == 'canceled') ...[
                _line(estadoTrabajo),
                _statusCircle('canceled', estadoTrabajo),
              ]
            ],
          ),

          const SizedBox(height: 20),

          // Chip con estado
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color, width: 1.5),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 18, color: color),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusCircle(String circleState, String currentState) {
    Color color = Colors.grey;
    IconData icon = Icons.info;

    switch (circleState) {
      case 'pending':
        color = currentState.toLowerCase() == 'pending' ? Colors.purple : Colors.grey[700]!;
        icon = currentState.toLowerCase() == 'pending' ? Icons.schedule : Icons.info;
        break;
      case 'accepted':
        color = currentState.toLowerCase() == 'accepted' ? Colors.blue : Colors.grey[700]!;
        icon = currentState.toLowerCase() == 'accepted' ? Icons.check : Icons.info;
        break;
      case 'in_progress':
        color = currentState.toLowerCase() == 'in_progress' ? Colors.orange : Colors.grey[700]!;
        icon = currentState.toLowerCase() == 'in_progress' ? Icons.autorenew : Icons.info;
        break;
      case 'completed':
        color = currentState.toLowerCase() == 'completed' ? Colors.green : Colors.grey[700]!;
        icon = currentState.toLowerCase() == 'completed' ? Icons.check : Icons.info;
        break;
      case 'canceled':
        color = Colors.red;
        icon = Icons.cancel;
        break;
    }

    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      child: Icon(icon, size: 16, color: Colors.white),
    );
  }

  Widget _line(String currentState) {
    Color lineColor = (currentState.toLowerCase() == 'completed' || currentState.toLowerCase() == 'in_progress'|| currentState.toLowerCase() == 'accepted')
        ? Colors.green
        : Colors.grey[300]!;

    if (currentState.toLowerCase() == 'canceled') lineColor = Colors.red;

    return Expanded(
      child: Container(height: 3, color: lineColor),
    );
  }
}
