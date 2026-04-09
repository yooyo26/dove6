// Core data snapshot — everything any screen needs
import 'train_state.dart';
import 'language.dart';

class DisplayData {
  final TrainState state;
  final String trainId;
  final String currentStation;
  final String nextStation;
  final String destination;
  final double speedKmh;
  final double routeProgress; // 0.0 to 1.0
  final List<String> routeStations;
  final DateTime timestamp;

  // French translations
  final String currentStationFr;
  final String nextStationFr;
  final String destinationFr;
  final List<String> routeStationsFr;

  // Arabic translations
  final String currentStationAr;
  final String nextStationAr;
  final String destinationAr;
  final List<String> routeStationsAr;

  // Messages from server in all 3 languages
  final String messageEn;
  final String messageFr;
  final String messageAr;

  // Audio sync — which language speaker is announcing
  // Values: "en" "fr" "ar" or "" for silence
  final String activeAudioLang;
  final String audioFile;

  // Passenger count from NVR (0 = not available)
  final int passengerCount;

  const DisplayData({
    required this.state,
    required this.trainId,
    required this.currentStation,
    required this.nextStation,
    required this.destination,
    required this.speedKmh,
    required this.routeProgress,
    required this.routeStations,
    required this.timestamp,
    this.currentStationFr = '',
    this.nextStationFr = '',
    this.destinationFr = '',
    this.routeStationsFr = const [],
    this.currentStationAr = '',
    this.nextStationAr = '',
    this.destinationAr = '',
    this.routeStationsAr = const [],
    this.messageEn = '',
    this.messageFr = '',
    this.messageAr = '',
    this.activeAudioLang = '',
    this.audioFile = '',
    this.passengerCount = 0,
  });

  DisplayData copyWith({
    TrainState? state,
    String? trainId,
    String? currentStation,
    String? nextStation,
    String? destination,
    double? speedKmh,
    double? routeProgress,
    List<String>? routeStations,
    DateTime? timestamp,
    String? currentStationFr,
    String? nextStationFr,
    String? destinationFr,
    List<String>? routeStationsFr,
    String? currentStationAr,
    String? nextStationAr,
    String? destinationAr,
    List<String>? routeStationsAr,
    String? messageEn,
    String? messageFr,
    String? messageAr,
    String? activeAudioLang,
    String? audioFile,
    int? passengerCount,
  }) {
    return DisplayData(
      state: state ?? this.state,
      trainId: trainId ?? this.trainId,
      currentStation: currentStation ?? this.currentStation,
      nextStation: nextStation ?? this.nextStation,
      destination: destination ?? this.destination,
      speedKmh: speedKmh ?? this.speedKmh,
      routeProgress: routeProgress ?? this.routeProgress,
      routeStations: routeStations ?? this.routeStations,
      timestamp: timestamp ?? this.timestamp,
      currentStationFr: currentStationFr ?? this.currentStationFr,
      nextStationFr: nextStationFr ?? this.nextStationFr,
      destinationFr: destinationFr ?? this.destinationFr,
      routeStationsFr: routeStationsFr ?? this.routeStationsFr,
      currentStationAr: currentStationAr ?? this.currentStationAr,
      nextStationAr: nextStationAr ?? this.nextStationAr,
      destinationAr: destinationAr ?? this.destinationAr,
      routeStationsAr: routeStationsAr ?? this.routeStationsAr,
      messageEn: messageEn ?? this.messageEn,
      messageFr: messageFr ?? this.messageFr,
      messageAr: messageAr ?? this.messageAr,
      activeAudioLang: activeAudioLang ?? this.activeAudioLang,
      audioFile: audioFile ?? this.audioFile,
      passengerCount: passengerCount ?? this.passengerCount,
    );
  }

  // Blank starting state — all route data comes from the server.
  // No station names or route lists live in the client.
  static DisplayData initial() => DisplayData(
    state: TrainState.idle,
    trainId: '',
    currentStation: '',
    nextStation: '',
    destination: '',
    speedKmh: 0,
    routeProgress: 0,
    routeStations: const [],
    timestamp: DateTime.now(),
    currentStationFr: '',
    nextStationFr: '',
    destinationFr: '',
    routeStationsFr: const [],
    currentStationAr: '',
    nextStationAr: '',
    destinationAr: '',
    routeStationsAr: const [],
    messageEn: '',
    messageFr: '',
    messageAr: '',
    activeAudioLang: '',
    audioFile: '',
  );

  // Returns station name in the requested language.
  // Falls back to base name if translation is empty.
  String currentStationIn(DisplayLanguage lang) {
    switch (lang) {
      case DisplayLanguage.fr:
        return currentStationFr.isEmpty ? currentStation : currentStationFr;
      case DisplayLanguage.ar:
        return currentStationAr.isEmpty ? currentStation : currentStationAr;
    }
  }

  String nextStationIn(DisplayLanguage lang) {
    switch (lang) {
      case DisplayLanguage.fr:
        return nextStationFr.isEmpty ? nextStation : nextStationFr;
      case DisplayLanguage.ar:
        return nextStationAr.isEmpty ? nextStation : nextStationAr;
    }
  }

  String destinationIn(DisplayLanguage lang) {
    switch (lang) {
      case DisplayLanguage.fr:
        return destinationFr.isEmpty ? destination : destinationFr;
      case DisplayLanguage.ar:
        return destinationAr.isEmpty ? destination : destinationAr;
    }
  }

  List<String> routeStationsIn(DisplayLanguage lang) {
    switch (lang) {
      case DisplayLanguage.fr:
        return routeStationsFr.isEmpty ? routeStations : routeStationsFr;
      case DisplayLanguage.ar:
        return routeStationsAr.isEmpty ? routeStations : routeStationsAr;
    }
  }

  String messageIn(DisplayLanguage lang) {
    switch (lang) {
      case DisplayLanguage.fr:
        return messageFr.isEmpty ? messageEn : messageFr;
      case DisplayLanguage.ar:
        return messageAr.isEmpty ? messageEn : messageAr;
    }
  }

  // Returns the language the display should follow.
  // When audio is playing the display syncs to it.
  // When silent the display shows all 3 languages.
  DisplayLanguage get syncedLanguage {
    if (activeAudioLang.isEmpty) return DisplayLanguage.fr;
    return DisplayLanguageExt.fromCode(activeAudioLang);
  }

  bool get isAudioSynced => activeAudioLang.isNotEmpty;
}
