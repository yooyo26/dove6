# UI_REDESIGN.md — Refonte Complète du Design dove6_client

## LIRE CE FICHIER ENTIÈREMENT AVANT DE TOUCHER QUOI QUE CE SOIT

Tu vas refondre le design de toute l'application Flutter dove6_client.
L'architecture du code ne change PAS.
La logique métier ne change PAS.
Les fichiers domain/ et data/ ne changent PAS.
Seuls les fichiers de présentation changent:
- lib/presentation/screens/_shared.dart
- lib/presentation/screens/idle_screen.dart
- lib/presentation/screens/route_selected_screen.dart
- lib/presentation/screens/station_screen.dart
- lib/presentation/screens/departing_screen.dart
- lib/presentation/screens/moving_speed_screen.dart
- lib/presentation/screens/moving_progress_screen.dart
- lib/presentation/screens/arriving_screen.dart
- lib/presentation/screens/arrived_message_screen.dart
- lib/presentation/screens/end_of_route_screen.dart

---

## DESIGN TOKENS — NE JAMAIS DÉVIER DE CES VALEURS

```dart
// Couleurs — identiques à la palette existante
const kBg         = Color(0xFFE8E4DF); // --pis-bg
const kSurface    = Color(0xFFD6CFC7); // --pis-surface
const kBorder     = Color(0xFFC8C3BC); // --pis-track
const kPrimary    = Color(0xFF1A1A1A); // --pis-text-primary
const kSecondary  = Color(0xFF5F5E5A); // --pis-text-secondary
const kAccent     = Color(0xFFE8650A); // --pis-accent
const kDim        = Color(0xFFBFB9B1); // --pis-text-tertiary
const kCard       = Color(0xFFD6CFC7); // --pis-surface
```

---

## COMPOSANT PARTAGÉ — SharedHeader

Ce header apparaît sur TOUS les écrans sans exception.
Crée un widget réutilisable SharedHeader dans _shared.dart.

```
┌──────────────────────────────────────────────────────────────────┐
│  [ONCF]  |  Z2M · DOVE-6 · Marrakech → Tanger          18:42  │
└──────────────────────────────────────────────────────────────────┘
```

Spécifications exactes:
- Hauteur totale: 72px
- Padding horizontal: 40px
- Padding vertical: 12px
- Background: kBg
- Séparateur bas: 1px kBorder

Côté GAUCHE (Row, gap 16px):
  - Text "ONCF" style: fontSize 18, fontWeight w700, color kAccent,
    letterSpacing 3 — remplace le logo jusqu'à avoir le SVG
  - Container vertical 24px height, 1px width, color kBorder (divider)
  - Text dynamique: "Z2M · ${data.trainId}"
    style: fontSize 16, fontWeight w600, color kPrimary, letterSpacing 1.5

Côté DROIT:
  - ClockWidget (voir ci-dessous)

### ClockWidget — Horloge avec deux-points pulsants

Widget StatefulWidget dans _shared.dart.
Affiche l'heure actuelle format HH:MM.
Le deux-points ":" pulse toutes les 500ms (visible/invisible).
Animation Timer.periodic(Duration(milliseconds: 500)).

```dart
// Structure du ClockWidget
// - Timer qui update toutes les secondes pour l'heure
// - Timer qui toggle le colon toutes les 500ms
// - Text HH:MM où : pulse entre opacity 1.0 et 0.2
// fontSize: 48px, fontWeight: w400, color: kPrimary
// fontFeatures: [FontFeature.tabularFigures()] pour alignement fixe
```

---

## COMPOSANT PARTAGÉ — RouteProgressPainter (REDESIGN COMPLET)

### Comportement visuel EXACT demandé:

La progress bar affiche TOUS les dots de toutes les stations.
Si la route a 18 stations → 18 dots visibles toujours.
Une ligne orange remplit de gauche vers la droite selon la progression.
Les dots passés sont orange. Le dot actuel est grand avec glow.
Le dot suivant est creux avec bordure orange.
Les dots futurs sont gris.

### Spécifications de la track line:

Ligne de base (background):
- Couleur: kBorder
- Épaisseur: 6px (plus large que avant — demande spécifique)
- Round caps
- Pleine largeur

