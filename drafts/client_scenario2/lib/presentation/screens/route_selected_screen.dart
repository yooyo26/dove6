// Route selected screen — shows origin, destination, and all route stations
import 'package:flutter/material.dart';
import '../../domain/display_data.dart';
import '../../domain/language.dart';
import '_shared.dart';

class RouteSelectedScreen extends StatelessWidget {
  final DisplayData data;
  final bool isArabic;

  const RouteSelectedScreen({
    super.key,
    required this.data,
    required this.isArabic,
  });

  @override
  Widget build(BuildContext context) {
    final lang = isArabic ? DisplayLanguage.ar : DisplayLanguage.fr;
    final stations = data.routeStationsIn(lang);

    return ScreenScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            TrainIdChip(trainId: data.trainId),
            const Spacer(),
            AudioSyncBadge(activeAudioLang: data.activeAudioLang),
          ]),
          const Spacer(),
          Text(
            isArabic ? 'المسار' : 'ITINÉRAIRE',
            style: const TextStyle(
              color: kSecondary,
              fontSize: 13,
              letterSpacing: 4,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: isArabic
                    ? Directionality(
                        textDirection: TextDirection.rtl,
                        child: Text(
                          data.currentStationAr,
                          style: const TextStyle(
                            color: kPrimary,
                            fontSize: 28,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                    : Text(
                        data.currentStationFr,
                        style: const TextStyle(
                          color: kPrimary,
                          fontSize: 28,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Icon(Icons.arrow_forward_rounded, color: kAccent, size: 28),
              ),
              Expanded(
                child: isArabic
                    ? Directionality(
                        textDirection: TextDirection.rtl,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            data.destinationAr,
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                              color: kAccent,
                              fontSize: 28,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      )
                    : Text(
                        data.destinationFr,
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          color: kAccent,
                          fontSize: 28,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: kCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: kBorder),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: stations.map((s) {
                final isFirst = s == stations.first;
                final isLast = s == stations.last;
                return isArabic
                    ? Directionality(
                        textDirection: TextDirection.rtl,
                        child: Text(
                          s,
                          style: TextStyle(
                            color: isFirst || isLast ? kAccent : kSecondary,
                            fontSize: 13,
                            fontWeight: isFirst || isLast
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                        ),
                      )
                    : Text(
                        s,
                        style: TextStyle(
                          color: isFirst || isLast ? kAccent : kSecondary,
                          fontSize: 13,
                          fontWeight: isFirst || isLast
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      );
              }).toList(),
            ),
          ),
          const Spacer(),
          isArabic
              ? Directionality(
                  textDirection: TextDirection.rtl,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'الاستعداد للمغادرة',
                      style: const TextStyle(
                        color: kSecondary,
                        fontSize: 16,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ),
                )
              : const Text(
                  'Préparation au départ',
                  style: TextStyle(
                    color: kSecondary,
                    fontSize: 16,
                    fontWeight: FontWeight.w300,
                  ),
                ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
