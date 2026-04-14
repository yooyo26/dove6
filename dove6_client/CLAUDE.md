# CLAUDE.md — dove6_client
# Passenger Information Display System — Z2M trains — ONCF Morocco
# Read this entire file before touching anything.

---

## Project Identity

App: dove6_client — Flutter passenger information display
Target: Ubuntu Linux on Aeon Gene BT06 (Dove6 train screen)
Company: AVIARAIL — Z2M rail renovation project
Operator: ONCF — Office National des Chemins de Fer
Student: Ayoub Nahji — ENSA Tanger — End of study internship
Server: dove6_server (Go) at ~/dove6/server — run with: go run .
Client: this app — run with: flutter run -d linux
GitHub: https://github.com/yooyo26/dove6

---

## Architecture — NEVER change this structure

Pattern: domain → data → presentation
One-way data flow. No exceptions.

```
lib/
  main.dart                         ← entry point, config only
  domain/
    train_state.dart                ← enum of all states
    display_data.dart               ← core data model
  data/
    data_service.dart               ← abstract interface
    fake_data_service.dart          ← local simulation
    nvr_data_service.dart           ← real server polling
  presentation/
    display_mapper.dart             ← state → screen router
    screens/
      _shared.dart                  ← colors, shared widgets
      idle_screen.dart
      route_selected_screen.dart
      station_screen.dart
      departing_screen.dart
      moving_speed_screen.dart
      moving_progress_screen.dart
      arriving_screen.dart
      arrived_message_screen.dart
      end_of_route_screen.dart
```

### Architecture rules — violation = stop and report

1. No screen imports anything except DisplayData and _shared.dart
2. All routing logic ONLY in display_mapper.dart
3. All colors and shared widgets ONLY in _shared.dart
4. DataService is the only contract between data and UI
5. main.dart is the only place service is instantiated
6. All screens are StatelessWidget
7. All timer logic stays in DisplayMapper only
8. No packages except http
9. Swapping fake to real = change useLocalSimulation bool only

---

## Configuration — main.dart

```dart
const bool useLocalSimulation = false;
const String nvrIp = '192.168.137.1';
```

ThemeData must be:
```dart
theme: ThemeData(
  brightness: Brightness.light,
  scaffoldBackgroundColor: const Color(0xFFE8E4DF),
),
```

Assets declared in pubspec.yaml:
```yaml
flutter:
  assets:
    - assets/images/Logo-oncf.png
```

---

## Domain Layer — do not modify these files

### train_state.dart
```dart
enum TrainState {
  idle,
  routeSelected,
  atStation,
  departing,
  moving,
  arriving,
  endOfRoute,
  warning,
  manual,
  recovery,
}
```

### display_data.dart
All data comes from this object. Never hardcode station names.

Fields:
- state: TrainState
- trainId: String (e.g. 'DOVE-6')
- currentStation: String (FR name)
- currentStationFr: String
- currentStationAr: String
- nextStation: String (FR name)
- nextStationFr: String
- nextStationAr: String
- destination: String (FR name)
- destinationFr: String
- destinationAr: String
- speedKmh: double
- routeProgress: double (0.0 to 1.0)
- routeStations: List<String> (FR names)
- routeStationsFr: List<String>
- routeStationsAr: List<String>
- activeAudioLang: String ('fr', 'ar', '')
- timestamp: DateTime

isArabic is derived from: activeAudioLang == 'ar'

static DisplayData initial() provides safe defaults.

---

## Data Layer — do not modify these files

### data_service.dart
```dart
abstract class DataService {
  Stream<DisplayData> get stream;
  void start();
  void dispose();
}
```

### fake_data_service.dart
Local simulation. Cycles through all states automatically.
No network needed. Uses routeStations list from server.

### nvr_data_service.dart
Polls Go server every 2 seconds.
Calls multiple endpoints per the NVR API contract:
  GET /running-state
  GET /audio-state
  GET /data/speed
  GET /data/distance-ratio
  GET /data/current-route
  GET /data/stations-in-route/{id}
  GET /data/station-info/{id}
On timeout or error → emits TrainState.recovery.

---

## Presentation Layer

### display_mapper.dart rules
- StatefulWidget subscribing to Stream<DisplayData>
- On entering moving: show MovingSpeedScreen 5 seconds
  then MovingProgressScreen
