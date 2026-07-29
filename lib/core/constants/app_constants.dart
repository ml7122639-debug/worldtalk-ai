import '../../models/app_models.dart';

/// The 15 languages supported in WorldTalk AI V1 MVP.
/// Ordered by global reach: English first, then by population.
const kSupportedLanguages = <AppLanguage>[
  AppLanguage(code: 'en', name: 'English', nativeName: 'English', flag: '🇬🇧'),
  AppLanguage(code: 'bn', name: 'Bengali', nativeName: 'বাংলা', flag: '🇧🇩'),
  AppLanguage(code: 'hi', name: 'Hindi', nativeName: 'हिन्दी', flag: '🇮🇳'),
  AppLanguage(code: 'es', name: 'Spanish', nativeName: 'Español', flag: '🇪🇸'),
  AppLanguage(code: 'fr', name: 'French', nativeName: 'Français', flag: '🇫🇷'),
  AppLanguage(code: 'de', name: 'German', nativeName: 'Deutsch', flag: '🇩🇪'),
  AppLanguage(code: 'zh', name: 'Chinese', nativeName: '中文', flag: '🇨🇳'),
  AppLanguage(code: 'ja', name: 'Japanese', nativeName: '日本語', flag: '🇯🇵'),
  AppLanguage(code: 'ko', name: 'Korean', nativeName: '한국어', flag: '🇰🇷'),
  AppLanguage(code: 'ar', name: 'Arabic', nativeName: 'العربية', flag: '🇸🇦'),
  AppLanguage(code: 'pt', name: 'Portuguese', nativeName: 'Português', flag: '🇵🇹'),
  AppLanguage(code: 'ru', name: 'Russian', nativeName: 'Русский', flag: '🇷🇺'),
  AppLanguage(code: 'ur', name: 'Urdu', nativeName: 'اردو', flag: '🇵🇰'),
  AppLanguage(code: 'tr', name: 'Turkish', nativeName: 'Türkçe', flag: '🇹🇷'),
  AppLanguage(code: 'it', name: 'Italian', nativeName: 'Italiano', flag: '🇮🇹'),
];

/// The auto-detect placeholder language
const kAutoDetectLanguage = AppLanguage(
  code: 'auto',
  name: 'Detect Language',
  nativeName: 'Auto',
  flag: '🌐',
);

/// Key storage keys
class StorageKeys {
  static const sourceLanguage = 'source_language_code';
  static const targetLanguage = 'target_language_code';
  static const themeMode = 'theme_mode';
  static const onboardingComplete = 'onboarding_complete';
  static const translationCount = 'translation_count';
  static const lastHistorySync = 'last_history_sync';

  const StorageKeys._();
}

/// API endpoints — replace with your Cloudflare Worker URL
class ApiEndpoints {
  static const translate = '/translate';
  static const speechToText = '/speech-to-text';
  static const textToSpeech = '/text-to-speech';
  static const novaChat = '/nova/chat';
  static const detectLanguage = '/detect';

  const ApiEndpoints._();
}

/// App metadata
class AppMeta {
  static const appName = 'WorldTalk AI';
  static const version = '1.0.0';
  static const buildNumber = 1;
  static const privacyPolicyUrl = 'https://worldtalk.ai/privacy';
  static const termsOfServiceUrl = 'https://worldtalk.ai/terms';

  const AppMeta._();
}
