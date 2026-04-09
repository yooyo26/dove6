// Departing screen — welcome and next stop info in French or Arabic
import 'package:flutter/material.dart';
import '../../domain/display_data.dart';
import '_shared.dart';

class DepartingScreen extends StatelessWidget {
  final DisplayData data;
  final bool isArabic;

  const DepartingScreen({
    super.key,
    required this.data,
    required this.isArabic,
  });

  @override
  Widget build(BuildContext context) {
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
                      'مرحباً بكم على متن القطار',
                      style: const TextStyle(
                        color: kPrimary,
                        fontSize: 42,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ),
                )
              : const Text(
                  'Bienvenue à bord',
                  style: TextStyle(
                    color: kPrimary,
                    fontSize: 42,
                    fontWeight: FontWeight.w300,
                  ),
                ),
          const SizedBox(height: 8),
          isArabic
              ? Directionality(
                  textDirection: TextDirection.rtl,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'المغادرة من ${data.currentStationAr}',
                      style: const TextStyle(
                        color: kSecondary,
                        fontSize: 20,
                      ),
                    ),
                  ),
                )
              : Text(
                  'Départ de ${data.currentStationFr}',
                  style: const TextStyle(color: kSecondary, fontSize: 20),
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
          const Spacer(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