- On arriving→atStation: show ArrivedMessageScreen 3 seconds
  then StationScreen
- Priority states override everything: warning, manual, recovery
- AnimatedSwitcher 600ms crossfade between all screen changes
- Key: ValueKey('${state}-${_showSpeedPhase}-${_showArrivedMessage}')
- Cancel all timers in dispose()

---

## Design System — _shared.dart

### COLOR PALETTE — THESE VALUES NEVER CHANGE

```dart
const kBg         = Color(0xFFE8E4DF); // warm light grey — background
const kSurface    = Color(0xFFD6CFC7); // card surfaces
const kCard       = Color(0xFFD6CFC7); // cards
const kBorder     = Color(0xFFC8C3BC); // borders and track line
const kPrimary    = Color(0xFF1A1A1A); // main text — near black
const kSecondary  = Color(0xFF5F5E5A); // muted labels
const kAccent     = Color(0xFFE8650A); // ONCF orange — main accent
const kAccentGold = Color(0xFF333333); // dark grey — speed display
const kDim        = Color(0xFFBFB9B1); // subtle elements
```

WARNING: Never change these to dark/blue/gold theme.
The background is WARM BEIGE. The accent is ONCF ORANGE.

### SHARED WIDGETS in _shared.dart

#### ScreenScaffold
Wraps every screen. Provides kBg background and horizontal padding.
```dart
class ScreenScaffold extends StatelessWidget {
  final Widget child;
  // Scaffold backgroundColor: kBg
  // SafeArea with padding horizontal 40px
}
```

#### SharedHeader
Appears on EVERY screen. Takes DisplayData data, bool isArabic.
Height: 72px. Padding: horizontal 40px, vertical 12px.
Background: kBg. Bottom border: 1px kBorder.

Left side (Row, gap 16px):
  - ONCF logo: Image.asset('assets/images/Logo-oncf.png', height: 48)
  - Divider: Container 1px wide, 24px tall, color kBorder
  - Train info: Text 'Z2M · ${data.trainId}'
    fontSize 16, fontWeight w600, color kPrimary, letterSpacing 1.5

Right side:
  - ClockWidget

#### ClockWidget
StatefulWidget. Displays system time HH:MM.
The ":" pulses between opacity 1.0 and 0.2 every 500ms.
Uses two Timers — one for time update (1s), one for colon pulse (500ms).
Cancel both timers in dispose().
Style: fontSize 48, fontWeight w400, color kPrimary.
Use FontFeature.tabularFigures() for fixed-width digits.

#### RouteConnector
StatelessWidget. Displays: ● ———→
Row CrossAxisAlignment.center:
  - Circle container 16x16 kAccent
  - SizedBox width 12
  - Rectangle container 144x6 kAccent radius 3
  - SizedBox width 12
  - Icon Icons.arrow_forward_rounded kAccent size 28

#### RouteProgressPainter
CustomPainter. Parameters:
  List<String> stations
  double progress (0.0 to 1.0)
  int currentStationIndex
  bool isArabic

Paint method:
  trackY = size.height * 0.40

  1. Background track:
     Line from x=0 to x=size.width
     color kBorder, strokeWidth 6, StrokeCap.round

  2. Orange fill:
     Line from x=0 to x=(progress * size.width)
     color kAccent, strokeWidth 6, StrokeCap.round

  3. ALL station dots — always all visible:
     x position: i==0 → 0, i==last → size.width, else size.width*i/last
     CRITICAL: all dots centered exactly on trackY

     PAST (i < currentStationIndex):
       Filled circle, color kAccent, radius 8

     CURRENT (i == currentStationIndex):
       Glow ring: kAccent opacity 0.15, radius 18
       Main dot: kAccent filled, radius 12

     NEXT (i == currentStationIndex + 1):
       Fill: kBg, radius 8
       Stroke: kAccent, strokeWidth 2.5, radius 8

     FUTURE (i > currentStationIndex + 1):
       Fill: kBg, radius 8
       Stroke: kBorder, strokeWidth 1.5, radius 8

  4. Labels (TextPainter):
     CURRENT dot only:
       text: stations[i], color kAccent, fontSize 14, w700
       position: trackY + 22, centered on dot x
     NEXT dot only:
       text: stations[i], color kSecondary, fontSize 12, w500
       position: trackY + 22, centered on dot x

  5. Anchors:
     LEFT: stations.first, kDim, fontSize 10, x=0
     RIGHT: stations.last, kDim, fontSize 10, x=size.width-tp.width

  SizedBox height for painter: 90px on all screens.

  currentStationIndex calculated in each screen as:
  final int curIdx = data.routeStations
    .indexOf(data.currentStation)
    .clamp(0, data.routeStations.length - 1);

