// Moving (speed phase) screen — large speed readout
import 'package:flutter/material.dart';
import '../../domain/display_data.dart';
import '_shared.dart';

class MovingSpeedScreen extends StatelessWidget {
  final DisplayData data;
  final bool isArabic;

  const MovingSpeedScreen({
    super.key,
    required this.data,
    required this.isArabic,
  });

  @override
  Widget build(BuildContext context) {
    final String nxtFr = data.nextStation?.nameFr ?? '';
    final String nxtAr = data.nextStation?.nameAr ?? '';

    return ScreenScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              TrainIdChip(trainId: data.trainId),
              const Spacer(),
              Text(
                isArabic ? data.destinationAr : data.destinationFr,
                style: const TextStyle(color: kSecondary, fontSize: 14),
              ),
              const SizedBox(width: 12),
              AudioSyncBadge(isArabic: isArabic),
            ],
          ),
          const Spacer(),
          Center(
            child: Text(
              data.speedKmh.toStringAsFixed(0),
              style: const TextStyle(
                color: kAccentGold,
                fontSize: 130,
                fontWeight: FontWeight.w200,
                letterSpacing: -4,
                height: 1,
              ),
            ),
          ),
          const Center(
            child: Text(
              'km/h',
              style: TextStyle(
                color: kSecondary,
                fontSize: 22,
                fontWeight: FontWeight.w300,
                letterSpacing: 4,
              ),
            ),
          ),
          const Spacer(),
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
                      nxtAr,
                      style: const TextStyle(
                        color: kAccent,
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                )
              : Text(
                  nxtFr,
                  style: const TextStyle(
                    color: kAccent,
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
