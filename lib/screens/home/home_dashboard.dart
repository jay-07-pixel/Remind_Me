import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:remind_me/core/constants/app_colors.dart';
import 'package:remind_me/core/constants/app_routes.dart';
import 'package:remind_me/core/constants/app_spacing.dart';
import 'package:remind_me/core/utils/greeting_utils.dart';
import 'package:remind_me/models/contact_details_args.dart';
import 'package:remind_me/models/contact_event.dart';
import 'package:remind_me/models/contact_model.dart';
import 'package:remind_me/services/contact_service.dart';
import 'package:remind_me/services/storage_service.dart';
import 'package:remind_me/widgets/app_card.dart';
import 'package:remind_me/widgets/dashboard_empty_state.dart';
import 'package:remind_me/widgets/dashboard_section_header.dart';
import 'package:remind_me/widgets/today_event_card.dart';
import 'package:remind_me/widgets/upcoming_event_tile.dart';

class HomeDashboard extends StatefulWidget {
  const HomeDashboard({
    super.key,
    this.refreshToken = 0,
  });

  final int refreshToken;

  @override
  State<HomeDashboard> createState() => _HomeDashboardState();
}

class _HomeDashboardState extends State<HomeDashboard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;

  String _userName = 'there';
  List<ContactEvent> _todayEvents = const [];
  List<ContactEvent> _upcomingEvents = const [];
  Map<String, ContactModel> _contactsById = const {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    );
    _loadDashboard();
    _animationController.forward();
  }

  @override
  void didUpdateWidget(covariant HomeDashboard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.refreshToken != widget.refreshToken) {
      _loadDashboard();
    }
  }

  Future<void> _loadDashboard() async {
    final name = await StorageService.instance.getName();
    final todayEvents = await ContactService.instance.getTodayEvents();
    final upcomingEvents = await ContactService.instance.getUpcomingEvents();
    final contacts = await ContactService.instance.getStoredContacts();
    final byId = <String, ContactModel>{};
    for (final contact in contacts) {
      byId[contact.id] = contact;
    }

    if (!mounted) return;
    setState(() {
      _userName = GreetingUtils.firstName(name);
      _todayEvents = todayEvents;
      _upcomingEvents = upcomingEvents;
      _contactsById = byId;
      _isLoading = false;
    });
  }

  Future<void> _openContactDetails(ContactEvent event) async {
    final selectedContact = _contactsById[event.contactId] ??
        await ContactService.instance.getContactById(event.contactId);
    if (!mounted || selectedContact == null) return;

    context.push(
      AppRoutes.contactDetails,
      extra: ContactDetailsArgs(
        contact: selectedContact,
        selectedEvent: event,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final todayLabel = DateFormat('EEEE, MMMM d').format(DateTime.now());
    final greeting = GreetingUtils.timeBasedGreeting();

    return FadeTransition(
      opacity: _fadeAnimation,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _DashboardHeader(
              greeting: greeting,
              userName: _userName,
              dateLabel: todayLabel,
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              0,
              AppSpacing.lg,
              AppSpacing.lg,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const DashboardSectionHeader(title: "Today's Events"),
                if (_isLoading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
                    child: Center(
                      child: CircularProgressIndicator(color: AppColors.primary),
                    ),
                  )
                else if (_todayEvents.isEmpty)
                  const DashboardEmptyState(message: 'No events today')
                else
                  ...List.generate(_todayEvents.length, (index) {
                    final event = _todayEvents[index];
                    return Padding(
                      padding: EdgeInsets.only(
                        bottom: index == _todayEvents.length - 1
                            ? AppSpacing.xl
                            : AppSpacing.sm,
                      ),
                      child: TodayEventCard(
                        event: event,
                        index: index,
                        onTap: () => _openContactDetails(event),
                        onWish: () {},
                      ),
                    );
                  }),
                const DashboardSectionHeader(title: 'Upcoming Events'),
                if (_isLoading)
                  const SizedBox.shrink()
                else if (_upcomingEvents.isEmpty)
                  const DashboardEmptyState(
                    message: 'No upcoming events',
                    icon: Icons.upcoming_outlined,
                  )
                else
                  AppCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: List.generate(_upcomingEvents.length, (index) {
                        return UpcomingEventTile(
                          event: _upcomingEvents[index],
                          index: index,
                          onTap: () => _openContactDetails(_upcomingEvents[index]),
                          showDivider: index < _upcomingEvents.length - 1,
                        );
                      }),
                    ),
                  ),
                const SizedBox(height: AppSpacing.md),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader({
    required this.greeting,
    required this.userName,
    required this.dateLabel,
  });

  final String greeting;
  final String userName;
  final String dateLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(alpha: 0.08),
            AppColors.background,
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Kalpanik',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '$greeting, $userName',
            style: GoogleFonts.poppins(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              letterSpacing: -0.4,
              height: 1.2,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            dateLabel,
            style: GoogleFonts.poppins(
              fontSize: 15,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
