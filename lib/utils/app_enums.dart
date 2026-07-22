enum AppLanguages {
  english('English', 'English', 'en', 'E'),
  hindi('Hindi', 'हिन्दी', 'hi', 'हि'),
  spanish('Spanish', 'Español', 'es', 'E'),
  italian('Italian', 'Italiano', 'it', 'I'),
  portuguese('Portuguese', 'Português', 'pt', 'P'),
  japanese('Japanese', '日本語', 'ja', '日'),
  korean('Korean', '한국어', 'ko', '한'),
  arabic('Arabic', 'العربية', 'ar', 'ع'),
  dutch('Dutch', 'Nederlands', 'nl', 'N'),
  german('German', 'Deutsch', 'de', 'D'),
  french('French', 'Français', 'fr', 'F'),
  russian('Russian', 'Русский', 'ru', 'Р'),
  simplifiedChinese('Chinese (Simplified)', '简体中文', 'zh-CN', '简'),
  traditionalChinese('Chinese (Traditional)', '繁體中文', 'zh-TW', '繁'),
  thai('Thai', 'ไทย', 'th', 'ท'),
  turkish('Turkish', 'Türkçe', 'tr', 'T'),
  indonesian('Indonesian', 'Bahasa Indonesia', 'id', 'B'),
  bengali('Bengali', 'বাংলা', 'bn', 'বা'),
  urdu('Urdu', 'اردو', 'ur', 'ا');

  const AppLanguages(
    this.title,
    this.nativeTitle,
    this.languageCode,
    this.badgeText,
  );

  final String title;
  final String nativeTitle;
  final String languageCode;
  final String badgeText;

  static AppLanguages fromLanguageCode(final String? languageCode) {
    return AppLanguages.values.firstWhere(
      (final AppLanguages language) => language.languageCode == languageCode,
      orElse: () => AppLanguages.english,
    );
  }
}
