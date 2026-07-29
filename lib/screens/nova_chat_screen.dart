import 'dart:async';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../core/theme/app_theme.dart';
import '../models/app_models.dart';

class NovaChatScreen extends StatefulWidget {
  const NovaChatScreen({super.key});
  @override
  State<NovaChatScreen> createState() => _NovaChatScreenState();
}

class _NovaChatScreenState extends State<NovaChatScreen> {
  final _msgCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  final _uuid = const Uuid();
  final List<ChatMessage> _messages = [];
  bool _thinking = false;

  @override
  void initState() {
    super.initState();
    _messages.add(ChatMessage(
      id: _uuid.v4(),
      text: 'স্বাগতম! আমি Nova AI, আপনার অনুবাদ সহকারী।\n\nআপনি যেকোনো ভাষায় আমাকে লিখতে পারেন — আমি অনুবাদ করব এবং সব প্রশ্নের উত্তর দেব।\n\nআজ আমি কীভাবে সাহায্য করতে পারি? 😊',
      isUser: false, timestamp: DateTime.now(),
    ));
  }

  @override
  void dispose() { _msgCtrl.dispose(); _scrollCtrl.dispose(); super.dispose(); }

  Future<void> _send() async {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty || _thinking) return;
    final um = ChatMessage(id: _uuid.v4(), text: text, isUser: true, timestamp: DateTime.now());
    setState(() { _messages.add(um); _thinking = true; });
    _msgCtrl.clear(); _scrollDown();

    // Simulate Nova reply (replace with real API call)
    await Future.delayed(const Duration(milliseconds: 1200));
    final reply = _mockReply(text);
    final nm = ChatMessage(id: _uuid.v4(), text: reply, isUser: false, timestamp: DateTime.now());
    setState(() { _messages.add(nm); _thinking = false; });
    _scrollDown();
  }

  String _mockReply(String input) {
    final l = input.toLowerCase();
    if (l.contains('translate') || l.contains('অনুবাদ')) return 'আমি যে কোন ভাষায় অনুবাদ করতে প্রস্তুত! What would you like to translate?';
    if (l.contains('hello') || l.contains('hi') || l.contains('হ্যালো')) return 'Hello! 👋 I\'m Nova AI, ready to help with any translation. Try pasting text or asking: "Translate this to Spanish" 😊';
    if (l.contains('language') || l.contains('ভাষা')) return 'WorldTalk AI currently supports 15 languages.\n\n🇬🇧🇧🇩🇮🇳🇪🇸🇫🇷🇩🇪🇨🇳🇯🇵🇰🇷🇸🇦🇵🇹🇷🇺🇵🇰🇹🇷🇮🇹\n\nMore coming in V2!';
    return 'I\'m here to help with translations, language learning tips, and communication across cultures!\n\nAsk me anything 🌍';
  }

  void _scrollDown() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollCtrl.hasClients) _scrollCtrl.animateTo(_scrollCtrl.position.maxScrollExtent, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Row(children: [
          Container(width: 32, height: 32, decoration: const BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(colors: [AppColors.lilac, AppColors.teal])), child: const Icon(Icons.auto_awesome, size: 16, color: Colors.white)),
          const SizedBox(width: 10),
          const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Nova AI', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.primaryText)),
            Text('Online', style: TextStyle(fontSize: 11, color: AppColors.green, fontWeight: FontWeight.w600)),
          ]),
        ]),
      ),
      body: SafeArea(child: Column(children: [
        Expanded(
          child: ListView.builder(
            controller: _scrollCtrl,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: _messages.length + (_thinking ? 1 : 0),
            itemBuilder: (c, i) {
              if (i == _messages.length) return _Typing();
              final m = _messages[i];
              return Align(
                alignment: m.isUser ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: m.isUser ? AppColors.lilac : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(18), topRight: const Radius.circular(18),
                      bottomLeft: Radius.circular(m.isUser ? 18 : 4), bottomRight: Radius.circular(m.isUser ? 4 : 18),
                    ),
                    border: m.isUser ? null : Border.all(color: AppColors.cardBorder),
                  ),
                  child: Text(m.text, style: TextStyle(fontSize: 14.5, height: 1.5, color: m.isUser ? AppColors.ink : AppColors.primaryText)),
                ),
              );
            }),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
          decoration: BoxDecoration(color: Theme.of(context).cardColor, border: const Border(top: BorderSide(color: AppColors.cardBorder))),
          child: Row(children: [
            Container(width: 42, height: 42, decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.lilac.withValues(alpha: 0.1)), child: const IconButton(icon: Icon(Icons.mic, size: 20, color: AppColors.lilac), onPressed: null)),
            const SizedBox(width: 8),
            Expanded(child: TextField(controller: _msgCtrl, onSubmitted: (_) => _send(), textCapitalization: TextCapitalization.sentences, decoration: const InputDecoration(hintText: 'Nova AI-কে কিছু জিজ্ঞাসা করুন...'))),
            const SizedBox(width: 8),
            Container(width: 42, height: 42, decoration: BoxDecoration(shape: BoxShape.circle, color: _thinking ? AppColors.disabled : AppColors.lilac), child: IconButton(icon: _thinking ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.metaText)) : const Icon(Icons.send_rounded, size: 18), color: _thinking ? AppColors.metaText : AppColors.ink, onPressed: _thinking ? null : _send)),
          ]),
        ),
      ])),
    );
  }
}

class _Typing extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.centerLeft,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: const BorderRadius.only(topLeft: Radius.circular(18), topRight: Radius.circular(18), bottomRight: Radius.circular(18), bottomLeft: Radius.circular(4)), border: Border.all(color: AppColors.cardBorder)),
      child: const Text('Nova is typing...', style: TextStyle(fontSize: 13, color: AppColors.metaText)),
    ),
  );
}
