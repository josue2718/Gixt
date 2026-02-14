import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gixt/components/colors.dart';
import 'package:gixt/pages/ViewLocationpage.dart';

class LocationsOptions extends StatelessWidget {
  final String street;
  final String neighborhood;
  final String state;
  final String city;
  final String references;
  final String id;

  const LocationsOptions({
    super.key,
    required this.street,
    required this.neighborhood,
    required this.state,
    required this.city,
    required this.references,
    required this.id,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ViewLocationPage(location_id: id),
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              height: 60,
              width: 60,
              decoration: BoxDecoration(
                color: colorsecundario,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.location_on, size: 30, color: colorWhite),
            ),

            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    street,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: colorsecundario,
                    ),
                  ),
                  Text(
                    '${neighborhood} ${state} ${city}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.surface,
                    ),
                  ),
                  Text(
                    references,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.surface,
                    ),
                  ),
                ],
              ),
            ),

            InkWell(
              onTap: () {
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //     builder: (context) => ViewUbicacionPage(id_ubicacion: id),
                //   ),
                // );
              },
              child: Icon(
                Icons.arrow_forward_ios,
                size: 20,
                color: colorsecundario,
              ),
            ),
          ],
        ),
      ),
    ).animate().fade(duration: 300.ms).slideX(begin: -0.2);
  }
}
