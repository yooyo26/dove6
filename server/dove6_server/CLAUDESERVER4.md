# CLAUDESERVER4.md — Match Real NVR API Contract

## Mission
Update dove6_server to expose the same endpoints as the
real NVR (R6S Lanner) described in the colleague README.
The fake server must be a perfect simulation of the real one.
Keep the journey script exactly as it is.
Only change how data is exposed via HTTP endpoints.

---

## CRITICAL RULES
- Keep journey.go script exactly as is
- Keep /health endpoint exactly as is
- Keep /jump endpoint exactly as is
- Keep stepDuration constant
- Only add new endpoints and remove old /state endpoint
- No external Go packages — standard library only
- Port stays 8080

---

## REMOVE
Delete the old /state endpoint from handler.go completely.

---

## ADD these new endpoints in handler.go

All endpoints read from the current journey step
via currentStepData().

### GET /running-state
```go
http.HandleFunc("/running-state", func(w http.ResponseWriter, r *http.Request) {
    w.Header().Set("Content-Type", "application/json")
    w.Header().Set("Access-Control-Allow-Origin", "*")
    step := currentStepData()
    stateStr := toNvrState(step.State)
    json.NewEncoder(w).Encode(map[string]string{
        "current_state": stateStr,
    })
})
```

### GET /audio-state
```go
http.HandleFunc("/audio-state", func(w http.ResponseWriter, r *http.Request) {
    w.Header().Set("Content-Type", "application/json")
    w.Header().Set("Access-Control-Allow-Origin", "*")
    step := currentStepData()
    action := toAudioAction(step.ActiveAudioLang)
    json.NewEncoder(w).Encode(map[string]string{
        "audio_action": action,
    })
})
```

### GET /data/speed
```go
http.HandleFunc("/data/speed", func(w http.ResponseWriter, r *http.Request) {
    w.Header().Set("Content-Type", "application/json")
    w.Header().Set("Access-Control-Allow-Origin", "*")
    step := currentStepData()
    json.NewEncoder(w).Encode(map[string]float64{
        "speed": step.SpeedKmh,
    })
})
```

### GET /data/distance-ratio
```go
http.HandleFunc("/data/distance-ratio", func(w http.ResponseWriter, r *http.Request) {
    w.Header().Set("Content-Type", "application/json")
    w.Header().Set("Access-Control-Allow-Origin", "*")
    step := currentStepData()
    ratio := int(step.RouteProgress * 100)
    json.NewEncoder(w).Encode(map[string]int{
        "ratio": ratio,
    })
})
```

### GET /data/current-route
```go
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
```

### GET /data/stations-in-route/{route_id}
```go
http.HandleFunc("/data/stations-in-route/", func(w http.ResponseWriter, r *http.Request) {
    w.Header().Set("Content-Type", "application/json")
    w.Header().Set("Access-Control-Allow-Origin", "*")
    ids := make([]string, len(routeFr))
    for i := range routeFr {
        ids[i] = fmt.Sprintf("st-%03d", i+1)
    }
    json.NewEncoder(w).Encode(ids)
})
```

### GET /data/station-info/{station_id}
```go
http.HandleFunc("/data/station-info/", func(w http.ResponseWriter, r *http.Request) {
    w.Header().Set("Content-Type", "application/json")
    w.Header().Set("Access-Control-Allow-Origin", "*")
    // Extract station ID from path
    path  := r.URL.Path
    parts := strings.Split(path, "/")
    idStr := parts[len(parts)-1]
    // Parse index from id format "st-001"
    idx := 0
    fmt.Sscanf(idStr, "st-%d", &idx)
    idx = idx - 1 // convert to 0-based
    if idx < 0 || idx >= len(routeFr) {
        http.Error(w, "station not found", http.StatusNotFound)
        return
    }
    json.NewEncoder(w).Encode(map[string]string{
        "display_name":    strings.ToLower(routeFr[idx]),
        "display_name_fr": routeFr[idx],
        "display_name_en": routeFr[idx],
        "display_name_ar": routeAr[idx],
    })
})
```

### GET /sensors/human-counter
```go
http.HandleFunc("/sensors/human-counter", func(w http.ResponseWriter, r *http.Request) {
    w.Header().Set("Content-Type", "application/json")
    w.Header().Set("Access-Control-Allow-Origin", "*")
    json.NewEncoder(w).Encode(map[string]int{
        "count": 42,
    })
})
```

---

## ADD these helper functions in handler.go

```go
func toNvrState(s string) string {
    switch s {
    case "IDLE":           return "operating_state_idle"
    case "ROUTE_SELECTED": return "operating_state_routeselected"
    case "AT_STATION":     return "operating_state_atstation"
    case "DEPARTING":      return "operating_state_departing"
    case "MOVING":         return "operating_state_moving"
    case "ARRIVING":       return "operating_state_arriving"
    case "END_OF_ROUTE":   return "operating_state_endofroute"
    case "WARNING":        return "operating_state_warning"
    case "MANUAL":         return "Operating_State_ManualHandling"
    case "RECOVERY":       return "operating_state_recovery"
    default:               return "operating_state_idle"
    }
}

func toAudioAction(lang string) string {
    switch lang {
    case "ar": return "playing_arabic_audio"
    case "fr": return "playing_french_audio"
    case "en": return "playing_english_audio"
    default:   return "no_audio_is_playing"
    }
}

func currentStationIndex(step Step) int {
    for i, s := range routeFr {
        if s == step.CurrentStation {
            return i
        }
    }
    return 0
}
```

---

## ADD import "strings" and "fmt" to handler.go imports
Make sure handler.go imports:
```go
import (
    "encoding/json"
    "fmt"
    "net/http"
    "strconv"
    "strings"
    "sync"
)
```

---

## UPDATE main.go startup box
Replace the startup box text with:

```
┌──────────────────────────────────────────────────┐
│         DOVE6 NVR Server v2.0                    │
│         Matching real NVR API contract           │
│                                                  │
│  GET /running-state          current state       │
│  GET /audio-state            audio language      │
│  GET /data/speed             current speed       │
│  GET /data/distance-ratio    route progress      │
│  GET /data/current-route     route info          │
│  GET /data/stations-in-route/:id  station ids   │
│  GET /data/station-info/:id  station names       │
│  GET /sensors/human-counter  passenger count     │
│  GET /health                 connectivity        │
│  GET /jump?step=N            demo control        │
│                                                  │
│  Listening on http://0.0.0.0:8080                │
└──────────────────────────────────────────────────┘
```

---

## VERIFY

After implementing run:
```bash
go run .
```

Test each endpoint:
```bash
curl http://localhost:8080/running-state
curl http://localhost:8080/audio-state
curl http://localhost:8080/data/speed
curl http://localhost:8080/data/distance-ratio
curl http://localhost:8080/data/current-route
curl http://localhost:8080/data/stations-in-route/dove6-route-001
curl http://localhost:8080/data/station-info/st-007
curl http://localhost:8080/sensors/human-counter
curl http://localhost:8080/health
curl "http://localhost:8080/jump?step=14"
curl http://localhost:8080/running-state
```

After jumping to step 14 (Settat) running-state must return:
```json
{"current_state": "operating_state_atstation"}
```

Report which files were modified when done.