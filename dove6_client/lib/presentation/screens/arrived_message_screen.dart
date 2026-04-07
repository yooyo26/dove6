// Arrived message screen — brief centered arrival confirmation
import 'package:flutter/material.dart';
import '../../domain/display_data.dart';
import '_shared.dart';

class ArrivedMessageScreen extends StatelessWidget {
  final DisplayData data;
  const ArrivedMessageScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return ScreenScaffold(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.location_on_rounded,
              color: kAccent,
              size: 56,
            ),
            const SizedBox(height: 24),
            const Text(
              'Arrived at',
              style: TextStyle(
                color: kSecondary,
                fontSize: 22,
                fontWeight: FontWeight.w300,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              data.currentStation,
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
