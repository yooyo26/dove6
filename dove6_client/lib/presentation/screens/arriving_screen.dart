// Arriving screen — destination station name, fully centered with accent dividers
import 'package:flutter/material.dart';
import '../../domain/display_data.dart';
import '_shared.dart';

class ArrivingScreen extends StatelessWidget {
  final DisplayData data;
  final bool isArabic;

  const ArrivingScreen({super.key, required this.data, required this.isArabic});

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
                  // ── Top accent divider ────────────────────────────────────
                  Container(width: 48, height: 2, color: kAccent),

                  const SizedBox(height: 12),

                  // ── Context label ─────────────────────────────────────────
                  Directionality(
                    textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
                    child: Text(
                      isArabic ? 'الوصول · ARRIVÉE' : 'ARRIVÉE · الوصول',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: kSecondary,
                        letterSpacing: 2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ── Bottom accent divider ─────────────────────────────────
                  Container(width: 48, height: 2, color: kAccent),

                  const SizedBox(height: 16),

                  // ── Station name (primary language) ───────────────────────
                  Directionality(
                    textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
                    child: Text(
                      isArabic ? data.nextStationAr : data.nextStationFr,
                      style: const TextStyle(
                        fontSize: 88,
                        fontWeight: FontWeight.w700,
                        color: kPrimary,
                      ),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ── Station name (secondary language) ─────────────────────
                  Directionality(
                    textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
                    child: Text(
                      isArabic ? data.nextStationFr : data.nextStationAr,
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w500,
                        color: kDim,
                      ),
                      textAlign: TextAlign.center,
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
