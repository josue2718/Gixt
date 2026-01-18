import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:gixt/Componets/Indicador.dart';
import 'package:gixt/Componets/colors.dart';

class Circleimage extends StatelessWidget {
  const Circleimage({
    super.key,
    required this.link_imagen,
    required this.w,
    required this.h,
  });

  final double h;
  final double w;
  final String? link_imagen;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: colorWhite, width: 2),
      ),
      child: ClipOval(
        child: link_imagen != null
            ? CachedNetworkImage(
                imageUrl: link_imagen!,
                fit: BoxFit.cover,
                errorWidget: (context, url, error) => _placeholder(),
              )
            : _placeholder(),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: Colors.white,
      child: const Icon(
        Icons.person,
        size: 30,
        color: Colors.grey,
      ),
    );
  }
}
