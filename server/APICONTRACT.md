# API Documentation

---

## Human Counter

### Endpoint & Method
`GET /sensors/human-counter`

### Description
Returns the number of humans detected.

### Response Body
```json
{
  "count": 0
}
```

### Example Response
```json
{
  "count": 12
}
```

---

## Speed

### Endpoint & Method
`GET /data/speed`

### Description
Returns the current speed.

### Response Body
```json
{
  "speed": 0
}
```

### Example Response
```json
{
  "speed": 18.5
}
```

---

## Distance Ratio Between Stations

### Endpoint & Method
`GET /data/distance-ratio`

### Description
Returns the distance ratio between two stations.

### Response Body
```json
{
  "ratio": 0
}
```

### Example Response
```json
{
  "ratio": 65
}
```

---

## Current Route

### Endpoint & Method
`GET /data/current-route`

### Description
Returns information about the current route.

### Response Body
```json
{
  "route_id": "string",
  "is_in_reverse": false,
  "start_station_index": 0
}
```

### Example Response
```json
{
  "route_id": "route_1",
  "is_in_reverse": false,
  "start_station_index": 2
}
```

---

## Get Route Info

### Endpoint & Method
`GET /data/stations-in-route/{route_id}`

### Example Request
```json
http://localhost:3002/v0/data/stations-in-route/3bc351ec-c8be-4ce5-8f36-7c5f0a204e4c
```

### Example Response Body
```json
[
  "c1076a25-0b19-430a-a84a-5fe47f5db4da",
  "8745eac2-6f11-4461-83b4-fd0cd462d63b",
  "8547be80-9148-4da8-96cc-d1851ca68bf6",
  "49c23cfb-08dd-4f3c-9c01-e000bca8f99f",
]

```

---

## Get Station Info

### Endpoint & Method
`GET /data/station-info/{station_id}`

### Example Request
```json
http://localhost:3002/v0/data/station-view-info/c1076a25-0b19-430a-a84a-5fe47f5db4da
```

### Example Response
```json

{
  "display_name": "casa_port",
  "display_name_en": "casa_port en",
  "display_name_fr": "casa_port fr"
}
```

---

## Audio State

### Endpoint & Method
`GET /audio-state`

### Description
Returns the current audio playback state.

### Response Body
```json
{
  "audio_action": "playing_default_audio"
}

```

### Possible Values for `audio_action`
- `playing_default_audio`
- `playing_english_audio`
- `playing_french_audio`
- `no_audio_is_playing`

### Example Response
```json
{
  "audio_action": "playing_english_audio"
}
```

---

## Running State

### Endpoint & Method
`GET /running-state`

### Description
Returns the current operating state.

### Response Body
```json
{
  "current_state": "operating_state_idle"
}
```

### Possible Values for `current_state`
- `operating_state_idle`
- `operating_state_routeselected`
- `operating_state_atstation`
- `operating_state_departing`
- `operating_state_endofroute`
- `operating_state_moving`
- `operating_state_arriving`
- `operating_state_coasting`
- `operating_state_recovery`
- `operating_state_warning`
- `Operating_State_ManualHandling`

### Example Response
```json
{
  "current_state": "operating_state_moving"
}
```
