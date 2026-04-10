# Context Load — Full Session Brief
# DOVE6 — Passenger Information Display System

A bilingual (French + Arabic) passenger information
display for Morocco national railways ONCF.
Built for the Z2M train renovation project at AVIARAIL.

## What this system does

DOVE6 is a real-time passenger information display
that runs on the Dove6 screen inside Z2M trains.
It shows passengers their current station, next stop,
destination, speed, and route progress.
It communicates in French and Arabic, synchronized
with on-board audio announcements.
---
## Technology

- Flutter (Dart) — passenger display application
- Go — NVR simulation server
- Target OS: Ubuntu Linux (Aeon Gene BT06 hardware)
- Languages: French + Arabic (RTL)

---

## Repository structure

```
dove6/
  client/          Flutter application (Ubuntu Linux)
  server/          Go NVR simulation server
  docs/            All documentation and specifications
  scripts/         Helper scripts to run the system
  README.md        This file
  CLAUDE.md        AI session context
```

---
## Who I am
My name is Ayoub Nahji. 24 years old. Born 24 March 2001.
Based in Ain Sebaa, Casablanca, Morocco.
Final year engineering student at ENSA Tanger.
Specialization: Electronics and Automatic Systems.
Currently in end-of-study internship at AVIARAIL.

## My current mission
Developing the dove6 Flutter passenger information display
application for the Z2M rail renovation project at AVIARAIL.
This is my chance to prove myself professionally.
I want this to look like senior engineer work, not a student project.

## My work setup
- VSCode + WSL Ubuntu on Windows
- Claude Code subscription
- GitHub repository: https://github.com/yooyo26/dove6
- Obsidian vault for project knowledge and personal context
- Office in Beausejour, Casablanca — arrive at 9am daily

## My colleague
Built by a 1337 engineer. Developing the NVR application
in Go to run on R6S Lanner. We communicate well.
Integration spec still being finalized.

### dove6_client (Flutter → Ubuntu Linux)
Location: ~/dove6/dove6_client
Runs on: Aeon Gene BT06 motherboard (Dove6 screen)
Command to run: flutter run -d linux
Architecture: domain → data → presentation
Languages: French (default) + Arabic (RTL when audio synced)
State machine: 10 states
Color palette:
  kBg #E8E4DF — warm light grey background
  kAccent #E8650A — orange
  kPrimary #1A1A1A — dark text
  kSecondary #5F5E5A — muted text
  kDim #BFB9B1 — subtle elements

## My personality and working style
- I think in systems not local fixes (working on this)
- I want work to be beautiful and make people amazed
- I do not like ordinary results
- I learn fast — do not over-explain basics
- I prefer one clear path not ten options
- When stuck I want to understand WHY not just the fix


## Top-level structure

| Folder/File | What it is |
|---|---|
| client/ | Flutter passenger display app |
| server/ | Go NVR simulation server |
| docs/ | All documentation files |
| scripts/ | Helper scripts |
| README.md | Project overview |
| CLAUDE.md | AI session context file |
| REPORT.md | This file |
| .gitignore | Git ignore rules |

---### Folder structure inside client/
```
client/lib/
  main.dart                       App entry point
  domain/
    train_state.dart              11-state enum
    display_data.dart             Core data model
    language.dart                 FR/AR language enum
  data/
    data_service.dart             Abstract interface
    fake_data_service.dart        Local simulation
    nvr_data_service.dart         Real server polling
  presentation/
    display_mapper.dart           Routes state to screen
    screens/
      _shared.dart                Colors, painter, widgets
      idle_screen.dart            Train waiting screen
      route_selected_screen.dart  Route confirmation screen
      station_screen.dart         At station screen
      departing_screen.dart       Departure screen
      moving_speed_screen.dart    Speed display screen
      moving_progress_screen.dart Progress display screen
      arriving_screen.dart        Arriving screen
      arrived_message_screen.dart Arrival confirmation
      end_of_route_screen.dart    Journey complete screen
```

---