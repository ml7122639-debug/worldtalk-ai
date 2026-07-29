/// Represents a supported language in WorldTalk AI
class AppLanguage {
  final String code; // ISO 639-1, e.g. 'en', 'bn'
  final String name; // Display name, e.g. 'English', 'বাংলা'
  final String nativeName; // Native script, e.g. 'বাংলা'
  final String flag; // Country flag emoji, e.g. '🇧🇩'

  const AppLanguage({
    required this.code,
    required this.name,
    required this.nativeName,
    required this.flag,
  });

  String get displayName => '$flag $name';

  /// Lexicographic comparator by code
  int compareTo(AppLanguage other) => code.compareTo(other.code);

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is AppLanguage && code == other.code;

  @override
  int get hashCode => code.hashCode;

  Map<String, String> toJson() => {
        'code': code,
        'name': name,
        'nativeName': nativeName,
        'flag': flag,
      };

  factory AppLanguage.fromJson(Map<String, dynamic> json) => AppLanguage(
        code: json['code'] as String,
        name: json['name'] as String,
        nativeName: json['nativeName'] as String,
        flag: json['flag'] as String,
      );
}

/// Represents a single translation result
class TranslationResult {
  final String id;
  final String sourceText;
  final String translatedText;
  final String sourceLang;
  final String targetLang;
  final DateTime timestamp;
  final TranslationMode mode;

  const TranslationResult({
    required this.id,
    required this.sourceText,
    required this.translatedText,
    required this.sourceLang,
    required this.targetLang,
    required this.timestamp,
    this.mode = TranslationMode.text,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'sourceText': sourceText,
        'translatedText': translatedText,
        'sourceLang': sourceLang,
        'targetLang': targetLang,
        'timestamp': timestamp.toIso8601String(),
        'mode': mode.name,
      };

  factory TranslationResult.fromJson(Map<String, dynamic> json) =>
      TranslationResult(
        id: json['id'] as String,
        sourceText: json['sourceText'] as String,
        translatedText: json['translatedText'] as String,
        sourceLang: json['sourceLang'] as String,
        targetLang: json['targetLang'] as String,
        timestamp: DateTime.parse(json['timestamp'] as String),
        mode: TranslationMode.values.firstWhere(
          (e) => e.name == json['mode'],
          orElse: () => TranslationMode.text,
        ),
      );
}

enum TranslationMode { text, voice, image, camera, pdf }

/// Represents a Nova AI chat message
class ChatMessage {
  final String id;
  final String text;
  final bool isUser; // true = user, false = Nova
  final DateTime timestamp;

  const ChatMessage({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'isUser': isUser,
        'timestamp': timestamp.toIso8601String(),
      };

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        id: json['id'] as String,
        text: json['text'] as String,
        isUser: json['isUser'] as bool,
        timestamp: DateTime.parse(json['timestamp'] as String),
      );
}
