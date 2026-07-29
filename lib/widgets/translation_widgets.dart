import 'package:flutter/material.dart';

/// Animated text input field with character count, auto-height, and clear action.
/// Uses StatefulWidget to reactively track controller.text changes.
class TranslationInputField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;

  const TranslationInputField({
    super.key,
    required this.controller,
    required this.hintText,
    this.onChanged,
    this.onClear,
  });

  @override
  State<TranslationInputField> createState() => _TranslationInputFieldState();
}

class _TranslationInputFieldState extends State<TranslationInputField> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onControllerChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    super.dispose();
  }

  void _onControllerChanged() {
    setState(() {}); // rebuild when text changes for char count
  }

  @override
  Widget build(BuildContext context) {
    final hasText = widget.controller.text.isNotEmpty;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F7FC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8E5F2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: label + char count + clear
          Row(
            children: [
              Text(
                'INPUT',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade500,
                  letterSpacing: 1.2,
                ),
              ),
              const Spacer(),
              if (hasText) ...[
                Text(
                  '${widget.controller.text.length} chars',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF9B9B9B),
                  ),
                ),
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: widget.onClear,
                  child: const Icon(
                    Icons.close,
                    size: 15,
                    color: Color(0xFF9B9B9B),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          // Text input
          Expanded(
            child: TextField(
              controller: widget.controller,
              onChanged: widget.onChanged,
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              style: const TextStyle(
                fontSize: 17,
                height: 1.5,
                color: Color(0xFF1A1A1A),
                fontWeight: FontWeight.w400,
              ),
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade400,
                  fontWeight: FontWeight.w400,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Output panel showing translated text with copy/share actions and loading state
class TranslationOutputPanel extends StatelessWidget {
  final String text;
  final bool isLoading;
  final bool hasInput;
  final VoidCallback? onCopy;
  final VoidCallback? onShare;
  final VoidCallback? onRetry;

  const TranslationOutputPanel({
    super.key,
    required this.text,
    this.isLoading = false,
    this.hasInput = false,
    this.onCopy,
    this.onShare,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFE),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8E5F2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: label + actions
          Row(
            children: [
              Text(
                'TRANSLATION',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade500,
                  letterSpacing: 1.2,
                ),
              ),
              const Spacer(),
              if (text.isNotEmpty) ...[
                _ActionChip(
                  icon: Icons.copy,
                  label: 'Copy',
                  onTap: onCopy,
                ),
                const SizedBox(width: 8),
                _ActionChip(
                  icon: Icons.share_outlined,
                  label: 'Share',
                  onTap: onShare,
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          // Content
          Expanded(
            child: isLoading
                ? _LoadingState()
                : text.isNotEmpty
                    ? _TranslationText(text: text)
                    : _EmptyState(hasInput: hasInput, onRetry: onRetry),
          ),
        ],
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _ActionChip({
    required this.icon,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: const Color(0xFFF0F0F0),
          borderRadius: BorderRadius.circular(100),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: const Color(0xFF6B6B6B)),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF6B6B6B),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TranslationText extends StatelessWidget {
  final String text;

  const _TranslationText({required this.text});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 17,
          height: 1.5,
          color: Color(0xFF1A1A1A),
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: Color(0xFFB8A9E8),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Translating...',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool hasInput;
  final VoidCallback? onRetry;

  const _EmptyState({required this.hasInput, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.translate, size: 36, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Text(
            hasInput
                ? 'Translation will appear here.'
                : 'Start typing to see the translation.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade400,
              fontStyle: FontStyle.italic,
            ),
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Retry'),
              style: TextButton.styleFrom(foregroundColor: const Color(0xFFB8A9E8)),
            ),
          ],
        ],
      ),
    );
  }
}
