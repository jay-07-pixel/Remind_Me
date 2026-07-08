import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:remind_me/core/constants/app_colors.dart';
import 'package:remind_me/core/constants/app_spacing.dart';
import 'package:remind_me/models/message_preview_args.dart';
import 'package:remind_me/services/storage_service.dart';
import 'package:remind_me/services/whatsapp_service.dart';
import 'package:remind_me/widgets/app_card.dart';
import 'package:remind_me/widgets/contact_avatar.dart';

class MessagePreviewScreen extends StatefulWidget {
  const MessagePreviewScreen({
    super.key,
    required this.args,
  });

  final MessagePreviewArgs args;

  @override
  State<MessagePreviewScreen> createState() => _MessagePreviewScreenState();
}

class _MessagePreviewScreenState extends State<MessagePreviewScreen>
    with SingleTickerProviderStateMixin {
  final _messageController = TextEditingController();

  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  bool _isSending = false;
  bool _isResetting = false;

  @override
  void initState() {
    super.initState();
    _messageController.text = widget.args.initialMessage;

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    final curve = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(curve);
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.02), end: Offset.zero)
            .animate(curve);
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _resetToTemplate() async {
    setState(() => _isResetting = true);
    try {
      final template = await StorageService.instance.getMessageTemplate(
        widget.args.templateKey,
      );
      final firstName = _firstName(widget.args.contact.name);
      _messageController.text = template.replaceAll('{name}', firstName);
    } finally {
      if (mounted) setState(() => _isResetting = false);
    }
  }

  Future<void> _sendViaWhatsApp() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Message cannot be empty'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isSending = true);
    try {
      final result = await WhatsAppService.instance.openChatWithMessage(
        rawPhoneNumber: widget.args.contact.phone,
        message: message,
      );

      if (!mounted || result.isSuccess) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.errorMessage ?? 'Unable to open WhatsApp.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = widget.args;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Message Preview')),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                children: [
                  AppCard(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Row(
                      children: [
                        ContactAvatar(
                          initials: _initials(args.contact.name),
                          size: 52,
                          gradientIndex: 1,
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                args.contact.name,
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${args.eventType.label} • ${args.styleLabel}',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Expanded(
                    child: AppCard(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Edit Message',
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Expanded(
                            child: TextFormField(
                              controller: _messageController,
                              expands: true,
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: AppColors.textPrimary,
                              ),
                              decoration: const InputDecoration(
                                hintText: 'Type your message...',
                                alignLabelWithHint: true,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: _isResetting ? null : _resetToTemplate,
                      child: _isResetting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.2,
                                color: AppColors.primary,
                              ),
                            )
                          : const Text('Reset to Template'),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSending ? null : _sendViaWhatsApp,
                      child: _isSending
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Send via WhatsApp'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

String _firstName(String fullName) {
  final trimmed = fullName.trim();
  if (trimmed.isEmpty) return 'there';
  return trimmed.split(RegExp(r'\s+')).first;
}

String _initials(String name) {
  final parts = name.trim().split(RegExp(r'\s+'));
  if (parts.isEmpty || parts.first.isEmpty) return '?';
  if (parts.length == 1 || parts.last.isEmpty) {
    return parts.first.substring(0, 1).toUpperCase();
  }
  return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}'
      .toUpperCase();
}
