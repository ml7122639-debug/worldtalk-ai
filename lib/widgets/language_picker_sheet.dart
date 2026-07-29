import 'package:flutter/material.dart';
import '../../models/app_models.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';

/// Bottom sheet language picker with search and quick-select flags
class LanguagePickerSheet extends StatefulWidget {
  final List<AppLanguage> languages;
  final AppLanguage? selectedLanguage;
  final bool showAutoDetect;
  final bool isAutoDetectSelected;
  final String title;
  final ValueChanged<AppLanguage> onSelect;

  const LanguagePickerSheet({
    super.key,
    required this.languages,
    this.selectedLanguage,
    this.showAutoDetect = false,
    this.isAutoDetectSelected = false,
    required this.title,
    required this.onSelect,
  });

  @override
  State<LanguagePickerSheet> createState() => _LanguagePickerSheetState();
}

class _LanguagePickerSheetState extends State<LanguagePickerSheet> {
  final _searchCtrl = TextEditingController();
  List<AppLanguage> _filtered = [];

  @override
  void initState() { super.initState(); _filtered = widget.languages; _searchCtrl.addListener(_onSearchChanged); }

  void _onSearchChanged() { _filter(_searchCtrl.text); }

  void _filter(String q) {
    setState(() {
      if (q.isEmpty) { _filtered = widget.languages; } else {
        final l = q.toLowerCase();
        _filtered = widget.languages.where((lg) => lg.name.toLowerCase().contains(l) || lg.nativeName.toLowerCase().contains(l) || lg.code.contains(l)).toList();
      }
    });
  }

  @override
  void dispose() { _searchCtrl.removeListener(_onSearchChanged); _searchCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      child: Column(
        children: [
          Container(margin: const EdgeInsets.only(top: 10), width: 40, height: 4, decoration: BoxDecoration(color: AppColors.disabled, borderRadius: BorderRadius.circular(100))),
          Padding(padding: const EdgeInsets.fromLTRB(20, 16, 20, 0), child: Row(children: [Text(widget.title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.primaryText)), const Spacer(), IconButton(icon: const Icon(Icons.close, size: 20), onPressed: () => Navigator.pop(context), splashRadius: 20)])),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), child: TextField(controller: _searchCtrl, decoration: InputDecoration(hintText: 'Search languages...', prefixIcon: const Icon(Icons.search, size: 18, color: AppColors.metaText), suffixIcon: _searchCtrl.text.isNotEmpty ? IconButton(icon: const Icon(Icons.clear, size: 16), onPressed: () => _searchCtrl.clear()) : null))),
          if (widget.showAutoDetect) ...[
            _LanguageTile(language: kAutoDetectLanguage, isSelected: widget.isAutoDetectSelected, highlightColor: AppColors.amber, onTap: () { widget.onSelect(kAutoDetectLanguage); Navigator.pop(context); }),
            const Divider(height: 1, indent: 20, endIndent: 20),
          ],
          Expanded(
            child: _filtered.isEmpty
              ? const Center(child: Text('No languages found.', style: TextStyle(color: AppColors.metaText)))
              : ListView.builder(padding: const EdgeInsets.symmetric(vertical: 4), itemCount: _filtered.length, itemBuilder: (c, i) => _LanguageTile(language: _filtered[i], isSelected: widget.selectedLanguage?.code == _filtered[i].code, onTap: () { widget.onSelect(_filtered[i]); Navigator.pop(context); })),
          ),
        ],
      ),
    );
  }
}

class _LanguageTile extends StatelessWidget {
  final AppLanguage language;
  final bool isSelected;
  final Color? highlightColor;
  final VoidCallback onTap;
  const _LanguageTile({required this.language, this.isSelected = false, this.highlightColor, required this.onTap});
  @override
  Widget build(BuildContext context) => ListTile(
    onTap: onTap,
    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
    leading: Text(language.flag, style: const TextStyle(fontSize: 24)),
    title: Text(language.name, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.primaryText)),
    subtitle: Text(language.nativeName, style: const TextStyle(fontSize: 12, color: AppColors.metaText)),
    trailing: isSelected ? Container(width: 28, height: 28, decoration: BoxDecoration(shape: BoxShape.circle, color: (highlightColor ?? AppColors.lilac).withValues(alpha: 0.15)), child: Icon(Icons.check, size: 16, color: highlightColor ?? AppColors.lilac)) : null,
  );
}
