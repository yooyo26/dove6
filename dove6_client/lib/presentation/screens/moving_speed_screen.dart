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
    return ScreenScaffold(
      child: Column(
        children: [
          SharedHeader(data: data, isArabic: isArabic),
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ── Speed ───────────────────────────────────────────────
                  Text(
                    '${data.speedKmh.round()}',
                    style: pisMegaDisplay(color: kPrimary).copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'km/h',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w400,
                      color: kSecondary,
                      letterSpacing: 4,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 48),

                  // ── Label ───────────────────────────────────────────────
                  const Text(
                    'Prochain arrêt · المحطة القادمة',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: kSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 10),

                  // ── French (primary) ───────────────────────────────────
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      data.nextStationFr,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: pisStationCallout(color: kAccent),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // ── Arabic (confirmation) ──────────────────────────────
                  Directionality(
                    textDirection: TextDirection.rtl,
                    child: Text(
                      data.nextStationAr,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: pisArabicMedium(color: kDim),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}