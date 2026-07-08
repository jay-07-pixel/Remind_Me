import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:remind_me/core/constants/app_colors.dart';
import 'package:remind_me/core/constants/app_routes.dart';
import 'package:remind_me/core/constants/app_spacing.dart';
import 'package:remind_me/models/onboarding_page.dart';
import 'package:remind_me/widgets/onboarding_page_content.dart';
import 'package:remind_me/widgets/onboarding_page_indicator.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  static const _pages = [
    OnboardingPageData(
      title: 'Never Miss a Moment',
      description:
          'Keep track of birthdays, anniversaries, and every special day that matters to you.',
      icon: Icons.celebration_rounded,
      gradientColors: [AppColors.primaryLight, AppColors.primary],
    ),
    OnboardingPageData(
      title: 'Smart Reminders',
      description:
          'Get gentle notifications ahead of time so you are always prepared.',
      icon: Icons.notifications_active_rounded,
      gradientColors: [AppColors.primary, AppColors.primaryDark],
    ),
    OnboardingPageData(
      title: 'Your People, One Place',
      description:
          'Organize contacts and events in a calm, beautiful space built for you.',
      icon: Icons.people_alt_rounded,
      gradientColors: [Color(0xFF60A5FA), AppColors.primary],
    ),
  ];

  late final PageController _pageController;
  int _currentPage = 0;

  bool get _isLastPage => _currentPage == _pages.length - 1;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToRegistration() {
    context.go(AppRoutes.registration);
  }

  void _onNext() {
    if (_isLastPage) {
      _goToRegistration();
      return;
    }

    _pageController.nextPage(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _goToRegistration,
                child: const Text('Skip'),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) => setState(() => _currentPage = index),
                physics: const BouncingScrollPhysics(),
                itemBuilder: (context, index) {
                  return Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                      child: OnboardingPageContent(data: _pages[index]),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.md,
                AppSpacing.lg,
                AppSpacing.lg,
              ),
              child: Column(
                children: [
                  OnboardingPageIndicator(
                    count: _pages.length,
                    currentIndex: _currentPage,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _onNext,
                      child: Text(_isLastPage ? 'Get Started' : 'Next'),
                    ),
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
