package main

import (
	"encoding/json"
	"fmt"
	"net/http"
	"strconv"
	"strings"
	"sync"
)

// mu protects currentStep so reading and writing is safe
var (
	currentStep int
	mu          sync.RWMutex
)

func currentStepData() Step {
	mu.RLock()
	defer mu.RUnlock()
	return journey[currentStep]
}

func setStep(n int) {
	mu.Lock()
	defer mu.Unlock()
	if n >= 0 && n < len(journey) {
		currentStep = n
	}
}

func toNvrState(s string) string {
	switch s {
	case "IDLE":
		return "operating_state_idle"
	case "ROUTE_SELECTED":
		return "operating_state_routeselected"
	case "AT_STATION":
		return "operating_state_atstation"
	case "DEPARTING":
		return "operating_state_departing"
	case "MOVING":
		return "operating_state_moving"
	case "ARRIVING":
		return "operating_state_arriving"
	case "END_OF_ROUTE":
		return "operating_state_endofroute"
	case "WARNING":
		return "operating_state_warning"
	case "MANUAL":
		return "Operating_State_ManualHandling"
	case "RECOVERY":
		return "operating_state_recovery"
	default:
		return "operating_state_idle"
	}
}

func toAudioAction(lang string) string {
	switch lang {
	case "ar":
		return "playing_arabic_audio"
	case "fr":
		return "playing_french_audio"
	case "en":
		return "playing_english_audio"
	default:
		return "no_audio_is_playing"
	}
}

func currentStationIndex(step Step) int {
	for i, s := range activeRoute.StationsFr {
		if s == step.CurrentStation {
			return i
		}
	}
	return 0
}

func setupRoutes() {

	// GET /running-state
	http.HandleFunc("/running-state", func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		w.Header().Set("Access-Control-Allow-Origin", "*")
		step := currentStepData()
		stateStr := toNvrState(step.State)
		json.NewEncoder(w).Encode(map[string]string{
			"current_state": stateStr,
		})
	})

	// GET /audio-state
	http.HandleFunc("/audio-state", func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		w.Header().Set("Access-Control-Allow-Origin", "*")
		step := currentStepData()
		action := toAudioAction(step.ActiveAudioLang)
		json.NewEncoder(w).Encode(map[string]string{
			"audio_action": action,
		})
	})

	// GET /data/speed
	http.HandleFunc("/data/speed", func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		w.Header().Set("Access-Control-Allow-Origin", "*")
		step := currentStepData()
		json.NewEncoder(w).Encode(map[string]float64{
			"speed": step.SpeedKmh,
		})
	})

	// GET /data/distance-ratio
	http.HandleFunc("/data/distance-ratio", func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		w.Header().Set("Access-Control-Allow-Origin", "*")
		step := currentStepData()
		ratio := int(step.RouteProgress * 100)
		json.NewEncoder(w).Encode(map[string]int{
			"ratio": ratio,
		})
	})

	// GET /data/current-route
	http.HandleFunc("/data/current-route", func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		w.Header().Set("Access-Control-Allow-Origin", "*")
		step := currentStepData()
		stationIdx := currentStationIndex(step)
		json.NewEncoder(w).Encode(map[string]interface{}{
			"route_id":            "dove6-route-001",
			"is_in_reverse":       false,
			"start_station_index": stationIdx,
		})
	})

	// GET /data/stations-in-route/{route_id}
	http.HandleFunc("/data/stations-in-route/", func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		w.Header().Set("Access-Control-Allow-Origin", "*")
		ids := make([]string, len(activeRoute.StationsFr))
		for i := range activeRoute.StationsFr {
			ids[i] = fmt.Sprintf("st-%03d", i+1)
		}
		json.NewEncoder(w).Encode(ids)
	})

	// GET /data/station-info/{station_id}
	http.HandleFunc("/data/station-info/", func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		w.Header().Set("Access-Control-Allow-Origin", "*")
		path := r.URL.Path
		parts := strings.Split(path, "/")
		idStr := parts[len(parts)-1]
		idx := 0
		fmt.Sscanf(idStr, "st-%d", &idx)
		idx = idx - 1 // convert to 0-based
		if idx < 0 || idx >= len(activeRoute.StationsFr) {
			http.Error(w, "station not found", http.StatusNotFound)
			return
		}
		json.NewEncoder(w).Encode(map[string]string{
			"display_name":    strings.ToLower(activeRoute.StationsFr[idx]),
			"display_name_fr": activeRoute.StationsFr[idx],
			"display_name_en": activeRoute.StationsFr[idx],
			"display_name_ar": activeRoute.StationsAr[idx],
		})
	})

	// GET /sensors/human-counter
	http.HandleFunc("/sensors/human-counter", func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		w.Header().Set("Access-Control-Allow-Origin", "*")
		json.NewEncoder(w).Encode(map[string]int{
			"count": 42,
		})
	})

	// GET /health
	// Flutter checks this on startup to confirm the server is reachable.
	http.HandleFunc("/health", func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		w.Write([]byte(`{"status":"ok","server":"dove6_server"}`))
	})

	// GET /jump?step=N
	// Manually jump to any step during a demo.
	// Example: open browser → http://localhost:8080/jump?step=4
	http.HandleFunc("/jump", func(w http.ResponseWriter, r *http.Request) {
		n, err := strconv.Atoi(r.URL.Query().Get("step"))
		if err != nil {
			http.Error(w, "usage: /jump?step=0", http.StatusBadRequest)
			return
		}
		setStep(n)
		mu.RLock()
		fmt.Printf("[DOVE6] Manual jump → Step %d/%d: %s\n",
			currentStep+1, len(journey), journey[currentStep].State)
		mu.RUnlock()
		w.Header().Set("Content-Type", "application/json")
		json.NewEncoder(w).Encode(currentStepData())
	})
}
