import 'dart:math';
import 'package:flutter/material.dart';
import 'package:gixt/components/colors.dart';

class Radar extends StatefulWidget {
  const Radar({super.key});

  @override
  State<Radar> createState() => _RadarState();
}

class _RadarState extends State<Radar> with TickerProviderStateMixin {

  late AnimationController _pulseController;
  late AnimationController _ripple1Controller;
  late AnimationController _ripple2Controller;
  late AnimationController _ripple3Controller;

  @override
  void initState() {
    super.initState();

    // círculo central que late
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    // ondas
    _ripple1Controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    _ripple2Controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    _ripple3Controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    // delay entre ondas
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) _ripple2Controller.value = 0.3;
    });

    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) _ripple3Controller.value = 0.6;
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _ripple1Controller.dispose();
    _ripple2Controller.dispose();
    _ripple3Controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      height: 300,
      child: Stack(
        alignment: Alignment.center,
        children: [

          AnimatedBuilder(
            animation: _ripple1Controller,
            builder: (_, __) {
              final v = _ripple1Controller.value;
              return Container(
                width: 60 + (240 * v),
                height: 60 + (240 * v),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colorsecundario.withOpacity((1 - v) * 0.12),
                  border: Border.all(
                    color: colorsecundario.withOpacity((1 - v) * 0.5),
                    width: 1.5,
                  ),
                ),
              );
            },
          ),

          AnimatedBuilder(
            animation: _ripple2Controller,
            builder: (_, __) {
              final v = _ripple2Controller.value;
              return Container(
                width: 60 + (240 * v),
                height: 60 + (240 * v),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colorsecundario.withOpacity((1 - v) * 0.12),
                  border: Border.all(
                    color: colorsecundario.withOpacity((1 - v) * 0.5),
                    width: 1.5,
                  ),
                ),
              );
            },
          ),

          AnimatedBuilder(
            animation: _ripple3Controller,
            builder: (_, __) {
              final v = _ripple3Controller.value;
              return Container(
                width: 60 + (240 * v),
                height: 60 + (240 * v),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colorsecundario.withOpacity((1 - v) * 0.12),
                  border: Border.all(
                    color: colorsecundario.withOpacity((1 - v) * 0.5),
                    width: 1.5,
                  ),
                ),
              );
            },
          ),

        ],
      ),
    );
  }
}