# DOVE6 — Passenger Information Display System

A bilingual (French + Arabic) passenger information
display for Morocco national railways ONCF.
Built for the Z2M train renovation project at AVIARAIL.

---

## What this system does

DOVE6 is a real-time passenger information display
that runs on the Dove6 screen inside Z2M trains.
It shows passengers their current station, next stop,
destination, speed, and route progress.
It communicates in French and Arabic, synchronized
with on-board audio announcements.

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

## Quick start

### Run the server
```bash
cd server
go run .
```

### Run the Flutter app
```bash
cd client
flutter pub get
flutter run -d linux
```

### Change the simulated route
Edit server/routes.json and change active_route.
Then restart the server.

---

## Documentation

All documentation is in the docs/ folder:
- ARCHITECTURE.md   Complete system architecture
- API_CONTRACT.md   NVR API endpoint specification
- ROUTES.md         How to configure routes

---

## Technology

- Flutter (Dart) — passenger display application
- Go — NVR simulation server
- Target OS: Ubuntu Linux (Aeon Gene BT06 hardware)
- Languages: French + Arabic (RTL)

---

## Project context

End-of-study internship project at AVIARAIL.
Part of the Z2M rail renovation — replacing the old
passenger information system with a modern bilingual
display running on the R6S Lanner embedded computer.

Student: Ayoub Nahji — ENSA Tanger