Ligne de progression (fill orange):
- Couleur: kAccent
- Épaisseur: 6px (même épaisseur que background)
- Commence à x=0
- Se termine à x = routeProgress * totalWidth
- Round caps

### Spécifications des dots:

PASSÉ (index < currentStationIndex):
- Cercle plein kAccent
- Rayon: 8px
- Centré exactement sur la track line

ACTUEL (index == currentStationIndex):
- Anneau de glow: kAccent opacity 0.15, rayon 18px
- Cercle plein kAccent, rayon 12px
- Centré exactement sur la track line
- RÈGLE CRITIQUE: node_center_y == track_center_y

SUIVANT (index == currentStationIndex + 1):
- Cercle creux: fill kBg, bordure kAccent 2.5px
- Rayon: 8px
- Centré exactement sur la track line

FUTUR (index > currentStationIndex + 1):
- Cercle creux: fill transparent, bordure kBorder 1.5px
- Rayon: 8px
- Centré exactement sur la track line

### Labels sous les dots:

Label ACTUEL uniquement (toujours affiché, jamais tronqué):
- Couleur: kAccent
- fontSize: 14px, fontWeight w700
- Position: 20px sous le centre du dot

Label SUIVANT uniquement:
- Couleur: kSecondary
- fontSize: 12px, fontWeight w500
- Position: 20px sous le centre du dot

Tous les autres dots: PAS de label

Ancre GAUCHE (origin, sous le premier dot):
- Couleur: kDim, fontSize: 10px
- Aligné au bord gauche

Ancre DROITE (destination, sous le dernier dot):
- Couleur: kDim, fontSize: 10px
- Aligné au bord droit

### Implémentation exacte RouteProgressPainter:

```dart
class RouteProgressPainter extends CustomPainter {
  final List<String> stations;
  final double progress;
  final int currentStationIndex;
  final bool isArabic;

  const RouteProgressPainter({
    required this.stations,
    required this.progress,
    required this.currentStationIndex,
    this.isArabic = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final int total = stations.length;
    if (total == 0) return;
    final int cur = currentStationIndex.clamp(0, total - 1);
    final int last = total - 1;
    final double w = size.width;
    // CRITIQUE: trackY au centre exact du painter
    final double trackY = size.height * 0.40;

    // 1. Draw background track — 6px épaisseur
    canvas.drawLine(
      Offset(0, trackY),
      Offset(w, trackY),
      Paint()
        ..color = kBorder
        ..strokeWidth = 6
        ..strokeCap = StrokeCap.round,
    );

    // 2. Draw orange fill — 6px épaisseur
    final double fillW = (progress.clamp(0.0, 1.0) * w);
    if (fillW > 0) {
      canvas.drawLine(
        Offset(0, trackY),
        Offset(fillW, trackY),
        Paint()
          ..color = kAccent
          ..strokeWidth = 6
          ..strokeCap = StrokeCap.round,
      );
    }

    // 3. Draw ALL dots — TOUS les stations toujours visibles
    for (int i = 0; i <= last; i++) {
      final double x = last == 0 ? 0 : w * i / last;
      final bool isPast = i < cur;
      final bool isCurrent = i == cur;
      final bool isNext = i == cur + 1;

      if (isCurrent) {
        // Glow ring
        canvas.drawCircle(Offset(x, trackY), 18,
            Paint()..color = kAccent.withOpacity(0.15)..style = PaintingStyle.fill);
        // Main dot
        canvas.drawCircle(Offset(x, trackY), 12,
            Paint()..color = kAccent..style = PaintingStyle.fill);
      } else if (isPast) {
        canvas.drawCircle(Offset(x, trackY), 8,
            Paint()..color = kAccent..style = PaintingStyle.fill);
      } else if (isNext) {
        // Hollow with orange border
        canvas.drawCircle(Offset(x, trackY), 8,
            Paint()..color = kBg..style = PaintingStyle.fill);
        canvas.drawCircle(Offset(x, trackY), 8,
            Paint()..color = kAccent..style = PaintingStyle.stroke..strokeWidth = 2.5);
      } else {
        // Future — hollow grey
        canvas.drawCircle(Offset(x, trackY), 8,
            Paint()..color = kBg..style = PaintingStyle.fill);
        canvas.drawCircle(Offset(x, trackY), 8,
            Paint()..color = kBorder..style = PaintingStyle.stroke..strokeWidth = 1.5);
      }

      // Labels
      if (isCurrent) {
        _paintLabel(canvas, size, stations[i], x, trackY,
            color: kAccent, fontSize: 14, bold: true);
      } else if (isNext) {
        _paintLabel(canvas, size, stations[i], x, trackY,
            color: kSecondary, fontSize: 12, bold: false);
      }
    }

    // Origin anchor left
    _paintAnchor(canvas, stations.first, 0, trackY, left: true);
    // Destination anchor right
    _paintAnchor(canvas, stations.last, w, trackY, left: false);
  }

  void _paintLabel(Canvas canvas, Size size, String text,
      double x, double trackY,
      {required Color color, required double fontSize, required bool bold}) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: size.width / 4);
    final double lx = (x - tp.width / 2).clamp(0, size.width - tp.width);
    tp.paint(canvas, Offset(lx, trackY + 22));
  }

  void _paintAnchor(Canvas canvas, String text,
      double x, double trackY, {required bool left}) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          color: kDim,
          fontSize: 10,
          fontWeight: FontWeight.w400,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: 120);
    final double lx = left ? 0 : x - tp.width;
    tp.paint(canvas, Offset(lx, trackY + 22));
  }

  @override
  bool shouldRepaint(RouteProgressPainter old) =>
      old.progress != progress ||
      old.currentStationIndex != currentStationIndex ||
      old.stations != stations;
}
```

