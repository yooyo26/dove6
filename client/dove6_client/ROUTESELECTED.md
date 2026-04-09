# ROUTESELECTED.md — Route Selected Screen Redesign

## Read this completely before touching any file

You are rebuilding route_selected_screen.dart only.
Do not touch any other file.
Do not touch any other screen.
Do not touch _shared.dart colors or widgets.
Do not touch display_mapper.dart.

---

## WHAT THIS SCREEN LOOKS LIKE

```
┌────────────────────────────────────────────────────┐
│                                                    │
│  DOVE-6                    ITINÉRAIRE SÉLECTIONNÉ  │
│  Z2M · ONCF                                        │
│                                                    │
│                                                    │
│  Départ                              Destination   │
│  Marrakech              →          Tanger Ville    │
│                                                    │
│                                                    │
│  Préparation au départ...    OFFICE NATIONAL DES   │
│                              CHEMINS DE FER        │
└────────────────────────────────────────────────────┘
```

Clean. Minimal. Institutional. Nothing else on this screen.

---

## EXACT LAYOUT SPECIFICATION

### Overall structure
ScreenScaffold wrapping a Column with these sections:
- Top row
- Spacer
- Center row (the main content)
- Spacer
- Bottom row

---

### Top row
Row with MainAxisAlignment.spaceBetween

LEFT side — train identification:
```dart
Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Text(
      data.trainId,
      style: TextStyle(
        color: kPrimary,
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: 2,
      ),
    ),
    SizedBox(height: 4),
    Text(
      'Z2M · ONCF',
      style: TextStyle(
        color: kSecondary,
        fontSize: 11,
        letterSpacing: 1.5,
      ),
    ),
  ],
)
```

RIGHT side — status pill:
```dart
Container(
  padding: EdgeInsets.symmetric(horizontal: 14, vertical: 5),
  decoration: BoxDecoration(
    color: kSurface,
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: kBorder),
  ),
  child: Text(
    isArabic ? 'تم اختيار المسار' : 'ITINÉRAIRE SÉLECTIONNÉ',
    style: TextStyle(
      color: kSecondary,
      fontSize: 10,
      fontWeight: FontWeight.w600,
      letterSpacing: 2,
    ),
  ),
)
```

---

### Center row — the main content
Row with MainAxisAlignment.spaceBetween and
CrossAxisAlignment.center

LEFT block — origin station:
```dart
Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Text(
      isArabic ? 'المغادرة' : 'Départ',
      style: TextStyle(
        color: kSecondary,
        fontSize: 10,
        fontWeight: FontWeight.w600,
        letterSpacing: 3,
      ),
    ),
    SizedBox(height: 10),
    isArabic
      ? Directionality(
          textDirection: TextDirection.rtl,
          child: Text(
            data.currentStationAr,
            style: TextStyle(
              color: kPrimary,
              fontSize: 52,
              fontWeight: FontWeight.w700,
              letterSpacing: -1,
              height: 1,
            ),
          ),
        )
      : Text(
          data.currentStationFr,
          style: TextStyle(
            color: kPrimary,
            fontSize: 52,
            fontWeight: FontWeight.w700,
            letterSpacing: -1,
            height: 1,
          ),
        ),
  ],
)
```

CENTER — arrow separator:
```dart
Column(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    Container(
      width: 2,
      height: 32,
      color: kBorder,
    ),
    SizedBox(height: 6),
    Icon(
      Icons.arrow_forward_rounded,
      color: kAccent,
      size: 24,
    ),
    SizedBox(height: 6),
    Container(
      width: 2,
      height: 32,
      color: kBorder,
    ),
  ],
)
```

RIGHT block — destination station:
```dart
Column(
  crossAxisAlignment: CrossAxisAlignment.end,
  children: [
    Text(
      isArabic ? 'الوجهة' : 'Destination',
      style: TextStyle(
        color: kSecondary,
        fontSize: 10,
        fontWeight: FontWeight.w600,
        letterSpacing: 3,
      ),
    ),
    SizedBox(height: 10),
    isArabic
      ? Directionality(
          textDirection: TextDirection.rtl,
          child: Text(
            data.destinationAr,
            textAlign: TextAlign.right,
            style: TextStyle(
              color: kAccent,
              fontSize: 52,
              fontWeight: FontWeight.w700,
              letterSpacing: -1,
              height: 1,
            ),
          ),
        )
      : Text(
          data.destinationFr,
          textAlign: TextAlign.right,
          style: TextStyle(
            color: kAccent,
            fontSize: 52,
            fontWeight: FontWeight.w700,
            letterSpacing: -1,
            height: 1,
          ),
        ),
  ],
)
```

---

### Bottom row
Row with MainAxisAlignment.spaceBetween and
CrossAxisAlignment.end

LEFT — preparation message:
```dart
Text(
  isArabic ? 'جارٍ الاستعداد للمغادرة...' : 'Préparation au départ...',
  style: TextStyle(
    color: kSecondary,
    fontSize: 14,
    fontWeight: FontWeight.w300,
    fontStyle: FontStyle.italic,
  ),
)
```

RIGHT — ONCF institutional name:
```dart
Text(
  isArabic
    ? 'المكتب الوطني للسكك الحديدية'
    : 'OFFICE NATIONAL DES CHEMINS DE FER',
  textAlign: TextAlign.right,
  style: TextStyle(
    color: kDim,
    fontSize: 9,
    letterSpacing: 1.5,
  ),
)
```

---

## COMPLETE FILE

Replace the entire content of
lib/presentation/screens/route_selected_screen.dart
with this:

```dart
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
        ? data.currentStationAr
        : data.currentStationFr;
    final String destName = isArabic
        ? data.destinationAr
        : data.destinationFr;
    final String departLabel =
        isArabic ? 'المغادرة' : 'Départ';
    final String destLabel =
        isArabic ? 'الوجهة' : 'Destination';
    final String statusLabel = isArabic
        ? 'تم اختيار المسار'
        : 'ITINÉRAIRE SÉLECTIONNÉ';
    final String prepLabel = isArabic
        ? 'جارٍ الاستعداد للمغادرة...'
        : 'Préparation au départ...';
    final String oncfLabel = isArabic
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
              // Train ID + line
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
              // Status pill
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 5),
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
                  Container(
                      width: 2, height: 28, color: kBorder),
                  const SizedBox(height: 6),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    color: kAccent,
                    size: 22,
                  ),
                  const SizedBox(height: 6),
                  Container(
                      width: 2, height: 28, color: kBorder),
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
```

---

## VERIFY

Run:
```bash
flutter analyze
flutter run -d linux
```

Test:
```
http://localhost:8080/jump?step=1
```

Expected screen:
- Top left: DOVE-6 + Z2M · ONCF
- Top right: quiet pill ITINÉRAIRE SÉLECTIONNÉ
- Center left: Départ / Marrakech (large dark)
- Center: orange arrow
- Center right: Destination / Tanger Ville (large orange)
- Bottom left: italic preparation text
- Bottom right: ONCF name quiet grey

Nothing else. No station list. No progress bar.
Clean, minimal, professional.

Report which file was modified.