import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../core/theme/app_theme.dart';
import '../models/app_models.dart';
import '../services/history_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});
  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<TranslationResult> _history = [];
  List<TranslationResult> _filtered = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final history = await HistoryService.getHistory();
    setState(() { _history = history; _filtered = history; _loading = false; });
  }

  Future<void> _deleteItem(TranslationResult item) async {
    await HistoryService.deleteItem(item.id);
    setState(() { _history.removeWhere((t) => t.id == item.id); _filtered.removeWhere((t) => t.id == item.id); });
  }

  Future<void> _clearAll() async {
    final ok = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Clear history?'),
      content: const Text('Delete all translation history permanently.'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
        TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Clear all', style: TextStyle(color: AppColors.coral))),
      ],
    ));
    if (ok == true) { await HistoryService.clearAll(); setState(() { _history.clear(); _filtered.clear(); }); }
  }

  void _filter(String q) {
    final l = q.toLowerCase();
    setState(() { _filtered = _history.where((t) => t.sourceText.toLowerCase().contains(l) || t.translatedText.toLowerCase().contains(l)).toList(); });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('History'),
        actions: [if (_history.isNotEmpty) IconButton(icon: const Icon(Icons.delete_outline, size: 20), tooltip: 'Clear all', onPressed: _clearAll)],
      ),
      body: SafeArea(child: Column(children: [
        Padding(padding: const EdgeInsets.fromLTRB(16, 8, 16, 8), child: TextField(onChanged: _filter, decoration: const InputDecoration(hintText: 'Search translations...', prefixIcon: Icon(Icons.search, size: 18, color: AppColors.metaText)))),
        Expanded(child: _loading
          ? const Center(child: CircularProgressIndicator())
          : _filtered.isEmpty
            ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.history, size: 48, color: Colors.grey.shade300),
                const SizedBox(height: 12),
                Text(_history.isEmpty ? 'No translations yet.\nStart translating to see your history here.' : 'No results found.', textAlign: TextAlign.center, style: const TextStyle(color: AppColors.metaText, fontSize: 14)),
              ]))
            : ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                itemCount: _filtered.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (c, i) => _HistoryTile(item: _filtered[i], onDelete: () => _deleteItem(_filtered[i])))),
      ])),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  final TranslationResult item;
  final VoidCallback onDelete;
  const _HistoryTile({required this.item, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final time = DateFormat('hh:mm a').format(item.timestamp);
    final date = DateFormat('dd MMM').format(item.timestamp);
    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      background: Container(alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 20), color: AppColors.coral.withValues(alpha: 0.1), child: const Icon(Icons.delete, color: AppColors.coral, size: 20)),
      onDismissed: (_) => onDelete(),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(width: 36, height: 36, decoration: BoxDecoration(color: AppColors.lilac.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.translate, size: 16, color: AppColors.lilac)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(item.sourceText, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.primaryText), maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 3),
            Text(item.translatedText, style: TextStyle(fontSize: 13, color: AppColors.ink.withValues(alpha: 0.6)), maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 6),
            Row(children: [
              Text('${item.sourceLang} → ${item.targetLang}', style: const TextStyle(fontSize: 11, color: AppColors.lilac, fontWeight: FontWeight.w600)),
              const SizedBox(width: 8),
              Text('$time, $date', style: const TextStyle(fontSize: 11, color: AppColors.metaText)),
            ]),
          ])),
        ]),
      ),
    );
  }
}
