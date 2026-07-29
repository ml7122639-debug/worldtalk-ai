import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_theme.dart';
import '../core/providers/theme_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('Settings')),
      body: SafeArea(child: ListView(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), children: [
        _Header(title: 'Appearance'),
        _Tile(icon: Icons.brightness_6, color: AppColors.amber, title: 'Theme', subtitle: switch(themeMode){ ThemeMode.system => 'System', ThemeMode.light => 'Light', ThemeMode.dark => 'Dark' }, onTap: () => ref.read(themeModeProvider.notifier).toggleNext()),
        _Header(title: 'Data & Privacy'),
        _Tile(icon: Icons.visibility_off_outlined, color: AppColors.coral, title: 'Incognito mode', subtitle: 'Translations won\'t be saved to history', trailing: Switch(value: false, onChanged: (_) {})),
        _Tile(icon: Icons.download_outlined, color: AppColors.green, title: 'Export my data', subtitle: 'Download all translations as JSON', onTap: () { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Export coming soon.'))); }),
        _Tile(icon: Icons.delete_forever_outlined, color: AppColors.coral, title: 'Delete all data', subtitle: 'Permanently remove all stored data', onTap: () async {
          final ok = await showDialog<bool>(context: context, builder: (c) => AlertDialog(
            title: const Text('Delete all?'), content: const Text('This is permanent. Continue?'),
            actions: [TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')), TextButton(onPressed: () => Navigator.pop(c, true), child: const Text('Delete', style: TextStyle(color: AppColors.coral)))]));
          if (ok == true) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Data deleted.'))); }
        }),
        _Header(title: 'About'),
        _Tile(icon: Icons.info_outline, color: AppColors.teal, title: 'Version', subtitle: '1.0.0 (build 1)'),
        _Tile(icon: Icons.privacy_tip_outlined, color: AppColors.lilac, title: 'Privacy policy', onTap: () {}),
        _Tile(icon: Icons.description_outlined, color: AppColors.amber, title: 'Terms of service', onTap: () {}),
        const SizedBox(height: 40),
      ])),
    );
  }
}

class _Header extends StatelessWidget {
  final String title;
  const _Header({required this.title});
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.fromLTRB(4, 20, 4, 8), child: Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.metaText, letterSpacing: 1)));
}

class _Tile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  const _Tile({required this.icon, required this.color, required this.title, this.subtitle, this.trailing, this.onTap});

  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
    leading: Container(width: 36, height: 36, decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)), child: Icon(icon, size: 18, color: color)),
    title: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.primaryText)),
    subtitle: subtitle != null ? Text(subtitle!, style: const TextStyle(fontSize: 12, color: AppColors.metaText)) : null,
    trailing: trailing ?? (onTap != null ? const Icon(Icons.chevron_right, size: 18, color: AppColors.metaText) : null),
    onTap: onTap,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  );
}