Hauteur du SizedBox contenant le painter: 90px sur tous les écrans.

---

## ÉCRAN 1 — IDLE SCREEN

### Layout:

```
┌─────────────────────────────────────────────────────┐
│  SharedHeader (72px)                                │
├─────────────────────────────────────────────────────┤
│                                                     │
│                    [ONCF]                           │
│              48px, kAccent, w800                    │
│                                                     │
│          OFFICE NATIONAL DES CHEMINS DE FER         │
│            20px uppercase kSecondary                │
│                                                     │
│         Bienvenue · مرحباً بكم                      │
│              30px kDim w400                         │
│                                                     │
└─────────────────────────────────────────────────────┘
```

Spécifications:
- SharedHeader en haut
- Zone centrale: Column centré vertical + horizontal
- Text "ONCF": fontSize 48, fontWeight w800, color kAccent, letterSpacing 4
- SizedBox height 32
- Text "OFFICE NATIONAL DES CHEMINS DE FER":
  fontSize 16, fontWeight w500, color kSecondary,
  letterSpacing 3, textAlign center
- SizedBox height 16
- Text "Bienvenue · مرحباً بكم":
  fontSize 28, fontWeight w400, color kDim, textAlign center
- Fond: kBg
- Aucune animation sauf le clock dans le header

---

## ÉCRAN 2 — ROUTE SELECTED SCREEN

### Layout:

```
┌─────────────────────────────────────────────────────┐
│  SharedHeader                                       │
├─────────────────────────────────────────────────────┤
│                                                     │
│            Itinéraire · المسار                      │
│         18px uppercase kSecondary muted             │
│                                                     │
│   Marrakech      ●———→      Tanger Ville            │
│   60px bold                 60px bold kAccent       │
│   مراكش                     طنجة المدينة            │
│   24px kDim                 24px kDim               │
│                                                     │
│              18 arrêts · 18 محطة                    │
│           24px kSecondary center                    │
│                                                     │
└─────────────────────────────────────────────────────┘
```

### Connector ●———→ exact:

Widget custom dans _shared.dart appelé RouteConnector.
Row avec MainAxisAlignment.center, CrossAxisAlignment.center:
  - Container circle: 16px x 16px, color kAccent, shape circle
  - SizedBox width 12
  - Container: width 144px, height 6px, color kAccent, radius 3
  - SizedBox width 12
  - Icon(Icons.arrow_forward_rounded, color kAccent, size 28)