#### AudioSyncBadge
Small pill top right showing active language.
'ar' → shows 'ع', 'fr' → shows 'FR', '' → hidden.
Background kAccent, text white, fontSize 11, radius 4.

#### KDivider
Divider color kBorder thickness 1 height 32.

---

## SCREEN SPECIFICATIONS

All screens:
- StatelessWidget
- Parameters: DisplayData data, bool isArabic
- Import only DisplayData and _shared.dart
- No hardcoded station names, numbers, or messages
- All text from data.* fields
- isArabic → use Arabic fields, rtl, textAlign.right
- Wrapped in ScreenScaffold
- Start with SharedHeader(data: data, isArabic: isArabic)

---

### idle_screen.dart

Layout (Column):
  SharedHeader
  Expanded:
    Column MainAxisAlignment.center CrossAxisAlignment.center:
      Image.asset logo 112px
      SizedBox 32
      Text 'OFFICE NATIONAL DES CHEMINS DE FER'
        fontSize 16, w500, kSecondary, letterSpacing 3, center
      SizedBox 16
      Text isArabic ? 'مرحباً بكم' : 'Bienvenue · مرحباً بكم'
        fontSize 28, w400, kDim, center

---

### route_selected_screen.dart

Layout (Column):
  SharedHeader
  Expanded:
    Column MainAxisAlignment.center:
      Text isArabic ? 'المسار · Itinéraire' : 'Itinéraire · المسار'
        fontSize 18, w500, kSecondary, letterSpacing 2, center
      SizedBox 32
      Row MainAxisAlignment.spaceBetween CrossAxisAlignment.center:
        LEFT Expanded CrossAxisAlignment.end:
          Text isArabic ? data.currentStationAr : data.currentStationFr
            fontSize 60, w700, kPrimary, textAlign right
            overflow TextOverflow.ellipsis
          SizedBox 8
          Text isArabic ? data.currentStationFr : data.currentStationAr
            fontSize 24, w500, kDim, textAlign right
        CENTER SizedBox width 80:
          RouteConnector centered
        RIGHT Expanded CrossAxisAlignment.start:
          Text isArabic ? data.destinationAr : data.destinationFr
            fontSize 60, w700, kAccent, textAlign left
            overflow TextOverflow.ellipsis
          SizedBox 8
          Text isArabic ? data.destinationFr : data.destinationAr
            fontSize 24, w500, kDim, textAlign left
      SizedBox 40
      Text '${data.routeStations.length} arrêts · ${data.routeStations.length} محطة'
        fontSize 24, w500, kSecondary, center

---

### station_screen.dart

Layout (Column):
  SharedHeader
  Expanded:
    Column:
      SizedBox 16
      Text isArabic ? 'المحطة الحالية · Gare actuelle'
           : 'Gare actuelle · المحطة الحالية'
        fontSize 18, w500, kSecondary, letterSpacing 2, center
      SizedBox 16
      Text isArabic ? data.currentStationAr : data.currentStationFr
        fontSize 96, w700, kPrimary, center
        overflow TextOverflow.ellipsis
      SizedBox 12
      Text isArabic ? data.currentStationFr : data.currentStationAr
        fontSize 30, w500, kDim, center
      SizedBox 40
      Container card kSurface radius 12 padding h24 v16:
        Row MainAxisAlignment.spaceBetween:
          Text isArabic ? 'الاتجاه' : 'Direction'
            fontSize 24, w500, kSecondary
          Row:
            Icon Icons.arrow_forward kAccent × 3
          Text isArabic ? data.destinationAr : data.destinationFr
            fontSize 30, w700, kAccent
      SizedBox 40
      SizedBox height 90:
        CustomPaint RouteProgressPainter(
          stations: data.routeStations,
          progress: data.routeProgress,
          currentStationIndex: curIdx,
          isArabic: isArabic,
        )

