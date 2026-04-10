// Route selected screen — shown when conductor selects route
// Simple, clean, institutional — shows origin and destination only
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
    final String originName = isArabic
        ? (data.currentStation?.nameAr ?? '')
        : (data.currentStation?.nameFr ?? '');
    final String destName = isArabic ? data.destinationAr : data.destinationFr;
    final String departLabel  = isArabic ? 'المغادرة' : 'Départ';
    final String destLabel    = isArabic ? 'الوجهة' : 'Destination';
    final String statusLabel  = isArabic ? 'تم اختيار المسار' : 'ITINÉRAIRE SÉLECTIONNÉ';
    final String prepLabel    = isArabic ? 'جارٍ الاستعداد للمغادرة...' : 'Préparation au départ...';
    final String oncfLabel    = isArabic
        ? 'المكتب الوطني للسكك الحديدية'
        : 'OFFICE NATIONAL DES CHEMINS DE FER';

    return ScreenScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ── Top row ──────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.trainId,
                    style: const TextStyle(
                      color: kPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Z2M · ONCF',
                    style: TextStyle(
                      color: kSecondary,
                      fontSize: 11,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                decoration: BoxDecoration(
                  color: kSurface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: kBorder),
                ),
                child: Text(
                  statusLabel,
                  style: const TextStyle(
                    color: kSecondary,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ],
          ),

          const Spacer(),

          // ── Center row — origin → destination ────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [

              // Origin
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    departLabel,
                    style: const TextStyle(
                      color: kSecondary,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 3,
                    ),
                  ),
                  const SizedBox(height: 10),
                  isArabic
                    ? Directionality(
                        textDirection: TextDirection.rtl,
                        child: Text(
                          originName,
                          style: const TextStyle(
                            color: kPrimary,
                            fontSize: 52,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -1,
                            height: 1,
                          ),
                        ),
                      )
                    : Text(
                        originName,
                        style: const TextStyle(
                          color: kPrimary,
                          fontSize: 52,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -1,
                          height: 1,
                        ),
                      ),
                ],
              ),

              // Arrow separator
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(width: 2, height: 28, color: kBorder),
                  const SizedBox(height: 6),
                  const Icon(Icons.arrow_forward_rounded, color: kAccent, size: 22),
                  const SizedBox(height: 6),
                  Container(width: 2, height: 28, color: kBorder),
                ],
              ),

              // Destination
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    destLabel,
                    style: const TextStyle(
                      color: kSecondary,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 3,
                    ),
                  ),
                  const SizedBox(height: 10),
                  isArabic
                    ? Directionality(
                        textDirection: TextDirection.rtl,
                        child: Text(
                          destName,
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                            color: kAccent,
                            fontSize: 52,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -1,
                            height: 1,
                          ),
                        ),
                      )
                    : Text(
                        destName,
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          color: kAccent,
                          fontSize: 52,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -1,
                          height: 1,
                        ),
                      ),
                ],
              ),

            ],
          ),

          const Spacer(),

          // ── Bottom row ───────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                prepLabel,
                style: const TextStyle(
                  color: kSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w300,
                  fontStyle: FontStyle.italic,
                ),
              ),
              Text(
                oncfLabel,
                textAlign: TextAlign.right,
                style: const TextStyle(
                  color: kDim,
                  fontSize: 9,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
