// Station screen — current stop identity, direction callout, and route map
import 'package:flutter/material.dart';
import '../../domain/display_data.dart';
import '_shared.dart';

class StationScreen extends StatelessWidget {
  final DisplayData data;
  final bool isArabic;

  const StationScreen({super.key, required this.data, required this.isArabic});

  @override
  Widget build(BuildContext context) {
    final int curIdx = data.routeStations
        .indexOf(data.currentStation)
        .clamp(0, data.routeStations.length - 1);

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
                  const SizedBox(height: 16),

                  // ── Context label ─────────────────────────────────────────
                  Directionality(
                    textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
                    child: Text(
                      isArabic
                          ? 'المحطة الحالية · Gare actuelle'
                          : 'Gare actuelle · المحطة الحالية',
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
                        fontSize: 96,
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
                      isArabic ? data.currentStationFr : data.currentStationAr,
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w500,
                        color: kDim,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // ── Direction callout card ────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 16),
                      decoration: BoxDecoration(
                        color: kSurface,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Directionality(
                            textDirection: isArabic
                                ? TextDirection.rtl
                                : TextDirection.ltr,
                            child: Text(
                              isArabic ? 'الاتجاه' : 'Direction',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w500,
                                color: kSecondary,
                              ),
                            ),
                          ),
                          const Row(
                            children: [
                              Icon(Icons.arrow_forward_rounded,
                                  color: kAccent, size: 20),
                              Icon(Icons.arrow_forward_rounded,
                                  color: kAccent, size: 20),
                              Icon(Icons.arrow_forward_rounded,
                                  color: kAccent, size: 20),
                            ],
                          ),
                          Flexible(
                            child: Text(
                              isArabic ? data.destinationAr : data.destinationFr,
                              style: const TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.w700,
                                color: kAccent,
                              ),
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.right,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // ── Route progress painter ────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: SizedBox(
                      height: 90,
                      child: CustomPaint(
                        painter: RouteProgressPainter(
                          stations: data.routeStations,
                          progress: data.routeProgress,
                          currentStationIndex: curIdx,
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
