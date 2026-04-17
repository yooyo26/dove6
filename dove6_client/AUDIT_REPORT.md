# AUDIT_REPORT.md — Dove6 Client Gap Analysis

**Auditor:** Claude (automated code audit)
**Date:** 2026-04-17
**References:**
1. ARCHITECTURE.md (system architecture, 13 sections)
2. NVR_API_CONTRACT.md (real NVR endpoint shapes)
3. ui_spec.md (UI redesign spec — exact visual design)

**Code inspected:** all files in `lib/`, `dove6_server/`, `pubspec.yaml`

---

## 1. File Tree

### lib/

| File | Purpose | Exists |
|---|---|---|
| `main.dart` | Entry point, service instantiation, theme | YES |
| `domain/train_state.dart` | TrainState enum (10 values) | YES |
| `domain/display_data.dart` | DisplayData snapshot class | YES |
| `data/data_service.dart` | Abstract DataService interface | YES |
| `data/fake_data_service.dart` | Local scripted simulation | YES |
| `data/nvr_data_service.dart` | Real NVR HTTP polling | YES |
| `presentation/display_mapper.dart` | State-to-screen router + timers | YES |
| `presentation/screens/_shared.dart` | Colors, scaffold, shared widgets | YES |
| `presentation/screens/idle_screen.dart` | Idle state screen | YES |
| `presentation/screens/route_selected_screen.dart` | Route selected screen | YES |
| `presentation/screens/station_screen.dart` | At-station screen | YES |
| `presentation/screens/departing_screen.dart` | Departing screen | YES |
| `presentation/screens/moving_speed_screen.dart` | Moving speed phase screen | YES |
| `presentation/screens/moving_progress_screen.dart` | Moving progress phase screen | YES |
| `presentation/screens/arriving_screen.dart` | Arriving screen | YES |
| `presentation/screens/arrived_message_screen.dart` | Arrived message flash screen | YES |
| `presentation/screens/end_of_route_screen.dart` | End of route screen | YES |

### dove6_server/

| File | Purpose |
|---|---|
| `main.go` | Server entry point, auto-advance goroutine |
| `handler.go` | HTTP endpoint handlers (`/state`, `/health`, `/jump`) |
| `journer.go` | Step struct + scripted journey sequence |
| `routes.go` | routes.json loader + Arabic lookup |
| `routes.json` | Route definitions (1 route: casa_tanger) |

All required files present. No missing files.

---

## 2. Implemented Correctly

- **DataService abstraction**: clean abstract class with `Stream<DisplayData>`, `start()`, `dispose()`. Both `FakeDataService` and `NvrDataService` implement it. `main.dart` switches via `useLocalSimulation` flag.
- **DisplayMapper priority overrides**: warning, manual, recovery checked FIRST (lines 85-111) before the normal state switch. Correct priority ordering.
- **Arrived-flash edge trigger**: correctly fires ONLY on `arriving -> atStation` transition (line 60), not on idle->atStation or routeSelected->atStation.
- **Speed-phase timer**: 5-second timer on entering `moving` state (line 54).
- **Arrived-flash timer**: 3-second timer on arriving->atStation (line 63).
- **Timer disposal**: both timers cancelled in `dispose()` (lines 77-78).
- **AnimatedSwitcher 600ms crossfade**: present (line 147).
- **Color constants**: all 8 design tokens present with correct hex values.
- **RouteConnector**: matches spec exactly (16x16 circle, 144x6 line, arrow 28px, kAccent).
- **KDivider**: correct (kBorder, thickness 1, height 32).
- **ClockWidget dual-timer architecture**: 1s for time update + 500ms for colon pulse, both cancelled in dispose().

---

## 3. API Contract Mismatches (CRITICAL)

### 3.1 — NvrDataService polls a SINGLE monolithic endpoint

| Aspect | What real NVR does | What code does |
|---|---|---|
| Endpoint | 8 separate endpoints under `/v0` | Single `$baseUrl/state` (line 30) |
| Severity | **CRITICAL** | Breaks all production integration |

