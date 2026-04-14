// Arrived message screen — 3-second welcome display after pulling into station
import 'package:flutter/material.dart';
import '../../domain/display_data.dart';
import '_shared.dart';

class ArrivedMessageScreen extends StatelessWidget {
  final DisplayData data;
  final bool isArabic;

  const ArrivedMessageScreen({super.key, required this.data, required this.isArabic});

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
                  // ── Context label ─────────────────────────────────────────
                  Directionality(
                    textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
                    child: Text(
                      isArabic ? 'مرحبا · BIENVENUE' : 'BIENVENUE · مرحبا',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: kSecondary,
                        letterSpacing: 2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── Station name (primary language) ───────────────────────
                  Directionality(
                    textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
                    child: Text(
                      isArabic ? data.currentStationAr : data.currentStationFr,
                      style: const TextStyle(
                        fontSize: 88,
                        fontWeight: FontWeight.w700,
                        color: kAccent,
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
                      isArabic ? data.currentStationFr : data.currentStationAr,
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w500,
                        color: kDim,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── Welcome message ───────────────────────────────────────
                  Directionality(
                    textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
                    child: Text(
                      isArabic
                          ? 'أهلاً بكم في ${data.currentStationAr}'
                          : 'Bienvenue à ${data.currentStationFr} — Bonne continuation',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w400,
                        color: kSecondary,
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
