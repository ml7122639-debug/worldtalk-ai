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
      ref.read(languageProvider.notifier).setError('Something went wrong.');
    } finally {
      ref.read(languageProvider.notifier).setTranslating(false);
    }
  }

  void _onTextChanged(String text) {
    _debounceTimer?.cancel();
    if (text.trim().isNotEmpty) {
      _debounceTimer = Timer(const Duration(milliseconds: 1500), _translate);
    }
  }

  void _swapLanguages() {
    ref.read(languageProvider.notifier).swapLanguages();
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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text('Copied to clipboard'), behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), duration: const Duration(seconds: 2)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final ls = ref.watch(languageProvider);
    final th = Theme.of(context);
    final dk = th.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: th.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Translator'),
        actions: [if (_inputController.text.isNotEmpty || _hasTranslated) IconButton(icon: const Icon(Icons.close, size: 20), tooltip: 'Clear', onPressed: _clearAll)],
      ),
      body: SafeArea(
        child: Column(children: [
          _LanguageBar(sourceLanguage: ls.sourceLanguage, targetLanguage: ls.targetLanguage, autoDetect: ls.autoDetect, onTapSource: () => _showLanguagePicker(isSource: true), onTapTarget: () => _showLanguagePicker(isSource: false), onSwap: ls.autoDetect ? null : _swapLanguages),
          const SizedBox(height: 4),
          if (ls.errorMessage != null)
            Container(margin: const EdgeInsets.symmetric(horizontal: 16), padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10), decoration: BoxDecoration(color: AppColors.coral.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.coral.withValues(alpha: 0.3))), child: Row(children: [const Icon(Icons.error_outline, size: 16, color: AppColors.coral), const SizedBox(width: 8), Expanded(child: Text(ls.errorMessage!, style: TextStyle(fontSize: 13, color: dk ? AppColors.coral : const Color(0xFFDC2626)))), GestureDetector(onTap: () => ref.read(languageProvider.notifier).setError(null), child: const Icon(Icons.close, size: 16, color: AppColors.coral))])),
          Expanded(
            child: Column(children: [
              Expanded(flex: 5, child: TranslationInputField(controller: _inputController, hintText: 'Type or paste text to translate...', onChanged: _onTextChanged, onClear: _inputController.text.isNotEmpty ? () => _inputController.clear() : null)),
              const Divider(height: 1),
              Expanded(flex: 5, child: TranslationOutputPanel(text: _translatedText, isLoading: ls.isTranslating, hasInput: _inputController.text.isNotEmpty, onCopy: _copyOutput, onShare: _hasTranslated ? () {} : null, onRetry: ls.errorMessage != null ? _translate : null)),
            ]),
          ),
          _BottomActionBar(hasInput: _inputController.text.isNotEmpty, hasOutput: _hasTranslated, isTranslating: ls.isTranslating, onTranslate: _translate, onClear: _clearAll, onCopy: _copyOutput),
        ]),
      ),
    );
  }

  void _showLanguagePicker({required bool isSource}) {
    final ls = ref.read(languageProvider);
    showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (_) => LanguagePickerSheet(languages: kSupportedLanguages, selectedLanguage: isSource ? ls.sourceLanguage : ls.targetLanguage, showAutoDetect: isSource, isAutoDetectSelected: isSource && ls.autoDetect, title: isSource ? 'Translate from' : 'Translate to', onSelect: (lang) { if (isSource) ref.read(languageProvider.notifier).setSourceLanguage(lang); else ref.read(languageProvider.notifier).setTargetLanguage(lang); }));
  }
}

class _LanguageBar extends StatelessWidget {
  final AppLanguage sourceLanguage;
  final AppLanguage targetLanguage;
  final bool autoDetect;
  final VoidCallback onTapSource;
  final VoidCallback onTapTarget;
  final VoidCallback? onSwap;
  const _LanguageBar({required this.sourceLanguage, required this.targetLanguage, required this.autoDetect, required this.onTapSource, required this.onTapTarget, this.onSwap});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    child: Row(children: [
      Expanded(child: _LanguagePill(label: 'From', language: autoDetect ? null : sourceLanguage, autoDetect: autoDetect, onTap: onTapSource)),
      Container(width: 40, height: 40, margin: const EdgeInsets.symmetric(horizontal: 4), decoration: BoxDecoration(shape: BoxShape.circle, color: onSwap != null ? AppColors.lilac.withValues(alpha: 0.12) : Colors.grey.withValues(alpha: 0.08), border: Border.all(color: onSwap != null ? AppColors.lilac.withValues(alpha: 0.3) : Colors.grey.withValues(alpha: 0.15))), child: IconButton(icon: const Icon(Icons.swap_horiz, size: 18), color: onSwap != null ? AppColors.ink : AppColors.disabled, onPressed: onSwap, padding: EdgeInsets.zero, splashRadius: 20)),
      Expanded(child: _LanguagePill(label: 'To', language: targetLanguage, onTap: onTapTarget)),
    ]),
  );
}

class _LanguagePill extends StatelessWidget {
  final String label;
  final AppLanguage? language;
  final bool autoDetect;
  final VoidCallback onTap;
  const _LanguagePill({required this.label, this.language, this.autoDetect = false, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(100), border: Border.all(color: AppColors.cardBorder)),
      child: Row(children: [
        Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: autoDetect ? AppColors.amber.withValues(alpha: 0.15) : AppColors.lilac.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(100)), child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: autoDetect ? AppColors.amber : AppColors.lilac))),
        const SizedBox(width: 10),
        Expanded(child: Text(autoDetect ? '🌐 Auto-detect' : '${language!.flag} ${language!.name}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primaryText), overflow: TextOverflow.ellipsis)),
        const Icon(Icons.chevron_right, size: 18, color: AppColors.metaText),
      ]),
    ),
  );
}

class _BottomActionBar extends StatelessWidget {
  final bool hasInput;
  final bool hasOutput;
  final bool isTranslating;
  final VoidCallback onTranslate;
  final VoidCallback onClear;
  final VoidCallback onCopy;
  const _BottomActionBar({required this.hasInput, required this.hasOutput, required this.isTranslating, required this.onTranslate, required this.onClear, required this.onCopy});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    decoration: BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor, border: const Border(top: BorderSide(color: AppColors.cardBorder))),
    child: Row(children: [
      if (hasInput || hasOutput) _IconActionBtton(icon: Icons.close, tooltip: 'Clear all', onTap: onClear),
      const Spacer(),
      ElevatedButton.icon(onPressed: isTranslating || !hasInput ? null : onTranslate, icon: isTranslating ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.ink)) : const Icon(Icons.translate, size: 18), label: Text(isTranslating ? 'Translating...' : 'Translate'), style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14))),
      const Spacer(),
      if (hasOutput) _IconActionBtton(icon: Icons.copy, tooltip: 'Copy', onTap: onCopy),
    ]),
  );
}

class _IconActionBtton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  const _IconActionBtton({required this.icon, required this.tooltip, required this.onTap});
  @override
  Widget build(BuildContext context) => Material(color: Colors.transparent, child: IconButton(icon: Icon(icon, size: 20), color: AppColors.secondaryText, tooltip: tooltip, onPressed: onTap, splashRadius: 22));
}