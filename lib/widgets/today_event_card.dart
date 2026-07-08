import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:remind_me/core/constants/app_colors.dart';
import 'package:remind_me/core/constants/app_spacing.dart';
import 'package:remind_me/models/contact_event.dart';
import 'package:remind_me/widgets/app_card.dart';
import 'package:remind_me/widgets/contact_avatar.dart';

class TodayEventCard extends StatelessWidget {
  const TodayEventCard({
    super.key,
    required this.event,
    required this.index,
    this.onTap,
    this.onWish,
  });

  final ContactEvent event;
  final int index;
  final VoidCallback? onTap;
  final VoidCallback? onWish;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      onTap: onTap,
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
                    Text(
                      event.eventLabel,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          SizedBox(
            height: 40,
            child: ElevatedButton(
              onPressed: onWish,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                minimumSize: const Size(72, 40),
              ),
              child: const Text('Wish'),
            ),
          ),
        ],
      ),
    );
  }
}
