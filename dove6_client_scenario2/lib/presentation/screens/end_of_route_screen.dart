// End of route screen — thank you message with full route progress
import 'package:flutter/material.dart';
import '../../domain/display_data.dart';
import '_shared.dart';

class EndOfRouteScreen extends StatelessWidget {
  final DisplayData data;
  final bool isArabic;

  const EndOfRouteScreen({
    super.key,
    required this.data,
    required this.isArabic,
  });

  @override
  Widget build(BuildContext context) {
    final int lastIndex = data.routeStations.length - 1;

    return ScreenScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              TrainIdChip(trainId: data.trainId),
              const Spacer(),
              AudioSyncBadge(activeAudioLang: data.activeAudioLang),
            ],
          ),
          const Spacer(),
          isArabic
              ? Directionality(
                  textDirection: TextDirection.rtl,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'شكراً لسفركم معنا.',
                      style: const TextStyle(
                        color: kPrimary,
                        fontSize: 46,
                        fontWeight: FontWeight.w300,
                        height: 1.2,
                      ),
                    ),
                  ),
                )
              : const Text(
                  'Merci de voyager\navec nous.',
                  style: TextStyle(
                    color: kPrimary,
                    fontSize: 46,
                    fontWeight: FontWeight.w300,
                    height: 1.2,
                  ),
                ),
          const SizedBox(height: 24),
          Text(
            isArabic ? 'المحطة النهائية' : 'TERMINUS',
            style: TextStyle(
              color: kSecondary,
              fontSize: 16,
              letterSpacing: isArabic ? 0 : 2,
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
                      style: const TextStyle(
                        color: kAccent,
                        fontSize: 22,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                )
              : Text(
                  'Terminal — ${data.destinationFr}',
                  style: const TextStyle(
                    color: kAccent,
                    fontSize: 22,
                    fontWeight: FontWeight.w500,
                  ),
                ),
          const SizedBox(height: 12),
          const Spacer(),
          SizedBox(
            height: 60,
            child: CustomPaint(
              painter: RouteProgressPainter(
                progress: 1.0,
                currentStationIndex: lastIndex < 0 ? 0 : lastIndex,
                stations: data.routeStations,
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