### Spécifications:
- Context label: "Itinéraire · المسار" centered, margin-bottom 32px
- Three-column Row:
  LEFT (Expanded, CrossAxisAlignment.end):
    - Text origin FR: 60px, w700, kPrimary, textAlign right
    - SizedBox 8
    - Text origin AR: 24px, w500, kDim, textAlign right, rtl
  CENTER (fixed width, CrossAxisAlignment.center):
    - RouteConnector widget
    - SizedBox height 48 — pour aligner verticalement
  RIGHT (Expanded, CrossAxisAlignment.start):
    - Text destination FR: 60px, w700, kAccent, textAlign left
    - SizedBox 8
    - Text destination AR: 24px, w500, kDim, textAlign left, rtl
- Stop count: "${data.routeStations.length} arrêts" centered below
- Noms ne doivent PAS wrapper — overflow TextOverflow.ellipsis

---

## ÉCRAN 3 — AT STATION (BOARDING) SCREEN

### Layout:

```
┌─────────────────────────────────────────────────────┐
│  SharedHeader                                       │
├─────────────────────────────────────────────────────┤
│         Gare actuelle · المحطة الحالية              │
│              18px kSecondary center                 │
│                                                     │
│                   SETTAT                           │
│              96px w700 kPrimary center              │
│                   سطات                              │
│              30px w500 kDim center                  │
│                                                     │
│  ┌──────────────────────────────────────────────┐  │
│  │  Direction →  →  →     Tanger Ville          │  │
│  │  24px kSecondary       30px w700 kAccent     │  │
│  └──────────────────────────────────────────────┘  │
│                                                     │
│  [Route Progress Bar — tous les dots]              │
│                                                     │
└─────────────────────────────────────────────────────┘
```

### Spécifications:
- Context label: margin-bottom 16px
- Station name FR: fontSize 96, fontWeight w700, color kPrimary, center
- Station name AR: fontSize 30, fontWeight w500, color kDim, center, rtl
  Margin entre FR et AR: 12px
- Direction card (margin-top 40px):
  Container avec:
    padding: EdgeInsets.symmetric(horizontal 24, vertical 16)
    decoration: BoxDecoration(
      color: kSurface,
      borderRadius: BorderRadius.circular(12),
    )
  Row MainAxisAlignment.spaceBetween:
    LEFT: Row avec Icon(Icons.arrow_forward, kAccent) x3 + Text "Direction"
    RIGHT: Text destination FR (30px w700 kAccent)
- RouteProgressPainter (margin-top 40px):
  SizedBox height 90
  currentStationIndex = data.routeStations.indexOf(data.currentStation)

---

## ÉCRAN 4 — DEPARTING SCREEN

### Layout:

```
┌─────────────────────────────────────────────────────┐
│  SharedHeader                                       │
├─────────────────────────────────────────────────────┤
│                                                     │
│            Départ · المغادرة                        │
│              18px kSecondary center                 │
│                                                     │
│                   SETTAT                           │
│              80px w700 kPrimary center              │
│                   سطات                              │
│              28px kDim center                       │
│                                                     │
│            Prochain arrêt:                         │
│              16px kSecondary center                 │
│              El Jadida                              │
│              36px w700 kAccent center               │
│                                                     │
└─────────────────────────────────────────────────────┘
```

### Spécifications:
- Même structure qu'At Station mais plus simple
- Pas de direction card
- Pas de progress bar sur cet écran
- Tout centré verticalement et horizontalement
- Current station: 80px
- Next station: 36px kAccent

---

## ÉCRAN 5 — MOVING SPEED SCREEN

### Layout:

```
┌─────────────────────────────────────────────────────┐
│  SharedHeader                                       │
├─────────────────────────────────────────────────────┤
│                                                     │
│                    175                             │
│           120px w200 kPrimary center               │
│                   km/h                             │
│            24px w400 kSecondary center             │
│                                                     │
│            Prochain arrêt:                         │
│              16px kSecondary center                 │
│              El Jadida                              │
│              36px w700 kAccent center               │
│                                                     │
└─────────────────────────────────────────────────────┘
```

### Spécifications:
- Vitesse: fontSize 120, fontWeight w200 (très fin), color kPrimary
  Ce grand nombre fin crée un effet moderne et aéré
- "km/h": fontSize 24, fontWeight w400, color kSecondary
- Prochain arrêt label + nom station en dessous
- Tout centré

---

## ÉCRAN 6 — MOVING PROGRESS SCREEN

