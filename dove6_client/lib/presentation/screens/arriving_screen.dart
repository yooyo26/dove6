import 'package:flutter/material.dart';
import '../../domain/display_data.dart';
import '_shared.dart';

class ArrivingScreen extends StatelessWidget {
  final DisplayData data;
  final bool isArabic;

  const ArrivingScreen({
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
                  Container(width: 48, height: 2, color: kAccent),
                  const SizedBox(height: 12),
                  const Text(
                    'ARRIVÉE · الوصول',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: kSecondary,
                      letterSpacing: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Container(width: 48, height: 2, color: kAccent),
                  const SizedBox(height: 16),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      data.nextStationFr,
                      style: pisStationHero(color: kPrimary),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Directionality(
                    textDirection: TextDirection.rtl,
                    child: Text(
                      data.nextStationAr,
                      style: pisArabicLarge(color: kDim),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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