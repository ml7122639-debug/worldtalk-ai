import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../models/app_models.dart';
import '../constants/app_constants.dart';

/// Manages the selected source and target languages across the app
class LanguageState {
  final AppLanguage sourceLanguage;
  final AppLanguage targetLanguage;
  final bool autoDetect;
  final bool isTranslating;
  final String? errorMessage;

  const LanguageState({
    this.sourceLanguage = kAutoDetectLanguage,
    this.targetLanguage = const AppLanguage(
        code: 'en', name: 'English', nativeName: 'English', flag: '🇬🇧'),
    this.autoDetect = true,
    this.isTranslating = false,
    this.errorMessage,
  });

  LanguageState copyWith({
    AppLanguage? sourceLanguage,
    AppLanguage? targetLanguage,
    bool? autoDetect,
    bool? isTranslating,
    String? errorMessage,
    bool clearError = false,
  }) {
    return LanguageState(
      sourceLanguage: sourceLanguage ?? this.sourceLanguage,
      targetLanguage: targetLanguage ?? this.targetLanguage,
      autoDetect: autoDetect ?? this.autoDetect,
      isTranslating: isTranslating ?? this.isTranslating,
      errorMessage: clearError ? null : errorMessage,
    );
  }
}

/// Provider for language state
class LanguageNotifier extends StateNotifier<LanguageState> {
  LanguageNotifier(this.ref) : super(const LanguageState()) {
    _loadFromStorage();
  }

  final Ref ref;

  Future<void> _loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final srcCode = prefs.getString(StorageKeys.sourceLanguage);
    final tgtCode = prefs.getString(StorageKeys.targetLanguage);

    if (srcCode != null) {
      final lang = kSupportedLanguages.firstWhere(
        (l) => l.code == srcCode,
        orElse: () => kSupportedLanguages.first,
      );
      state = state.copyWith(sourceLanguage: lang, autoDetect: srcCode == 'auto');
    }
    if (tgtCode != null) {
      final lang = kSupportedLanguages.firstWhere(
        (l) => l.code == tgtCode,
        orElse: () => kSupportedLanguages.first,
      );
      state = state.copyWith(targetLanguage: lang);
    }
  }

  void setSourceLanguage(AppLanguage lang) {
    SharedPreferences.getInstance().then(
      (prefs) => prefs.setString(StorageKeys.sourceLanguage, lang.code),
    );
    state = state.copyWith(
      sourceLanguage: lang,
      autoDetect: lang.code == 'auto',
      clearError: true,
    );
  }

  void setTargetLanguage(AppLanguage lang) {
    SharedPreferences.getInstance().then(
      (prefs) => prefs.setString(StorageKeys.targetLanguage, lang.code),
    );
    state = state.copyWith(targetLanguage: lang, clearError: true);
  }

  void swapLanguages() {
    if (state.autoDetect) return; // can't swap auto-detect
    final src = state.targetLanguage;
    final tgt = state.sourceLanguage;
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString(StorageKeys.sourceLanguage, src.code);
      prefs.setString(StorageKeys.targetLanguage, tgt.code);
    });
    state = state.copyWith(
      sourceLanguage: src,
      targetLanguage: tgt,
      autoDetect: false,
    );
  }

  void setTranslating(bool value) {
    state = state.copyWith(isTranslating: value);
  }

  void setError(String? message) {
    state = state.copyWith(errorMessage: message);
  }
}

/// Provider for the language notifier
final languageProvider =
    StateNotifierProvider<LanguageNotifier, LanguageState>((ref) {
  return LanguageNotifier(ref);
});

// ---------------------------------------------------------------------------
// Translation Service
// ---------------------------------------------------------------------------

/// Handles API calls to the Cloudflare Worker (which proxies Google Translate)
class TranslationService {
  // Replace with your Cloudflare Worker URL after deployment
  static const String _baseUrl = 'https://worldtalk-api.YOUR_SUBDOMAIN.workers.dev';

  final http.Client _client;

  TranslationService({http.Client? client}) : _client = client ?? http.Client();

  /// Translate text from sourceLang to targetLang.
  /// If sourceLang is 'auto', the Worker detects the language.
  Future<String> translateText({
    required String text,
    required String sourceLang,
    required String targetLang,
  }) async {
    final uri = Uri.parse('$_baseUrl${ApiEndpoints.translate}');
    final response = await _client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'text': text,
        'sourceLang': sourceLang,
        'targetLang': targetLang,
      }),
    );

    if (response.statusCode != 200) {
      throw TranslationException(
        'Translation failed (${response.statusCode})',
      );
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (body['error'] != null) {
      throw TranslationException(body['error'] as String);
    }
    return body['translatedText'] as String;
  }

  /// Detects the language of [text].
  /// Returns ISO 639-1 language code.
  Future<String> detectLanguage(String text) async {
    final uri = Uri.parse('$_baseUrl${ApiEndpoints.detectLanguage}');
    final response = await _client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'text': text}),
    );

    if (response.statusCode != 200) {
      throw TranslationException('Detection failed (${response.statusCode})');
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    return body['languageCode'] as String;
  }

  /// Send a message to Nova AI and get a response.
  Future<String> chatWithNova(List<ChatMessage> history) async {
    final uri = Uri.parse('$_baseUrl${ApiEndpoints.novaChat}');
    final response = await _client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'messages': history
            .map((m) => {
                  'role': m.isUser ? 'user' : 'assistant',
                  'content': m.text,
                })
            .toList(),
      }),
    );

    if (response.statusCode != 200) {
      throw TranslationException('Nova AI failed (${response.statusCode})');
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    return body['reply'] as String;
  }

  void dispose() {
    _client.close();
  }
}

class TranslationException implements Exception {
  final String message;
  const TranslationException(this.message);

  @override
  String toString() => 'TranslationException: $message';
}

/// Provider for the translation service
final translationServiceProvider = Provider<TranslationService>((ref) {
  final service = TranslationService();
  ref.onDispose(() => service.dispose());
  return service;
});
