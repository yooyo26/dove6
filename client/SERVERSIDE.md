                                                                                                                                                                               
  You are implementing the full DataService layer for dove6_client.                                                                                                             
  This is a Flutter app for a Moroccan train passenger display (Z2M project).                                                                                                   
  Target platform: Ubuntu Linux on Aeon Gene BT06.                                                                                                                              
  No third-party packages except http.                                                                                                                                          
                                                                                                                                                                                
  Read every section below completely before writing a single line of code.                                                                                                     
                                                                                                                                                                                
  ═══════════════════════════════════════════════════════                                                                                                                       
  1. ARCHITECTURE RULES — NEVER BREAK THESE                                                                                                                                   
  ═══════════════════════════════════════════════════════                                                                                                                       
  Pattern: domain → data → presentation
  - DataService is an abstract interface                                                                                                                                        
  - NvrDataService is the concrete implementation                                                                                                                             
  - DisplayMapper owns ALL state logic and ALL timers — nothing else does                                                                                                       
  - Screens are StatelessWidget — receive DisplayData + bool isArabic only                                                                                                      
  - No screen imports anything except DisplayData and _shared.dart                                                                                                              
  - No third-party packages except http                                                                                                                                         
  - All routing logic lives in display_mapper.dart only                                                                                                                         
  - All colors and shared widgets live in _shared.dart only                                                                                                                     
                                                                                                                                                                              
  ═══════════════════════════════════════════════════════                                                                                                                       
  2. BASE URLs                                                                                                                                                                
  ═══════════════════════════════════════════════════════                                                                                                                       
  Dev (fake NVR):  http://localhost:8080                                                                                                                                      
  Prod (real NVR): http://{nvrIp}:3002/v0                                                                                                                                       
                                                                                                                                                                                
  The DataService must be swappable by changing one line (the base URL).                                                                                                        
  The fake server on port 8080 exposes the exact same endpoints as the                                                                                                          
  real NVR on port 3002/v0. The client code sees no difference.                                                                                                                 
                                                                                                                                                                                
  ═══════════════════════════════════════════════════════                                                                                                                       
  3. POLLING STRATEGY                                                                                                                                                           
  ═══════════════════════════════════════════════════════                                                                                                                     
  - On startup: call GET /health. If unreachable, show error and retry every 3s.
  - Once healthy: fetch route data ONCE (stations list + each station's info).                                                                                                  
    Re-fetch only if route_id changes between polls.                                                                                                                            
  - Every 1 second: poll these 5 endpoints IN PARALLEL:                                                                                                                         
      GET /running-state                                                                                                                                                        
      GET /audio-state                                                                                                                                                          
      GET /data/speed                                                                                                                                                           
      GET /data/distance-ratio                                                                                                                                                
      GET /data/current-route                                                                                                                                                   
  - Merge all 5 responses into one DisplayData and pass to DisplayMapper.                                                                                                       
                                                                                                                                                                                
  ═══════════════════════════════════════════════════════                                                                                                                       
  4. ENDPOINT CONTRACTS — EXACT PAYLOADS                                                                                                                                        
  ═══════════════════════════════════════════════════════                                                                                                                     
                                                                                                                                                                                
  ─── GET /health ────────────────────────────────────────
  Response:                                                                                                                                                                     
    { "status": "ok", "server": "dove6_server" }                                                                                                                                
  Use: startup connectivity check only.
                                                                                                                                                                                
  ─── GET /running-state ─────────────────────────────────                                                                                                                    
  Response:                                                                                                                                                                     
    { "current_state": "<string>" }                                                                                                                                           
                                                                                                                                                                                
  Map current_state → TrainState:                                                                                                                                               
    "operating_state_idle"           → TrainState.idle                                                                                                                          
    "operating_state_routeselected"  → TrainState.routeSelected                                                                                                                 
    "operating_state_atstation"      → TrainState.atStation                                                                                                                   
    "operating_state_departing"      → TrainState.departing                                                                                                                     
    "operating_state_moving"         → TrainState.moving                                                                                                                        
    "operating_state_coasting"       → TrainState.moving   ← same visual as moving
    "operating_state_arriving"       → TrainState.arriving                                                                                                                      
    "operating_state_endofroute"     → TrainState.endOfRoute                                                                                                                  
    "operating_state_recovery"       → TrainState.recovery                                                                                                                      
    "operating_state_warning"        → TrainState.warning                                                                                                                     
    "Operating_State_ManualHandling" → TrainState.manual   ← capital O, exact string                                                                                            
                                                                                                                                                                                
  ─── GET /audio-state ───────────────────────────────────                                                                                                                      
  Response:                                                                                                                                                                     
    { "audio_action": "<string>" }                                                                                                                                            
                                                                                                                                                                                
  Map audio_action → bool isArabic:
    "playing_arabic_audio"   → true                                                                                                                                             
    "playing_french_audio"   → false                                                                                                                                            
    "playing_english_audio"  → false
    "playing_default_audio"  → false                                                                                                                                            
    "no_audio_is_playing"    → false                                                                                                                                            
    anything else            → false
                                                                                                                                                                                
  IMPORTANT: isArabic is read at the moment of a STATE TRANSITION only.                                                                                                         
  DisplayMapper reads it when entering a new state, not on every poll tick.
  Never switch language mid-screen.                                                                                                                                             
                                                                                                                                                                              
  ─── GET /data/speed ────────────────────────────────────                                                                                                                      
  Response:                                                                                                                                                                   
    { "speed": <float> }                                                                                                                                                        
                                                                                                                                                                              
  Unit: km/h. Range 0–200. Round to int for display.                                                                                                                            
  Used by MovingSpeedScreen (Phase 1 of moving state).
                                                                                                                                                                                
  ─── GET /data/distance-ratio ───────────────────────────                                                                                                                    
  Response:                                                                                                                                                                     
    { "ratio": <int> }                                                                                                                                                        
                                                                                                                                                                                
  Range: 0–100. Divide by 100.0 to get a 0.0–1.0 float (routeProgress).                                                                                                         
  Used by MovingProgressScreen and RouteProgressPainter.                                                                                                                        
                                                                                                                                                                                
  ─── GET /data/current-route ────────────────────────────                                                                                                                    
  Response:                                                                                                                                                                     
    {                                                                                                                                                                         
      "route_id":            "<uuid>",
      "is_in_reverse":       false,
      "start_station_index": <int>                                                                                                                                              
    }                                                                                                                                                                           
                                                                                                                                                                                
  CRITICAL: "start_station_index" is the INDEX OF THE CURRENT STATION                                                                                                           
  in the full station list — NOT the departure station of the route.                                                                                                          
  The name is misleading. Use it to highlight the current station                                                                                                               
  in the progress bar.                                                                                                                                                          
                                                                                                                                                                                
  route_id: if this changes between polls, re-fetch stations.                                                                                                                   
  is_in_reverse: if true, render station list and progress bar in reverse.                                                                                                    
                                                                                                                                                                                
  ─── GET /data/stations-in-route/{route_id} ─────────────                                                                                                                      
  Response:
    ["<uuid1>", "<uuid2>", ..., "<uuid18>"]                                                                                                                                     
                                                                                                                                                                                
  Array of station UUIDs in route order.
  Fetch once on startup (or when route_id changes).                                                                                                                             
  For each UUID, call GET /data/station-info/{id}.                                                                                                                              
   
  ─── GET /data/station-info/{station_id} ────────────────                                                                                                                      
  Response:                                                                                                                                                                   
    {                                                                                                                                                                           
      "display_name":    "<lowercase internal name>",                                                                                                                         
      "display_name_fr": "<French display name>",
      "display_name_ar": "<Arabic display name>"
    }                                                                                                                                                                           
   
  ALWAYS use display_name_fr for French screens.                                                                                                                                
  ALWAYS use display_name_ar for Arabic screens.                                                                                                                              
  If display_name_ar is absent in a response, fall back to display_name_fr.                                                                                                     
  Fetch all stations once at startup. Cache the results.                                                                                                                        
                                                                                                                                                                                
  ─── GET /sensors/human-counter ─────────────────────────                                                                                                                      
  Response:                                                                                                                                                                     
    { "count": <int> }                                                                                                                                                          
                                                                                                                                                                              
  Passenger count. Display on station screen. Non-critical.                                                                                                                     
   
  ═══════════════════════════════════════════════════════                                                                                                                       
  5. DATA MODELS                                                                                                                                                              
  ═══════════════════════════════════════════════════════                                                                                                                       
   
  class Station {                                                                                                                                                               
    final int    index;                                                                                                                                                       
    final String id;
    final String nameFr;                                                                                                                                                        
    final String nameAr;
  }                                                                                                                                                                             
                                                                                                                                                                              
  class DisplayData {
    final TrainState state;
    final double     speedKmh;          // from /data/speed
    final double     routeProgress;     // ratio / 100.0                                                                                                                        
    final int        currentStationIdx; // start_station_index from /data/current-route
    final bool       isInReverse;       // from /data/current-route                                                                                                             
    final String     routeId;           // from /data/current-route                                                                                                             
    final List<Station> stations;       // resolved from station-info calls                                                                                                     
    final String     destinationFr;                                                                                                                                             
    final String     destinationAr;                                                                                                                                           
    final int        passengerCount;    // from /sensors/human-counter                                                                                                          
  }                                                                                                                                                                             
   
  enum TrainState {                                                                                                                                                             
    idle,                                                                                                                                                                     
    routeSelected,
    atStation,
    departing,
    moving,
    arriving,
    endOfRoute,                                                                                                                                                                 
    warning,
    manual,                                                                                                                                                                     
    recovery,                                                                                                                                                                 
  }

  ═══════════════════════════════════════════════════════
  6. STATE MACHINE — DisplayMapper rules
  ═══════════════════════════════════════════════════════                                                                                                                       
  idle          → IdleScreen
  routeSelected → RouteSelectedScreen                                                                                                                                           
  atStation     → StationScreen                                                                                                                                                 
  departing     → DepartingScreen
  moving        → Phase 1 (first 5 seconds): MovingSpeedScreen                                                                                                                  
                 Phase 2 (after 5 seconds):  MovingProgressScreen                                                                                                               
                 Timer resets on EVERY new entry into moving state.                                                                                                             
  arriving      → ArrivingScreen                                                                                                                                                
  endOfRoute    → EndOfRouteScreen                                                                                                                                              
  warning       → WarningScreen    (priority — interrupts any state)                                                                                                          
  manual        → ManualScreen     (priority — interrupts any state)                                                                                                            
  recovery      → RecoveryScreen   (priority — interrupts any state)                                                                                                          
                                                                                                                                                                                
  arriving → atStation transition rule:                                                                                                                                         
    Show ArrivedMessageScreen for exactly 3 seconds.
    Then switch to StationScreen.                                                                                                                                               
    This 3-second timer lives ONLY in DisplayMapper.                                                                                                                          
                                                                                                                                                                                
  ═══════════════════════════════════════════════════════                                                                                                                     
  7. LANGUAGE BEHAVIOR                                                                                                                                                          
  ═══════════════════════════════════════════════════════                                                                                                                     
  French is the permanent default.
  Rule: on every state transition, read the current isArabic value                                                                                                              
        and apply it to the incoming screen. Never change it mid-screen.                                                                                                        
  Arabic screens use RTL layout.                                                                                                                                                
  One language per screen. Never mixed.                                                                                                                                         
                                                                                                                                                                                
  ═══════════════════════════════════════════════════════                                                                                                                       
  8. COLOR PALETTE — NEVER CHANGE THESE                                                                                                                                       
  ═══════════════════════════════════════════════════════                                                                                                                       
  const kBg         = Color(0xFFE8E4DF);   // warm light grey — background
  const kSurface    = Color(0xFFD6CFC7);   // card surface                                                                                                                      
  const kCard       = Color(0xFFD6CFC7);   // cards                                                                                                                             
  const kBorder     = Color(0xFFC8C3BC);   // borders                                                                                                                           
  const kPrimary    = Color(0xFF1A1A1A);   // main text                                                                                                                         
  const kSecondary  = Color(0xFF5F5E5A);   // muted text                                                                                                                        
  const kAccent     = Color(0xFFE8650A);   // orange — primary accent                                                                                                           
  const kAccentGold = Color(0xFF333333);   // dark grey — speed numbers                                                                                                         
  const kDim        = Color(0xFFBFB9B1);   // subtle elements                                                                                                                   
                                                                                                                                                                                
  ═══════════════════════════════════════════════════════                                                                                                                       
  9. KNOWN BUGS — FIX THESE FIRST                                                                                                                                               
  ═══════════════════════════════════════════════════════                                                                                                                       
  BUG-001 — Progress bar dot colors wrong
  File:   lib/presentation/screens/_shared.dart                                                                                                                                 
  Method: _renderSmartWindow in RouteProgressPainter                                                                                                                            
  Wrong:  _dotState(j, cur, last)                                                                                                                                               
  Right:  _dotState(item.index, cur, last)                                                                                                                                      
  Why:    j is the window-local index, item.index is the global route index.                                                                                                    
          Using j makes every dot think it's near the start of the route.                                                                                                       
                                                                                                                                                                                
  ═══════════════════════════════════════════════════════                                                                                                                       
  10. 18-STATION ROUTE REFERENCE                                                                                                                                                
  ═══════════════════════════════════════════════════════                                                                                                                       
  Index | FR                  | AR
    0   | Marrakech           | شكارم                                                                                                                                           
    1   | Youssoufia          | ةيفسويلا                                                                                                                                        
    2   | Benguerir           | ريركنب                                                                                                                                          
    3   | Settat              | تاطس                                                                                                                                            
    4   | El Jadida           | ةديدجلا                                                                                                                                         
    5   | Casa Oasis          | سيسيوأ ءاضيبلا رادلا                                                                                                                          
    6   | Casa Voyageurs      | نيرفاسملا ءاضيبلا رادلا                                                                                                                         
    7   | Casa Ain Sebaa      | عبسلا نيع ءاضيبلا رادلا                                                                                                                         
    8   | Mohammedia          | ةيدمحملا                                                                                                                                        
    9   | Rabat Agdal         | لادكأ طابرلا                                                                                                                                    
   10   | Rabat Ville         | ةنيدملا طابرلا                                                                                                                                  
   11   | Salé Tabriquet      | تقيرباط الس                                                                                                                                     
   12   | Salé Ville          | ةنيدملا الس                                                                                                                                     
   13   | Kénitra             | ةرطينقلا                                                                                                                                        
   14   | Sidi Bouknadel      | لدانقوب يديس                                                                                                                                    
   15   | Ksar El Kébir       | ريبكلا رصقلا                                                                                                                                    
   16   | Asilah              | ةليصأ                                                                                                                                         
   17   | Tanger Ville        | ةنيدملا ةجنط                                                                                                                                    
                                                                                                                                                                                
  These names come from GET /data/station-info/{uuid}.                                                                                                                          
  Do NOT hardcode them in the client. Always resolve from the API.                                                                                                              
                                                                                                                                                                                
  ---                                                                                                                                                                         
  What changed in the server and why                                                                                                                                            
                                            