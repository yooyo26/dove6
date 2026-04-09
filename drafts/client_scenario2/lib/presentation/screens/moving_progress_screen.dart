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
    final int currentIndex = data.routeStations.indexOf(data.currentStation);
    final int percent = (data.routeProgress * 100).round();

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
                style: const TextStyle(color: kSecondary, fontSize: 16),
              ),
              const SizedBox(width: 12),
              AudioSyncBadge(activeAudioLang: data.activeAudioLang),
            ],
          ),
          const Spacer(),
          Center(
            child: Text(
              '$percent%',
              style: const TextStyle(
                color: kAccent,
                fontSize: 100,
                fontWeight: FontWeight.w200,
                letterSpacing: -2,
                height: 1,
              ),
            ),
          ),
          Center(
            child: Text(
              isArabic ? 'من الرحلة مكتملة' : 'du trajet effectué',
              style: const TextStyle(
                color: kSecondary,
                fontSize: 16,
                letterSpacing: 2,
              ),
            ),
          ),
          const SizedBox(height: 40),
          SizedBox(
            height: 60,
            child: CustomPaint(
              painter: RouteProgressPainter(
                progress: data.routeProgress,
                currentStationIndex: currentIndex < 0 ? 0 : currentIndex,
                stations: data.routeStations,
              ),
              size: Size.infinite,
            ),
          ),
          const KDivider(),
          Text(
            isArabic ? 'المحطة القادمة' : 'PROCHAIN ARRÊT',
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
                      data.nextStationAr,
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        color: kAccent,
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                )
              : Text(
                  data.nextStationFr,
                  style: const TextStyle(
                    color: kAccent,
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                ),
          const SizedBox(height: 16),
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
                      style: const TextStyle(
                        color: kSecondary,
                        fontSize: 18,
                      ),
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
