// Arrived message screen — brief centered arrival confirmation
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
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.location_on_rounded, color: kAccent, size: 56),
            const SizedBox(height: 24),
            Text(
              isArabic ? 'وصلنا إلى' : 'ARRIVÉE À',
              style: const TextStyle(
                color: kSecondary,
                fontSize: 22,
                fontWeight: FontWeight.w300,
              ),
            ),
            const SizedBox(height: 8),
            isArabic
                ? Directionality(
                    textDirection: TextDirection.rtl,
                    child: Text(
                      data.currentStationAr,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: kPrimary,
                        fontSize: 46,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -1,
                      ),
                    ),
                  )
                : Text(
                    data.currentStationFr,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: kPrimary,
                      fontSize: 46,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -1,
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
