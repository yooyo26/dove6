package main

import "time"

const stepDuration = 15 * time.Second

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

// activeRoute is loaded from routes.json at startup
var activeRoute RouteData

var journey = []Step{

	// ── IDLE ─────────────────────────────────────────────
	{
		State:            "IDLE",
		CurrentStation:   "Marrakech",
		CurrentStationFr: "Marrakech",
		CurrentStationAr: "مراكش",
		NextStation:      "Youssoufia",
		NextStationFr:    "Youssoufia",
		NextStationAr:    "اليوسفية",
		SpeedKmh: 0, RouteProgress: 0.00,
		MessageFr:       "Bienvenue",
		MessageAr:       "مرحباً",
		ActiveAudioLang: "", AudioFile: "",
	},

	// ── ROUTE SELECTED ───────────────────────────────────
	{
		State:            "ROUTE_SELECTED",
		CurrentStation:   "Marrakech",
		CurrentStationFr: "Marrakech",
		CurrentStationAr: "مراكش",
		NextStation:      "Youssoufia",
		NextStationFr:    "Youssoufia",
		NextStationAr:    "اليوسفية",
		SpeedKmh: 0, RouteProgress: 0.00,
		MessageFr:       "Itinéraire sélectionné: Marrakech → Tanger Ville",
		MessageAr:       "تم اختيار المسار: مراكش ← طنجة المدينة",
		ActiveAudioLang: "fr", AudioFile: "route_selected_fr.mp3",
	},

	// ── AT STATION 1 — Marrakech ─────────────────────────
	{
		State:            "AT_STATION",
		CurrentStation:   "Marrakech",
		CurrentStationFr: "Marrakech",
		CurrentStationAr: "مراكش",
		NextStation:      "Youssoufia",
		NextStationFr:    "Youssoufia",
		NextStationAr:    "اليوسفية",
		SpeedKmh: 0, RouteProgress: 0.00,
		MessageFr:       "Bienvenue à Marrakech",
		MessageAr:       "مرحباً بكم في مراكش",
		ActiveAudioLang: "ar", AudioFile: "station_marrakech_ar.mp3",
	},

	// ── DEPARTING Marrakech ──────────────────────────────
	{
		State:            "DEPARTING",
		CurrentStation:   "Marrakech",
		CurrentStationFr: "Marrakech",
		CurrentStationAr: "مراكش",
		NextStation:      "Youssoufia",
		NextStationFr:    "Youssoufia",
		NextStationAr:    "اليوسفية",
		SpeedKmh: 20, RouteProgress: 0.01,
		MessageFr:       "Départ de Marrakech. Prochain arrêt: Youssoufia",
		MessageAr:       "المغادرة من مراكش. المحطة القادمة: اليوسفية",
		ActiveAudioLang: "fr", AudioFile: "depart_marrakech_fr.mp3",
	},

	// ── MOVING → Youssoufia ──────────────────────────────
	{
		State:            "MOVING",
		CurrentStation:   "Marrakech",
		CurrentStationFr: "Marrakech",
		CurrentStationAr: "مراكش",
		NextStation:      "Youssoufia",
		NextStationFr:    "Youssoufia",
		NextStationAr:    "اليوسفية",
		SpeedKmh: 140, RouteProgress: 0.03,
		ActiveAudioLang: "", AudioFile: "",
	},
	{
		State:            "MOVING",
		CurrentStation:   "Marrakech",
		CurrentStationFr: "Marrakech",
		CurrentStationAr: "مراكش",
		NextStation:      "Youssoufia",
		NextStationFr:    "Youssoufia",
		NextStationAr:    "اليوسفية",
		SpeedKmh: 160, RouteProgress: 0.05,
		ActiveAudioLang: "", AudioFile: "",
	},

	// ── ARRIVING Youssoufia ──────────────────────────────
	{
		State:            "ARRIVING",
		CurrentStation:   "Marrakech",
		CurrentStationFr: "Marrakech",
		CurrentStationAr: "مراكش",
		NextStation:      "Youssoufia",
		NextStationFr:    "Youssoufia",
		NextStationAr:    "اليوسفية",
		SpeedKmh: 55, RouteProgress: 0.057,
		MessageFr:       "Arrivée à Youssoufia",
		MessageAr:       "الوصول إلى اليوسفية",
		ActiveAudioLang: "ar", AudioFile: "arriving_youssoufia_ar.mp3",
	},

	// ── AT STATION 2 — Youssoufia ────────────────────────
	{
		State:            "AT_STATION",
		CurrentStation:   "Youssoufia",
		CurrentStationFr: "Youssoufia",
		CurrentStationAr: "اليوسفية",
		NextStation:      "Benguerir",
		NextStationFr:    "Benguerir",
		NextStationAr:    "بنكرير",
		SpeedKmh: 0, RouteProgress: 0.059,
		MessageFr:       "Bienvenue à Youssoufia",
		MessageAr:       "مرحباً بكم في اليوسفية",
		ActiveAudioLang: "fr", AudioFile: "station_youssoufia_fr.mp3",
	},

	// ── DEPARTING Youssoufia ─────────────────────────────
	{
		State:            "DEPARTING",
		CurrentStation:   "Youssoufia",
		CurrentStationFr: "Youssoufia",
		CurrentStationAr: "اليوسفية",
		NextStation:      "Benguerir",
		NextStationFr:    "Benguerir",
		NextStationAr:    "بنكرير",
		SpeedKmh: 25, RouteProgress: 0.065,
		MessageFr:       "Prochain arrêt: Benguerir",
		MessageAr:       "المحطة القادمة: بنكرير",
		ActiveAudioLang: "ar", AudioFile: "depart_youssoufia_ar.mp3",
	},

	// ── MOVING → Benguerir ───────────────────────────────
	{
		State:            "MOVING",
		CurrentStation:   "Youssoufia",
		CurrentStationFr: "Youssoufia",
		CurrentStationAr: "اليوسفية",
		NextStation:      "Benguerir",
		NextStationFr:    "Benguerir",
		NextStationAr:    "بنكرير",
		SpeedKmh: 150, RouteProgress: 0.09,
		ActiveAudioLang: "", AudioFile: "",
	},
	{
		State:            "MOVING",
		CurrentStation:   "Youssoufia",
		CurrentStationFr: "Youssoufia",
		CurrentStationAr: "اليوسفية",
		NextStation:      "Benguerir",
		NextStationFr:    "Benguerir",
		NextStationAr:    "بنكرير",
		SpeedKmh: 170, RouteProgress: 0.11,
		ActiveAudioLang: "", AudioFile: "",
	},

	// ── ARRIVING Benguerir ───────────────────────────────
	{
		State:            "ARRIVING",
		CurrentStation:   "Youssoufia",
		CurrentStationFr: "Youssoufia",
		CurrentStationAr: "اليوسفية",
		NextStation:      "Benguerir",
		NextStationFr:    "Benguerir",
		NextStationAr:    "بنكرير",
		SpeedKmh: 55, RouteProgress: 0.116,
		MessageFr:       "Arrivée à Benguerir",
		MessageAr:       "الوصول إلى بنكرير",
		ActiveAudioLang: "fr", AudioFile: "arriving_benguerir_fr.mp3",
	},

	// ── AT STATION 3 — Benguerir ─────────────────────────
	{
		State:            "AT_STATION",
		CurrentStation:   "Benguerir",
		CurrentStationFr: "Benguerir",
		CurrentStationAr: "بنكرير",
		NextStation:      "Settat",
		NextStationFr:    "Settat",
		NextStationAr:    "سطات",
		SpeedKmh: 0, RouteProgress: 0.118,
		MessageFr:       "Bienvenue à Benguerir",
		MessageAr:       "مرحباً بكم في بنكرير",
		ActiveAudioLang: "ar", AudioFile: "station_benguerir_ar.mp3",
	},

	// ── DEPARTING Benguerir ──────────────────────────────
	{
		State:            "DEPARTING",
		CurrentStation:   "Benguerir",
		CurrentStationFr: "Benguerir",
		CurrentStationAr: "بنكرير",
		NextStation:      "Settat",
		NextStationFr:    "Settat",
		NextStationAr:    "سطات",
		SpeedKmh: 25, RouteProgress: 0.125,
		MessageFr:       "Prochain arrêt: Settat",
		MessageAr:       "المحطة القادمة: سطات",
		ActiveAudioLang: "fr", AudioFile: "depart_benguerir_fr.mp3",
	},

	// ── MOVING → Settat ──────────────────────────────────
	{
		State:            "MOVING",
		CurrentStation:   "Benguerir",
		CurrentStationFr: "Benguerir",
		CurrentStationAr: "بنكرير",
		NextStation:      "Settat",
		NextStationFr:    "Settat",
		NextStationAr:    "سطات",
		SpeedKmh: 160, RouteProgress: 0.15,
		ActiveAudioLang: "", AudioFile: "",
	},
	{
		State:            "MOVING",
		CurrentStation:   "Benguerir",
		CurrentStationFr: "Benguerir",
		CurrentStationAr: "بنكرير",
		NextStation:      "Settat",
		NextStationFr:    "Settat",
		NextStationAr:    "سطات",
		SpeedKmh: 180, RouteProgress: 0.165,
		ActiveAudioLang: "", AudioFile: "",
	},

	// ── ARRIVING Settat ──────────────────────────────────
	{
		State:            "ARRIVING",
		CurrentStation:   "Benguerir",
		CurrentStationFr: "Benguerir",
		CurrentStationAr: "بنكرير",
		NextStation:      "Settat",
		NextStationFr:    "Settat",
		NextStationAr:    "سطات",
		SpeedKmh: 60, RouteProgress: 0.175,
		MessageFr:       "Arrivée à Settat",
		MessageAr:       "الوصول إلى سطات",
		ActiveAudioLang: "ar", AudioFile: "arriving_settat_ar.mp3",
	},

	// ── AT STATION 4 — Settat ────────────────────────────
	{
		State:            "AT_STATION",
		CurrentStation:   "Settat",
		CurrentStationFr: "Settat",
		CurrentStationAr: "سطات",
		NextStation:      "El Jadida",
		NextStationFr:    "El Jadida",
		NextStationAr:    "الجديدة",
		SpeedKmh: 0, RouteProgress: 0.177,
		MessageFr:       "Bienvenue à Settat",
		MessageAr:       "مرحباً بكم في سطات",
		ActiveAudioLang: "fr", AudioFile: "station_settat_fr.mp3",
	},

	// ── DEPARTING Settat ─────────────────────────────────
	{
		State:            "DEPARTING",
		CurrentStation:   "Settat",
		CurrentStationFr: "Settat",
		CurrentStationAr: "سطات",
		NextStation:      "El Jadida",
		NextStationFr:    "El Jadida",
		NextStationAr:    "الجديدة",
		SpeedKmh: 30, RouteProgress: 0.182,
		MessageFr:       "Prochain arrêt: El Jadida",
		MessageAr:       "المحطة القادمة: الجديدة",
		ActiveAudioLang: "ar", AudioFile: "depart_settat_ar.mp3",
	},

	// ── MOVING → El Jadida ───────────────────────────────
	{
		State:            "MOVING",
		CurrentStation:   "Settat",
		CurrentStationFr: "Settat",
		CurrentStationAr: "سطات",
		NextStation:      "El Jadida",
		NextStationFr:    "El Jadida",
		NextStationAr:    "الجديدة",
		SpeedKmh: 155, RouteProgress: 0.21,
		ActiveAudioLang: "", AudioFile: "",
	},
	{
		State:            "MOVING",
		CurrentStation:   "Settat",
		CurrentStationFr: "Settat",
		CurrentStationAr: "سطات",
		NextStation:      "El Jadida",
		NextStationFr:    "El Jadida",
		NextStationAr:    "الجديدة",
		SpeedKmh: 175, RouteProgress: 0.225,
		ActiveAudioLang: "", AudioFile: "",
	},

	// ── ARRIVING El Jadida ───────────────────────────────
	{
		State:            "ARRIVING",
		CurrentStation:   "Settat",
		CurrentStationFr: "Settat",
		CurrentStationAr: "سطات",
		NextStation:      "El Jadida",
		NextStationFr:    "El Jadida",
		NextStationAr:    "الجديدة",
		SpeedKmh: 55, RouteProgress: 0.234,
		MessageFr:       "Arrivée à El Jadida",
		MessageAr:       "الوصول إلى الجديدة",
		ActiveAudioLang: "fr", AudioFile: "arriving_eljadida_fr.mp3",
	},

	// ── AT STATION 5 — El Jadida ─────────────────────────
	{
		State:            "AT_STATION",
		CurrentStation:   "El Jadida",
		CurrentStationFr: "El Jadida",
		CurrentStationAr: "الجديدة",
		NextStation:      "Casa Oasis",
		NextStationFr:    "Casa Oasis",
		NextStationAr:    "الدار البيضاء أويسيس",
		SpeedKmh: 0, RouteProgress: 0.236,
		MessageFr:       "Bienvenue à El Jadida",
		MessageAr:       "مرحباً بكم في الجديدة",
		ActiveAudioLang: "ar", AudioFile: "station_eljadida_ar.mp3",
	},

	// ── DEPARTING El Jadida ──────────────────────────────
	{
		State:            "DEPARTING",
		CurrentStation:   "El Jadida",
		CurrentStationFr: "El Jadida",
		CurrentStationAr: "الجديدة",
		NextStation:      "Casa Oasis",
		NextStationFr:    "Casa Oasis",
		NextStationAr:    "الدار البيضاء أويسيس",
		SpeedKmh: 25, RouteProgress: 0.242,
		MessageFr:       "Prochain arrêt: Casa Oasis",
		MessageAr:       "المحطة القادمة: الدار البيضاء أويسيس",
		ActiveAudioLang: "fr", AudioFile: "depart_eljadida_fr.mp3",
	},

	// ── MOVING → Casa Oasis ──────────────────────────────
	{
		State:            "MOVING",
		CurrentStation:   "El Jadida",
		CurrentStationFr: "El Jadida",
		CurrentStationAr: "الجديدة",
		NextStation:      "Casa Oasis",
		NextStationFr:    "Casa Oasis",
		NextStationAr:    "الدار البيضاء أويسيس",
		SpeedKmh: 145, RouteProgress: 0.265,
		ActiveAudioLang: "", AudioFile: "",
	},
	{
		State:            "MOVING",
		CurrentStation:   "El Jadida",
		CurrentStationFr: "El Jadida",
		CurrentStationAr: "الجديدة",
		NextStation:      "Casa Oasis",
		NextStationFr:    "Casa Oasis",
		NextStationAr:    "الدار البيضاء أويسيس",
		SpeedKmh: 160, RouteProgress: 0.28,
		ActiveAudioLang: "", AudioFile: "",
	},

	// ── ARRIVING Casa Oasis ──────────────────────────────
	{
		State:            "ARRIVING",
		CurrentStation:   "El Jadida",
		CurrentStationFr: "El Jadida",
		CurrentStationAr: "الجديدة",
		NextStation:      "Casa Oasis",
		NextStationFr:    "Casa Oasis",
		NextStationAr:    "الدار البيضاء أويسيس",
		SpeedKmh: 50, RouteProgress: 0.292,
		MessageFr:       "Arrivée à Casa Oasis",
		MessageAr:       "الوصول إلى الدار البيضاء أويسيس",
		ActiveAudioLang: "ar", AudioFile: "arriving_casaoasis_ar.mp3",
	},

	// ── AT STATION 6 — Casa Oasis ────────────────────────
	{
		State:            "AT_STATION",
		CurrentStation:   "Casa Oasis",
		CurrentStationFr: "Casa Oasis",
		CurrentStationAr: "الدار البيضاء أويسيس",
		NextStation:      "Casa Voyageurs",
		NextStationFr:    "Casa Voyageurs",
		NextStationAr:    "الدار البيضاء المسافرين",
		SpeedKmh: 0, RouteProgress: 0.295,
		MessageFr:       "Bienvenue à Casa Oasis",
		MessageAr:       "مرحباً بكم في الدار البيضاء أويسيس",
		ActiveAudioLang: "fr", AudioFile: "station_casaoasis_fr.mp3",
	},

	// ── DEPARTING Casa Oasis ─────────────────────────────
	{
		State:            "DEPARTING",
		CurrentStation:   "Casa Oasis",
		CurrentStationFr: "Casa Oasis",
		CurrentStationAr: "الدار البيضاء أويسيس",
		NextStation:      "Casa Voyageurs",
		NextStationFr:    "Casa Voyageurs",
		NextStationAr:    "الدار البيضاء المسافرين",
		SpeedKmh: 20, RouteProgress: 0.300,
		MessageFr:       "Prochain arrêt: Casa Voyageurs",
		MessageAr:       "المحطة القادمة: الدار البيضاء المسافرين",
		ActiveAudioLang: "ar", AudioFile: "depart_casaoasis_ar.mp3",
	},

	// ── MOVING → Casa Voyageurs ──────────────────────────
	{
		State:            "MOVING",
		CurrentStation:   "Casa Oasis",
		CurrentStationFr: "Casa Oasis",
		CurrentStationAr: "الدار البيضاء أويسيس",
		NextStation:      "Casa Voyageurs",
		NextStationFr:    "Casa Voyageurs",
		NextStationAr:    "الدار البيضاء المسافرين",
		SpeedKmh: 80, RouteProgress: 0.31,
		ActiveAudioLang: "", AudioFile: "",
	},

	// ── ARRIVING Casa Voyageurs ──────────────────────────
	{
		State:            "ARRIVING",
		CurrentStation:   "Casa Oasis",
		CurrentStationFr: "Casa Oasis",
		CurrentStationAr: "الدار البيضاء أويسيس",
		NextStation:      "Casa Voyageurs",
		NextStationFr:    "Casa Voyageurs",
		NextStationAr:    "الدار البيضاء المسافرين",
		SpeedKmh: 30, RouteProgress: 0.348,
		MessageFr:       "Arrivée à Casa Voyageurs",
		MessageAr:       "الوصول إلى الدار البيضاء المسافرين",
		ActiveAudioLang: "fr", AudioFile: "arriving_casavoy_fr.mp3",
	},

	// ── AT STATION 7 — Casa Voyageurs ────────────────────
	{
		State:            "AT_STATION",
		CurrentStation:   "Casa Voyageurs",
		CurrentStationFr: "Casa Voyageurs",
		CurrentStationAr: "الدار البيضاء المسافرين",
		NextStation:      "Casa Ain Sebaa",
		NextStationFr:    "Casa Ain Sebaa",
		NextStationAr:    "الدار البيضاء عين السبع",
		SpeedKmh: 0, RouteProgress: 0.353,
		MessageFr:       "Bienvenue à Casa Voyageurs",
		MessageAr:       "مرحباً بكم في الدار البيضاء المسافرين",
		ActiveAudioLang: "ar", AudioFile: "station_casavoy_ar.mp3",
	},

	// ── DEPARTING Casa Voyageurs ─────────────────────────
	{
		State:            "DEPARTING",
		CurrentStation:   "Casa Voyageurs",
		CurrentStationFr: "Casa Voyageurs",
		CurrentStationAr: "الدار البيضاء المسافرين",
		NextStation:      "Casa Ain Sebaa",
		NextStationFr:    "Casa Ain Sebaa",
		NextStationAr:    "الدار البيضاء عين السبع",
		SpeedKmh: 20, RouteProgress: 0.358,
		MessageFr:       "Prochain arrêt: Casa Ain Sebaa",
		MessageAr:       "المحطة القادمة: الدار البيضاء عين السبع",
		ActiveAudioLang: "fr", AudioFile: "depart_casavoy_fr.mp3",
	},

	// ── MOVING → Casa Ain Sebaa ──────────────────────────
	{
		State:            "MOVING",
		CurrentStation:   "Casa Voyageurs",
		CurrentStationFr: "Casa Voyageurs",
		CurrentStationAr: "الدار البيضاء المسافرين",
		NextStation:      "Casa Ain Sebaa",
		NextStationFr:    "Casa Ain Sebaa",
		NextStationAr:    "الدار البيضاء عين السبع",
		SpeedKmh: 80, RouteProgress: 0.375,
		ActiveAudioLang: "", AudioFile: "",
	},

	// ── ARRIVING Casa Ain Sebaa ──────────────────────────
	{
		State:            "ARRIVING",
		CurrentStation:   "Casa Voyageurs",
		CurrentStationFr: "Casa Voyageurs",
		CurrentStationAr: "الدار البيضاء المسافرين",
		NextStation:      "Casa Ain Sebaa",
		NextStationFr:    "Casa Ain Sebaa",
		NextStationAr:    "الدار البيضاء عين السبع",
		SpeedKmh: 30, RouteProgress: 0.408,
		MessageFr:       "Arrivée à Casa Ain Sebaa",
		MessageAr:       "الوصول إلى الدار البيضاء عين السبع",
		ActiveAudioLang: "ar", AudioFile: "arriving_ainsebaa_ar.mp3",
	},

	// ── AT STATION 8 — Casa Ain Sebaa ────────────────────
	{
		State:            "AT_STATION",
		CurrentStation:   "Casa Ain Sebaa",
		CurrentStationFr: "Casa Ain Sebaa",
		CurrentStationAr: "الدار البيضاء عين السبع",
		NextStation:      "Mohammedia",
		NextStationFr:    "Mohammedia",
		NextStationAr:    "المحمدية",
		SpeedKmh: 0, RouteProgress: 0.412,
		MessageFr:       "Bienvenue à Casa Ain Sebaa",
		MessageAr:       "مرحباً بكم في الدار البيضاء عين السبع",
		ActiveAudioLang: "fr", AudioFile: "station_ainsebaa_fr.mp3",
	},

	// ── DEPARTING Casa Ain Sebaa ─────────────────────────
	{
		State:            "DEPARTING",
		CurrentStation:   "Casa Ain Sebaa",
		CurrentStationFr: "Casa Ain Sebaa",
		CurrentStationAr: "الدار البيضاء عين السبع",
		NextStation:      "Mohammedia",
		NextStationFr:    "Mohammedia",
		NextStationAr:    "المحمدية",
		SpeedKmh: 25, RouteProgress: 0.418,
		MessageFr:       "Prochain arrêt: Mohammedia",
		MessageAr:       "المحطة القادمة: المحمدية",
		ActiveAudioLang: "ar", AudioFile: "depart_ainsebaa_ar.mp3",
	},

	// ── MOVING → Mohammedia ──────────────────────────────
	{
		State:            "MOVING",
		CurrentStation:   "Casa Ain Sebaa",
		CurrentStationFr: "Casa Ain Sebaa",
		CurrentStationAr: "الدار البيضاء عين السبع",
		NextStation:      "Mohammedia",
		NextStationFr:    "Mohammedia",
		NextStationAr:    "المحمدية",
		SpeedKmh: 120, RouteProgress: 0.438,
		ActiveAudioLang: "", AudioFile: "",
	},
	{
		State:            "MOVING",
		CurrentStation:   "Casa Ain Sebaa",
		CurrentStationFr: "Casa Ain Sebaa",
		CurrentStationAr: "الدار البيضاء عين السبع",
		NextStation:      "Mohammedia",
		NextStationFr:    "Mohammedia",
		NextStationAr:    "المحمدية",
		SpeedKmh: 140, RouteProgress: 0.455,
		ActiveAudioLang: "", AudioFile: "",
	},

	// ── ARRIVING Mohammedia ──────────────────────────────
	{
		State:            "ARRIVING",
		CurrentStation:   "Casa Ain Sebaa",
		CurrentStationFr: "Casa Ain Sebaa",
		CurrentStationAr: "الدار البيضاء عين السبع",
		NextStation:      "Mohammedia",
		NextStationFr:    "Mohammedia",
		NextStationAr:    "المحمدية",
		SpeedKmh: 50, RouteProgress: 0.466,
		MessageFr:       "Arrivée à Mohammedia",
		MessageAr:       "الوصول إلى المحمدية",
		ActiveAudioLang: "fr", AudioFile: "arriving_mohammedia_fr.mp3",
	},

	// ── AT STATION 9 — Mohammedia ────────────────────────
	{
		State:            "AT_STATION",
		CurrentStation:   "Mohammedia",
		CurrentStationFr: "Mohammedia",
		CurrentStationAr: "المحمدية",
		NextStation:      "Rabat Agdal",
		NextStationFr:    "Rabat Agdal",
		NextStationAr:    "الرباط أكدال",
		SpeedKmh: 0, RouteProgress: 0.470,
		MessageFr:       "Bienvenue à Mohammedia",
		MessageAr:       "مرحباً بكم في المحمدية",
		ActiveAudioLang: "ar", AudioFile: "station_mohammedia_ar.mp3",
	},

	// ── DEPARTING Mohammedia ─────────────────────────────
	{
		State:            "DEPARTING",
		CurrentStation:   "Mohammedia",
		CurrentStationFr: "Mohammedia",
		CurrentStationAr: "المحمدية",
		NextStation:      "Rabat Agdal",
		NextStationFr:    "Rabat Agdal",
		NextStationAr:    "الرباط أكدال",
		SpeedKmh: 25, RouteProgress: 0.476,
		MessageFr:       "Prochain arrêt: Rabat Agdal",
		MessageAr:       "المحطة القادمة: الرباط أكدال",
		ActiveAudioLang: "fr", AudioFile: "depart_mohammedia_fr.mp3",
	},

	// ── MOVING → Rabat Agdal ─────────────────────────────
	{
		State:            "MOVING",
		CurrentStation:   "Mohammedia",
		CurrentStationFr: "Mohammedia",
		CurrentStationAr: "المحمدية",
		NextStation:      "Rabat Agdal",
		NextStationFr:    "Rabat Agdal",
		NextStationAr:    "الرباط أكدال",
		SpeedKmh: 160, RouteProgress: 0.50,
		ActiveAudioLang: "", AudioFile: "",
	},
	{
		State:            "MOVING",
		CurrentStation:   "Mohammedia",
		CurrentStationFr: "Mohammedia",
		CurrentStationAr: "المحمدية",
		NextStation:      "Rabat Agdal",
		NextStationFr:    "Rabat Agdal",
		NextStationAr:    "الرباط أكدال",
		SpeedKmh: 180, RouteProgress: 0.515,
		ActiveAudioLang: "", AudioFile: "",
	},

	// ── ARRIVING Rabat Agdal ─────────────────────────────
	{
		State:            "ARRIVING",
		CurrentStation:   "Mohammedia",
		CurrentStationFr: "Mohammedia",
		CurrentStationAr: "المحمدية",
		NextStation:      "Rabat Agdal",
		NextStationFr:    "Rabat Agdal",
		NextStationAr:    "الرباط أكدال",
		SpeedKmh: 55, RouteProgress: 0.525,
		MessageFr:       "Arrivée à Rabat Agdal",
		MessageAr:       "الوصول إلى الرباط أكدال",
		ActiveAudioLang: "ar", AudioFile: "arriving_rabatagdal_ar.mp3",
	},

	// ── AT STATION 10 — Rabat Agdal ──────────────────────
	{
		State:            "AT_STATION",
		CurrentStation:   "Rabat Agdal",
		CurrentStationFr: "Rabat Agdal",
		CurrentStationAr: "الرباط أكدال",
		NextStation:      "Rabat Ville",
		NextStationFr:    "Rabat Ville",
		NextStationAr:    "الرباط المدينة",
		SpeedKmh: 0, RouteProgress: 0.529,
		MessageFr:       "Bienvenue à Rabat Agdal",
		MessageAr:       "مرحباً بكم في الرباط أكدال",
		ActiveAudioLang: "fr", AudioFile: "station_rabatagdal_fr.mp3",
	},

	// ── DEPARTING Rabat Agdal ────────────────────────────
	{
		State:            "DEPARTING",
		CurrentStation:   "Rabat Agdal",
		CurrentStationFr: "Rabat Agdal",
		CurrentStationAr: "الرباط أكدال",
		NextStation:      "Rabat Ville",
		NextStationFr:    "Rabat Ville",
		NextStationAr:    "الرباط المدينة",
		SpeedKmh: 20, RouteProgress: 0.533,
		MessageFr:       "Prochain arrêt: Rabat Ville",
		MessageAr:       "المحطة القادمة: الرباط المدينة",
		ActiveAudioLang: "ar", AudioFile: "depart_rabatagdal_ar.mp3",
	},

	// ── MOVING → Rabat Ville ─────────────────────────────
	{
		State:            "MOVING",
		CurrentStation:   "Rabat Agdal",
		CurrentStationFr: "Rabat Agdal",
		CurrentStationAr: "الرباط أكدال",
		NextStation:      "Rabat Ville",
		NextStationFr:    "Rabat Ville",
		NextStationAr:    "الرباط المدينة",
		SpeedKmh: 80, RouteProgress: 0.550,
		ActiveAudioLang: "", AudioFile: "",
	},

	// ── ARRIVING Rabat Ville ─────────────────────────────
	{
		State:            "ARRIVING",
		CurrentStation:   "Rabat Agdal",
		CurrentStationFr: "Rabat Agdal",
		CurrentStationAr: "الرباط أكدال",
		NextStation:      "Rabat Ville",
		NextStationFr:    "Rabat Ville",
		NextStationAr:    "الرباط المدينة",
		SpeedKmh: 30, RouteProgress: 0.585,
		MessageFr:       "Arrivée à Rabat Ville",
		MessageAr:       "الوصول إلى الرباط المدينة",
		ActiveAudioLang: "fr", AudioFile: "arriving_rabatville_fr.mp3",
	},

	// ── AT STATION 11 — Rabat Ville ──────────────────────
	{
		State:            "AT_STATION",
		CurrentStation:   "Rabat Ville",
		CurrentStationFr: "Rabat Ville",
		CurrentStationAr: "الرباط المدينة",
		NextStation:      "Salé Tabriquet",
		NextStationFr:    "Salé Tabriquet",
		NextStationAr:    "سلا طابريقت",
		SpeedKmh: 0, RouteProgress: 0.588,
		MessageFr:       "Bienvenue à Rabat Ville",
		MessageAr:       "مرحباً بكم في الرباط المدينة",
		ActiveAudioLang: "ar", AudioFile: "station_rabatville_ar.mp3",
	},

	// ── DEPARTING Rabat Ville ────────────────────────────
	{
		State:            "DEPARTING",
		CurrentStation:   "Rabat Ville",
		CurrentStationFr: "Rabat Ville",
		CurrentStationAr: "الرباط المدينة",
		NextStation:      "Salé Tabriquet",
		NextStationFr:    "Salé Tabriquet",
		NextStationAr:    "سلا طابريقت",
		SpeedKmh: 20, RouteProgress: 0.592,
		MessageFr:       "Prochain arrêt: Salé Tabriquet",
		MessageAr:       "المحطة القادمة: سلا طابريقت",
		ActiveAudioLang: "fr", AudioFile: "depart_rabatville_fr.mp3",
	},

	// ── MOVING → Salé Tabriquet ──────────────────────────
	{
		State:            "MOVING",
		CurrentStation:   "Rabat Ville",
		CurrentStationFr: "Rabat Ville",
		CurrentStationAr: "الرباط المدينة",
		NextStation:      "Salé Tabriquet",
		NextStationFr:    "Salé Tabriquet",
		NextStationAr:    "سلا طابريقت",
		SpeedKmh: 80, RouteProgress: 0.608,
		ActiveAudioLang: "", AudioFile: "",
	},

	// ── ARRIVING Salé Tabriquet ──────────────────────────
	{
		State:            "ARRIVING",
		CurrentStation:   "Rabat Ville",
		CurrentStationFr: "Rabat Ville",
		CurrentStationAr: "الرباط المدينة",
		NextStation:      "Salé Tabriquet",
		NextStationFr:    "Salé Tabriquet",
		NextStationAr:    "سلا طابريقت",
		SpeedKmh: 30, RouteProgress: 0.642,
		MessageFr:       "Arrivée à Salé Tabriquet",
		MessageAr:       "الوصول إلى سلا طابريقت",
		ActiveAudioLang: "ar", AudioFile: "arriving_saletab_ar.mp3",
	},

	// ── AT STATION 12 — Salé Tabriquet ───────────────────
	{
		State:            "AT_STATION",
		CurrentStation:   "Salé Tabriquet",
		CurrentStationFr: "Salé Tabriquet",
		CurrentStationAr: "سلا طابريقت",
		NextStation:      "Salé Ville",
		NextStationFr:    "Salé Ville",
		NextStationAr:    "سلا المدينة",
		SpeedKmh: 0, RouteProgress: 0.645,
		MessageFr:       "Bienvenue à Salé Tabriquet",
		MessageAr:       "مرحباً بكم في سلا طابريقت",
		ActiveAudioLang: "fr", AudioFile: "station_saletab_fr.mp3",
	},

	// ── DEPARTING Salé Tabriquet ─────────────────────────
	{
		State:            "DEPARTING",
		CurrentStation:   "Salé Tabriquet",
		CurrentStationFr: "Salé Tabriquet",
		CurrentStationAr: "سلا طابريقت",
		NextStation:      "Salé Ville",
		NextStationFr:    "Salé Ville",
		NextStationAr:    "سلا المدينة",
		SpeedKmh: 20, RouteProgress: 0.649,
		MessageFr:       "Prochain arrêt: Salé Ville",
		MessageAr:       "المحطة القادمة: سلا المدينة",
		ActiveAudioLang: "ar", AudioFile: "depart_saletab_ar.mp3",
	},

	// ── MOVING → Salé Ville ──────────────────────────────
	{
		State:            "MOVING",
		CurrentStation:   "Salé Tabriquet",
		CurrentStationFr: "Salé Tabriquet",
		CurrentStationAr: "سلا طابريقت",
		NextStation:      "Salé Ville",
		NextStationFr:    "Salé Ville",
		NextStationAr:    "سلا المدينة",
		SpeedKmh: 80, RouteProgress: 0.662,
		ActiveAudioLang: "", AudioFile: "",
	},

	// ── ARRIVING Salé Ville ──────────────────────────────
	{
		State:            "ARRIVING",
		CurrentStation:   "Salé Tabriquet",
		CurrentStationFr: "Salé Tabriquet",
		CurrentStationAr: "سلا طابريقت",
		NextStation:      "Salé Ville",
		NextStationFr:    "Salé Ville",
		NextStationAr:    "سلا المدينة",
		SpeedKmh: 30, RouteProgress: 0.697,
		MessageFr:       "Arrivée à Salé Ville",
		MessageAr:       "الوصول إلى سلا المدينة",
		ActiveAudioLang: "fr", AudioFile: "arriving_saleville_fr.mp3",
	},

	// ── AT STATION 13 — Salé Ville ───────────────────────
	{
		State:            "AT_STATION",
		CurrentStation:   "Salé Ville",
		CurrentStationFr: "Salé Ville",
		CurrentStationAr: "سلا المدينة",
		NextStation:      "Kénitra",
		NextStationFr:    "Kénitra",
		NextStationAr:    "القنيطرة",
		SpeedKmh: 0, RouteProgress: 0.700,
		MessageFr:       "Bienvenue à Salé Ville",
		MessageAr:       "مرحباً بكم في سلا المدينة",
		ActiveAudioLang: "ar", AudioFile: "station_saleville_ar.mp3",
	},

	// ── DEPARTING Salé Ville ─────────────────────────────
	{
		State:            "DEPARTING",
		CurrentStation:   "Salé Ville",
		CurrentStationFr: "Salé Ville",
		CurrentStationAr: "سلا المدينة",
		NextStation:      "Kénitra",
		NextStationFr:    "Kénitra",
		NextStationAr:    "القنيطرة",
		SpeedKmh: 25, RouteProgress: 0.705,
		MessageFr:       "Prochain arrêt: Kénitra",
		MessageAr:       "المحطة القادمة: القنيطرة",
		ActiveAudioLang: "fr", AudioFile: "depart_saleville_fr.mp3",
	},

	// ── MOVING → Kénitra ─────────────────────────────────
	{
		State:            "MOVING",
		CurrentStation:   "Salé Ville",
		CurrentStationFr: "Salé Ville",
		CurrentStationAr: "سلا المدينة",
		NextStation:      "Kénitra",
		NextStationFr:    "Kénitra",
		NextStationAr:    "القنيطرة",
		SpeedKmh: 160, RouteProgress: 0.725,
		ActiveAudioLang: "", AudioFile: "",
	},
	{
		State:            "MOVING",
		CurrentStation:   "Salé Ville",
		CurrentStationFr: "Salé Ville",
		CurrentStationAr: "سلا المدينة",
		NextStation:      "Kénitra",
		NextStationFr:    "Kénitra",
		NextStationAr:    "القنيطرة",
		SpeedKmh: 180, RouteProgress: 0.740,
		ActiveAudioLang: "", AudioFile: "",
	},

	// ── ARRIVING Kénitra ─────────────────────────────────
	{
		State:            "ARRIVING",
		CurrentStation:   "Salé Ville",
		CurrentStationFr: "Salé Ville",
		CurrentStationAr: "سلا المدينة",
		NextStation:      "Kénitra",
		NextStationFr:    "Kénitra",
		NextStationAr:    "القنيطرة",
		SpeedKmh: 55, RouteProgress: 0.755,
		MessageFr:       "Arrivée à Kénitra",
		MessageAr:       "الوصول إلى القنيطرة",
		ActiveAudioLang: "ar", AudioFile: "arriving_kenitra_ar.mp3",
	},

	// ── AT STATION 14 — Kénitra ──────────────────────────
	{
		State:            "AT_STATION",
		CurrentStation:   "Kénitra",
		CurrentStationFr: "Kénitra",
		CurrentStationAr: "القنيطرة",
		NextStation:      "Sidi Bouknadel",
		NextStationFr:    "Sidi Bouknadel",
		NextStationAr:    "سيدي بوقنادل",
		SpeedKmh: 0, RouteProgress: 0.758,
		MessageFr:       "Bienvenue à Kénitra",
		MessageAr:       "مرحباً بكم في القنيطرة",
		ActiveAudioLang: "fr", AudioFile: "station_kenitra_fr.mp3",
	},

	// ── DEPARTING Kénitra ────────────────────────────────
	{
		State:            "DEPARTING",
		CurrentStation:   "Kénitra",
		CurrentStationFr: "Kénitra",
		CurrentStationAr: "القنيطرة",
		NextStation:      "Sidi Bouknadel",
		NextStationFr:    "Sidi Bouknadel",
		NextStationAr:    "سيدي بوقنادل",
		SpeedKmh: 25, RouteProgress: 0.762,
		MessageFr:       "Prochain arrêt: Sidi Bouknadel",
		MessageAr:       "المحطة القادمة: سيدي بوقنادل",
		ActiveAudioLang: "ar", AudioFile: "depart_kenitra_ar.mp3",
	},

	// ── MOVING → Sidi Bouknadel ──────────────────────────
	{
		State:            "MOVING",
		CurrentStation:   "Kénitra",
		CurrentStationFr: "Kénitra",
		CurrentStationAr: "القنيطرة",
		NextStation:      "Sidi Bouknadel",
		NextStationFr:    "Sidi Bouknadel",
		NextStationAr:    "سيدي بوقنادل",
		SpeedKmh: 140, RouteProgress: 0.778,
		ActiveAudioLang: "", AudioFile: "",
	},
	{
		State:            "MOVING",
		CurrentStation:   "Kénitra",
		CurrentStationFr: "Kénitra",
		CurrentStationAr: "القنيطرة",
		NextStation:      "Sidi Bouknadel",
		NextStationFr:    "Sidi Bouknadel",
		NextStationAr:    "سيدي بوقنادل",
		SpeedKmh: 160, RouteProgress: 0.792,
		ActiveAudioLang: "", AudioFile: "",
	},

	// ── ARRIVING Sidi Bouknadel ──────────────────────────
	{
		State:            "ARRIVING",
		CurrentStation:   "Kénitra",
		CurrentStationFr: "Kénitra",
		CurrentStationAr: "القنيطرة",
		NextStation:      "Sidi Bouknadel",
		NextStationFr:    "Sidi Bouknadel",
		NextStationAr:    "سيدي بوقنادل",
		SpeedKmh: 50, RouteProgress: 0.813,
		MessageFr:       "Arrivée à Sidi Bouknadel",
		MessageAr:       "الوصول إلى سيدي بوقنادل",
		ActiveAudioLang: "fr", AudioFile: "arriving_sidibou_fr.mp3",
	},

	// ── AT STATION 15 — Sidi Bouknadel ───────────────────
	{
		State:            "AT_STATION",
		CurrentStation:   "Sidi Bouknadel",
		CurrentStationFr: "Sidi Bouknadel",
		CurrentStationAr: "سيدي بوقنادل",
		NextStation:      "Ksar El Kébir",
		NextStationFr:    "Ksar El Kébir",
		NextStationAr:    "القصر الكبير",
		SpeedKmh: 0, RouteProgress: 0.815,
		MessageFr:       "Bienvenue à Sidi Bouknadel",
		MessageAr:       "مرحباً بكم في سيدي بوقنادل",
		ActiveAudioLang: "ar", AudioFile: "station_sidibou_ar.mp3",
	},

	// ── DEPARTING Sidi Bouknadel ─────────────────────────
	{
		State:            "DEPARTING",
		CurrentStation:   "Sidi Bouknadel",
		CurrentStationFr: "Sidi Bouknadel",
		CurrentStationAr: "سيدي بوقنادل",
		NextStation:      "Ksar El Kébir",
		NextStationFr:    "Ksar El Kébir",
		NextStationAr:    "القصر الكبير",
		SpeedKmh: 25, RouteProgress: 0.819,
		MessageFr:       "Prochain arrêt: Ksar El Kébir",
		MessageAr:       "المحطة القادمة: القصر الكبير",
		ActiveAudioLang: "fr", AudioFile: "depart_sidibou_fr.mp3",
	},

	// ── MOVING → Ksar El Kébir ───────────────────────────
	{
		State:            "MOVING",
		CurrentStation:   "Sidi Bouknadel",
		CurrentStationFr: "Sidi Bouknadel",
		CurrentStationAr: "سيدي بوقنادل",
		NextStation:      "Ksar El Kébir",
		NextStationFr:    "Ksar El Kébir",
		NextStationAr:    "القصر الكبير",
		SpeedKmh: 160, RouteProgress: 0.840,
		ActiveAudioLang: "", AudioFile: "",
	},
	{
		State:            "MOVING",
		CurrentStation:   "Sidi Bouknadel",
		CurrentStationFr: "Sidi Bouknadel",
		CurrentStationAr: "سيدي بوقنادل",
		NextStation:      "Ksar El Kébir",
		NextStationFr:    "Ksar El Kébir",
		NextStationAr:    "القصر الكبير",
		SpeedKmh: 175, RouteProgress: 0.855,
		ActiveAudioLang: "", AudioFile: "",
	},

	// ── ARRIVING Ksar El Kébir ───────────────────────────
	{
		State:            "ARRIVING",
		CurrentStation:   "Sidi Bouknadel",
		CurrentStationFr: "Sidi Bouknadel",
		CurrentStationAr: "سيدي بوقنادل",
		NextStation:      "Ksar El Kébir",
		NextStationFr:    "Ksar El Kébir",
		NextStationAr:    "القصر الكبير",
		SpeedKmh: 55, RouteProgress: 0.868,
		MessageFr:       "Arrivée à Ksar El Kébir",
		MessageAr:       "الوصول إلى القصر الكبير",
		ActiveAudioLang: "ar", AudioFile: "arriving_ksarlakbir_ar.mp3",
	},

	// ── AT STATION 16 — Ksar El Kébir ───────────────────
	{
		State:            "AT_STATION",
		CurrentStation:   "Ksar El Kébir",
		CurrentStationFr: "Ksar El Kébir",
		CurrentStationAr: "القصر الكبير",
		NextStation:      "Asilah",
		NextStationFr:    "Asilah",
		NextStationAr:    "أصيلة",
		SpeedKmh: 0, RouteProgress: 0.871,
		MessageFr:       "Bienvenue à Ksar El Kébir",
		MessageAr:       "مرحباً بكم في القصر الكبير",
		ActiveAudioLang: "fr", AudioFile: "station_ksarlakbir_fr.mp3",
	},

	// ── DEPARTING Ksar El Kébir ──────────────────────────
	{
		State:            "DEPARTING",
		CurrentStation:   "Ksar El Kébir",
		CurrentStationFr: "Ksar El Kébir",
		CurrentStationAr: "القصر الكبير",
		NextStation:      "Asilah",
		NextStationFr:    "Asilah",
		NextStationAr:    "أصيلة",
		SpeedKmh: 25, RouteProgress: 0.875,
		MessageFr:       "Prochain arrêt: Asilah",
		MessageAr:       "المحطة القادمة: أصيلة",
		ActiveAudioLang: "ar", AudioFile: "depart_ksarlakbir_ar.mp3",
	},

	// ── MOVING → Asilah ──────────────────────────────────
	{
		State:            "MOVING",
		CurrentStation:   "Ksar El Kébir",
		CurrentStationFr: "Ksar El Kébir",
		CurrentStationAr: "القصر الكبير",
		NextStation:      "Asilah",
		NextStationFr:    "Asilah",
		NextStationAr:    "أصيلة",
		SpeedKmh: 155, RouteProgress: 0.895,
		ActiveAudioLang: "", AudioFile: "",
	},
	{
		State:            "MOVING",
		CurrentStation:   "Ksar El Kébir",
		CurrentStationFr: "Ksar El Kébir",
		CurrentStationAr: "القصر الكبير",
		NextStation:      "Asilah",
		NextStationFr:    "Asilah",
		NextStationAr:    "أصيلة",
		SpeedKmh: 170, RouteProgress: 0.908,
		ActiveAudioLang: "", AudioFile: "",
	},

	// ── ARRIVING Asilah ──────────────────────────────────
	{
		State:            "ARRIVING",
		CurrentStation:   "Ksar El Kébir",
		CurrentStationFr: "Ksar El Kébir",
		CurrentStationAr: "القصر الكبير",
		NextStation:      "Asilah",
		NextStationFr:    "Asilah",
		NextStationAr:    "أصيلة",
		SpeedKmh: 50, RouteProgress: 0.921,
		MessageFr:       "Arrivée à Asilah",
		MessageAr:       "الوصول إلى أصيلة",
		ActiveAudioLang: "fr", AudioFile: "arriving_asilah_fr.mp3",
	},

	// ── AT STATION 17 — Asilah ───────────────────────────
	{
		State:            "AT_STATION",
		CurrentStation:   "Asilah",
		CurrentStationFr: "Asilah",
		CurrentStationAr: "أصيلة",
		NextStation:      "Tanger Ville",
		NextStationFr:    "Tanger Ville",
		NextStationAr:    "طنجة المدينة",
		SpeedKmh: 0, RouteProgress: 0.924,
		MessageFr:       "Bienvenue à Asilah",
		MessageAr:       "مرحباً بكم في أصيلة",
		ActiveAudioLang: "ar", AudioFile: "station_asilah_ar.mp3",
	},

	// ── DEPARTING Asilah ─────────────────────────────────
	{
		State:            "DEPARTING",
		CurrentStation:   "Asilah",
		CurrentStationFr: "Asilah",
		CurrentStationAr: "أصيلة",
		NextStation:      "Tanger Ville",
		NextStationFr:    "Tanger Ville",
		NextStationAr:    "طنجة المدينة",
		SpeedKmh: 25, RouteProgress: 0.928,
		MessageFr:       "Prochain arrêt: Tanger Ville — terminus",
		MessageAr:       "المحطة القادمة: طنجة المدينة — المحطة النهائية",
		ActiveAudioLang: "fr", AudioFile: "depart_asilah_fr.mp3",
	},

	// ── MOVING → Tanger Ville ────────────────────────────
	{
		State:            "MOVING",
		CurrentStation:   "Asilah",
		CurrentStationFr: "Asilah",
		CurrentStationAr: "أصيلة",
		NextStation:      "Tanger Ville",
		NextStationFr:    "Tanger Ville",
		NextStationAr:    "طنجة المدينة",
		SpeedKmh: 155, RouteProgress: 0.948,
		ActiveAudioLang: "", AudioFile: "",
	},
	{
		State:            "MOVING",
		CurrentStation:   "Asilah",
		CurrentStationFr: "Asilah",
		CurrentStationAr: "أصيلة",
		NextStation:      "Tanger Ville",
		NextStationFr:    "Tanger Ville",
		NextStationAr:    "طنجة المدينة",
		SpeedKmh: 170, RouteProgress: 0.962,
		ActiveAudioLang: "", AudioFile: "",
	},

	// ── ARRIVING Tanger Ville ────────────────────────────
	{
		State:            "ARRIVING",
		CurrentStation:   "Asilah",
		CurrentStationFr: "Asilah",
		CurrentStationAr: "أصيلة",
		NextStation:      "Tanger Ville",
		NextStationFr:    "Tanger Ville",
		NextStationAr:    "طنجة المدينة",
		SpeedKmh: 45, RouteProgress: 0.975,
		MessageFr:       "Arrivée à Tanger Ville — terminus",
		MessageAr:       "الوصول إلى طنجة المدينة — المحطة النهائية",
		ActiveAudioLang: "ar", AudioFile: "arriving_tanger_ar.mp3",
	},

	// ── AT STATION 18 — Tanger Ville (final) ─────────────
	{
		State:            "AT_STATION",
		CurrentStation:   "Tanger Ville",
		CurrentStationFr: "Tanger Ville",
		CurrentStationAr: "طنجة المدينة",
		NextStation:      "Tanger Ville",
		NextStationFr:    "Tanger Ville",
		NextStationAr:    "طنجة المدينة",
		SpeedKmh: 0, RouteProgress: 1.00,
		MessageFr:       "Bienvenue à Tanger Ville. Terminus.",
		MessageAr:       "مرحباً بكم في طنجة المدينة. المحطة النهائية.",
		ActiveAudioLang: "fr", AudioFile: "terminus_tanger_fr.mp3",
	},

	// ── END OF ROUTE ─────────────────────────────────────
	{
		State:            "END_OF_ROUTE",
		CurrentStation:   "Tanger Ville",
		CurrentStationFr: "Tanger Ville",
		CurrentStationAr: "طنجة المدينة",
		NextStation:      "Tanger Ville",
		NextStationFr:    "Tanger Ville",
		NextStationAr:    "طنجة المدينة",
		SpeedKmh: 0, RouteProgress: 1.00,
		MessageFr:       "Merci de voyager avec l'ONCF.",
		MessageAr:       "شكراً لسفركم مع المكتب الوطني للسكك الحديدية.",
		ActiveAudioLang: "ar", AudioFile: "endofroute_ar.mp3",
	},
}

func fillJourney() {
	for i := range journey {
		journey[i].TrainID         = "DOVE-6"
		journey[i].Destination     = activeRoute.Destination
		journey[i].DestinationFr   = activeRoute.Destination
		journey[i].DestinationAr   = activeRoute.DestinationAr
		journey[i].RouteStations   = activeRoute.StationsFr
		journey[i].RouteStationsFr = activeRoute.StationsFr
		journey[i].RouteStationsAr = activeRoute.StationsAr
	}
}
