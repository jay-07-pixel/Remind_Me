import 'dart:io';

import 'package:flutter/material.dart';
import 'package:remind_me/core/constants/app_spacing.dart';
import 'package:remind_me/models/greeting_card_preview_args.dart';
import 'package:remind_me/services/greeting_card_service.dart';
import 'package:remind_me/services/whatsapp_service.dart';
import 'package:remind_me/widgets/greeting_card_canvas.dart';

class GreetingCardPreviewScreen extends StatefulWidget {
  const GreetingCardPreviewScreen({super.key, required this.args});

  final GreetingCardPreviewArgs args;

  @override
  State<GreetingCardPreviewScreen> createState() => _GreetingCardPreviewScreenState();
}

class _GreetingCardPreviewScreenState extends State<GreetingCardPreviewScreen> {
  final _repaintKey = GlobalKey();
  final _service = GreetingCardService.instance;
  bool _busy = false;

  Future<File> _exportFile() async {
    final bytes = await _service.renderPngFromBoundary(_repaintKey);
    return _service.savePngToCache(bytes);
  }

  Future<void> _shareToWhatsApp() async {
    setState(() => _busy = true);
    try {
      final file = await _exportFile();
      await _service.shareCard(
        imageFile: file,
        caption: widget.args.message,
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to share greeting card right now.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _saveToGallery() async {
    setState(() => _busy = true);
    try {
      final bytes = await _service.renderPngFromBoundary(_repaintKey);
      final saved = await _service.savePngToGallery(bytes);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            saved
                ? 'Greeting card saved to gallery.'
                : 'Unable to save greeting card to gallery.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _openTextWhatsApp() async {
    final result = await WhatsAppService.instance.openChatWithMessage(
      rawPhoneNumber: widget.args.phoneNumber,
      message: widget.args.message,
    );
    if (!mounted || result.isSuccess) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result.errorMessage ?? 'Unable to open WhatsApp chat.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Live Preview'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: RepaintBoundary(
                    key: _repaintKey,
                    child: AspectRatio(
                      aspectRatio: 3 / 4,
                      child: GreetingCardCanvas(
                        assetPath: widget.args.card.assetPath,
                        toName: widget.args.toName,
                        fromName: widget.args.fromName,
                        message: widget.args.message,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _busy ? null : _shareToWhatsApp,
                      icon: const Icon(Icons.share_rounded),
                      label: const Text('Share to WhatsApp'),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _busy ? null : _saveToGallery,
                      icon: const Icon(Icons.download_rounded),
                      label: const Text('Save to Gallery'),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextButton(
                    onPressed: _busy ? null : _openTextWhatsApp,
                    child: const Text('Open message-only WhatsApp chat'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
