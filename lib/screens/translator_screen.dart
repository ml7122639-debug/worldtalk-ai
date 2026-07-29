import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import 'package:flutter/services.dart';
import '../core/theme/app_theme.dart';
import '../core/constants/app_constants.dart';
import '../core/providers/language_provider.dart';
import '../models/app_models.dart';
import '../widgets/language_picker_sheet.dart';
import '../widgets/translation_widgets.dart';
import '../services/history_service.dart';

/// Main translator screen — the heart of WorldTalk AI.
/// Supports text input, auto language detection, translation,
/// copy-to-clipboard, share, and swapping languages.
class TranslatorScreen extends ConsumerStatefulWidget {
  final String? initialSourceLang;
  final String? initialTargetLang;

  const TranslatorScreen({
    super.key,
    this.initialSourceLang,
    this.initialTargetLang,
  });

  @override
  ConsumerState<TranslatorScreen> createState() => _TranslatorScreenState();
}

class _TranslatorScreenState extends ConsumerState<TranslatorScreen>
    with TickerProviderStateMixin {
  final _inputController = TextEditingController();
  final _uuid = const Uuid();
  String _translatedText = '';
  Timer? _debounceTimer;
  bool _hasTranslated = false;

  @override
  void initState() {
    super.initState();

    // Apply initial language overrides if navigated with params
    if (widget.initialSourceLang != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final lang = kSupportedLanguages.firstWhere(
          (l) => l.code == widget.initialSourceLang,
          orElse: () => kSupportedLanguages.first,
        );
        ref.read(languageProvider.notifier).setSourceLanguage(lang);
      });
    }
    if (widget.initialTargetLang != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final lang = kSupportedLanguages.firstWhere(
          (l) => l.code == widget.initialTargetLang,
          orElse: () => kSupportedLanguages.first,
        );
        ref.read(languageProvider.notifier).setTargetLanguage(lang);
      });
    }
  }

  @override
  void dispose() {
    _inputController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  Future<void> _translate() async {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;

    final langState = ref.read(languageProvider);
    final service = ref.read(translationServiceProvider);

    ref.read(languageProvider.notifier).setTranslating(true);
    ref.read(languageProvider.notifier).setError(null);

    try {
      final sourceLang =
          langState.autoDetect ? 'auto' : langState.sourceLanguage.code;

      final result = await service.translateText(
        text: text,
        sourceLang: sourceLang,
        targetLang: langState.targetLanguage.code,
      );

      setState(() {
        _translatedText = result;
        _hasTranslated = true;
      });

      // Save to history
      await HistoryService.saveTranslation(
        TranslationResult(
          id: _uuid.v4(),
          sourceText: text,
          translatedText: result,
          sourceLang: sourceLang,
          targetLang: langState.targetLanguage.code,
          timestamp: DateTime.now(),
        ),
      );
    } on TranslationException catch (e) {
      ref.read(languageProvider.notifier).setError(e.message);
    } catch (e) {
      ref.read(languageProvider.notifier).setError(
          'Something went wrong. Please try again.');
    } finally {
      ref.read(languageProvider.notifier).setTranslating(false);
    }
  }

  void _onTextChanged(String text) {
    // Debounced auto-translate (1.5s after user stops typing)
    _debounceTimer?.cancel();
    if (text.trim().isNotEmpty) {
      _debounceTimer = Timer(const Duration(milliseconds: 1500), _translate);
    }
  }

  void _swapLanguages() {
    ref.read(languageProvider.notifier).swapLanguages();
    // Swap the text too so the user sees what just happened
    if (_hasTranslated) {
      final original = _inputController.text;
      setState(() {
        _inputController.text = _translatedText;
        _translatedText = original;
      });
    }
  }

  void _clearAll() {
    setState(() {
      _inputController.clear();
      _translatedText = '';
      _hasTranslated = false;
    });
    ref.read(languageProvider.notifier).setError(null);
  }

  void _copyOutput() {
    if (_translatedText.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: _translatedText));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Copied to clipboard ✓'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final langState = ref.watch(languageProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Translator'),
        actions: [
          if (_inputController.text.isNotEmpty || _hasTranslated)
            IconButton(
              icon: const Icon(Icons.close, size: 20),
              tooltip: 'Clear',
              onPressed: _clearAll,
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ── Language selector bar ──
            _LanguageBar(
              sourceLanguage: langState.sourceLanguage,
              targetLanguage: langState.targetLanguage,
              autoDetect: langState.autoDetect,
              onTapSource: () => _showLanguagePicker(isSource: true),
              onTapTarget: () => _showLanguagePicker(isSource: false),
              onSwap: langState.autoDetect ? null : _swapLanguages,
            ),

            const SizedBox(height: 4),

            // ── Error banner ──
            if (langState.errorMessage != null)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.coral.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.coral.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline,
                        size: 16, color: AppColors.coral),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        langState.errorMessage!,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? AppColors.coral : const Color(0xFFDC2626),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () =>
                          ref.read(languageProvider.notifier).setError(null),
                      child: const Icon(Icons.close,
                          size: 16, color: AppColors.coral),
                    ),
                  ],
                ),
              ),

            // ── Main translation area ──
            Expanded(
              child: Column(
                children: [
                  // Input
                  Expanded(
                    flex: 5,
                    child: TranslationInputField(
                      controller: _inputController,
                      hintText: 'Type or paste text to translate...',
                      onChanged: _onTextChanged,
                      onClear: _inputController.text.isNotEmpty
                          ? () => _inputController.clear()
                          : null,
                    ),
                  ),

                  // Divider
                  const Divider(height: 1),

                  // Output
                  Expanded(
                    flex: 5,
                    child: TranslationOutputPanel(
                      text: _translatedText,
                      isLoading: langState.isTranslating,
                      hasInput: _inputController.text.isNotEmpty,
                      onCopy: _copyOutput,
                      onShare: _hasTranslated ? () {} : null,
                      onRetry: langState.errorMessage != null ? _translate : null,
                    ),
                  ),
                ],
              ),
            ),

            // ── Bottom action bar ──
            _BottomActionBar(
              hasInput: _inputController.text.isNotEmpty,
              hasOutput: _hasTranslated,
              isTranslating: langState.isTranslating,
              onTranslate: _translate,
              onClear: _clearAll,
              onCopy: _copyOutput,
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguagePicker({required bool isSource}) {
    final langState = ref.read(languageProvider);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => LanguagePickerSheet(
        languages: kSupportedLanguages,
        selectedLanguage:
            isSource ? langState.sourceLanguage : langState.targetLanguage,
        showAutoDetect: isSource,
        isAutoDetectSelected: isSource && langState.autoDetect,
        title: isSource ? 'Translate from' : 'Translate to',
        onSelect: (lang) {
          if (isSource) {
            ref.read(languageProvider.notifier).setSourceLanguage(lang);
          } else {
            ref.read(languageProvider.notifier).setTargetLanguage(lang);
          }
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Language selector bar
// ---------------------------------------------------------------------------

class _LanguageBar extends StatelessWidget {
  final AppLanguage sourceLanguage;
  final AppLanguage targetLanguage;
  final bool autoDetect;
  final VoidCallback onTapSource;
  final VoidCallback onTapTarget;
  final VoidCallback? onSwap;

  const _LanguageBar({
    required this.sourceLanguage,
    required this.targetLanguage,
    required this.autoDetect,
    required this.onTapSource,
    required this.onTapTarget,
    this.onSwap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Source language pill
          Expanded(
            child: _LanguagePill(
              label: 'From',
              language: autoDetect ? null : sourceLanguage,
              autoDetect: autoDetect,
              onTap: onTapSource,
            ),
          ),

          // Swap button
          Container(
            width: 40,
            height: 40,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: onSwap != null
                  ? AppColors.lilac.withValues(alpha: 0.12)
                  : Colors.grey.withValues(alpha: 0.08),
              border: Border.all(
                color: onSwap != null
                    ? AppColors.lilac.withValues(alpha: 0.3)
                    : Colors.grey.withValues(alpha: 0.15),
              ),
            ),
            child: IconButton(
              icon: const Icon(Icons.swap_horiz, size: 18),
              color: onSwap != null ? AppColors.ink : AppColors.disabled,
              onPressed: onSwap,
              padding: EdgeInsets.zero,
              splashRadius: 20,
            ),
          ),

          // Target language pill
          Expanded(
            child: _LanguagePill(
              label: 'To',
              language: targetLanguage,
              onTap: onTapTarget,
            ),
          ),
        ],
      ),
    );
  }
}

class _LanguagePill extends StatelessWidget {
  final String label;
  final AppLanguage? language;
  final bool autoDetect;
  final VoidCallback onTap;

  const _LanguagePill({
    required this.label,
    this.language,
    this.autoDetect = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Row(
          children: [
            // Label
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: autoDetect
                    ? AppColors.amber.withValues(alpha: 0.15)
                    : AppColors.lilac.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(100),
              ),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: autoDetect ? AppColors.amber : AppColors.lilac,
                ),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                autoDetect
                    ? '🌐 Auto'
                    : '${language!.flag} ${language!.name}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryText,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            const SizedBox(width: 2),
            const Icon(Icons.chevron_right,
                size: 16, color: AppColors.metaText),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Bottom action bar
// ---------------------------------------------------------------------------

class _BottomActionBar extends StatelessWidget {
  final bool hasInput;
  final bool hasOutput;
  final bool isTranslating;
  final VoidCallback onTranslate;
  final VoidCallback onClear;
  final VoidCallback onCopy;

  const _BottomActionBar({
    required this.hasInput,
    required this.hasOutput,
    required this.isTranslating,
    required this.onTranslate,
    required this.onClear,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: const Border(top: BorderSide(color: AppColors.cardBorder)),
      ),
      child: Row(
        children: [
          // Clear button
          if (hasInput || hasOutput)
            _IconActionButton(
              icon: Icons.close,
              tooltip: 'Clear all',
              onTap: onClear,
            ),

          const Spacer(),

          // Translate button
          ElevatedButton.icon(
            onPressed: isTranslating || !hasInput ? null : onTranslate,
            icon: isTranslating
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.ink,
                    ),
                  )
                : const Icon(Icons.translate, size: 18),
            label: Text(isTranslating ? 'Translating...' : 'Translate'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
            ),
          ),

          const Spacer(),

          // Copy button
          if (hasOutput)
            _IconActionButton(
              icon: Icons.copy,
              tooltip: 'Copy',
              onTap: onCopy,
            ),
        ],
      ),
    );
  }
}

class _IconActionButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _IconActionButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: IconButton(
        icon: Icon(icon, size: 20),
        color: AppColors.secondaryText,
        tooltip: tooltip,
        onPressed: onTap,
        splashRadius: 22,
      ),
    );
  }
}
