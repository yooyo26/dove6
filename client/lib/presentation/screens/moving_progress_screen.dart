// Moving (progress phase) screen — journey progress percentage and route bar
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
    final bool hasRoute = data.routeStations.isNotEmpty;
    final int curIdx = hasRoute
        ? data.routeStations.indexOf(data.currentStation).clamp(0, data.routeStations.length - 1)
        : 0;
    final int stNum   = curIdx + 1;
    final int total   = hasRoute ? data.routeStations.length : 0;
    final int activePd = (data.routeProgress * 5).round().clamp(0, 5);

    final String curStation = isArabic
        ? data.currentStationAr
        : data.currentStationFr;
    final String nxtStation = isArabic
        ? data.nextStationAr
        : data.nextStationFr;
    final String origin = isArabic
        ? (data.routeStationsAr.isEmpty ? '' : data.routeStationsAr.first)
        : (data.routeStationsFr.isEmpty ? '' : data.routeStationsFr.first);
    final String destination = isArabic
        ? (data.routeStationsAr.isEmpty ? '' : data.routeStationsAr.last)
        : (data.routeStationsFr.isEmpty ? '' : data.routeStationsFr.last);
    final String approachLabel = isArabic ? 'اقتراب' : 'Approche';
    final String currentLabel  = isArabic ? 'المحطة الحالية' : 'ARRÊT ACTUEL';
    final String nextLabel     = isArabic ? 'المحطة القادمة' : 'PROCHAIN ARRÊT';
    final String departLabel   = isArabic ? 'المغادرة' : 'Départ';
    final String destLabel     = isArabic ? 'الوجهة النهائية' : 'Destination finale';

    return ScreenScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TrainIdChip(trainId: data.trainId),
              Row(
                children: [
                  Text(
                    '${data.speedKmh.round()} km/h',
                    style: const TextStyle(
                      color: kSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 12),
                  AudioSyncBadge(
                      activeAudioLang: data.activeAudioLang),
                ],
              ),
            ],
          ),

          const SizedBox(height: 32),

          // ── TRACK — all dots, no orange line ──────────────
          SizedBox(
            height: 60,
            child: CustomPaint(
              painter: RouteProgressPainter(
                stations:            data.routeStations,
                progress:            data.routeProgress,
                currentStationIndex: curIdx,
              ),
              size: Size.infinite,
            ),
          ),

          // ── DIVIDER ───────────────────────────────────────
          const SizedBox(height: 20),
          const Divider(color: kBorder, thickness: 1.5, height: 1),
          const SizedBox(height: 20),

          // ── INFO ZONE top row ─────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // LEFT — current station
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currentLabel,
                      style: const TextStyle(
                        color: kSecondary,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    isArabic
                      ? Directionality(
                          textDirection: TextDirection.rtl,
                          child: Text(
                            curStation,
                            style: const TextStyle(
                              color: kPrimary,
                              fontSize: 36,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.5,
                            ),
                          ),
                        )
                      : Text(
                          curStation,
                          style: const TextStyle(
                            color: kPrimary,
                            fontSize: 36,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.5,
                          ),
                        ),
                    const SizedBox(height: 6),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '$stNum',
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
                  ],
                ),
              ),

              // RIGHT — next stop
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      nextLabel,
                      style: const TextStyle(
                        color: kSecondary,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    isArabic
                      ? Directionality(
                          textDirection: TextDirection.rtl,
                          child: Text(
                            nxtStation,
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                              color: kAccent,
                              fontSize: 36,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.5,
                            ),
                          ),
                        )
                      : Text(
                          nxtStation,
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                            color: kAccent,
                            fontSize: 36,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.5,
                          ),
                        ),
                    const SizedBox(height: 6),
                    // Proximity dots
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          approachLabel,
                          style: const TextStyle(
                            color: kSecondary,
                            fontSize: 9,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(width: 6),
                        ...List.generate(5, (i) => Container(
                          width: 7,
                          height: 7,
                          margin: const EdgeInsets.only(left: 4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: i < activePd ? kAccent : kDim,
                          ),
                        )),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const Spacer(),

          // ── BOTTOM ROW — route endpoints ──────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(departLabel,
                      style: const TextStyle(
                          color: kDim, fontSize: 9, letterSpacing: 1.5)),
                  const SizedBox(height: 2),
                  Text(origin,
                      style: const TextStyle(
                          color: kSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w500)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(destLabel,
                      style: const TextStyle(
                          color: kDim, fontSize: 9, letterSpacing: 1.5)),
                  const SizedBox(height: 2),
                  Text(destination,
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                          color: kSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w500)),
                ],
              ),
            ],
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
