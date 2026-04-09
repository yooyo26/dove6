# CLAUDESERVER2.md — New Route Update

## Mission
Update the journey script to simulate the real 8-station
route Marrakech → Fès with correct French and Arabic names.
Keep everything else exactly as it is.

---

## CRITICAL RULES

- Do NOT change the HTTP server setup
- Do NOT change any endpoint logic
- Do NOT change main.go startup box
- Do NOT change handler.go
- Only update journey.go

---

## TASK — Replace journey.go content entirely

Replace the route variables and journey slice with this:

```go
package main

import "time"

const stepDuration = 5 * time.Second

type Step struct {
    State             string   `json:"state"`
    TrainID           string   `json:"train_id"`
    CurrentStation    string   `json:"current_station"`
    CurrentStationFr  string   `json:"current_station_fr"`
    CurrentStationAr  string   `json:"current_station_ar"`
    NextStation       string   `json:"next_station"`
    NextStationFr     string   `json:"next_station_fr"`
    NextStationAr     string   `json:"next_station_ar"`
    Destination       string   `json:"destination"`
    DestinationFr     string   `json:"destination_fr"`
    DestinationAr     string   `json:"destination_ar"`
    SpeedKmh          float64  `json:"speed_kmh"`
    RouteProgress     float64  `json:"route_progress"`
    RouteStations     []string `json:"route_stations"`
    RouteStationsFr   []string `json:"route_stations_fr"`
    RouteStationsAr   []string `json:"route_stations_ar"`
    MessageEn         string   `json:"message_en"`
    MessageFr         string   `json:"message_fr"`
    MessageAr         string   `json:"message_ar"`
    ActiveAudioLang   string   `json:"active_audio_lang"`
    AudioFile         string   `json:"audio_file"`
}

var routeFr = []string{
    "Marrakech",
    "Benguerir",
    "Settat",
    "Casablanca Voyageurs",
    "Rabat Agdal",
    "Kénitra",
    "Meknès",
    "Fès",
}

var routeAr = []string{
    "مراكش",
    "بنكرير",
    "سطات",
    "الدار البيضاء المسافرين",
    "الرباط أكدال",
    "القنيطرة",
    "مكناس",
    "فاس",
}

var journey = []Step{
    // ── IDLE ─────────────────────────────────────────────
    {
        State: "IDLE",
        CurrentStation: "Marrakech", CurrentStationFr: "Marrakech",
        CurrentStationAr: "مراكش",
        NextStation: "Benguerir", NextStationFr: "Benguerir",
        NextStationAr: "بنكرير",
        SpeedKmh: 0, RouteProgress: 0.00,
        MessageFr: "Bienvenue", MessageAr: "مرحباً",
        ActiveAudioLang: "", AudioFile: "",
    },
    // ── ROUTE SELECTED ───────────────────────────────────
    {
        State: "ROUTE_SELECTED",
        CurrentStation: "Marrakech", CurrentStationFr: "Marrakech",
        CurrentStationAr: "مراكش",
        NextStation: "Benguerir", NextStationFr: "Benguerir",
        NextStationAr: "بنكرير",
        SpeedKmh: 0, RouteProgress: 0.00,
        MessageFr: "Itinéraire sélectionné",
        MessageAr: "تم اختيار المسار",
        ActiveAudioLang: "fr", AudioFile: "route_selected_fr.mp3",
    },
    // ── AT STATION — Marrakech ───────────────────────────
    {
        State: "AT_STATION",
        CurrentStation: "Marrakech", CurrentStationFr: "Marrakech",
        CurrentStationAr: "مراكش",
        NextStation: "Benguerir", NextStationFr: "Benguerir",
        NextStationAr: "بنكرير",
        SpeedKmh: 0, RouteProgress: 0.00,
        MessageFr: "Bienvenue à Marrakech",
        MessageAr: "مرحباً بكم في مراكش",
        ActiveAudioLang: "ar", AudioFile: "station_marrakech_ar.mp3",
    },
    // ── DEPARTING Marrakech ──────────────────────────────
    {
        State: "DEPARTING",
        CurrentStation: "Marrakech", CurrentStationFr: "Marrakech",
        CurrentStationAr: "مراكش",
        NextStation: "Benguerir", NextStationFr: "Benguerir",
        NextStationAr: "بنكرير",
        SpeedKmh: 20, RouteProgress: 0.01,
        MessageFr: "Prochain arrêt Benguerir",
        MessageAr: "المحطة القادمة بنكرير",
        ActiveAudioLang: "fr", AudioFile: "depart_marrakech_fr.mp3",
    },
    // ── MOVING → Benguerir ───────────────────────────────
    {
        State: "MOVING",
        CurrentStation: "Marrakech", CurrentStationFr: "Marrakech",
        CurrentStationAr: "مراكش",
        NextStation: "Benguerir", NextStationFr: "Benguerir",
        NextStationAr: "بنكرير",
        SpeedKmh: 140, RouteProgress: 0.06,
        MessageFr: "Prochain arrêt: Benguerir",
        MessageAr: "المحطة القادمة: بنكرير",
        ActiveAudioLang: "", AudioFile: "",
    },
    {
        State: "MOVING",
        CurrentStation: "Marrakech", CurrentStationFr: "Marrakech",
        CurrentStationAr: "مراكش",
        NextStation: "Benguerir", NextStationFr: "Benguerir",
        NextStationAr: "بنكرير",
        SpeedKmh: 180, RouteProgress: 0.11,
        MessageFr: "Prochain arrêt: Benguerir",
        MessageAr: "المحطة القادمة: بنكرير",
        ActiveAudioLang: "", AudioFile: "",
    },
    // ── ARRIVING Benguerir ───────────────────────────────
    {
        State: "ARRIVING",
        CurrentStation: "Marrakech", CurrentStationFr: "Marrakech",
        CurrentStationAr: "مراكش",
        NextStation: "Benguerir", NextStationFr: "Benguerir",
        NextStationAr: "بنكرير",
        SpeedKmh: 55, RouteProgress: 0.13,
        MessageFr: "Arrivée à Benguerir",
        MessageAr: "الوصول إلى بنكرير",
        ActiveAudioLang: "ar", AudioFile: "arriving_benguerir_ar.mp3",
    },
    // ── AT STATION — Benguerir ───────────────────────────
    {
        State: "AT_STATION",
        CurrentStation: "Benguerir", CurrentStationFr: "Benguerir",
        CurrentStationAr: "بنكرير",
        NextStation: "Settat", NextStationFr: "Settat",
        NextStationAr: "سطات",
        SpeedKmh: 0, RouteProgress: 0.14,
        MessageFr: "Bienvenue à Benguerir",
        MessageAr: "مرحباً بكم في بنكرير",
        ActiveAudioLang: "fr", AudioFile: "station_benguerir_fr.mp3",
    },
    // ── DEPARTING Benguerir ──────────────────────────────
    {
        State: "DEPARTING",
        CurrentStation: "Benguerir", CurrentStationFr: "Benguerir",
        CurrentStationAr: "بنكرير",
        NextStation: "Settat", NextStationFr: "Settat",
        NextStationAr: "سطات",
        SpeedKmh: 25, RouteProgress: 0.15,
        MessageFr: "Prochain arrêt Settat",
        MessageAr: "المحطة القادمة سطات",
        ActiveAudioLang: "ar", AudioFile: "depart_benguerir_ar.mp3",
    },
    // ── MOVING → Settat ──────────────────────────────────
    {
        State: "MOVING",
        CurrentStation: "Benguerir", CurrentStationFr: "Benguerir",
        CurrentStationAr: "بنكرير",
        NextStation: "Settat", NextStationFr: "Settat",
        NextStationAr: "سطات",
        SpeedKmh: 160, RouteProgress: 0.20,
        ActiveAudioLang: "", AudioFile: "",
    },
    {
        State: "MOVING",
        CurrentStation: "Benguerir", CurrentStationFr: "Benguerir",
        CurrentStationAr: "بنكرير",
        NextStation: "Settat", NextStationFr: "Settat",
        NextStationAr: "سطات",
        SpeedKmh: 185, RouteProgress: 0.25,
        ActiveAudioLang: "", AudioFile: "",
    },
    // ── ARRIVING Settat ──────────────────────────────────
    {
        State: "ARRIVING",
        CurrentStation: "Benguerir", CurrentStationFr: "Benguerir",
        CurrentStationAr: "بنكرير",
        NextStation: "Settat", NextStationFr: "Settat",
        NextStationAr: "سطات",
        SpeedKmh: 60, RouteProgress: 0.27,
        MessageFr: "Arrivée à Settat",
        MessageAr: "الوصول إلى سطات",
        ActiveAudioLang: "fr", AudioFile: "arriving_settat_fr.mp3",
    },
    // ── AT STATION — Settat ──────────────────────────────
    {
        State: "AT_STATION",
        CurrentStation: "Settat", CurrentStationFr: "Settat",
        CurrentStationAr: "سطات",
        NextStation: "Casablanca Voyageurs",
        NextStationFr: "Casablanca Voyageurs",
        NextStationAr: "الدار البيضاء المسافرين",
        SpeedKmh: 0, RouteProgress: 0.28,
        MessageFr: "Bienvenue à Settat",
        MessageAr: "مرحباً بكم في سطات",
        ActiveAudioLang: "ar", AudioFile: "station_settat_ar.mp3",
    },
    // ── DEPARTING Settat ─────────────────────────────────
    {
        State: "DEPARTING",
        CurrentStation: "Settat", CurrentStationFr: "Settat",
        CurrentStationAr: "سطات",
        NextStation: "Casablanca Voyageurs",
        NextStationFr: "Casablanca Voyageurs",
        NextStationAr: "الدار البيضاء المسافرين",
        SpeedKmh: 30, RouteProgress: 0.30,
        MessageFr: "Prochain arrêt Casablanca",
        MessageAr: "المحطة القادمة الدار البيضاء",
        ActiveAudioLang: "fr", AudioFile: "depart_settat_fr.mp3",
    },
    // ── MOVING → Casablanca ──────────────────────────────
    {
        State: "MOVING",
        CurrentStation: "Settat", CurrentStationFr: "Settat",
        CurrentStationAr: "سطات",
        NextStation: "Casablanca Voyageurs",
        NextStationFr: "Casablanca Voyageurs",
        NextStationAr: "الدار البيضاء المسافرين",
        SpeedKmh: 170, RouteProgress: 0.36,
        ActiveAudioLang: "", AudioFile: "",
    },
    {
        State: "MOVING",
        CurrentStation: "Settat", CurrentStationFr: "Settat",
        CurrentStationAr: "سطات",
        NextStation: "Casablanca Voyageurs",
        NextStationFr: "Casablanca Voyageurs",
        NextStationAr: "الدار البيضاء المسافرين",
        SpeedKmh: 190, RouteProgress: 0.40,
        ActiveAudioLang: "", AudioFile: "",
    },
    // ── ARRIVING Casablanca ──────────────────────────────
    {
        State: "ARRIVING",
        CurrentStation: "Settat", CurrentStationFr: "Settat",
        CurrentStationAr: "سطات",
        NextStation: "Casablanca Voyageurs",
        NextStationFr: "Casablanca Voyageurs",
        NextStationAr: "الدار البيضاء المسافرين",
        SpeedKmh: 50, RouteProgress: 0.42,
        MessageFr: "Arrivée à Casablanca",
        MessageAr: "الوصول إلى الدار البيضاء",
        ActiveAudioLang: "ar", AudioFile: "arriving_casa_ar.mp3",
    },
    // ── AT STATION — Casablanca ──────────────────────────
    {
        State: "AT_STATION",
        CurrentStation: "Casablanca Voyageurs",
        CurrentStationFr: "Casablanca Voyageurs",
        CurrentStationAr: "الدار البيضاء المسافرين",
        NextStation: "Rabat Agdal",
        NextStationFr: "Rabat Agdal",
        NextStationAr: "الرباط أكدال",
        SpeedKmh: 0, RouteProgress: 0.43,
        MessageFr: "Bienvenue à Casablanca",
        MessageAr: "مرحباً بكم في الدار البيضاء",
        ActiveAudioLang: "fr", AudioFile: "station_casa_fr.mp3",
    },
    // ── DEPARTING Casablanca ─────────────────────────────
    {
        State: "DEPARTING",
        CurrentStation: "Casablanca Voyageurs",
        CurrentStationFr: "Casablanca Voyageurs",
        CurrentStationAr: "الدار البيضاء المسافرين",
        NextStation: "Rabat Agdal",
        NextStationFr: "Rabat Agdal",
        NextStationAr: "الرباط أكدال",
        SpeedKmh: 25, RouteProgress: 0.45,
        MessageFr: "Prochain arrêt Rabat",
        MessageAr: "المحطة القادمة الرباط",
        ActiveAudioLang: "ar", AudioFile: "depart_casa_ar.mp3",
    },
    // ── MOVING → Rabat ───────────────────────────────────
    {
        State: "MOVING",
        CurrentStation: "Casablanca Voyageurs",
        CurrentStationFr: "Casablanca Voyageurs",
        CurrentStationAr: "الدار البيضاء المسافرين",
        NextStation: "Rabat Agdal",
        NextStationFr: "Rabat Agdal",
        NextStationAr: "الرباط أكدال",
        SpeedKmh: 155, RouteProgress: 0.52,
        ActiveAudioLang: "", AudioFile: "",
    },
    {
        State: "MOVING",
        CurrentStation: "Casablanca Voyageurs",
        CurrentStationFr: "Casablanca Voyageurs",
        CurrentStationAr: "الدار البيضاء المسافرين",
        NextStation: "Rabat Agdal",
        NextStationFr: "Rabat Agdal",
        NextStationAr: "الرباط أكدال",
        SpeedKmh: 175, RouteProgress: 0.56,
        ActiveAudioLang: "", AudioFile: "",
    },
    // ── ARRIVING Rabat ───────────────────────────────────
    {
        State: "ARRIVING",
        CurrentStation: "Casablanca Voyageurs",
        CurrentStationFr: "Casablanca Voyageurs",
        CurrentStationAr: "الدار البيضاء المسافرين",
        NextStation: "Rabat Agdal",
        NextStationFr: "Rabat Agdal",
        NextStationAr: "الرباط أكدال",
        SpeedKmh: 55, RouteProgress: 0.57,
        MessageFr: "Arrivée à Rabat",
        MessageAr: "الوصول إلى الرباط",
        ActiveAudioLang: "fr", AudioFile: "arriving_rabat_fr.mp3",
    },
    // ── AT STATION — Rabat ───────────────────────────────
    {
        State: "AT_STATION",
        CurrentStation: "Rabat Agdal",
        CurrentStationFr: "Rabat Agdal",
        CurrentStationAr: "الرباط أكدال",
        NextStation: "Kénitra",
        NextStationFr: "Kénitra",
        NextStationAr: "القنيطرة",
        SpeedKmh: 0, RouteProgress: 0.57,
        MessageFr: "Bienvenue à Rabat",
        MessageAr: "مرحباً بكم في الرباط",
        ActiveAudioLang: "ar", AudioFile: "station_rabat_ar.mp3",
    },
    // ── DEPARTING Rabat ──────────────────────────────────
    {
        State: "DEPARTING",
        CurrentStation: "Rabat Agdal",
        CurrentStationFr: "Rabat Agdal",
        CurrentStationAr: "الرباط أكدال",
        NextStation: "Kénitra",
        NextStationFr: "Kénitra",
        NextStationAr: "القنيطرة",
        SpeedKmh: 30, RouteProgress: 0.59,
        MessageFr: "Prochain arrêt Kénitra",
        MessageAr: "المحطة القادمة القنيطرة",
        ActiveAudioLang: "fr", AudioFile: "depart_rabat_fr.mp3",
    },
    // ── MOVING → Kénitra ─────────────────────────────────
    {
        State: "MOVING",
        CurrentStation: "Rabat Agdal",
        CurrentStationFr: "Rabat Agdal",
        CurrentStationAr: "الرباط أكدال",
        NextStation: "Kénitra",
        NextStationFr: "Kénitra",
        NextStationAr: "القنيطرة",
        SpeedKmh: 150, RouteProgress: 0.64,
        ActiveAudioLang: "", AudioFile: "",
    },
    // ── ARRIVING Kénitra ─────────────────────────────────
    {
        State: "ARRIVING",
        CurrentStation: "Rabat Agdal",
        CurrentStationFr: "Rabat Agdal",
        CurrentStationAr: "الرباط أكدال",
        NextStation: "Kénitra",
        NextStationFr: "Kénitra",
        NextStationAr: "القنيطرة",
        SpeedKmh: 50, RouteProgress: 0.66,
        MessageFr: "Arrivée à Kénitra",
        MessageAr: "الوصول إلى القنيطرة",
        ActiveAudioLang: "ar", AudioFile: "arriving_kenitra_ar.mp3",
    },
    // ── AT STATION — Kénitra ─────────────────────────────
    {
        State: "AT_STATION",
        CurrentStation: "Kénitra",
        CurrentStationFr: "Kénitra",
        CurrentStationAr: "القنيطرة",
        NextStation: "Meknès",
        NextStationFr: "Meknès",
        NextStationAr: "مكناس",
        SpeedKmh: 0, RouteProgress: 0.67,
        MessageFr: "Bienvenue à Kénitra",
        MessageAr: "مرحباً بكم في القنيطرة",
        ActiveAudioLang: "fr", AudioFile: "station_kenitra_fr.mp3",
    },
    // ── DEPARTING Kénitra ────────────────────────────────
    {
        State: "DEPARTING",
        CurrentStation: "Kénitra",
        CurrentStationFr: "Kénitra",
        CurrentStationAr: "القنيطرة",
        NextStation: "Meknès",
        NextStationFr: "Meknès",
        NextStationAr: "مكناس",
        SpeedKmh: 25, RouteProgress: 0.69,
        MessageFr: "Prochain arrêt Meknès",
        MessageAr: "المحطة القادمة مكناس",
        ActiveAudioLang: "ar", AudioFile: "depart_kenitra_ar.mp3",
    },
    // ── MOVING → Meknès ──────────────────────────────────
    {
        State: "MOVING",
        CurrentStation: "Kénitra",
        CurrentStationFr: "Kénitra",
        CurrentStationAr: "القنيطرة",
        NextStation: "Meknès",
        NextStationFr: "Meknès",
        NextStationAr: "مكناس",
        SpeedKmh: 160, RouteProgress: 0.75,
        ActiveAudioLang: "", AudioFile: "",
    },
    {
        State: "MOVING",
        CurrentStation: "Kénitra",
        CurrentStationFr: "Kénitra",
        CurrentStationAr: "القنيطرة",
        NextStation: "Meknès",
        NextStationFr: "Meknès",
        NextStationAr: "مكناس",
        SpeedKmh: 185, RouteProgress: 0.80,
        ActiveAudioLang: "", AudioFile: "",
    },
    // ── ARRIVING Meknès ──────────────────────────────────
    {
        State: "ARRIVING",
        CurrentStation: "Kénitra",
        CurrentStationFr: "Kénitra",
        CurrentStationAr: "القنيطرة",
        NextStation: "Meknès",
        NextStationFr: "Meknès",
        NextStationAr: "مكناس",
        SpeedKmh: 50, RouteProgress: 0.82,
        MessageFr: "Arrivée à Meknès",
        MessageAr: "الوصول إلى مكناس",
        ActiveAudioLang: "fr", AudioFile: "arriving_meknes_fr.mp3",
    },
    // ── AT STATION — Meknès ──────────────────────────────
    {
        State: "AT_STATION",
        CurrentStation: "Meknès",
        CurrentStationFr: "Meknès",
        CurrentStationAr: "مكناس",
        NextStation: "Fès",
        NextStationFr: "Fès",
        NextStationAr: "فاس",
        SpeedKmh: 0, RouteProgress: 0.83,
        MessageFr: "Bienvenue à Meknès",
        MessageAr: "مرحباً بكم في مكناس",
        ActiveAudioLang: "ar", AudioFile: "station_meknes_ar.mp3",
    },
    // ── DEPARTING Meknès ─────────────────────────────────
    {
        State: "DEPARTING",
        CurrentStation: "Meknès",
        CurrentStationFr: "Meknès",
        CurrentStationAr: "مكناس",
        NextStation: "Fès",
        NextStationFr: "Fès",
        NextStationAr: "فاس",
        SpeedKmh: 25, RouteProgress: 0.85,
        MessageFr: "Prochain arrêt Fès — terminus",
        MessageAr: "المحطة القادمة فاس — المحطة النهائية",
        ActiveAudioLang: "fr", AudioFile: "depart_meknes_fr.mp3",
    },
    // ── MOVING → Fès ─────────────────────────────────────
    {
        State: "MOVING",
        CurrentStation: "Meknès",
        CurrentStationFr: "Meknès",
        CurrentStationAr: "مكناس",
        NextStation: "Fès",
        NextStationFr: "Fès",
        NextStationAr: "فاس",
        SpeedKmh: 155, RouteProgress: 0.90,
        ActiveAudioLang: "", AudioFile: "",
    },
    {
        State: "MOVING",
        CurrentStation: "Meknès",
        CurrentStationFr: "Meknès",
        CurrentStationAr: "مكناس",
        NextStation: "Fès",
        NextStationFr: "Fès",
        NextStationAr: "فاس",
        SpeedKmh: 175, RouteProgress: 0.94,
        ActiveAudioLang: "", AudioFile: "",
    },
    // ── ARRIVING Fès ─────────────────────────────────────
    {
        State: "ARRIVING",
        CurrentStation: "Meknès",
        CurrentStationFr: "Meknès",
        CurrentStationAr: "مكناس",
        NextStation: "Fès",
        NextStationFr: "Fès",
        NextStationAr: "فاس",
        SpeedKmh: 45, RouteProgress: 0.97,
        MessageFr: "Arrivée à Fès — terminus",
        MessageAr: "الوصول إلى فاس — المحطة النهائية",
        ActiveAudioLang: "ar", AudioFile: "arriving_fes_ar.mp3",
    },
    // ── AT STATION — Fès (final) ─────────────────────────
    {
        State: "AT_STATION",
        CurrentStation: "Fès",
        CurrentStationFr: "Fès",
        CurrentStationAr: "فاس",
        NextStation: "Fès",
        NextStationFr: "Fès",
        NextStationAr: "فاس",
        SpeedKmh: 0, RouteProgress: 1.00,
        MessageFr: "Bienvenue à Fès. Terminus.",
        MessageAr: "مرحباً بكم في فاس. المحطة النهائية.",
        ActiveAudioLang: "fr", AudioFile: "terminus_fes_fr.mp3",
    },
    // ── END OF ROUTE ─────────────────────────────────────
    {
        State: "END_OF_ROUTE",
        CurrentStation: "Fès",
        CurrentStationFr: "Fès",
        CurrentStationAr: "فاس",
        NextStation: "Fès",
        NextStationFr: "Fès",
        NextStationAr: "فاس",
        SpeedKmh: 0, RouteProgress: 1.00,
        MessageFr: "Merci de voyager avec l'ONCF.",
        MessageAr: "شكراً لسفركم مع المكتب الوطني للسكك الحديدية.",
        ActiveAudioLang: "ar", AudioFile: "endofroute_ar.mp3",
    },
}

func fillJourney() {
    for i := range journey {
        journey[i].TrainID         = "DOVE-6"
        journey[i].Destination     = "Fès"
        journey[i].DestinationFr   = "Fès"
        journey[i].DestinationAr   = "فاس"
        journey[i].RouteStations   = routeFr
        journey[i].RouteStationsFr = routeFr
        journey[i].RouteStationsAr = routeAr
    }
}
```

## VERIFY

After implementing run:
```bash
go run . &
sleep 2
curl http://localhost:8080/state | python3 -m json.tool
pkill -f "go run"
```

Confirm output contains:
- route_stations with 8 stations
- route_stations_ar with 8 Arabic names
- current_station_ar in Arabic
- next_station_ar in Arabic
- active_audio_lang field present