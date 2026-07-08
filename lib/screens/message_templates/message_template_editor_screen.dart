import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:remind_me/core/constants/app_colors.dart';
import 'package:remind_me/core/constants/app_spacing.dart';
import 'package:remind_me/models/message_template_editor_args.dart';
import 'package:remind_me/services/storage_service.dart';
import 'package:remind_me/widgets/app_card.dart';

class MessageTemplateEditorScreen extends StatefulWidget {
  const MessageTemplateEditorScreen({
    super.key,
    required this.args,
  });

  final MessageTemplateEditorArgs args;

  @override
  State<MessageTemplateEditorScreen> createState() =>
      _MessageTemplateEditorScreenState();
}

class _MessageTemplateEditorScreenState extends State<MessageTemplateEditorScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();

  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
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
    _loadTemplate();
  }

  Future<void> _loadTemplate() async {
    final option = widget.args.option;
    final template =
        await StorageService.instance.getMessageTemplate(option.key);
    if (!mounted) return;
    _controller.text = template.isEmpty ? option.defaultTemplate : template;
    setState(() => _isLoading = false);
  }

  Future<void> _saveTemplate() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();
    setState(() => _isSaving = true);
    try {
      await StorageService.instance.saveMessageTemplate(
        key: widget.args.option.key,
        template: _controller.text.trim(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Template saved successfully'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final option = widget.args.option;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text('${option.category} Template')),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  )
                : Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          AppCard(
                            padding: const EdgeInsets.all(AppSpacing.md),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${option.section.title} • ${option.category}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                Text(
                                  'Use {name} as a placeholder for contact first name.',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.md),
                                TextFormField(
                                  controller: _controller,
                                  minLines: 6,
                                  maxLines: 10,
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: AppColors.textPrimary,
                                  ),
                                  decoration: const InputDecoration(
                                    hintText: 'Write your message template...',
                                    alignLabelWithHint: true,
                                  ),
                                  validator: (value) {
                                    final text = value?.trim() ?? '';
                                    if (text.isEmpty) {
                                      return 'Template cannot be empty';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isSaving ? null : _saveTemplate,
                              child: _isSaving
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text('Save'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
