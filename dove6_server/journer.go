// journer.go — defines the Step struct and the simulated journey sequence
package main

import "time"

// stepDuration controls how long each state is shown.
// Increase this to slow down the demo. Decrease to speed it up.
const stepDuration = 5 * time.Second

type Step struct {
	State           string   `json:"state"`
	TrainID         string   `json:"train_id"`
	CurrentStation  string   `json:"current_station"`
	NextStation     string   `json:"next_station"`
	Destination     string   `json:"destination"`
	SpeedKmh        float64  `json:"speed_kmh"`
	RouteProgress   float64  `json:"route_progress"`
	RouteStations   []string `json:"route_stations"`
	ActiveAudioLang string   `json:"active_audio_lang"`
}

var routeFr = []string{
	"Casa Voyageurs",
	"Rabat Ville",
	"Kénitra",
	"Tanger Ville",
}

var routeAr = []string{
	"الدار البيضاء المسافرين",
	"الرباط المدينة",
	"القنيطرة",
	"طنجة المدينة",
}

var journey = []Step{
	// ── Casa Voyageurs segment (audio: ar) ───────────────────────────────
	{State: "IDLE",           CurrentStation: "Casa Voyageurs", NextStation: "Rabat Ville",  SpeedKmh: 0,   RouteProgress: 0.00, ActiveAudioLang: "ar"},
	{State: "ROUTE_SELECTED", CurrentStation: "Casa Voyageurs", NextStation: "Rabat Ville",  SpeedKmh: 0,   RouteProgress: 0.00, ActiveAudioLang: "ar"},
	{State: "AT_STATION",     CurrentStation: "Casa Voyageurs", NextStation: "Rabat Ville",  SpeedKmh: 0,   RouteProgress: 0.00, ActiveAudioLang: "ar"},
	{State: "DEPARTING",      CurrentStation: "Casa Voyageurs", NextStation: "Rabat Ville",  SpeedKmh: 20,  RouteProgress: 0.02, ActiveAudioLang: "ar"},
	{State: "MOVING",         CurrentStation: "Casa Voyageurs", NextStation: "Rabat Ville",  SpeedKmh: 120, RouteProgress: 0.15, ActiveAudioLang: "ar"},
	{State: "MOVING",         CurrentStation: "Casa Voyageurs", NextStation: "Rabat Ville",  SpeedKmh: 175, RouteProgress: 0.28, ActiveAudioLang: "ar"},
	{State: "ARRIVING",       CurrentStation: "Casa Voyageurs", NextStation: "Rabat Ville",  SpeedKmh: 60,  RouteProgress: 0.32, ActiveAudioLang: "ar"},
	// ── Rabat Ville segment (audio: fr) ──────────────────────────────────
	{State: "AT_STATION",     CurrentStation: "Rabat Ville",    NextStation: "Kénitra",      SpeedKmh: 0,   RouteProgress: 0.33, ActiveAudioLang: "fr"},
	{State: "DEPARTING",      CurrentStation: "Rabat Ville",    NextStation: "Kénitra",      SpeedKmh: 25,  RouteProgress: 0.35, ActiveAudioLang: "fr"},
	{State: "MOVING",         CurrentStation: "Rabat Ville",    NextStation: "Kénitra",      SpeedKmh: 150, RouteProgress: 0.50, ActiveAudioLang: "fr"},
	{State: "MOVING",         CurrentStation: "Rabat Ville",    NextStation: "Kénitra",      SpeedKmh: 185, RouteProgress: 0.62, ActiveAudioLang: "fr"},
	{State: "ARRIVING",       CurrentStation: "Rabat Ville",    NextStation: "Kénitra",      SpeedKmh: 55,  RouteProgress: 0.65, ActiveAudioLang: "fr"},
	// ── Kénitra segment (audio: ar) ───────────────────────────────────────
	{State: "AT_STATION",     CurrentStation: "Kénitra",        NextStation: "Tanger Ville", SpeedKmh: 0,   RouteProgress: 0.66, ActiveAudioLang: "ar"},
	{State: "DEPARTING",      CurrentStation: "Kénitra",        NextStation: "Tanger Ville", SpeedKmh: 30,  RouteProgress: 0.68, ActiveAudioLang: "ar"},
	{State: "MOVING",         CurrentStation: "Kénitra",        NextStation: "Tanger Ville", SpeedKmh: 160, RouteProgress: 0.80, ActiveAudioLang: "ar"},
	{State: "MOVING",         CurrentStation: "Kénitra",        NextStation: "Tanger Ville", SpeedKmh: 195, RouteProgress: 0.92, ActiveAudioLang: "ar"},
	{State: "ARRIVING",       CurrentStation: "Kénitra",        NextStation: "Tanger Ville", SpeedKmh: 40,  RouteProgress: 0.96, ActiveAudioLang: "ar"},
	// ── Tanger Ville segment (audio: fr) ─────────────────────────────────
	{State: "AT_STATION",     CurrentStation: "Tanger Ville",   NextStation: "Tanger Ville", SpeedKmh: 0,   RouteProgress: 1.00, ActiveAudioLang: "fr"},
	{State: "END_OF_ROUTE",   CurrentStation: "Tanger Ville",   NextStation: "Tanger Ville", SpeedKmh: 0,   RouteProgress: 1.00, ActiveAudioLang: "fr"},
}

// fillJourney adds the fields that are the same for every step.
func fillJourney() {
	for i := range journey {
		journey[i].TrainID       = "DOVE-6"
		journey[i].Destination   = "Tanger Ville"
		journey[i].RouteStations = routeFr
	}
}