**File:** `lib/data/nvr_data_service.dart`, line 30
The code fetches `$baseUrl/state` and expects a monolithic JSON object with ALL fields. The real NVR exposes 8 separate endpoints each returning a different JSON shape. The entire data-fetching and parsing pipeline must be rewritten.

### 3.2 — No `/v0` path prefix

**File:** `lib/main.dart`, line 11
**Code:** `defaultValue: 'http://192.168.137.1:8080'`
**Expected:** Production URL must be `http://<ip>:3002/v0`
**Severity:** CRITICAL — every endpoint call will 404 on the real NVR.

### 3.3 — State-string mapping uses wrong values

**File:** `lib/data/nvr_data_service.dart`, lines 66-79

| Real NVR string | Code expects | Status |
|---|---|---|
| `operating_state_idle` | `IDLE` | WRONG |
| `operating_state_routeselected` | `ROUTE_SELECTED` | WRONG |
| `operating_state_atstation` | `AT_STATION` | WRONG |
| `operating_state_departing` | `DEPARTING` | WRONG |
| `operating_state_moving` | `MOVING` | WRONG |
| `operating_state_coasting` | (not handled) | MISSING |
| `operating_state_arriving` | `ARRIVING` | WRONG |
| `operating_state_endofroute` | `END_OF_ROUTE` | WRONG |
| `operating_state_recovery` | `RECOVERY` | WRONG |
| `operating_state_warning` | `WARNING` | WRONG |
| `Operating_State_ManualHandling` | `MANUAL` | WRONG (mixed case not handled) |

**Severity:** CRITICAL — every state would be unrecognized, defaulting to idle.

### 3.4 — Unknown state defaults to idle instead of recovery

**File:** `lib/data/nvr_data_service.dart`, line 79
**Code:** `default: return TrainState.idle;`
**Expected:** Should return `TrainState.recovery` — an unrecognized state is a contract violation and should be treated as a connectivity problem, not a quiet idle.
**Severity:** MAJOR

### 3.5 — JSON field names mismatch

**File:** `lib/data/nvr_data_service.dart`, lines 44-62

| Real NVR field | Code expects | Endpoint |
|---|---|---|
| `current_state` (in `{"current_state":"..."}`) | `j['state']` | /running-state |
| `speed` (in `{"speed": N}`) | `j['speed_kmh']` | /data/speed |
| `ratio` (int 0-100, in `{"ratio": N}`) | `j['route_progress']` (double 0.0-1.0) | /data/distance-ratio |
| `audio_action` (in `{"audio_action":"..."}`) | `j['active_audio_lang']` | /audio-state |

**Severity:** CRITICAL — runtime type errors and null crashes.

### 3.6 — distance-ratio not divided by 100

**File:** `lib/data/nvr_data_service.dart`, line 52
The real NVR returns an integer 0-100. The code must divide by 100 to get a 0.0-1.0 float. Currently not done.
**Severity:** CRITICAL — progress bar would show 65x scale.

### 3.7 — No station data pipeline

**File:** `lib/data/nvr_data_service.dart`
The real NVR requires a 3-step fetch:
1. `GET /data/current-route` → `{route_id, is_in_reverse, start_station_index}`
2. `GET /data/stations-in-route/{route_id}` → bare JSON array of UUIDs
3. `GET /data/station-info/{station_id}` → `{display_name, display_name_fr, display_name_en}`

None of these are implemented. The code expects pre-assembled station name strings from the monolithic `/state` response.
**Severity:** CRITICAL

### 3.8 — No station cache

No caching logic for station info. Must fetch station list only when `route_id` changes, cache station names, and invalidate on route change.
**Severity:** CRITICAL (functional gap)

### 3.9 — `is_in_reverse` not handled

The real NVR returns `is_in_reverse: true/false` in `/data/current-route`. When true, the station list must be reversed client-side. Not implemented.
**File:** `lib/data/nvr_data_service.dart` — no reverse logic
**Severity:** MAJOR — stations would display in wrong order on reverse routes.

### 3.10 — `display_name_ar` missing from real NVR