---

### departing_screen.dart

Layout (Column):
  SharedHeader
  Expanded:
    Column MainAxisAlignment.center CrossAxisAlignment.center:
      Text isArabic ? 'المغادرة · Départ' : 'Départ · المغادرة'
        fontSize 18, w500, kSecondary, letterSpacing 2, center
      SizedBox 24
      Text isArabic ? data.currentStationAr : data.currentStationFr
        fontSize 80, w700, kPrimary, center
      SizedBox 12
      Text isArabic ? data.currentStationFr : data.currentStationAr
        fontSize 28, w500, kDim, center
      SizedBox 40
      Text isArabic ? 'المحطة القادمة' : 'Prochain arrêt'
        fontSize 16, w500, kSecondary, center
      SizedBox 8
      Text isArabic ? data.nextStationAr : data.nextStationFr
        fontSize 36, w700, kAccent, center

---

### moving_speed_screen.dart

Layout (Column):
  SharedHeader
  Expanded:
    Column MainAxisAlignment.center CrossAxisAlignment.center:
      Text '${data.speedKmh.round()}'
        fontSize 120, w200, kPrimary, center
        letterSpacing -2
      Text 'km/h'
        fontSize 24, w400, kSecondary, center, letterSpacing 4
      SizedBox 40
      Text isArabic ? 'المحطة القادمة' : 'Prochain arrêt'
        fontSize 16, kSecondary, center
      SizedBox 8
      Text isArabic ? data.nextStationAr : data.nextStationFr
        fontSize 36, w700, kAccent, center

---

### moving_progress_screen.dart

Layout (Column):
  SharedHeader
  Expanded:
    Column:
      SizedBox 20
      Row MainAxisAlignment.spaceBetween:
        Text (direction info):
          isArabic ? data.destinationAr : 'Direction → ${data.destinationFr}'
          fontSize 18, kSecondary
        Text '${data.speedKmh.round()} km/h'
          fontSize 16, kSecondary
      SizedBox 40
      SizedBox height 90:
        CustomPaint RouteProgressPainter(...)
      SizedBox 20
      Divider kBorder
      SizedBox 20
      Row MainAxisAlignment.spaceBetween:
        LEFT Column CrossAxisAlignment.start:
          Text isArabic ? 'المحطة الحالية' : 'ARRÊT ACTUEL'
            fontSize 10, kSecondary, letterSpacing 2
          SizedBox 6
          Text isArabic ? data.currentStationAr : data.currentStationFr
            fontSize 36, w700, kPrimary
        RIGHT Column CrossAxisAlignment.end:
          Text isArabic ? 'المحطة القادمة' : 'PROCHAIN ARRÊT'
            fontSize 10, kSecondary, letterSpacing 2
          SizedBox 6
          Text isArabic ? data.nextStationAr : data.nextStationFr
            fontSize 36, w700, kAccent, textAlign right
      SizedBox 12
      RichText center:
        TextSpan kAccent '${curIdx + 1}'
        TextSpan kSecondary ' / ${data.routeStations.length} stations'
      Spacer
      Row MainAxisAlignment.spaceBetween:
        Text isArabic ? data.routeStationsAr.first
             : data.routeStationsFr.first
          fontSize 10, kDim
        Text isArabic ? data.routeStationsAr.last
             : data.routeStationsFr.last
          fontSize 10, kDim, textAlign right
      SizedBox 40

---

### arriving_screen.dart

Layout (Column):
  SharedHeader
  Expanded:
    Column MainAxisAlignment.center CrossAxisAlignment.center:
      Container 48px wide 2px tall kAccent (divider)
      SizedBox 12
      Text isArabic ? 'الوصول · ARRIVÉE' : 'ARRIVÉE · الوصول'
        fontSize 18, w500, kSecondary, letterSpacing 2, center
      SizedBox 12
      Container 48px wide 2px tall kAccent (divider)
      SizedBox 16
      Text isArabic ? data.nextStationAr : data.nextStationFr
        fontSize 88, w700, kPrimary, center
        overflow TextOverflow.ellipsis
      SizedBox 12
      Text isArabic ? data.nextStationFr : data.nextStationAr
        fontSize 30, w500, kDim, center

