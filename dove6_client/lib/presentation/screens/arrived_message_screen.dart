import 'package:flutter/material.dart';
import '../../domain/display_data.dart';
import '_shared.dart';

class ArrivedMessageScreen extends StatelessWidget {
  final DisplayData data;
  final bool isArabic;

  const ArrivedMessageScreen({
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
                    'BIENVENUE · مرحبا',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: kSecondary,
                      letterSpacing: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 16),

                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      data.currentStationFr,
                      style: pisStationHero(color: kAccent),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Directionality(
                    textDirection: TextDirection.rtl,
                    child: Text(
                      data.currentStationAr,
                      style: pisArabicLarge(color: kDim),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  const SizedBox(height: 18),

                  Text(
                    'Bienvenue à ${data.currentStationFr}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w400,
                      color: kSecondary,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 6),

                  Directionality(
                    textDirection: TextDirection.rtl,
                    child: Text(
                      'أهلاً بكم في ${data.currentStationAr}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                        color: kDim,
                      ),
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