The real NVR station-info response has `{display_name, display_name_en, display_name_fr}` — no `display_name_ar`. Code must fall back to `display_name_fr` or `display_name` when `display_name_ar` is absent.
**File:** `lib/data/nvr_data_service.dart`, line 56 — would crash on null key
**Severity:** CRITICAL — null access crash in production.

### 3.11 — Audio-state values not mapped

**File:** `lib/data/nvr_data_service.dart`, line 61
Code expects `active_audio_lang` with values like `'ar'`, `'fr'`. Real NVR sends `audio_action` with values `playing_french_audio`, `playing_arabic_audio`, `playing_english_audio`, `playing_default_audio`, `no_audio_is_playing`.
**Severity:** CRITICAL — Arabic display would never trigger.

### 3.12 — No `/sensors/human-counter` endpoint called

Not polled. `humanCount` field missing from DisplayData.
**Severity:** MINOR (not displayed yet, but data is lost).

---

## 4. State Machine and Timer Bugs

### 4.1 — `coasting` state missing from TrainState enum

**File:** `lib/domain/train_state.dart`
The enum has 10 values. The architecture specifies 11 states including `coasting`. The real NVR sends `operating_state_coasting` which should map to the same display as `moving`. Without a `coasting` enum value OR explicit mapping to `moving`, this state would be unrecognized.
**Severity:** MAJOR — coasting state would fall through to idle (or recovery if default is fixed).

### 4.2 — Speed timer not cancelled when LEAVING moving state

**File:** `lib/presentation/display_mapper.dart`, lines 51-57
The speed timer is only cancelled when RE-entering moving. If the state transitions from moving to arriving (or any other state), the 5-second timer continues running. When it fires, it sets `_showSpeedPhase = false` which is harmless (wrong state), but the timer object is leaked until next moving entry or dispose.
**Severity:** MINOR — no visible bug, but unclean timer lifecycle.

### 4.3 — Arrived timer not cancelled when LEAVING atStation

**File:** `lib/presentation/display_mapper.dart`, lines 59-66
Same pattern: if state changes away from `atStation` during the 3-second arrived flash, the timer continues. No visible bug, but the timer should be cancelled.
**Severity:** MINOR

---

## 5. UI Spec Deviations

### 5.1 — ScreenScaffold padding

**File:** `_shared.dart`, line 107
**Spec:** `EdgeInsets.symmetric(horizontal: 40)` — no vertical padding
**Code:** `EdgeInsets.symmetric(horizontal: 48, vertical: 40)`
**Severity:** MAJOR — 8px wider and 40px taller padding on every screen.

### 5.2 — SharedHeader extra widgets

**File:** `_shared.dart`, lines 283-305
Code adds hardcoded "Voiture 3" and "1ère Classe" pills. These are NOT in any spec.
**Severity:** MINOR — extra UI elements not specified.

### 5.3 — SharedHeader trainId style

**File:** `_shared.dart`, lines 279-281
**Spec:** "Z2M · ${data.trainId}" as one text, fontSize 16, w600, kPrimary, letterSpacing 1.5
**Code:** Split into two Text widgets — "Z2M" (fontSize 18, w700, kSecondary) + "· ${data.trainId}" (fontSize 16, w500, kDim)
**Severity:** MINOR

### 5.4 — SharedHeader divider height

**File:** `_shared.dart`, line 277
**Spec:** Container 1px wide, 24px tall
**Code:** Container 1px wide, 32px tall
**Severity:** MINOR

### 5.5 — ClockWidget colon opacity

**File:** `_shared.dart`, line 236
**Spec:** Pulses between opacity 1.0 and 0.2
**Code:** Pulses between 1.0 and 0.6
**Severity:** MINOR — less dramatic pulse.

### 5.6 — ClockWidget font weight

**File:** `_shared.dart`, line 66 (pisClock)
**Spec:** fontWeight w400
**Code:** fontWeight w500
**Severity:** MINOR

### 5.7 — RouteProgressPainter — track thickness

**File:** `_shared.dart`, lines 406-407
**Spec:** strokeWidth 6
**Code:** strokeWidth 4
**Severity:** MAJOR — visually noticeably thinner track.

### 5.8 — RouteProgressPainter — trackY position

