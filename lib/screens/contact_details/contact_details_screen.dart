import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:remind_me/core/constants/app_colors.dart';
import 'package:remind_me/core/constants/app_spacing.dart';
import 'package:remind_me/models/contact_date_event.dart';
import 'package:remind_me/models/contact_details_args.dart';
import 'package:remind_me/models/event_type.dart';
import 'package:remind_me/services/whatsapp_service.dart';
import 'package:remind_me/widgets/app_card.dart';
import 'package:remind_me/widgets/contact_action_button.dart';
import 'package:remind_me/widgets/contact_avatar.dart';

class ContactDetailsScreen extends StatefulWidget {
  const ContactDetailsScreen({super.key, required this.args});

  final ContactDetailsArgs args;

  @override
  State<ContactDetailsScreen> createState() => _ContactDetailsScreenState();
}

class _ContactDetailsScreenState extends State<ContactDetailsScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );
    final curve = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(curve);
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.04), end: Offset.zero)
            .animate(curve);
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final contact = widget.args.contact;
    final selectedType = widget.args.selectedEvent?.eventType;
    final birthday = _firstEvent(contact.events, EventType.birthday);
    final anniversary = _firstEvent(contact.events, EventType.anniversary);
    final primaryType = selectedType ??
        (birthday != null
            ? EventType.birthday
            : (anniversary != null ? EventType.anniversary : EventType.other));
    final messageTemplate = _defaultMessageTemplate(primaryType);
    final firstName = _firstName(contact.name);
    final previewMessage = _resolveMessageTemplate(
      template: messageTemplate,
      firstName: firstName,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Contact Details')),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              AppCard(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  children: [
                    ContactAvatar(
                      initials: _initials(contact.name),
                      size: 88,
                      gradientIndex: 1,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      contact.name,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      contact.phone ?? 'Phone number not available',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              _InfoSection(
                title: 'Events',
                children: [
                  _EventInfoTile(
                    label: 'Birthday',
                    event: birthday,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _EventInfoTile(
                    label: 'Anniversary',
                    event: anniversary,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _EventTypeTile(
                    eventType: primaryType,
                    customLabel: widget.args.selectedEvent?.customLabel,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              _InfoSection(
                title: 'Message Preview',
                children: [
                  _MessagePreviewCard(
                    message: previewMessage,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              _InfoSection(
                title: 'Actions',
                children: [
                  Row(
                    children: [
                      ContactActionButton(
                        icon: Icons.chat_rounded,
                        label: 'WhatsApp',
                        onTap: () => _onWhatsAppTap(
                          rawPhoneNumber: contact.phone,
                          messageTemplate: messageTemplate,
                          firstName: firstName,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      ContactActionButton(
                        icon: Icons.call_rounded,
                        label: 'Call',
                        onTap: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      ContactActionButton(
                        icon: Icons.sms_rounded,
                        label: 'SMS',
                        onTap: () {},
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      ContactActionButton(
                        icon: Icons.edit_rounded,
                        label: 'Edit Message',
                        onTap: () {},
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onWhatsAppTap({
    required String? rawPhoneNumber,
    required String messageTemplate,
    required String firstName,
  }) async {
    final result = await WhatsAppService.instance.openChat(
      rawPhoneNumber: rawPhoneNumber,
      messageTemplate: messageTemplate,
      firstName: firstName,
    );

    if (!mounted || result.isSuccess) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result.errorMessage ?? 'Unable to open WhatsApp.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  const _InfoSection({
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          ...children,
        ],
      ),
    );
  }
}

class _EventInfoTile extends StatelessWidget {
  const _EventInfoTile({
    required this.label,
    required this.event,
  });

  final String label;
  final ContactDateEvent? event;

  @override
  Widget build(BuildContext context) {
    final subtitle = event == null
        ? 'Not available'
        : DateFormat('MMM d').format(
            DateTime(2024, event!.month, event!.day),
          );
    return _SimpleTile(
      icon: Icons.event_rounded,
      title: label,
      subtitle: subtitle,
    );
  }
}

class _EventTypeTile extends StatelessWidget {
  const _EventTypeTile({
    required this.eventType,
    this.customLabel,
  });

  final EventType eventType;
  final String? customLabel;

  @override
  Widget build(BuildContext context) {
    return _SimpleTile(
      icon: eventType.icon,
      title: 'Event Type',
      subtitle: eventType.displayLabel(customLabel: customLabel),
    );
  }
}

class _SimpleTile extends StatelessWidget {
  const _SimpleTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MessagePreviewCard extends StatelessWidget {
  const _MessagePreviewCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Text(
        message,
        style: GoogleFonts.poppins(
          fontSize: 14,
          height: 1.6,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

ContactDateEvent? _firstEvent(List<ContactDateEvent> events, EventType type) {
  for (final event in events) {
    if (event.eventType == type) {
      return event;
    }
  }
  return null;
}

String _defaultMessageTemplate(EventType eventType) {
  return switch (eventType) {
    EventType.birthday =>
      'Happy Birthday {name}! Wishing you a joyful day filled with happiness and beautiful moments.',
    EventType.anniversary =>
      'Happy Anniversary {name}! Wishing you both love, laughter, and many more wonderful years together.',
    EventType.other =>
      'Hi {name}, wishing you a wonderful day and many happy moments ahead.',
  };
}

String _resolveMessageTemplate({
  required String template,
  required String firstName,
}) {
  return template.replaceAll('{name}', firstName);
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
