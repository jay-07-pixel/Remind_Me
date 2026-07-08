import 'package:flutter/material.dart';
import 'package:remind_me/core/constants/app_colors.dart';
import 'package:remind_me/core/constants/app_spacing.dart';
import 'package:remind_me/models/onboarding_page.dart';

class OnboardingIllustration extends StatelessWidget {
  const OnboardingIllustration({
    super.key,
    required this.data,
  });

  final OnboardingPageData data;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.1,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius + 8),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              data.gradientColors.first.withValues(alpha: 0.12),
              data.gradientColors.last.withValues(alpha: 0.04),
            ],
          ),
          border: Border.all(
            color: AppColors.border.withValues(alpha: 0.8),
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              top: AppSpacing.xl,
              right: AppSpacing.xl,
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: data.gradientColors.first.withValues(alpha: 0.1),
                ),
              ),
            ),
            Positioned(
              bottom: AppSpacing.xl,
              left: AppSpacing.xl,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: data.gradientColors.last.withValues(alpha: 0.12),
                ),
              ),
            ),
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(32),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: data.gradientColors,
                ),
                boxShadow: [
                  BoxShadow(
                    color: data.gradientColors.last.withValues(alpha: 0.3),
                    blurRadius: 28,
                    offset: const Offset(0, 14),
                  ),
                ],
              ),
              child: Icon(
                data.icon,
                size: 56,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
