import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:remind_me/core/constants/app_routes.dart';
import 'package:remind_me/models/contact_details_args.dart';
import 'package:remind_me/models/message_template_editor_args.dart';
import 'package:remind_me/screens/contact_sync/contact_sync_screen.dart';
import 'package:remind_me/screens/contact_details/contact_details_screen.dart';
import 'package:remind_me/screens/home/home_screen.dart';
import 'package:remind_me/screens/message_templates/message_template_editor_screen.dart';
import 'package:remind_me/screens/message_templates/message_templates_screen.dart';
import 'package:remind_me/screens/onboarding/onboarding_screen.dart';
import 'package:remind_me/screens/permissions/permissions_screen.dart';
import 'package:remind_me/screens/profile/profile_screen.dart';
import 'package:remind_me/screens/registration/registration_screen.dart';
import 'package:remind_me/screens/settings/settings_screen.dart';
import 'package:remind_me/screens/splash/splash_screen.dart';
import 'package:remind_me/screens/today_events/today_events_screen.dart';

abstract final class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        name: 'splash',
        pageBuilder: (context, state) => _buildPage(
          state: state,
          child: const SplashScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        name: 'onboarding',
        pageBuilder: (context, state) => _buildPage(
          state: state,
          child: const OnboardingScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.registration,
        name: 'registration',
        pageBuilder: (context, state) => _buildPage(
          state: state,
          child: const RegistrationScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.permissions,
        name: 'permissions',
        pageBuilder: (context, state) => _buildPage(
          state: state,
          child: const PermissionsScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.contactSync,
        name: 'contactSync',
        pageBuilder: (context, state) => _buildPage(
          state: state,
          child: const ContactSyncScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.home,
        name: 'home',
        pageBuilder: (context, state) => _buildPage(
          state: state,
          child: const HomeScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.contactDetails,
        name: 'contactDetails',
        pageBuilder: (context, state) {
          final args = state.extra;
          if (args is! ContactDetailsArgs) {
            return _buildPage(
              state: state,
              child: const HomeScreen(),
            );
          }
          return _buildPage(
            state: state,
            child: ContactDetailsScreen(args: args),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.myProfile,
        name: 'myProfile',
        pageBuilder: (context, state) => _buildPage(
          state: state,
          child: const ProfileScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.messageTemplates,
        name: 'messageTemplates',
        pageBuilder: (context, state) => _buildPage(
          state: state,
          child: const MessageTemplatesScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.messageTemplateEditor,
        name: 'messageTemplateEditor',
        pageBuilder: (context, state) {
          final args = state.extra;
          if (args is! MessageTemplateEditorArgs) {
            return _buildPage(
              state: state,
              child: const MessageTemplatesScreen(),
            );
          }
          return _buildPage(
            state: state,
            child: MessageTemplateEditorScreen(args: args),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.settings,
        name: 'settings',
        pageBuilder: (context, state) => _buildPage(
          state: state,
          child: const SettingsScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.todayEvents,
        name: 'todayEvents',
        pageBuilder: (context, state) => _buildPage(
          state: state,
          child: const TodayEventsScreen(),
        ),
      ),
    ],
  );

  static CustomTransitionPage<void> _buildPage({
    required GoRouterState state,
    required Widget child,
  }) {
    return CustomTransitionPage<void>(
      key: state.pageKey,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }
}
