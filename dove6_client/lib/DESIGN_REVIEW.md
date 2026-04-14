# DESIGN_REVIEW.md — UI Review Against Lovable Specification

## MISSION — READ ONLY FIRST, THEN ASK

Read CLAUDE.md for full project context.
Read this file completely before touching anything.

This file describes a professional design specification
produced by Lovable for the ONCF Z2M passenger display.
Your job is to REVIEW the existing Flutter code against
this specification and apply ONLY the changes listed below.

DO NOT rebuild anything from scratch.
DO NOT change architecture, data flow, or logic.
DO NOT change color values — they are already correct.
ONLY apply the specific UI changes listed in each section.

---

## CRITICAL RULES

RULE 1 — Colors are FINAL — do not change:
  kBg         #E8E4DF  warm light grey
  kSurface    #D6CFC7  cards
  kBorder     #C8C3BC  borders and track
  kPrimary    #1A1A1A  main text
  kSecondary  #5F5E5A  labels
  kAccent     #E8650A  ONCF orange
  kDim        #BFB9B1  subtle text

RULE 2 — Architecture is FINAL — do not touch:
  domain/, data/, display_mapper.dart, main.dart

RULE 3 — One change at a time:
  After each section run flutter analyze.
  Report the change made.
  Wait for confirmation.

RULE 4 — No data hardcoding:
  All station names come from DisplayData.
  Never write station names in screen files.

---

## SECTION 1 — TYPOGRAPHY IMPROVEMENTS

### What the spec says
The spec defines a precise type scale with two fonts:
- DM Sans for all text (geometric, institutional, readable at distance)
- Inter for numeric displays only (tabular figures, no layout shift)

### What to change in _shared.dart

Add Google Fonts package to pubspec.yaml:
```yaml
dependencies:
  flutter:
    sdk: flutter
  http: ^1.0.0
  google_fonts: ^6.1.0
```

Run: flutter pub get

Then in _shared.dart add these text style helpers:

```dart
// Typography helpers — use these in all screens
TextStyle pisStationHero({Color color = kPrimary}) =>
  GoogleFonts.dmSans(
    fontSize: 96, fontWeight: FontWeight.w700,
    letterSpacing: -0.01 * 96, height: 1.1, color: color);

TextStyle pisStationPrimary({Color color = kPrimary}) =>
  GoogleFonts.dmSans(
    fontSize: 60, fontWeight: FontWeight.w700,
    letterSpacing: -0.01 * 60, height: 1.15, color: color);

TextStyle pisStationCallout({Color color = kPrimary}) =>
  GoogleFonts.dmSans(
    fontSize: 36, fontWeight: FontWeight.w700,
    height: 1.2, color: color);

TextStyle pisDirectionName({Color color = kPrimary}) =>
  GoogleFonts.dmSans(
    fontSize: 30, fontWeight: FontWeight.w700,
    height: 1.3, color: color);

TextStyle pisArabicLarge({Color color = kDim}) =>
  GoogleFonts.dmSans(
    fontSize: 30, fontWeight: FontWeight.w500,
    height: 1.4, color: color);

TextStyle pisArabicMedium({Color color = kDim}) =>
  GoogleFonts.dmSans(
    fontSize: 24, fontWeight: FontWeight.w500,
    height: 1.4, color: color);

TextStyle pisContextLabel({Color color = kSecondary}) =>
  GoogleFonts.dmSans(
    fontSize: 18, fontWeight: FontWeight.w500,
    letterSpacing: 0.04 * 18, height: 1.3, color: color);

TextStyle pisInfoLabel({Color color = kSecondary}) =>
  GoogleFonts.dmSans(
    fontSize: 24, fontWeight: FontWeight.w500,
    height: 1.3, color: color);

TextStyle pisMegaDisplay({Color color = kPrimary}) =>
  GoogleFonts.inter(
    fontSize: 120, fontWeight: FontWeight.w300,
    letterSpacing: -0.02 * 120, height: 1.0, color: color,
    fontFeatures: [const FontFeature.tabularFigures()]);

TextStyle pisClock({Color color = kPrimary}) =>
  GoogleFonts.inter(
    fontSize: 48, fontWeight: FontWeight.w500,
    letterSpacing: -0.02 * 48, height: 1.0, color: color,
    fontFeatures: [const FontFeature.tabularFigures()]);

TextStyle pisHeaderTrainId({Color color = kSecondary}) =>
  GoogleFonts.dmSans(
    fontSize: 18, fontWeight: FontWeight.w700,
    letterSpacing: 0.1, height: 1.2, color: color);

TextStyle pisHeaderMeta({Color color = kDim}) =>
  GoogleFonts.dmSans(
    fontSize: 16, fontWeight: FontWeight.w500,
    height: 1.2, color: color);

TextStyle pisProgressCurrent({Color color = kAccent}) =>
  GoogleFonts.dmSans(
    fontSize: 20, fontWeight: FontWeight.w700,
    height: 1.2, color: color);

TextStyle pisProgressNext({Color color = kPrimary}) =>
  GoogleFonts.dmSans(
    fontSize: 18, fontWeight: FontWeight.w700,
    height: 1.2, color: color);

TextStyle pisProgressOther({Color color = kSecondary}) =>
  GoogleFonts.dmSans(
    fontSize: 14, fontWeight: FontWeight.w600,
    height: 1.2, color: color);
```

