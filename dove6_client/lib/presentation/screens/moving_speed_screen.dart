// Moving (speed phase) screen — large speed readout and next stop
import 'package:flutter/material.dart';
import '../../domain/display_data.dart';
import '_shared.dart';

class MovingSpeedScreen extends StatelessWidget {
  final DisplayData data;
  final bool isArabic;

  const MovingSpeedScreen({super.key, required this.data, required this.isArabic});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: Column(
          children: [
            SharedHeader(data: data, isArabic: isArabic),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // ── Speed value ───────────────────────────────────────────
                  Text(
                    '${data.speedKmh.round()}',
                    style: const TextStyle(
                      fontSize: 120,
                      fontWeight: FontWeight.w200,
                      color: kPrimary,
                      letterSpacing: -2,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 8),

                  // ── Unit ──────────────────────────────────────────────────
                  const Text(
                    'km/h',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w400,
                      color: kSecondary,
                      letterSpacing: 4,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 48),

                  // ── Next stop label ───────────────────────────────────────
                  Directionality(
                    textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
                    child: Text(
                      isArabic ? 'المحطة القادمة' : 'Prochain arrêt',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: kSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // ── Next stop name ────────────────────────────────────────
                  Directionality(
                    textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
                    child: Text(
                      isArabic ? data.nextStationAr : data.nextStationFr,
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w700,
                        color: kAccent,
                      ),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
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
}
