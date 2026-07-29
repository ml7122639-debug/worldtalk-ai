import 'package:flutter/material.dart';
import '../main.dart';
import '../core/theme/app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('WorldTalk AI'),
        actions: [
          IconButton(
            icon: Container(
              width: 32, height: 32,
              decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.lilac.withValues(alpha: 0.12)),
              child: const Icon(Icons.auto_awesome, size: 18, color: AppColors.lilac),
            ),
            tooltip: 'Nova AI',
            onPressed: () => AppNavigator.push(context, AppRoutes.novaChat),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _NovaCard(onTap: () => AppNavigator.push(context, AppRoutes.novaChat)),
          const SizedBox(height: 24),
          const Text('Translation tools', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.primaryText)),
          const SizedBox(height: 14),
          GridView.count(
            crossAxisCount: 2,
            mainAxisSpacing: 12, crossAxisSpacing: 12,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _Tile(icon: Icons.text_fields_rounded, label: 'Text\nTranslator', color: AppColors.lilac, onTap: () => AppNavigator.push(context, AppRoutes.translator)),
              _Tile(icon: Icons.mic_rounded, label: 'Voice\nTranslator', color: AppColors.amber, onTap: () => AppNavigator.push(context, AppRoutes.translator)),
              _Tile(icon: Icons.chat_bubble_rounded, label: 'Live\nConversation', color: AppColors.teal, onTap: () {}),
              _Tile(icon: Icons.camera_alt_rounded, label: 'Camera\nTranslate', color: AppColors.coral, onTap: () {}),
              _Tile(icon: Icons.history_rounded, label: 'History', color: AppColors.green, onTap: () => AppNavigator.push(context, AppRoutes.history)),
              _Tile(icon: Icons.settings_rounded, label: 'Settings', color: AppColors.secondaryText, onTap: () => AppNavigator.push(context, AppRoutes.settings)),
            ],
          ),
          const SizedBox(height: 32),
          const Text('Recent', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.primaryText)),
          const SizedBox(height: 12),
          _QuickCard(onTap: () => AppNavigator.push(context, AppRoutes.translator)),
          const SizedBox(height: 40),
        ]),
      )),
    );
  }
}

class _NovaCard extends StatelessWidget {
  final VoidCallback onTap;
  const _NovaCard({required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFFB8A9E8), Color(0xFF9B8ED8)], begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: BorderRadius.circular(20)),
      child: Row(children: [
        Container(width: 44, height: 44, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.25)), child: const Icon(Icons.auto_awesome, color: Colors.white, size: 22)),
        const SizedBox(width: 14),
        const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Nova AI', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
          SizedBox(height: 3),
          Text('স্বাগতম। আজ আমি কীভাবে সাহায্য করতে পারি?', style: TextStyle(fontSize: 13, color: Colors.white70)),
        ])),
        const Icon(Icons.chevron_right, color: Colors.white, size: 22),
      ]),
    ),
  );
}

class _Tile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _Tile({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.cardBorder)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(width: 40, height: 40, decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: color, size: 22)),
        const Spacer(),
        Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primaryText, height: 1.3)),
      ]),
    ),
  );
}

class _QuickCard extends StatelessWidget {
  final VoidCallback onTap;
  const _QuickCard({required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.cardBorder)),
      child: Row(children: [
        Container(width: 40, height: 40, decoration: BoxDecoration(color: AppColors.lilac.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.translate, color: AppColors.lilac, size: 22)),
        const SizedBox(width: 14),
        const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Quick Translate', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.primaryText)),
          SizedBox(height: 2),
          Text('Type or paste text to translate instantly', style: TextStyle(fontSize: 12, color: AppColors.metaText)),
        ])),
        const Icon(Icons.chevron_right, color: AppColors.metaText, size: 20),
      ]),
    ),
  );
}
