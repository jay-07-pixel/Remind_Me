import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:remind_me/core/constants/app_colors.dart';
import 'package:remind_me/core/constants/app_routes.dart';
import 'package:remind_me/core/constants/app_spacing.dart';
import 'package:remind_me/core/constants/message_template_catalog.dart';
import 'package:remind_me/models/message_template_editor_args.dart';
import 'package:remind_me/services/storage_service.dart';
import 'package:remind_me/widgets/app_card.dart';

class MessageTemplatesScreen extends StatefulWidget {
  const MessageTemplatesScreen({super.key});

  @override
  State<MessageTemplatesScreen> createState() => _MessageTemplatesScreenState();
}

class _MessageTemplatesScreenState extends State<MessageTemplatesScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  Map<String, String> _templates = const {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    final curve = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(curve);
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.03), end: Offset.zero)
            .animate(curve);
    _animationController.forward();
    _loadTemplates();
  }

  Future<void> _loadTemplates() async {
    final templates = await StorageService.instance.getMessageTemplates();
    if (!mounted) return;
    setState(() {
      _templates = templates;
      _isLoading = false;
    });
  }

  Future<void> _openEditor(MessageTemplateOption option) async {
    await context.push(
      AppRoutes.messageTemplateEditor,
      extra: MessageTemplateEditorArgs(option: option),
    );
    if (!mounted) return;
    _loadTemplates();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final birthdayOptions = MessageTemplateCatalog.options
        .where((option) => option.section == MessageTemplateSection.birthday)
        .toList();
    final anniversaryOptions = MessageTemplateCatalog.options
        .where((option) => option.section == MessageTemplateSection.anniversary)
        .toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Message Templates')),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  )
                : ListView(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    children: [
                      _TemplatesSection(
                        title: 'Birthday Templates',
                        options: birthdayOptions,
                        templates: _templates,
                        onTap: _openEditor,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      _TemplatesSection(
                        title: 'Anniversary Templates',
                        options: anniversaryOptions,
                        templates: _templates,
                        onTap: _openEditor,
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class _TemplatesSection extends StatelessWidget {
  const _TemplatesSection({
    required this.title,
    required this.options,
    required this.templates,
    required this.onTap,
  });

  final String title;
  final List<MessageTemplateOption> options;
  final Map<String, String> templates;
  final ValueChanged<MessageTemplateOption> onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.sm,
              AppSpacing.sm,
              AppSpacing.sm,
              AppSpacing.xs,
            ),
            child: Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          ...options.map((option) {
            final preview = (templates[option.key] ?? option.defaultTemplate)
                .replaceAll('\n', ' ');
            return ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
              ),
              leading: const Icon(Icons.message_rounded, color: AppColors.primary),
              title: Text(
                option.category,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              subtitle: Text(
                preview,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              trailing: const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textTertiary,
              ),
              onTap: () => onTap(option),
            );
          }),
        ],
      ),
    );
  }
}
