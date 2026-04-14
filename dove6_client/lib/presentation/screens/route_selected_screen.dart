// Route selected screen — origin/destination layout with bilingual labels
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
    final destFr    = data.destinationFr;
    final destAr    = data.destinationAr;

    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: Column(
          children: [
            SharedHeader(data: data, isArabic: isArabic),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Directionality(
                    textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
                    child: Text(
                      isArabic ? 'المسار · Itinéraire' : 'Itinéraire · المسار',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: kSecondary,
                        letterSpacing: 2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // ── Left: origin ──────────────────────────────────────
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              isArabic ? currentAr : currentFr,
                              style: const TextStyle(
                                fontSize: 60,
                                fontWeight: FontWeight.w700,
                                color: kPrimary,
                              ),
                              textAlign: TextAlign.right,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Directionality(
                              textDirection: TextDirection.rtl,
                              child: Text(
                                isArabic ? currentFr : currentAr,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w500,
                                  color: kDim,
                                ),
                                textAlign: TextAlign.right,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // ── Center: connector ─────────────────────────────────
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24),
                        child: RouteConnector(),
                      ),
                      // ── Right: destination ────────────────────────────────
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isArabic ? destAr : destFr,
                              style: const TextStyle(
                                fontSize: 60,
                                fontWeight: FontWeight.w700,
                                color: kAccent,
                              ),
                              textAlign: TextAlign.left,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Directionality(
                              textDirection: TextDirection.rtl,
                              child: Text(
                                isArabic ? destFr : destAr,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w500,
                                  color: kDim,
                                ),
                                textAlign: TextAlign.left,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: Text(
                      '${data.routeStations.length} arrêts · ${data.routeStations.length} محطة',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w500,
                        color: kSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
