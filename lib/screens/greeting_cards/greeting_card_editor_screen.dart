import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:remind_me/core/constants/app_colors.dart';
import 'package:remind_me/core/constants/app_spacing.dart';
import 'package:remind_me/models/greeting_card_editor_args.dart';
import 'package:remind_me/models/greeting_card_preview_args.dart';
import 'package:remind_me/screens/greeting_cards/greeting_card_preview_screen.dart';
import 'package:remind_me/services/storage_service.dart';
import 'package:remind_me/widgets/app_card.dart';
import 'package:remind_me/widgets/greeting_card_canvas.dart';

class GreetingCardEditorScreen extends StatefulWidget {
  const GreetingCardEditorScreen({super.key, required this.args});

  final GreetingCardEditorArgs args;

  @override
  State<GreetingCardEditorScreen> createState() => _GreetingCardEditorScreenState();
}

class _GreetingCardEditorScreenState extends State<GreetingCardEditorScreen> {
  late final TextEditingController _toController;
  late final TextEditingController _fromController;
  late final TextEditingController _messageController;

  @override
  void initState() {
    super.initState();
    final first = _firstName(widget.args.contact.name);
    _toController = TextEditingController(text: widget.args.contact.name);
    _fromController = TextEditingController(text: 'You');
    _messageController = TextEditingController(
      text: widget.args.templateText.replaceAll('{name}', first),
    );
    _loadSender();
    _toController.addListener(() => setState(() {}));
    _fromController.addListener(() => setState(() {}));
    _messageController.addListener(() => setState(() {}));
  }

  Future<void> _loadSender() async {
    final name = await StorageService.instance.getName();
    if (!mounted || name == null || name.trim().isEmpty) return;
    _fromController.text = name.trim();
  }

  @override
  void dispose() {
    _toController.dispose();
    _fromController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _openPreview() {
    if (_toController.text.trim().isEmpty ||
        _fromController.text.trim().isEmpty ||
        _messageController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please complete To, From and Message fields.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => GreetingCardPreviewScreen(
          args: GreetingCardPreviewArgs(
            card: widget.args.card,
            style: widget.args.style,
            toName: _toController.text.trim(),
            fromName: _fromController.text.trim(),
            message: _messageController.text.trim(),
            phoneNumber: widget.args.contact.phone,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Greeting Card Editor')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            SizedBox(
              height: 380,
              child: Hero(
                tag: widget.args.card.id,
                child: GreetingCardCanvas(
                  assetPath: widget.args.card.assetPath,
                  toName: _toController.text.trim().isEmpty
                      ? 'Recipient'
                      : _toController.text.trim(),
                  fromName: _fromController.text.trim().isEmpty
                      ? 'Sender'
                      : _fromController.text.trim(),
                  message: _messageController.text.trim().isEmpty
                      ? 'Your message appears here'
                      : _messageController.text.trim(),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppCard(
              child: Column(
                children: [
                  _Field(label: 'Recipient Name (To)', controller: _toController),
                  const SizedBox(height: AppSpacing.md),
                  _Field(label: 'Sender Name (From)', controller: _fromController),
                  const SizedBox(height: AppSpacing.md),
                  _Field(
                    label: 'Message',
                    controller: _messageController,
                    minLines: 5,
                    maxLines: 8,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _openPreview,
                icon: const Icon(Icons.visibility_rounded),
                label: const Text('Live Preview'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.label,
    required this.controller,
    this.minLines = 1,
    this.maxLines = 1,
  });

  final String label;
  final TextEditingController controller;
  final int minLines;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        TextField(
          controller: controller,
          minLines: minLines,
          maxLines: maxLines,
          style: GoogleFonts.poppins(
            fontSize: 15,
            color: AppColors.textPrimary,
          ),
          decoration: const InputDecoration(),
        ),
      ],
    );
  }
}

String _firstName(String fullName) {
  final value = fullName.trim();
  if (value.isEmpty) return 'Friend';
  return value.split(RegExp(r'\s+')).first;
}
