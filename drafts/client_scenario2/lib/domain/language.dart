// Represents the active display language — French (default) or Arabic (RTL).
enum DisplayLanguage { fr, ar }

extension DisplayLanguageExt on DisplayLanguage {
  bool get isRtl => this == DisplayLanguage.ar;

  static DisplayLanguage fromCode(String code) {
    if (code == 'ar') return DisplayLanguage.ar;
    return DisplayLanguage.fr;
  }
}