**File:** `_shared.dart`, line 402
**Spec:** `trackY = size.height * 0.40` (36px in 90px container)
**Code:** `trackY = 20` (fixed)
**Severity:** MAJOR — dots and track positioned too high.

### 5.9 — RouteProgressPainter — dot sizes wrong

**File:** `_shared.dart`, lines 437-477

| Dot type | Spec radius | Code radius |
|---|---|---|
| Past | 8 | 7 |
| Current glow | 18 | 14 |
| Current main | 12 | 10 |
| Next (hollow orange border) | 8 | N/A (not implemented) |
| Future | 8 | 7 |

**Severity:** MAJOR

### 5.10 — RouteProgressPainter — no distinct "next" dot

**File:** `_shared.dart`, lines 462-477
**Spec:** Next station dot should be hollow with kBg fill and kAccent border (2.5px)
**Code:** All future dots (including next) treated identically — kBg fill with kDim border
**Severity:** MAJOR — next station visually indistinguishable from future stations.

### 5.11 — RouteProgressPainter — labels on ALL dots

**File:** `_shared.dart`, lines 483-507
**Spec:** Labels only on current dot (kAccent 14px w700) and next dot (kSecondary 12px w500), plus origin/destination anchors at edges
**Code:** Labels on ALL stations, using truncation logic (`_shortenLabel`), with different font sizes (12.5 current, 10.5 others)
**Severity:** MAJOR — visual clutter, violates design principle "no abbreviated names."

### 5.12 — RouteProgressPainter — future dot border color

**File:** `_shared.dart`, line 469
**Spec:** kBorder (0xFFC8C3BC) with strokeWidth 1.5
**Code:** kDim (0xFFBFB9B1) with strokeWidth 2
**Severity:** MINOR

### 5.13 — RouteProgressPainter — missing origin/destination anchors

**File:** `_shared.dart`
**Spec:** Small text labels at far left (origin) and far right (destination), kDim fontSize 10
**Code:** Not implemented — all dots have their own labels instead
**Severity:** MINOR (subsumed by the "labels on all dots" deviation)

### 5.14 — IdleScreen not wrapped in ScreenScaffold

**File:** `idle_screen.dart`, line 16
**Spec:** Every screen wrapped in ScreenScaffold
**Code:** Uses inline `Scaffold(backgroundColor: kBg, body: SafeArea(...))` without padding
**Severity:** MINOR (functionally similar but inconsistent)

### 5.15 — IdleScreen uses Image.asset for "ONCF"

**File:** `idle_screen.dart`, lines 26-30
**ui_spec.md says:** Text "ONCF" fontSize 48, w800, kAccent, letterSpacing 4
**Code:** Image.asset('assets/images/Logo-oncf.png', height: 112)
**Note:** CLAUDE.md says Image.asset. See Ambiguities section.

### 5.16 — IdleScreen subtitle font size

**File:** `idle_screen.dart`, line 35
**Spec:** fontSize 16, w500, kSecondary, letterSpacing 3
**Code:** pisContextLabel = fontSize 18, letterSpacing 0.72
**Severity:** MINOR

### 5.17 — RouteSelectedScreen missing stop count

**File:** `route_selected_screen.dart`
**Spec:** Bottom text: "${data.routeStations.length} arrêts · ${data.routeStations.length} محطة" — 24px kSecondary center
**Code:** Not present
**Severity:** MAJOR — missing information element.

### 5.18 — RouteSelectedScreen always shows FR

**File:** `route_selected_screen.dart`, lines 50-58
**Spec:** isArabic should swap primary/secondary language for origin and destination names
**Code:** Always uses `currentFr` for primary and `currentAr` for secondary regardless of isArabic
**Severity:** MAJOR — Arabic mode doesn't work on this screen.

### 5.19 — StationScreen missing RouteProgressPainter

**File:** `station_screen.dart`
**Spec:** RouteProgressPainter should appear at the bottom (SizedBox height 90)
**Code:** No progress bar on this screen
**Severity:** MAJOR — missing key visual element.

### 5.20 — StationScreen direction card styling