### Layout:

```
┌─────────────────────────────────────────────────────┐
│  SharedHeader                                       │
├─────────────────────────────────────────────────────┤
│                                                     │
│  Direction →           Tanger Ville    [175 km/h]  │
│  16px kSecondary       24px w600 kAccent            │
│                                                     │
│  [══●══════════════════════════════════════════]   │
│  [Route Progress Bar full width — 90px height]     │
│                                                     │
├────────────────────────────────────────────────────┤
│                                                     │
│  ARRÊT ACTUEL              PROCHAIN ARRÊT           │
│  10px kSecondary           10px kSecondary          │
│                                                     │
│  Settat                    El Jadida               │
│  36px w700 kPrimary        36px w700 kAccent        │
│                                                     │
│  4 / 18 stations                                   │
│  11px kSecondary center                            │
│  "4" en kAccent                                    │
│                                                     │
│  Marrakech                          Tanger Ville   │
│  10px kDim left                     10px kDim right │
│                                                     │
└─────────────────────────────────────────────────────┘
```

### Spécifications:
- Direction row en haut: Row spaceBetween
  LEFT: Text "Direction →" + destination name
  RIGHT: Text vitesse "${data.speedKmh.round()} km/h"
- RouteProgressPainter: SizedBox height 90, full width
- Divider: kBorder 1px margin vertical 20px
- Info zone: Row spaceBetween
  LEFT col: label "ARRÊT ACTUEL" + station FR (36px kPrimary)
  RIGHT col: label "PROCHAIN ARRÊT" + station FR (36px kAccent)
- Station counter: RichText "${curIdx+1}" kAccent + " / ${total} stations" kSecondary
- Bottom row: origin left kDim + destination right kDim

### Calcul currentStationIndex:
```dart
final int curIdx = data.routeStations
    .indexOf(data.currentStation)
    .clamp(0, data.routeStations.length - 1);
```

---

## ÉCRAN 7 — ARRIVING SCREEN

### Layout:

```
┌─────────────────────────────────────────────────────┐
│  SharedHeader                                       │
├─────────────────────────────────────────────────────┤
│                   ——————                           │
│            ARRIVÉE · الوصول                        │
│              18px kSecondary center                 │
│                   ——————                           │
│                                                     │
│                El Jadida                           │
│              88px w700 kPrimary center              │
│                  الجديدة                            │
│              30px w500 kDim center                  │
│                                                     │
└─────────────────────────────────────────────────────┘
```

### Spécifications:
- Petit divider kAccent 48px width 2px height au-dessus du label
- Label "ARRIVÉE · الوصول": 18px kSecondary, letterSpacing 2, center
- Petit divider identique sous le label
- SizedBox 16px
- Station name: 88px w700 kPrimary center
- Arabic name: 30px w500 kDim center rtl
- Tout le contenu centré verticalement dans l'espace disponible

---

## ÉCRAN 8 — ARRIVED MESSAGE SCREEN

### Layout:

```
┌─────────────────────────────────────────────────────┐
│  SharedHeader                                       │
├─────────────────────────────────────────────────────┤
│                                                     │
│            BIENVENUE · مرحبا                        │
│              18px kSecondary center                 │
│                                                     │
│               El Jadida                            │
│           88px w700 kAccent center                  │
│               الجديدة                               │
│           30px w500 kDim center                    │
│                                                     │
│     Bienvenue à El Jadida — Bonne continuation     │
│         24px w400 kSecondary center                │
│                                                     │
└─────────────────────────────────────────────────────┘
```

### Spécifications:
- Label "BIENVENUE · مرحبا": uppercase kSecondary 18px
- Station name: 88px w700 kAccent (orange — moment joyeux)
- Arabic: 30px kDim rtl
- Message: "Bienvenue à ${station} — Bonne continuation"
  fontSize 24, kSecondary, textAlign center
- Affiché 3 secondes puis transition automatique (géré par DisplayMapper)

---

## ÉCRAN 9 — END OF ROUTE SCREEN

### Layout:

