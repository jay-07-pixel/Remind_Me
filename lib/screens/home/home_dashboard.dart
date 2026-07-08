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
import 'package:remind_me/models/event_type.dart';
import 'package:remind_me/services/contact_service.dart';
import 'package:remind_me/services/storage_service.dart';
import 'package:remind_me/widgets/app_card.dart';
import 'package:remind_me/widgets/contact_avatar.dart';

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
  List<ContactEvent> _allEvents = const [];
  Map<String, ContactModel> _contactsById = const {};
  DashboardFilter _selectedFilter = DashboardFilter.all;
  String _searchQuery = '';
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
    final allEvents = await ContactService.instance.getAllEvents();
    final contacts = await ContactService.instance.getStoredContacts();
    final byId = <String, ContactModel>{};
    for (final contact in contacts) {
      byId[contact.id] = contact;
    }

    if (!mounted) return;
    setState(() {
      _userName = GreetingUtils.firstName(name);
      _allEvents = allEvents;
      _contactsById = byId;
      _isLoading = false;
    });
  }

  List<ContactEvent> get _filteredEvents {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final query = _searchQuery.trim().toLowerCase();

    bool matchesFilter(ContactEvent event) {
      return switch (_selectedFilter) {
        DashboardFilter.all => true,
        DashboardFilter.today =>
          event.date.year == today.year &&
              event.date.month == today.month &&
              event.date.day == today.day,
        DashboardFilter.birthdays => event.eventType == EventType.birthday,
        DashboardFilter.anniversaries =>
          event.eventType == EventType.anniversary,
        DashboardFilter.upcoming => event.date.isAfter(today),
      };
    }

    bool matchesQuery(ContactEvent event) {
      if (query.isEmpty) return true;
      return event.contactName.toLowerCase().contains(query);
    }

    return _allEvents
        .where((event) => matchesFilter(event) && matchesQuery(event))
        .toList();
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
    final visibleEvents = _filteredEvents;

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
                _DashboardSearchBar(
                  onChanged: (value) => setState(() => _searchQuery = value),
                ),
                const SizedBox(height: AppSpacing.md),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: DashboardFilter.values.map((filter) {
                    final selected = filter == _selectedFilter;
                    return ChoiceChip(
                      label: Text(filter.label),
                      selected: selected,
                      onSelected: (_) {
                        setState(() => _selectedFilter = filter);
                      },
                      labelStyle: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: selected
                            ? Colors.white
                            : AppColors.textSecondary,
                      ),
                      selectedColor: AppColors.primary,
                      backgroundColor: AppColors.surface,
                      side: BorderSide(
                        color: selected
                            ? AppColors.primary
                            : AppColors.border,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: AppSpacing.lg),
                if (_isLoading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
                    child: Center(
                      child: CircularProgressIndicator(color: AppColors.primary),
                    ),
                  )
                else
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: visibleEvents.isEmpty
                        ? const _SearchEmptyState(
                            key: ValueKey('no-results'),
                          )
                        : Column(
                            key: ValueKey('events-list'),
                            children: List.generate(visibleEvents.length, (
                              index,
                            ) {
                              final event = visibleEvents[index];
                              return Padding(
                                padding: EdgeInsets.only(
                                  bottom: index == visibleEvents.length - 1
                                      ? AppSpacing.md
                                      : AppSpacing.sm,
                                ),
                                child: _DashboardEventCard(
                                  event: event,
                                  index: index,
                                  onTap: () => _openContactDetails(event),
                                ),
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

class _DashboardSearchBar extends StatelessWidget {
  const _DashboardSearchBar({
    required this.onChanged,
  });

  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: 'Search contacts...',
        prefixIcon: const Icon(Icons.search_rounded, size: 22),
        suffixIcon: const Icon(
          Icons.tune_rounded,
          size: 20,
          color: AppColors.textTertiary,
        ),
        filled: true,
        fillColor: AppColors.surface,
      ),
      style: GoogleFonts.poppins(
        fontSize: 15,
        color: AppColors.textPrimary,
      ),
    );
  }
}

class _DashboardEventCard extends StatelessWidget {
  const _DashboardEventCard({
    required this.event,
    required this.index,
    required this.onTap,
  });

  final ContactEvent event;
  final int index;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dateLabel = DateFormat('MMM d').format(event.date);

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          ContactAvatar(
            initials: event.initials,
            gradientIndex: index,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.contactName,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    Icon(
                      event.eventType.icon,
                      size: 16,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: Text(
                        event.eventLabel,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              dateLabel,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchEmptyState extends StatelessWidget {
  const _SearchEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xl,
      ),
      child: Column(
        children: [
          Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0.12),
                  AppColors.primaryLight.withValues(alpha: 0.06),
                ],
              ),
            ),
            child: const Icon(
              Icons.search_off_rounded,
              size: 40,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'No matching contacts found',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

enum DashboardFilter {
  all('All'),
  today("Today's Events"),
  birthdays('Birthdays'),
  anniversaries('Anniversaries'),
  upcoming('Upcoming');

  const DashboardFilter(this.label);
  final String label;
}