**File:** `station_screen.dart`, lines 59-98
**Spec:** kSurface background, radius 12, padding h24 v16, Row spaceBetween with 3 arrow icons + "Direction" label on left, destination name on right
**Code:** kSurface.withOpacity(0.35), radius 20, padding h28 v18, Row min-width centered, 1 arrow icon, "Direction" label
**Severity:** MAJOR — layout and styling differ significantly.

### 5.21 — StationScreen not bilingual-aware

**File:** `station_screen.dart`
**Spec:** isArabic should swap primary/secondary station names
**Code:** Always shows FR as primary, AR as secondary
**Severity:** MAJOR

### 5.22 — MovingSpeedScreen speed font weight

**File:** `moving_speed_screen.dart`, line 29
**Spec:** fontWeight w200 (très fin — thin modern look)
**Code:** pisMegaDisplay (w300) with `.copyWith(fontWeight: FontWeight.w500)` → w500
**Severity:** MAJOR — speed number appears heavy instead of light/airy.

### 5.23 — MovingSpeedScreen not bilingual-aware

**File:** `moving_speed_screen.dart`
**Spec:** isArabic switches "Prochain arrêt" → "المحطة القادمة" and station name to Arabic
**Code:** Always shows FR text plus combined bilingual label
**Severity:** MAJOR

### 5.24 — MovingProgressScreen left column shows wrong data

**File:** `moving_progress_screen.dart`, lines 107-119
**Spec:** Left column label "ARRÊT ACTUEL", value `data.currentStationFr` (36px w700 kPrimary)
**Code:** Label "DÉPART", value `data.routeStations.first` (origin station, not current station)
**Severity:** CRITICAL — displays wrong station name. Shows origin instead of current station.

### 5.25 — MovingProgressScreen layout differs

**File:** `moving_progress_screen.dart`
**Spec:** Simple Row spaceBetween for current/next station, Divider between progress bar and info zone, bottom row with origin/destination labels
**Code:** Container with rounded corners, border, and different internal layout. No divider. No bottom origin/destination row.
**Severity:** MAJOR

### 5.26 — MovingProgressScreen not bilingual-aware

**File:** `moving_progress_screen.dart`
**Spec:** isArabic switches all labels and station names
**Code:** Always shows FR
**Severity:** MAJOR

### 5.27 — ArrivingScreen station name font size

**File:** `arriving_screen.dart`, line 46
**Spec:** 88px w700 kPrimary
**Code:** pisStationHero = 96px w700 kPrimary
**Severity:** MINOR — 8px larger than spec.

### 5.28 — ArrivingScreen not bilingual-aware

**File:** `arriving_screen.dart`
**Spec:** isArabic switches primary/secondary languages
**Code:** Always shows FR as primary
**Severity:** MAJOR

### 5.29 — ArrivedMessageScreen station name font size

**File:** `arrived_message_screen.dart`, line 44
**Spec:** 88px w700 kAccent
**Code:** pisStationHero = 96px w700 kAccent
**Severity:** MINOR

### 5.30 — ArrivedMessageScreen missing "Bonne continuation"

**File:** `arrived_message_screen.dart`, line 67
**Spec:** "Bienvenue à ${station} — Bonne continuation"
**Code:** "Bienvenue à ${data.currentStationFr}" (missing suffix)
**Severity:** MINOR

### 5.31 — ArrivedMessageScreen not bilingual-aware

**File:** `arrived_message_screen.dart`
**Spec:** isArabic switches messages and station name
**Code:** Always shows both FR and AR messages regardless of isArabic
**Severity:** MAJOR

### 5.32 — EndOfRouteScreen not wrapped in ScreenScaffold

**File:** `end_of_route_screen.dart`, line 16
**Spec:** Every screen wrapped in ScreenScaffold
**Code:** Uses inline Scaffold + SafeArea
**Severity:** MINOR

### 5.33 — EndOfRouteScreen station name font size

**File:** `end_of_route_screen.dart`, line 48
**Spec:** 88px w700 kPrimary
**Code:** pisStationHero = 96px w700 kPrimary
**Severity:** MINOR

### 5.34 — google_fonts dependency

