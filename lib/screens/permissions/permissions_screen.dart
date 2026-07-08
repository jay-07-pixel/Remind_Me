import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:remind_me/core/constants/app_colors.dart';
import 'package:remind_me/core/constants/app_routes.dart';
import 'package:remind_me/core/constants/app_spacing.dart';
import 'package:remind_me/services/permission_service.dart';
import 'package:remind_me/widgets/permission_card.dart';

class PermissionsScreen extends StatefulWidget {
  const PermissionsScreen({super.key});

  @override
  State<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends State<PermissionsScreen>
    with SingleTickerProviderStateMixin {
  final _permissionService = PermissionService.instance;

  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  bool _contactsGranted = false;
  bool _notificationsGranted = false;
  bool _isRequestingContacts = false;
  bool _isRequestingNotifications = false;

  bool get _canContinue => _contactsGranted && _notificationsGranted;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    final curve = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(curve);
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(curve);

    _animationController.forward();
    _checkExistingPermissions();
  }

  Future<void> _checkExistingPermissions() async {
    final contactsGranted = await _permissionService.isContactsGranted();
    final notificationsGranted =
        await _permissionService.isNotificationGranted();

    if (!mounted) return;
    setState(() {
      _contactsGranted = contactsGranted;
      _notificationsGranted = notificationsGranted;
    });
  }

  Future<void> _requestContacts() async {
    setState(() => _isRequestingContacts = true);
    try {
      final granted = await _permissionService.requestContacts();
      if (!mounted) return;
      setState(() => _contactsGranted = granted);
    } finally {
      if (mounted) setState(() => _isRequestingContacts = false);
    }
  }

  Future<void> _requestNotifications() async {
    setState(() => _isRequestingNotifications = true);
    try {
      final granted = await _permissionService.requestNotifications();
      if (!mounted) return;
      setState(() => _notificationsGranted = granted);
    } finally {
      if (mounted) setState(() => _isRequestingNotifications = false);
    }
  }

  void _onContinue() {
    context.go(AppRoutes.contactSync);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          const _PermissionsAccent(),
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.lg,
                        AppSpacing.md,
                        AppSpacing.lg,
                        0,
                      ),
                      child: const _PermissionsHeader(),
                    ),
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        children: [
                          PermissionCard(
                            icon: Icons.contacts_rounded,
                            title: 'Access Your Contacts',
                            description:
                                'We use your contacts only to find birthdays, anniversaries, and important dates stored on your device. Your contacts never leave your phone.',
                            buttonLabel: 'Allow Contacts',
                            isGranted: _contactsGranted,
                            isLoading: _isRequestingContacts,
                            onAllow: _requestContacts,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          PermissionCard(
                            icon: Icons.notifications_active_rounded,
                            title: 'Enable Notifications',
                            description:
                                "We'll remind you about birthdays and important events at the right time so you never miss a special moment.",
                            buttonLabel: 'Allow Notifications',
                            isGranted: _notificationsGranted,
                            isLoading: _isRequestingNotifications,
                            onAllow: _requestNotifications,
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.lg,
                        0,
                        AppSpacing.lg,
                        AppSpacing.lg,
                      ),
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 300),
                        opacity: _canContinue ? 1 : 0.5,
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _canContinue ? _onContinue : null,
                            child: const Text('Continue'),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PermissionsHeader extends StatelessWidget {
  const _PermissionsHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Almost there',
          style: GoogleFonts.poppins(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Grant a couple of permissions so Kalpanik can keep you on track.',
          style: GoogleFonts.poppins(
            fontSize: 15,
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

class _PermissionsAccent extends StatelessWidget {
  const _PermissionsAccent();

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: -80,
      left: -60,
      child: Container(
        width: 240,
        height: 240,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              AppColors.primary.withValues(alpha: 0.1),
              Colors.transparent,
            ],
          ),
        ),
      ),
    );
  }
}