After adding these helpers DO NOT apply them to screens yet.
Run flutter analyze first.
Report result and wait for confirmation.

---

## SECTION 2 — HEADER BAR IMPROVEMENTS

### What the spec says
The header should show:
  Left: ONCF Logo | Z2M (bold, tracked) | Train [trainId] |
        [Voiture pill] [Classe pill]
  Right: Clock with Inter font

### What to change in _shared.dart — SharedHeader widget

Update the SharedHeader widget LEFT side to match:

Current left side shows: Logo | divider | "Z2M · trainId"
New left side must show:
  - ONCF Logo 48px
  - Vertical divider 1px 32px kBorder
  - Text "Z2M" using pisHeaderTrainId style kSecondary
  - Text "· ${data.trainId}" using pisHeaderMeta style kDim
  - Gap 8px
  - Pill container "Voiture 3":
      background kSurface, radius 6px,
      padding horizontal 12px vertical 4px
      text fontSize 14, fontWeight w500, color kDim
  - Pill container "1ère Classe":
      background kAccent.withOpacity(0.12), radius 6px,
      padding horizontal 12px vertical 4px
      text fontSize 14, fontWeight w700, color kAccent

Note: "Voiture 3" and "1ère Classe" are fixed labels.
They represent train configuration — not from DisplayData.
This is acceptable because they are operational constants
for Z2M trains, not passenger journey data.

Update ClockWidget to use pisClock() text style.
The colon pulse must oscillate between opacity 0.6 and 1.0
over 3 seconds (not 0.2 and 1.0 as currently implemented).

After changes run flutter analyze.
Report exact changes made and wait for confirmation.

---

## SECTION 3 — PROGRESS BAR REFINEMENTS

### What the spec says
Track line height: 4px (currently 6px — reduce to 4px)
Progress fill: smooth 1s transition on width change
Current node: 24px with animated glow (pisGlow animation)
Passed nodes: 16px, color kDim (muted grey — not orange)
Future nodes: 16px, hollow kSurface fill + kBorder stroke 2.5px
Node axis: must be perfectly centered on track center

Important change on passed nodes:
  Spec says passed nodes are muted grey (--pis-node-passed)
  NOT orange. This is different from current implementation.
  Current: passed nodes = kAccent (orange)
  Spec:    passed nodes = kDim (muted grey)

  This is a design decision — the spec wants subtle history,
  not a bright orange trail. Apply this change.

### What to change in RouteProgressPainter in _shared.dart

1. Track strokeWidth: change from 6 to 4

2. Fill strokeWidth: change from 6 to 4

3. trackY: keep at size.height * 0.40 — do not change

4. Passed dots:
   Old: kAccent filled radius 8
   New: kDim filled radius 8

5. Current dot:
   Old: static glow ring kAccent opacity 0.15 radius 18
   New: keep glow ring — CustomPainter cannot animate
        but use kAccent opacity 0.20 radius 16
        main dot kAccent radius 12 — unchanged

6. Next dot (i == currentStationIndex + 1):
   Old: kBg fill + kAccent stroke 2.5px radius 8
   New: kSurface fill + kBorder stroke 2.5px radius 8
   (more subtle — not orange, just outlined)

7. Future dots:
   Old: kBg fill + kBorder stroke 1.5px radius 8
   New: kSurface fill + kBorder stroke 2px radius 8
   (slightly stronger border for visibility)

After changes run flutter analyze.
Report exact changes made and wait for confirmation.

---

## SECTION 4 — STATION SCREENS TYPOGRAPHY

### What to change

Apply the new text style helpers to these screens.
Only change TextStyle definitions — not layout or logic.