**File:** `_shared.dart`, line 3; `pubspec.yaml`, line 38
**CLAUDE.md rule:** "No packages except http"
**Code:** Uses `google_fonts` throughout for DM Sans and Inter fonts
**Severity:** MAJOR — architecture violation. Requires network fetch on first run (problematic for offline train environment). Should use bundled fonts or system defaults.

### 5.35 — window_manager dependency

**File:** `main.dart`, line 3; `pubspec.yaml`, line 39
**CLAUDE.md rule:** "No packages except http"
**Code:** Uses `window_manager` for fullscreen
**Severity:** MINOR — functional necessity for production kiosk mode, but violates stated rule.

---

## 6. Architectural Violations

### 6.1 — google_fonts imported in presentation layer

**File:** `_shared.dart`, line 3; `idle_screen.dart`, line 3
**Rule:** No packages except `http`
**Impact:** `google_fonts` requires network access at runtime to download fonts. On the Aeon Gene BT06 with no internet, fonts may fail to load.
**Severity:** MAJOR

### 6.2 — Domain layer imports are clean

`display_data.dart` imports only `train_state.dart`. No dart:io, http, or material imports.
**Status:** PASS

### 6.3 — Screen imports are correct

All screens import only `display_data.dart` and `_shared.dart` (plus `google_fonts` where used). No data-layer or service imports.
**Status:** PASS (except google_fonts policy violation)

### 6.4 — DisplayMapper correctly lives in presentation layer

Subscribes to `Stream<DisplayData>`, no direct dependency on any DataService implementation.
**Status:** PASS

---

## 7. Fake-Server Shape Mismatches

### 7.1 — Single `/state` endpoint instead of 8 separate endpoints

**File:** `dove6_server/handler.go`, lines 61-66
**Real NVR:** 8 endpoints under `/v0` prefix
**Fake server:** Single `/state` returning monolithic JSON
**Severity:** CRITICAL — development cannot catch production integration bugs.

### 7.2 — No `/v0` path prefix

**File:** `dove6_server/handler.go`
All endpoints are at root (`/state`, `/health`, `/jump`). Real NVR uses `/v0/running-state`, `/v0/data/speed`, etc.
**Severity:** CRITICAL

### 7.3 — State strings use wrong format

**File:** `dove6_server/journer.go`, lines 38-59
**Code:** `"IDLE"`, `"MOVING"`, `"AT_STATION"`, etc.
**Real NVR:** `"operating_state_idle"`, `"operating_state_moving"`, `"operating_state_atstation"`, etc.
**Severity:** CRITICAL

### 7.4 — Field names differ from real NVR

**File:** `dove6_server/journer.go`, lines 11-19

| Fake server field | Real NVR field | Endpoint |
|---|---|---|
| `state` | `current_state` | /running-state |
| `speed_kmh` | `speed` | /data/speed |
| `route_progress` (float 0-1) | `ratio` (int 0-100) | /data/distance-ratio |
| `active_audio_lang` | `audio_action` | /audio-state |
| `current_station` (name string) | `start_station_index` (int) | /data/current-route |
| `route_stations` (name array) | bare UUID array | /data/stations-in-route |

**Severity:** CRITICAL

### 7.5 — Station identifiers are human-readable strings, not UUIDs

**File:** `dove6_server/journer.go`, lines 22-27
**Code:** `["Casa Voyageurs", "Rabat Ville", ...]`
**Real NVR:** `["c1076a25-0b19-430a-a84a-5fe47f5db4da", ...]`
**Severity:** MAJOR — hides UUID-related bugs.

### 7.6 — Only 1 route in routes.json

**File:** `dove6_server/routes.json`
**Architecture:** 3 routes (Marrakech→Tanger, Casa→Fès, Casa→Marrakech)
**Code:** 1 route (casa_tanger with only 4 stations instead of 18)
**Severity:** MINOR — sufficient for basic testing, but limits coverage.

### 7.7 — Audio state uses `active_audio_lang` with raw values

**File:** `dove6_server/journer.go`, line 19
**Code:** `ActiveAudioLang: "ar"` or `"fr"`
**Real NVR:** `audio_action: "playing_arabic_audio"` or `"playing_french_audio"`
**Severity:** CRITICAL

