# DOVE6 — Project Presentation
# Passenger Information Display System for Morocco Railways

**Author:** Ayoub Nahji — ENSA Tanger
**Company:** AVIARAIL — Z2M Rail Renovation Programme
**Date:** April 2026

---

## 1. What Is DOVE6

DOVE6 is a passenger information display system built
for Morocco's national railway, ONCF.
It runs on a dedicated screen inside Z2M trains and
shows passengers exactly where the train is, which
station is coming next, and how far the journey
has progressed — in both French and Arabic.

Think of it as the digital panel you see in an airport
arrivals hall, but installed inside the train itself,
updating in real time as the journey unfolds.

---

## 2. The Problem It Solves

Many Z2M trains today have no passenger display at all,
or carry only a static sign that shows the final
destination and nothing else.
A passenger boarding in Casablanca with no knowledge
of the route has no way to know when their stop
is approaching, how many stations remain, or whether
the train is running on schedule.

This is a problem not only for local passengers but
especially for international visitors, hearing-impaired
travellers, and anyone unfamiliar with the Moroccan
rail network.
DOVE6 solves this by making the train's state visible
and understandable to every passenger, at all times.

---

## 3. How the System Works

The system has two parts that work together.
The first part is a server application running on the
train's on-board computer, the R6S Lanner.
It reads data from physical sensors attached to the
train — a GPS unit, a speed sensor, a passenger
counter — and makes that data available over
the train's internal network.

The second part is the display application running
on a dedicated screen in the passenger cabin,
called the Aeon Gene BT06.
Every second, the display asks the server for the
latest data, decides which screen to show,
and updates the display instantly.
The two parts communicate over a simple, fast local
network connection — the same way a website
communicates with a web server.

---

## 4. The Display Screens

The display is not a single static image.
It is a sequence of carefully designed screens,
each one matched to a specific moment in the journey.

When the train is waiting, passengers see a calm idle
screen with the train identifier.
When a route is confirmed, a route overview screen
appears showing the origin, destination, and all
intermediate stations.
While moving, the display shows either the current
speed in large clear digits, or a progress bar
showing how far along the route the train has
travelled, with each station marked.
When the train is arriving, an arrival screen appears
with the station name in both languages.

Each screen is designed to communicate one thing
clearly — not to overwhelm the passenger with
information, but to show exactly what is relevant
at that moment.

---

## 5. The Server

The server is the invisible engine behind the display.
It runs silently on the R6S Lanner industrial computer
mounted inside the train, reads sensor data,
and answers questions from the display application.

Think of it as a knowledgeable assistant that always
knows the current state of the journey.
The display asks questions like "what speed are we
going?" or "which station are we at?" and the server
answers instantly.
During development, a simulation version of the server
runs on a laptop to allow full testing of every screen
and every state without needing to be inside a train.

---

## 6. How the Two Parts Communicate

The display and the server talk to each other using
HTTP, the same protocol used by every website
on the internet.
The display sends a simple request every second —
"what is the current state?" — and the server replies
with a short, structured answer.

This design choice is deliberate.
Because the communication uses a standard protocol,
the same display application can connect to the
development simulation server on a laptop, or to the
real R6S Lanner inside the train, by changing
a single configuration line.
No part of the display code needs to change when
moving from development to production.

---

## 7. The Bilingual System

Every screen in DOVE6 shows content in either
French or Arabic, never mixed.
French is the default language.
When the on-board audio system begins playing
an Arabic announcement, the display switches
to Arabic automatically — on the next state change.

Arabic text is written right to left, which is the
opposite direction from French.
The display handles this correctly: when in Arabic
mode, the entire screen layout mirrors itself —
text aligns to the right, and station names are shown
in Arabic script.
Passengers who read Arabic see a screen that feels
natural, not a French screen with Arabic words
awkwardly inserted.

---

## 8. The Route System

DOVE6 is not tied to any single train route.
Routes are defined in a plain configuration file —
a simple list of station names in French and Arabic,
with a start and an end.
To run the system on a different line, an operator
changes one word in that file and restarts the server.

No programming is needed to add a new route.
A non-technical railway operations person can add
the Rabat–Fès route or the Oujda–Casablanca route
in five minutes by editing the configuration file
in a text editor.
The display application reads the route from the
server and adapts automatically — whether the route
has four stations or twenty, the progress bar
and station list adjust to fit.

---

## 9. What Makes This Professional

**Real hardware integration.**
The display reads live data from physical sensors
on the train — speed, position, passenger count —
through a standardised interface already used
in railway operations worldwide.

**Correct bilingual implementation.**
Arabic text direction, font rendering, and screen
layout are handled properly, not patched together.
The language switch is synchronised with audio,
not manual.

**Designed for any route.**
No code change is required to deploy on a different
line. The system is configuration-driven by design.

**Recovery behaviour.**
If the connection to the server is lost, the display
does not crash or freeze. It handles the interruption
gracefully and reconnects automatically.

**Clean separation of concerns.**
The server does one job: provide data.
The display does one job: show the right screen.
Neither part knows the internal details of the other.
This makes the system easy to maintain and extend.

**Inspired by world-class systems.**
The design draws from the passenger information
displays of SNCF, Deutsche Bahn, and London
Underground — systems trusted daily by millions
of travellers.

---

## 10. Technology Choices and Why

**Flutter** is the framework used to build the
display application.
It was chosen because it produces smooth,
professional interfaces on any screen size,
and it runs natively on Ubuntu Linux —
the operating system of the Aeon Gene BT06 display
hardware installed in the Dove6 screen.

**Go** is the programming language used for the
server application.
It was chosen because it starts in milliseconds,
uses very little memory, and handles multiple
simultaneous requests reliably — qualities that
matter on an embedded computer inside a moving train.

**Ubuntu Linux** is the operating system running
on the display hardware.
It was chosen because it is stable, well-supported
on industrial hardware, and free — reducing the
per-train licensing cost of the renovation.

**GitHub** is the version control platform used
to manage all code.
It keeps every version of every file safe,
allows the project to be accessed from anywhere,
and provides a complete history of every
change ever made.

---

## 11. Project Context

This system was built during an end-of-study
internship at AVIARAIL, a company engaged in the
Z2M rail renovation programme for ONCF, Morocco's
national railway operator.
The student, Ayoub Nahji, is a final-year engineering
student at ENSA Tanger, specialising in Electronics
and Automatic Systems.

The internship mission was to design and build the
passenger information display component of the
renovation — replacing the old Sadel Almaviva display
system that previously ran on the Z2M trainsets.
A colleague at AVIARAIL is building the NVR
application in Go that will run in production
on the R6S Lanner embedded computer inside each train.
The DOVE6 display application is designed to connect
directly to that production NVR, requiring only
a single configuration change to move from
the development simulation to the live hardware.
