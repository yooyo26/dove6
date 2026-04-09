# CLAUDE.md — dove6 Session Context

Read this entire file before doing anything.
When done confirm: "Context loaded — ready to work."

---

## Who I am
Ayoub Nahji. Final year engineering student ENSA Tanger.
Internship at AVIARAIL — Z2M rail renovation project.
Building passenger information display for Morocco trains.
Goal: deliver senior-level professional work. Not a student project.

---

## Project structure
```
~/dove6/
  dove6_server/    — Go fake NVR server (development only)
  dove6_client/    — Flutter passenger display app
```

GitHub: https://github.com/yooyo26/dove6

---

## dove6_server — Go HTTP server
Fake NVR for development. Will be replaced by real NVR
on R6S Lanner when colleague finishes his backend.
Run: cd ~/dove6/dove6_server && go run .
Port: 8080

## dove6_client — Flutter Ubuntu Linux app
Run: cd ~/dove6/dove6_client && flutter run -d linux
Target: Aeon Gene BT06 motherboard — Dove6 train screen

---

## Real NVR API contract (from colleague README)
Base URL: http://{nvrIp}:3002/v0
These are the REAL endpoints to implement in NvrDataService:

GET /running-state
Returns: {"current_state": "operating_state_atstation"}
Poll every 1 second.

GET /audio-state  
Returns: {"audio_action": "playing_french_audio"}
Poll only when state changes.

GET /data/speed
Returns: {"speed": 18.5}
Poll every 1 second.

GET /data/distance-ratio
Returns: {"ratio": 65}
Poll every 1 second. Divide by 100 for routeProgress.

GET /data/current-route
Returns: {"route_id": "uuid", "is_in_reverse": false, "start_station_index": 2}
Call once on startup and on route change.

GET /data/stations-in-route/{route_id}
Returns: ["uuid1", "uuid2", ...]
Call once when route_id changes.

GET /data/station-info/{station_id}
Returns: {"display_name": "casa_port", "display_name_fr": "...", "display_name_en": "..."}
NOTE: No Arabic yet — ask colleague to add display_name_ar.
Call once per station when route loads.

GET /audio-state possible values:
playing_default_audio  → isArabic = false
playing_french_audio   → isArabic = false  
playing_english_audio  → isArabic = false
no_audio_is_playing    → isArabic = false
NOTE: playing_arabic_audio not in contract yet — ask colleague.

State string mapping:
operating_state_idle             → TrainState.idle
operating_state_routeselected    → TrainState.routeSelected
operating_state_atstation        → TrainState.atStation
operating_state_departing        → TrainState.departing
operating_state_moving           → TrainState.moving
operating_state_arriving         → TrainState.arriving
operating_state_endofroute       → TrainState.endOfRoute
operating_state_coasting         → TrainState.moving
operating_state_recovery         → TrainState.recovery
operating_state_warning          → TrainState.warning
Operating_State_ManualHandling   → TrainState.manual

---

## Architecture rules — NEVER break these

Pattern: domain → data → presentation
- No screen imports anything except DisplayData and _shared.dart
- All routing logic ONLY in display_mapper.dart
- All colors and shared widgets ONLY in _shared.dart
- DataService abstract interface — swap NVR with one line
- All screens are StatelessWidget taking DisplayData + bool isArabic
- All timer logic stays in DisplayMapper only
- No third-party packages except http

---

## Color palette — NEVER change these
```dart
const kBg         = Color(0xFFE8E4DF);
const kSurface    = Color(0xFFD6CFC7);
const kCard       = Color(0xFFD6CFC7);
const kBorder     = Color(0xFFC8C3BC);
const kPrimary    = Color(0xFF1A1A1A);
const kSecondary  = Color(0xFF5F5E5A);
const kAccent     = Color(0xFFE8650A);
const kAccentGold = Color(0xFF333333);
const kDim        = Color(0xFFBFB9B1);
```

---

## State machine — 10 states
idle → routeSelected → atStation → departing →
moving → arriving → endOfRoute
Priority: warning, manual, recovery

## Moving state — two visual phases
Phase 1 (0-5s): MovingSpeedScreen — large speed number
Phase 2 (5s+): MovingProgressScreen — progress % + smart bar
Timer in DisplayMapper only.

## Arrived message flash
arriving → atStation: show ArrivedMessageScreen 3 seconds
then StationScreen. Controlled only by DisplayMapper.

## Language behavior
French always default.
State changes → French immediately.
Read audio_action → if playing_arabic_audio → isArabic = true.
One language per screen. Never mixed.

---

## Known bugs to fix
BUG-001: Progress bar dot colors wrong.
File: lib/presentation/screens/_shared.dart
Method: _renderSmartWindow in RouteProgressPainter
Fix: _dotState must receive item.index not j.
Wrong: final DotState state = _dotState(j, cur, last);
Right: final DotState state = _dotState(item.index, cur, last);

---

## 18-station route
FR: Marrakech, Youssoufia, Benguerir, Settat, El Jadida,
Casa Oasis, Casa Voyageurs, Casa Ain Sebaa, Mohammedia,
Rabat Agdal, Rabat Ville, Salé Tabriquet, Salé Ville,
Kénitra, Sidi Bouknadel, Ksar El Kébir, Asilah, Tanger Ville

AR: مراكش، اليوسفية، بنكرير، سطات، الجديدة،
الدار البيضاء أويسيس، الدار البيضاء المسافرين،
الدار البيضاء عين السبع، المحمدية، الرباط أكدال،
الرباط المدينة، سلا طابريقت، سلا المدينة، القنيطرة،
سيدي بوقنادل، القصر الكبير، أصيلة، طنجة المدينة