package main

import "time"

// stepDuration controls how long each state is shown.
// Increase this to slow down the demo. Decrease to speed it up.
const stepDuration = 5 * time.Second

type Step struct {
	State          string   `json:"state"`
	TrainID        string   `json:"train_id"`
	CurrentStation string   `json:"current_station"`
	NextStation    string   `json:"next_station"`
	Destination    string   `json:"destination"`
	SpeedKmh       float64  `json:"speed_kmh"`
	RouteProgress  float64  `json:"route_progress"`
	RouteStations  []string `json:"route_stations"`
}

var route = []string{
	"Casa Voyageurs",
	"Rabat Agdal",
	"Kenitra",
	"Tanger Ville",
}

var journey = []Step{
	{State: "IDLE",           CurrentStation: "Casa Voyageurs", NextStation: "Rabat Agdal",  SpeedKmh: 0,   RouteProgress: 0.00},
	{State: "ROUTE_SELECTED", CurrentStation: "Casa Voyageurs", NextStation: "Rabat Agdal",  SpeedKmh: 0,   RouteProgress: 0.00},
	{State: "AT_STATION",     CurrentStation: "Casa Voyageurs", NextStation: "Rabat Agdal",  SpeedKmh: 0,   RouteProgress: 0.00},
	{State: "DEPARTING",      CurrentStation: "Casa Voyageurs", NextStation: "Rabat Agdal",  SpeedKmh: 20,  RouteProgress: 0.02},
	{State: "MOVING",         CurrentStation: "Casa Voyageurs", NextStation: "Rabat Agdal",  SpeedKmh: 120, RouteProgress: 0.15},
	{State: "MOVING",         CurrentStation: "Casa Voyageurs", NextStation: "Rabat Agdal",  SpeedKmh: 175, RouteProgress: 0.28},
	{State: "ARRIVING",       CurrentStation: "Casa Voyageurs", NextStation: "Rabat Agdal",  SpeedKmh: 60,  RouteProgress: 0.32},
	{State: "AT_STATION",     CurrentStation: "Rabat Agdal",    NextStation: "Kenitra",      SpeedKmh: 0,   RouteProgress: 0.33},
	{State: "DEPARTING",      CurrentStation: "Rabat Agdal",    NextStation: "Kenitra",      SpeedKmh: 25,  RouteProgress: 0.35},
	{State: "MOVING",         CurrentStation: "Rabat Agdal",    NextStation: "Kenitra",      SpeedKmh: 150, RouteProgress: 0.50},
	{State: "MOVING",         CurrentStation: "Rabat Agdal",    NextStation: "Kenitra",      SpeedKmh: 185, RouteProgress: 0.62},
	{State: "ARRIVING",       CurrentStation: "Rabat Agdal",    NextStation: "Kenitra",      SpeedKmh: 55,  RouteProgress: 0.65},
	{State: "AT_STATION",     CurrentStation: "Kenitra",        NextStation: "Tanger Ville", SpeedKmh: 0,   RouteProgress: 0.66},
	{State: "DEPARTING",      CurrentStation: "Kenitra",        NextStation: "Tanger Ville", SpeedKmh: 30,  RouteProgress: 0.68},
	{State: "MOVING",         CurrentStation: "Kenitra",        NextStation: "Tanger Ville", SpeedKmh: 160, RouteProgress: 0.80},
	{State: "MOVING",         CurrentStation: "Kenitra",        NextStation: "Tanger Ville", SpeedKmh: 195, RouteProgress: 0.92},
	{State: "ARRIVING",       CurrentStation: "Kenitra",        NextStation: "Tanger Ville", SpeedKmh: 40,  RouteProgress: 0.96},
	{State: "AT_STATION",     CurrentStation: "Tanger Ville",   NextStation: "Tanger Ville", SpeedKmh: 0,   RouteProgress: 1.00},
	{State: "END_OF_ROUTE",   CurrentStation: "Tanger Ville",   NextStation: "Tanger Ville", SpeedKmh: 0,   RouteProgress: 1.00},
}

// fillJourney adds the fields that are the same for every step
func fillJourney() {
	for i := range journey {
		journey[i].TrainID       = "DOVE-6"
		journey[i].Destination   = "Tanger Ville"
		journey[i].RouteStations = route
	}
}