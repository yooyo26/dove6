// Idle state screen — ONCF logo, subtitle, and bilingual welcome message
import 'package:flutter/material.dart';
import '../../domain/display_data.dart';
import '_shared.dart';

class IdleScreen extends StatelessWidget {
  final DisplayData data;
  final bool isArabic;

  const IdleScreen({super.key, required this.data, required this.isArabic});

  @override
  Widget build(BuildContext context) {
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
                  Image.asset(
                    'assets/images/Logo-oncf.png',
                    height: 112,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'OFFICE NATIONAL DES CHEMINS DE FER',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: kSecondary,
                      letterSpacing: 3,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  isArabic
                    ? const Directionality(
                        textDirection: TextDirection.rtl,
                        child: Text(
                          'مرحباً بكم',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w400,
                            color: kDim,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      )
                    : const Text(
                        'Bienvenue · مرحباً بكم',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w400,
                          color: kDim,
                        ),
                        textAlign: TextAlign.center,
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