#### station_screen.dart
  Current station name: apply pisStationHero(color: kPrimary)
  Arabic name: apply pisArabicLarge(color: kDim)
  Context label: apply pisContextLabel(color: kSecondary)
  Destination in card: apply pisDirectionName(color: kAccent)

#### arriving_screen.dart
  Next station name: apply pisStationHero(color: kPrimary)
  Arabic name: apply pisArabicLarge(color: kDim)
  Context label: apply pisContextLabel(color: kSecondary)

#### arrived_message_screen.dart
  Current station name: apply pisStationHero(color: kAccent)
  Arabic name: apply pisArabicLarge(color: kDim)
  Context label: apply pisContextLabel(color: kSecondary)

#### end_of_route_screen.dart
  Destination name: apply pisStationHero(color: kPrimary)
  Arabic name: apply pisArabicLarge(color: kDim)
  Context label: apply pisContextLabel(color: kSecondary)

#### departing_screen.dart
  Current station name:
    Old: fontSize 80, fontWeight w700
    New: apply pisStationHero but with fontSize 80 not 96
         GoogleFonts.dmSans(fontSize: 80, fontWeight: w700,
         letterSpacing: -0.01*80, height: 1.1, color: kPrimary)
  Arabic name: apply pisArabicLarge(color: kDim)
  Next station: apply pisStationCallout(color: kAccent)

#### moving_speed_screen.dart
  Speed number: apply pisMegaDisplay(color: kPrimary)
  "km/h" label: keep existing style — fontSize 24 kSecondary
  Next station: apply pisStationCallout(color: kAccent)

#### moving_progress_screen.dart
  Current station: apply pisStationCallout(color: kPrimary)
  Next station: apply pisStationCallout(color: kAccent)
  Context labels ARRÊT ACTUEL / PROCHAIN ARRÊT:
    fontSize 10 kSecondary letterSpacing 2 — keep as is

After all typography changes run flutter analyze.
Report changes and wait for confirmation.

---

## SECTION 5 — ROUTE SELECTED SCREEN

### What the spec says
Station names at 60px bold — already implemented.
Arabic subtitles at 24px medium — already implemented.
Stop count: "${N} arrêts · ${N} محطة" — already implemented.

### Only change needed
Apply pisStationPrimary() to the origin and destination:
  Origin: pisStationPrimary(color: kPrimary)
  Destination: pisStationPrimary(color: kAccent)

Apply pisArabicMedium() to the Arabic subtitles.

Apply pisInfoLabel() to the stop count text.

After changes run flutter analyze.
Report and wait for confirmation.

---

## SECTION 6 — IDLE SCREEN

### What the spec says
The welcome message "Bienvenue · مرحباً بكم" should use
the interpunct separator convention (U+00B7 with spaces).

### Check
Verify idle_screen.dart uses exactly:
  'Bienvenue · مرحباً بكم'
  (middle dot U+00B7 with space on each side)

If different update to match.

Apply pisContextLabel() to the ONCF subtitle text.

After changes run flutter analyze.
Report and wait for confirmation.

---

## SECTION 7 — CARD COMPONENTS

### What the spec says
All cards: background kSurface, borderRadius 16px,
padding 20px vertical 40px horizontal.
No borders, no shadows.

### What to change in station_screen.dart
The direction callout card currently uses:
  padding: h24 v16, radius: 12

Update to:
  padding: horizontal 32px vertical 20px
  borderRadius: 16px
  color: kSurface (already correct)

### What to change in moving_progress_screen.dart
Check if any card containers exist.
If yes apply same 16px radius and kSurface background.

After changes run flutter analyze.
Report and wait for confirmation.

---

## FINAL VERIFICATION

After ALL sections are completed:

1. Run: flutter analyze
   Must show: No issues found!

2. Run: flutter build linux --release
   Must succeed without errors.

3. Check that NO hardcoded station names exist:
   Run: grep -r "Marrakech\|Tanger\|Casa\|Rabat\|Kénitra" \
     lib/presentation/screens/
   Must return empty — no results.

4. Report final list of all files modified.

---

## WHAT NOT TO CHANGE

These are working correctly — do not touch:
  - lib/domain/ — any file
  - lib/data/ — any file
  - lib/presentation/display_mapper.dart
  - lib/main.dart
  - The color constants kBg, kAccent, kPrimary etc.
  - The layout structure of any screen
  - The logic of RouteProgressPainter dot calculation
  - The isArabic / Directionality logic
  - The SharedHeader structure (only update styles)