```
┌─────────────────────────────────────────────────────┐
│  SharedHeader                                       │
├─────────────────────────────────────────────────────┤
│                                                     │
│            Terminus · المحطة النهائية               │
│              18px kSecondary center                 │
│                                                     │
│              Tanger Ville                          │
│           88px w700 kPrimary center                 │
│              طنجة المدينة                           │
│           30px w500 kDim center rtl                │
│                                                     │
│     Merci de votre voyage avec l'ONCF              │
│         24px w400 kSecondary center                │
│                                                     │
│  المرجو التأكد من عدم نسيان أمتعتكم               │
│         20px w400 kDim center rtl                  │
│                                                     │
│  [Route Progress Bar — tous dots orange, fill 100%] │
│                                                     │
└─────────────────────────────────────────────────────┘
```

### Spécifications:
- Label "Terminus · المحطة النهائية"
- Station finale: 88px w700 kPrimary
- Message FR: "Merci de votre voyage avec l'ONCF"
- Message AR: "المرجو التأكد من عدم نسيان أمتعتكم"
- RouteProgressPainter avec:
  progress: 1.0
  currentStationIndex: data.routeStations.length - 1
  Tous les dots orange — journey complete

---

## RÈGLES ABSOLUES DE MISE EN PAGE

### ScreenScaffold — wrapper universel
Chaque écran est enveloppé dans ScreenScaffold.
ScreenScaffold dans _shared.dart:
```dart
class ScreenScaffold extends StatelessWidget {
  final Widget child;
  const ScreenScaffold({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: child,
        ),
      ),
    );
  }
}
```

### SharedHeader utilisation dans chaque écran:
```dart
Column(
  children: [
    SharedHeader(data: data),
    Expanded(
      child: // contenu de l'écran
    ),
  ],
)
```

### Padding horizontal global: 40px (géré par ScreenScaffold)
### Padding vertical interne à chaque écran: géré par SizedBox et Spacer

---

## RÈGLES BILINGUE FR / AR

- isArabic = true → tout le texte en arabe
- isArabic = false → tout le texte en français
- Jamais les deux langues mélangées sur le même écran
  SAUF les labels bilingual comme "Gare actuelle · المحطة الحالية"
- Tout texte arabe dans Directionality(textDirection: TextDirection.rtl)
- Tout texte arabe avec textAlign: TextAlign.right
- Le header SharedHeader affiche toujours les deux langues pour le label bilingue

---

## PROCÉDURE D'IMPLÉMENTATION

### Étape 1 — Mettre à jour _shared.dart
1. Vérifier que les couleurs sont exactement les bonnes
2. Implémenter SharedHeader avec ClockWidget
3. Implémenter RouteConnector widget
4. Remplacer RouteProgressPainter entièrement
5. S'assurer que ScreenScaffold est correct

### Étape 2 — Implémenter les écrans dans l'ordre
1. idle_screen.dart
2. route_selected_screen.dart
3. station_screen.dart
4. departing_screen.dart
5. moving_speed_screen.dart
6. moving_progress_screen.dart
7. arriving_screen.dart
8. arrived_message_screen.dart
9. end_of_route_screen.dart

### Étape 3 — Vérification
```bash
flutter analyze
```
Doit retourner: No issues found!

```bash
flutter run -d linux
```

Tests avec le serveur:
- step=0  → Idle screen
- step=1  → Route Selected
- step=2  → At Station (Marrakech)
- step=3  → Departing
- step=4  → Moving Speed (5 secondes)
- step=4+ → Moving Progress (après 5s)
- step=5  → Arriving
- step=6  → Arrived Message (3 secondes)
- step=70 → At Station (Tanger Ville)
- step=71 → End of Route

Pour chaque test vérifier:
- SharedHeader visible avec horloge qui pulse
- Contenu de l'écran correct
- Couleurs conformes aux tokens
- Texte arabe RTL correct quand isArabic=true
- Progress bar dots corrects et synchronisés

### Étape 4 — Rapport final
Lister chaque fichier modifié et les changements effectués.
Confirmer flutter analyze clean.
Confirmer chaque écran testé.

---

## CE QUI NE CHANGE PAS

- lib/domain/ → aucun changement
- lib/data/ → aucun changement
- lib/presentation/display_mapper.dart → aucun changement
- pubspec.yaml → aucun changement (pas de nouveaux packages)
- lib/main.dart → aucun changement

Seuls les fichiers de screens/ changent.