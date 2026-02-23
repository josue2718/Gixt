import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:gixt/components/colors.dart';
import 'package:gixt/roots/BottomNavigationBar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

class RootPage extends StatefulWidget {
  const RootPage({super.key});

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  int _backPressedCount = 0;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _backPressedCount++;
        if (_backPressedCount == 1) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: colorprimario,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              content: Text(
                'Presiona atrás de nuevo para salir',
                style: GoogleFonts.poppins(fontSize: 13, color: colorWhite),
              ),
            ),
          );

          Future.delayed(const Duration(seconds: 2), () {
            setState(() {
              _backPressedCount = 0;
            });
          });
          return Future.value(false);
        } else {
          SystemNavigator.pop();
          return Future.value(true);
        }
      },
      child: KeyboardDismisser(
        child: Scaffold(
          backgroundColor: colorfondo,
          body: const AppBottomNavigation(),
        ),
      ),
    );
  }
}
