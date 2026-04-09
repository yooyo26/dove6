// Station screen — shows current stop, next stop, and route progress
import 'package:flutter/material.dart';
import '../../domain/display_data.dart';
import '_shared.dart';

class StationScreen extends StatelessWidget {
  final DisplayData data;
  final bool isArabic;

  const StationScreen({super.key, required this.data, required this.isArabic});

  @override
  Widget build(BuildContext context) {
    final bool hasRoute = data.routeStations.isNotEmpty;
    final bool isFinal = hasRoute && data.currentStation == data.destination;
    final int curIdx = hasRoute
        ? data.routeStations.indexOf(data.currentStation).clamp(0, data.routeStations.length - 1)
        : 0;

    return ScreenScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              TrainIdChip(trainId: data.trainId),
              if (!isFinal) ...[
                const SizedBox(width: 12),
                Text(
                  isArabic ? 'متوقف' : 'ARRÊTÉ',
                  style: const TextStyle(
                    color: kSecondary,
                    fontSize: 13,
                    letterSpacing: 2,
                  ),
                ),
              ],
              const Spacer(),
              AudioSyncBadge(activeAudioLang: data.activeAudioLang),
            ],
          ),
          const Spacer(),
          Text(
            isArabic ? 'المحطة الحالية' : 'ARRÊT ACTUEL',
            style: TextStyle(
              color: kSecondary,
              fontSize: 13,
              letterSpacing: isArabic ? 0 : 3,
            ),
          ),
          const SizedBox(height: 8),
          isArabic
              ? Directionality(
                  textDirection: TextDirection.rtl,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      data.currentStationAr,
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        color: kPrimary,
                        fontSize: 48,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                )
              : Text(
                  data.currentStationFr,
                  style: const TextStyle(
                    color: kPrimary,
                    fontSize: 48,
                    fontWeight: FontWeight.w700,
                  ),
                ),
          const KDivider(),
          if (!isFinal) ...[
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
          ] else
            isArabic
                ? Directionality(
                    textDirection: TextDirection.rtl,
                    child: Text(
                      'تم الوصول إلى المحطة النهائية',
                      style: const TextStyle(color: kAccent, fontSize: 20),
                    ),
                  )
                : const Text(
                    'Destination finale atteinte',
                    style: TextStyle(color: kAccent, fontSize: 20),
                  ),
          const Spacer(),
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
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
