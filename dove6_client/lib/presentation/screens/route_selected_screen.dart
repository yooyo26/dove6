import 'package:flutter/material.dart';
import '../../domain/display_data.dart';
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
    final currentFr = data.currentStationFr;
    final currentAr = data.currentStationAr;
    final destFr = data.destinationFr;
    final destAr = data.destinationAr;

    return ScreenScaffold(
      child: Column(
        children: [
          SharedHeader(data: data, isArabic: isArabic),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Itinéraire · المسار',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: kSecondary,
                    letterSpacing: 2,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerRight,
                            child: Text(
                              currentFr,
                              style: pisStationPrimary(color: kPrimary),
                              textAlign: TextAlign.right,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Directionality(
                            textDirection: TextDirection.rtl,
                            child: Text(
                              currentAr,
                              style: pisArabicMedium(color: kDim),
                              textAlign: TextAlign.right,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 32),
                      child: RouteConnector(),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              destFr,
                              style: pisStationPrimary(color: kAccent),
                              textAlign: TextAlign.left,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Directionality(
                            textDirection: TextDirection.rtl,
                            child: Text(
                              destAr,
                              style: pisArabicMedium(color: kDim),
                              textAlign: TextAlign.left,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}