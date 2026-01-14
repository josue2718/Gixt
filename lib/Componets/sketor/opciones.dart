import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gixt/Componets/colors.dart';

class OptionsSkeleton extends StatelessWidget {
  const OptionsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      width: 85, // Mismo ancho que el componente real
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          /// Icon Circle Skeleton
          Container(
            height: 65,
            width: 65,
            decoration: BoxDecoration(
              color: colorWhite, // Fondo tenue
              shape: BoxShape.circle,
            ),
          ),
          
          const SizedBox(height: 12),

          /// Text Line Skeleton (Primera línea)
          Container(
            height: 10,
            width: 50,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.2),
              borderRadius: BorderRadius.circular(5),
            ),
          ),
          
          const SizedBox(height: 6),

          /// Text Line Skeleton (Segunda línea opcional)
          Container(
            height: 10,
            width: 30,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(5),
            ),
          ),
        ],
      ),
    )
    .animate(onPlay: (c) => c.repeat())
    .shimmer(
      duration: 1200.ms, 
      color: Colors.white.withOpacity(0.5),
    )
    .fade(duration: 800.ms, begin: 0.4, end: 0.8);
  }
}