### 7.8 — No `is_in_reverse` or `start_station_index` in response

**File:** `dove6_server/journer.go`
These fields from `/data/current-route` are not simulated.
**Severity:** MAJOR

### 7.9 — No `/sensors/human-counter` endpoint

Not implemented in fake server.
**Severity:** MINOR

---

## 8. Missing Features

| Feature | Reference | Status |
|---|---|---|
| `coasting` TrainState enum value | Architecture S3 | MISSING |
| `routeStationsFr` / `routeStationsAr` separate lists in DisplayData | CLAUDE.md | MISSING |
| `humanCount` field in DisplayData | NVR contract `/sensors/human-counter` | MISSING |
| `isInReverse` field in DisplayData | NVR contract `/data/current-route` | MISSING |
| Station data pipeline (3-step fetch) | NVR contract | NOT IMPLEMENTED |
| Station cache with route-change invalidation | Architecture S9 | NOT IMPLEMENTED |
| Arabic audio trigger from `playing_arabic_audio` | Architecture S8 | NOT IMPLEMENTED |
| `AudioSyncBadge` widget | CLAUDE.md | MISSING |
| `/v0` base URL support | NVR contract | MISSING |
| 8-endpoint polling architecture | NVR contract | NOT IMPLEMENTED |
| Audio-state polling on state change only | Architecture S4 | NOT IMPLEMENTED |
| Warning/manual/recovery dedicated screens (bilingual) | Architecture S3 | PARTIAL (exist but no bilingual, no SharedHeader) |

---

## 9. Risky Patterns

### 9.1 — `google_fonts` network dependency on offline device

**File:** `_shared.dart`, line 3
`google_fonts` downloads fonts from the internet on first run. The Aeon Gene BT06 has no internet. Fonts may render as fallback system font or cause delays.
**Risk:** UI renders incorrectly in production.

### 9.2 — No null safety on station name lookups

**File:** `nvr_data_service.dart`, lines 48-56
Casts like `j['current_station'] as String` will throw if the key is absent. In the multi-endpoint architecture, station names come from a separate fetch — any timing issue could leave fields null.
**Risk:** Runtime crash.

### 9.3 — `routeStations.indexOf(data.currentStation)` fragile

**File:** `moving_progress_screen.dart`, line 17; used in multiple screens
If `currentStation` doesn't exactly match a string in `routeStations` (e.g., encoding differences, extra whitespace), `indexOf` returns -1. The `.clamp(0, ...)` prevents a crash but shows the wrong station index.
**Risk:** Progress bar shows wrong position.

### 9.4 — No reconnection backoff in NvrDataService

**File:** `nvr_data_service.dart`, line 24
On connection failure, the timer fires every 2 seconds with no exponential backoff. If the NVR is down, this creates 30 error-state emissions per minute.
**Risk:** Log spam, unnecessary network load.

### 9.5 — FakeDataService Arabic names are same as French

**File:** `fake_data_service.dart`, lines 72-73
`currentStationAr: cur` uses French name as Arabic placeholder. Combined with the server's `stationAr()` lookup, this only works if the server is running. In pure fake mode, Arabic displays show French text.
**Risk:** Arabic testing is ineffective with FakeDataService.

### 9.6 — `_PriorityScreen` has no SharedHeader

**File:** `display_mapper.dart`, lines 156-202
Priority override screens (warning, manual, recovery) use `ScreenScaffold` but no `SharedHeader`. The spec requires SharedHeader on EVERY screen.
**Risk:** Time and train ID invisible during emergencies.

---

## 10. Top 10 Recommended Fixes in Priority Order

### 1. Rewrite NvrDataService to poll 8 separate NVR endpoints
**Why:** Current code fetches a single `/state` endpoint that doesn't exist on the real NVR. Nothing works in production without this.
**Files:** `lib/data/nvr_data_service.dart`

### 2. Fix state-string mapping to use real NVR values
**Why:** All 11 `operating_state_*` strings must be recognized, including mixed-case `Operating_State_ManualHandling` and `operating_state_coasting`. Unknown states must default to recovery, not idle.
**Files:** `lib/data/nvr_data_service.dart`, `lib/domain/train_state.dart` (add `coasting`)

