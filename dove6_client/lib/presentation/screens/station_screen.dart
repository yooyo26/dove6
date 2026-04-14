import 'package:flutter/material.dart';
import '../../domain/display_data.dart';
import '_shared.dart';

class StationScreen extends StatelessWidget {
  final DisplayData data;
  final bool isArabic;

  const StationScreen({
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
                  const Text(
                    'GARE ACTUELLE · المحطة الحالية',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: kSecondary,
                      letterSpacing: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      data.currentStationFr,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: pisStationHero(color: kPrimary),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Directionality(
                    textDirection: TextDirection.rtl,
                    child: Text(
                      data.currentStationAr,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: pisArabicLarge(color: kDim),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 36),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 18,
                    ),
                    decoration: BoxDecoration(
                      color: kSurface.withOpacity(0.35),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Direction',
                          style: pisContextLabel(color: kSecondary),
                        ),
                        const SizedBox(width: 14),
                        const Icon(
                          Icons.arrow_forward_rounded,
                          color: kAccent,
                          size: 24,
                        ),
                        const SizedBox(width: 14),
                        Text(
                          data.destinationFr,
                          style: pisDirectionName(color: kAccent),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Directionality(
                    textDirection: TextDirection.rtl,
                    child: Text(
                      data.destinationAr,
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