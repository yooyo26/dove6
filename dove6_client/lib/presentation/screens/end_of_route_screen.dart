// End of route screen — terminus identity, thank-you message, full route progress
import 'package:flutter/material.dart';
import '../../domain/display_data.dart';
import '_shared.dart';

class EndOfRouteScreen extends StatelessWidget {
  final DisplayData data;
  final bool isArabic;

  const EndOfRouteScreen({super.key, required this.data, required this.isArabic});

  @override
  Widget build(BuildContext context) {
    final int lastIdx = data.routeStations.length - 1;

    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: Column(
          children: [
            SharedHeader(data: data, isArabic: isArabic),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Spacer(),

                  // ── Context label ─────────────────────────────────────────
                  Directionality(
                    textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
                    child: Text(
                      isArabic
                          ? 'المحطة النهائية · Terminus'
                          : 'Terminus · المحطة النهائية',
                      style: pisContextLabel(color: kSecondary),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── Destination name (primary language) ───────────────────
                  Directionality(
                    textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
                    child: Text(
                      isArabic ? data.destinationAr : data.destinationFr,
                      style: pisStationHero(color: kPrimary),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ── Destination name (secondary language) ─────────────────
                  Directionality(
                    textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
                    child: Text(
                      isArabic ? data.destinationFr : data.destinationAr,
                      style: pisArabicLarge(color: kDim),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── Thank-you message ─────────────────────────────────────
                  Directionality(
                    textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
                    child: Text(
                      isArabic
                          ? 'شكراً لسفركم مع المكتب الوطني للسكك الحديدية'
                          : 'Merci de votre voyage avec l\'ONCF',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w400,
                        color: kSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ── Luggage reminder (always Arabic) ─────────────────────
                  const Directionality(
                    textDirection: TextDirection.rtl,
                    child: Text(
                      'المرجو التأكد من عدم نسيان أمتعتكم',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                        color: kDim,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const Spacer(),

                  // ── Full route progress — all dots orange ─────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: SizedBox(
                      height: 90,
                      child: CustomPaint(
                        painter: RouteProgressPainter(
                          stations: data.routeStations,
                          progress: 1.0,
                          currentStationIndex: lastIdx,
                          isArabic: isArabic,
                        ),
                        size: Size.infinite,
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
