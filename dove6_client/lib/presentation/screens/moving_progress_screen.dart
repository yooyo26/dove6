import 'package:flutter/material.dart';
import '../../domain/display_data.dart';
import '_shared.dart';

class MovingProgressScreen extends StatelessWidget {
  final DisplayData data;
  final bool isArabic;

  const MovingProgressScreen({
    super.key,
    required this.data,
    required this.isArabic,
  });

  @override
  Widget build(BuildContext context) {
    final int curIdx = data.routeStations
        .indexOf(data.currentStation)
        .clamp(0, data.routeStations.length - 1);

    final int total = data.routeStations.length;

    return ScreenScaffold(
      child: Column(
        children: [
          SharedHeader(data: data, isArabic: isArabic),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  // Top info row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Direction → ${data.destinationFr}',
                              style: pisContextLabel(color: kSecondary),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Directionality(
                              textDirection: TextDirection.rtl,
                              child: Text(
                                data.destinationAr,
                                style: pisArabicMedium(color: kDim),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),
                      Text(
                        '${data.speedKmh.round()} km/h',
                        style: pisContextLabel(color: kSecondary),
                      ),
                    ],
                  ),

                  const SizedBox(height: 34),

                  // Progress bar
                  SizedBox(
                    height: 100,
                    child: CustomPaint(
                      painter: RouteProgressPainter(
                        stations: data.routeStations,
                        progress: data.routeProgress,
                        currentStationIndex: curIdx,
                        isArabic: false,
                      ),
                      size: Size.infinite,
                    ),
                  ),

                  const SizedBox(height: 36),

                  // Current / next information block
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 22,
                    ),
                    decoration: BoxDecoration(
                      color: kSurface.withOpacity(0.28),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: kBorder, width: 1),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Current station
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'DÉPART',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: kSecondary,
                                  letterSpacing: 2,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                data.routeStations.first,
                                style: pisStationCallout(color: kPrimary),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 20),

                        // Counter
                        Padding(
                          padding: const EdgeInsets.only(top: 30),
                          child: RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: '${curIdx + 1}',
                                  style: const TextStyle(
                                    color: kAccent,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const TextSpan(
                                  text: ' / ',
                                  style: TextStyle(
                                    color: kSecondary,
                                    fontSize: 14,
                                  ),
                                ),
                                TextSpan(
                                  text: '$total',
                                  style: const TextStyle(
                                    color: kSecondary,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(width: 20),

                        // Next station
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text(
                                'PROCHAIN ARRÊT',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: kSecondary,
                                  letterSpacing: 2,
                                ),
                                textAlign: TextAlign.right,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                data.nextStationFr,
                                style: pisStationCallout(color: kAccent),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.right,
                              ),
                              const SizedBox(height: 6),
                              Directionality(
                                textDirection: TextDirection.rtl,
                                child: Text(
                                  data.nextStationAr,
                                  style: pisArabicMedium(color: kDim),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.right,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}