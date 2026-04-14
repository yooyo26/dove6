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
        children: [
          SharedHeader(data: data, isArabic: isArabic),
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Départ · المغادرة',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: kSecondary,
                      letterSpacing: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      data.currentStationFr,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 80,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.8,
                        height: 1.1,
                        color: kPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 12),
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
                  const SizedBox(height: 40),
                  const Text(
                    'Prochain arrêt',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: kSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
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