### 3. Implement station data pipeline with caching
**Why:** Real NVR returns UUIDs, not station names. The client must fetch `/data/stations-in-route/{id}` then `/data/station-info/{id}` for each station, cache results, and handle `is_in_reverse`.
**Files:** `lib/data/nvr_data_service.dart`, `lib/domain/display_data.dart`

### 4. Add Arabic fallback for missing `display_name_ar`
**Why:** Real NVR has no `display_name_ar` field. Client must fall back to `display_name_fr` to avoid null crashes.
**Files:** `lib/data/nvr_data_service.dart`

### 5. Rewrite fake server to match real NVR endpoint shapes
**Why:** Development with a fake server that returns different shapes hides integration bugs until production.
**Files:** `dove6_server/handler.go`, `dove6_server/journer.go`

### 6. Fix RouteProgressPainter to match UI spec
**Why:** Track thickness, dot sizes, distinct next-dot styling, label-only-on-current-and-next — all deviate from the design spec significantly.
**Files:** `lib/presentation/screens/_shared.dart`

### 7. Add bilingual isArabic switching to all screens
**Why:** Most screens always show French regardless of `isArabic` flag. Arabic mode is effectively broken.
**Files:** All screen files in `lib/presentation/screens/`

### 8. Fix ScreenScaffold padding and add missing RouteProgressPainter to StationScreen
**Why:** Padding is 48+40 instead of 40+0. StationScreen is missing its progress bar entirely.
**Files:** `lib/presentation/screens/_shared.dart`, `lib/presentation/screens/station_screen.dart`

### 9. Fix MovingProgressScreen to show current station (not origin)
**Why:** Left column shows `data.routeStations.first` (origin) labeled "DÉPART". Should show `data.currentStationFr` labeled "ARRÊT ACTUEL".
**Files:** `lib/presentation/screens/moving_progress_screen.dart`

### 10. Replace google_fonts with bundled fonts
**Why:** `google_fonts` requires internet access. The production device (Aeon Gene BT06) has no internet. Fonts will fail to load.
**Files:** `pubspec.yaml`, `lib/presentation/screens/_shared.dart`

---

## Ambiguities to Resolve with Architect/Colleague

1. **IdleScreen ONCF logo**: CLAUDE.md says `Image.asset('assets/images/Logo-oncf.png', height: 112)`. ui_spec.md says `Text "ONCF" fontSize 48, w800, kAccent`. Which is authoritative? The ui_spec.md describes the text as "remplace le logo jusqu'à avoir le SVG" — suggesting the text is a temporary placeholder until a proper logo asset is available. **Recommendation:** Use Image.asset if the PNG is available, text fallback otherwise.

2. **`start_station_index` semantics**: The real NVR field `start_station_index` in `/data/current-route` — does it represent the current station the train is at/near, or the station where the route started? The audit brief says to treat it as "live current-station index" pending confirmation.

3. **`operating_state_coasting`**: Should the `TrainState` enum include a `coasting` value, or should the NvrDataService map it directly to `TrainState.moving` at parse time? Adding the enum value is cleaner for future-proofing; mapping at parse time is simpler.

4. **SharedHeader logo vs text**: The current code uses `Image.asset` in SharedHeader but ui_spec.md says text "ONCF". The SharedHeader in CLAUDE.md says Image.asset. Need final decision.

5. **Priority screens (warning/manual/recovery)**: Should they include SharedHeader? CLAUDE.md says "SharedHeader on every screen," but the current _PriorityScreen omits it. Full-screen alerts may intentionally skip the header for maximum visibility.

6. **`playing_arabic_audio` support**: The real NVR contract does NOT include this value. The architecture requires Arabic display. Should the client recognize it anyway (for future NVR firmware update), or is there an alternative trigger mechanism?

7. **Station count in route**: The architecture mentions 18 stations (Marrakech→Tanger), but the current routes.json and journey script only have 4 stations (Casa→Tanger). Is this intentional for demo simplicity, or should routes.json be expanded?

---

*End of audit. No code was modified.*
