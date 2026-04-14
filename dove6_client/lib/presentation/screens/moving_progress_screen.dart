// Moving (progress phase) screen — route map, current/next stop, station counter
import 'package:flutter/material.dart';
import '../../domain/display_data.dart';
import '_shared.dart';

class MovingProgressScreen extends StatelessWidget {
  final DisplayData data;
  final bool isArabic;

  const MovingProgressScreen({super.key, required this.data, required this.isArabic});

  @override
  Widget build(BuildContext context) {
    final int curIdx = data.routeStations
        .indexOf(data.currentStation)
        .clamp(0, data.routeStations.length - 1);
    final int total = data.routeStations.length;

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
                  const SizedBox(height: 20),

                  // ── Direction row ─────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Directionality(
                          textDirection: isArabic
                              ? TextDirection.rtl
                              : TextDirection.ltr,
                          child: Text(
                            isArabic
                                ? 'الاتجاه ← ${data.destinationAr}'
                                : 'Direction → ${data.destinationFr}',
                            style: const TextStyle(
                              fontSize: 18,
                              color: kSecondary,
                            ),
                          ),
                        ),
                        Text(
                          '${data.speedKmh.round()} km/h',
                          style: const TextStyle(
                            fontSize: 16,
                            color: kSecondary,
                          ),
                        ),
                      ],
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

                  const SizedBox(height: 20),

                  const Divider(color: kBorder, thickness: 1),

                  const SizedBox(height: 20),

                  // ── Current / next stop row ───────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left: current station
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Directionality(
                                textDirection: isArabic
                                    ? TextDirection.rtl
                                    : TextDirection.ltr,
                                child: Text(
                                  isArabic ? 'المحطة الحالية' : 'ARRÊT ACTUEL',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: kSecondary,
                                    letterSpacing: 2,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Directionality(
                                textDirection: isArabic
                                    ? TextDirection.rtl
                                    : TextDirection.ltr,
                                child: Text(
                                  isArabic
                                      ? data.currentStationAr
                                      : data.currentStationFr,
                                  style: const TextStyle(
                                    fontSize: 36,
                                    fontWeight: FontWeight.w700,
                                    color: kPrimary,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Right: next station
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Directionality(
                                textDirection: isArabic
                                    ? TextDirection.rtl
                                    : TextDirection.ltr,
                                child: Text(
                                  isArabic ? 'المحطة القادمة' : 'PROCHAIN ARRÊT',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: kSecondary,
                                    letterSpacing: 2,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Directionality(
                                textDirection: isArabic
                                    ? TextDirection.rtl
                                    : TextDirection.ltr,
                                child: Text(
                                  isArabic
                                      ? data.nextStationAr
                                      : data.nextStationFr,
                                  style: const TextStyle(
                                    fontSize: 36,
                                    fontWeight: FontWeight.w700,
                                    color: kAccent,
                                  ),
                                  textAlign: TextAlign.right,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ── Station counter ───────────────────────────────────────
                  Center(
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '${curIdx + 1}',
                            style: const TextStyle(
                              color: kAccent,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          TextSpan(
                            text: ' / $total stations',
                            style: const TextStyle(
                              color: kSecondary,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const Spacer(),

                  // ── Anchor labels (first / last station) ──────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Directionality(
                          textDirection: isArabic
                              ? TextDirection.rtl
                              : TextDirection.ltr,
                          child: Text(
                            data.routeStations.first,
                            style: const TextStyle(
                              fontSize: 10,
                              color: kDim,
                            ),
                          ),
                        ),
                        Directionality(
                          textDirection: isArabic
                              ? TextDirection.rtl
                              : TextDirection.ltr,
                          child: Text(
                            data.routeStations.last,
                            style: const TextStyle(
                              fontSize: 10,
                              color: kDim,
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
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
