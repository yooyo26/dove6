// Arriving screen — shows approach to next station with progress indicators
import 'package:flutter/material.dart';
import '../../domain/display_data.dart';
import '_shared.dart';

class ArrivingScreen extends StatelessWidget {
  final DisplayData data;
  final bool isArabic;

  const ArrivingScreen({
    super.key,
    required this.data,
    required this.isArabic,
  });

  @override
  Widget build(BuildContext context) {
    final int curIdx = data.currentStationIdx;
    final String nxtFr = data.nextStation?.nameFr ?? '';
    final String nxtAr = data.nextStation?.nameAr ?? '';

    final List<String> stationNames = data.stations
        .map((s) => isArabic ? s.nameAr : s.nameFr)
        .toList();

    return ScreenScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              TrainIdChip(trainId: data.trainId),
              const Spacer(),
              Text(
                '${data.speedKmh.toStringAsFixed(0)} km/h',
                style: const TextStyle(color: kSecondary, fontSize: 14),
              ),
              const SizedBox(width: 12),
              AudioSyncBadge(isArabic: isArabic),
            ],
          ),
          const Spacer(),
          Text(
            isArabic ? 'الوصول إلى' : 'ARRIVÉE À',
            style: const TextStyle(
              color: kSecondary,
              fontSize: 22,
              fontWeight: FontWeight.w300,
            ),
          ),
          const SizedBox(height: 4),
          isArabic
              ? Directionality(
                  textDirection: TextDirection.rtl,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      nxtAr,
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        color: kAccent,
                        fontSize: 52,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -1,
                      ),
                    ),
                  ),
                )
              : Text(
                  nxtFr,
                  style: const TextStyle(
                    color: kAccent,
                    fontSize: 52,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -1,
                  ),
                ),
          const SizedBox(height: 40),
          SizedBox(
            height: 60,
            child: CustomPaint(
              painter: RouteProgressPainter(
                stations:            stationNames,
                progress:            data.routeProgress,
                currentStationIndex: curIdx,
              ),
              size: Size.infinite,
            ),
          ),
          const Spacer(),
          Text(
            isArabic ? 'الوجهة النهائية' : 'DESTINATION FINALE',
            style: TextStyle(
              color: kSecondary,
              fontSize: 13,
              letterSpacing: isArabic ? 0 : 3,
            ),
          ),
          const SizedBox(height: 4),
          isArabic
              ? Directionality(
                  textDirection: TextDirection.rtl,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      data.destinationAr,
                      textAlign: TextAlign.right,
                      style: const TextStyle(color: kSecondary, fontSize: 18),
                    ),
                  ),
                )
              : Text(
                  data.destinationFr,
                  style: const TextStyle(color: kSecondary, fontSize: 18),
                ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
