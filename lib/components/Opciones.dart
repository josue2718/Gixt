import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gixt/components/Indicador.dart';
import 'package:gixt/components/colors.dart';
import 'package:gixt/pages/CategoriaPage.dart';
import 'package:google_fonts/google_fonts.dart';

class Options extends StatelessWidget {
  final String name;
  final int id;
  final String image_url;
  final VoidCallback? onTap; // Añadido para manejar el clic

  const Options({
    super.key,
    required this.name,
    required this.id,
    required this.image_url,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      child: SizedBox(
        width: 100,
        height: 140,
        child: Card(
          elevation: 0,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          color: Theme.of(context).colorScheme.primary,
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      CategoriaPage(category_id: id, name: name),
                ),
              );
            },
            child: Stack(
              clipBehavior: Clip.none,
              fit: StackFit.expand,
              children: [
                CachedNetworkImage(
                  imageUrl: image_url,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Center(child: Indicador()),
                  errorWidget: (context, url, error) =>
                      const Icon(Icons.broken_image),
                ),

                Positioned(
                  bottom: 12,
                  left: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: colorsecundario,
                      borderRadius: BorderRadius.circular(10),
                    ),

                    child: Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            name,
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: colorWhite,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fade(duration: 400.ms).scale(begin: const Offset(0.9, 0.9));
  }
}