---

### arrived_message_screen.dart

Layout (Column):
  SharedHeader
  Expanded:
    Column MainAxisAlignment.center CrossAxisAlignment.center:
      Text isArabic ? 'مرحبا · BIENVENUE' : 'BIENVENUE · مرحبا'
        fontSize 18, w500, kSecondary, letterSpacing 2, center
      SizedBox 16
      Text isArabic ? data.currentStationAr : data.currentStationFr
        fontSize 88, w700, kAccent, center
        overflow TextOverflow.ellipsis
      SizedBox 12
      Text isArabic ? data.currentStationFr : data.currentStationAr
        fontSize 30, w500, kDim, center
      SizedBox 16
      Text isArabic
        ? 'أهلاً بكم في ${data.currentStationAr}'
        : 'Bienvenue à ${data.currentStationFr} — Bonne continuation'
        fontSize 24, w400, kSecondary, center

---

### end_of_route_screen.dart

Layout (Column):
  SharedHeader
  Expanded:
    Column:
      Spacer
      Text isArabic ? 'المحطة النهائية · Terminus'
           : 'Terminus · المحطة النهائية'
        fontSize 18, w500, kSecondary, letterSpacing 2, center
      SizedBox 16
      Text isArabic ? data.destinationAr : data.destinationFr
        fontSize 88, w700, kPrimary, center
      SizedBox 12
      Text isArabic ? data.destinationFr : data.destinationAr
        fontSize 30, w500, kDim, center
      SizedBox 24
      Text isArabic
        ? 'شكراً لسفركم مع المكتب الوطني للسكك الحديدية'
        : 'Merci de votre voyage avec l\'ONCF'
        fontSize 24, w400, kSecondary, center
      SizedBox 12
      Text 'المرجو التأكد من عدم نسيان أمتعتكم'
        fontSize 20, w400, kDim, center
      Spacer
      SizedBox height 90:
        CustomPaint RouteProgressPainter(
          stations: data.routeStations,
          progress: 1.0,
          currentStationIndex: data.routeStations.length - 1,
          isArabic: isArabic,
        )
      SizedBox 40

---

## NVR API Contract — server endpoints

Base URL: http://{nvrIp}:8080 (fake server)
Real NVR: http://{nvrIp}:3002/v0

State string mapping:
  operating_state_idle             → TrainState.idle
  operating_state_routeselected    → TrainState.routeSelected
  operating_state_atstation        → TrainState.atStation
  operating_state_departing        → TrainState.departing
  operating_state_moving           → TrainState.moving
  operating_state_coasting         → TrainState.moving
  operating_state_arriving         → TrainState.arriving
  operating_state_endofroute       → TrainState.endOfRoute
  operating_state_recovery         → TrainState.recovery
  operating_state_warning          → TrainState.warning
  Operating_State_ManualHandling   → TrainState.manual

Audio language mapping:
  playing_french_audio   → isArabic = false
  playing_arabic_audio   → isArabic = true
  playing_default_audio  → isArabic = false
  no_audio_is_playing    → isArabic = false

---


---

## How to run

Server:
  cd ~/dove6/server && go run .

Client development:
  cd ~/dove6/client && flutter run -d linux

Build for BT06:
  flutter build linux --release
  Binary: build/linux/x64/release/bundle/dove6_client

Test states:
  http://localhost:8080/jump?step=0   → IDLE
  http://localhost:8080/jump?step=1   → ROUTE_SELECTED
  http://localhost:8080/jump?step=2   → AT_STATION Marrakech
  http://localhost:8080/jump?step=3   → DEPARTING
  http://localhost:8080/jump?step=4   → MOVING
  http://localhost:8080/jump?step=14  → AT_STATION Settat
  http://localhost:8080/jump?step=38  → AT_STATION Rabat Agdal
  http://localhost:8080/jump?step=70  → AT_STATION Tanger Ville
  http://localhost:8080/jump?step=71  → END_OF_ROUTE

---

## Obsidian vault
Location: /mnt/c/Users/hp/Downloads/my-workspace
Contains all project knowledge and personal context.