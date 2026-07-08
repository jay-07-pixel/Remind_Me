import 'package:flutter_test/flutter_test.dart';
import 'package:remind_me/app.dart';
import 'package:remind_me/core/constants/app_routes.dart';
import 'package:remind_me/core/constants/preference_keys.dart';
import 'package:remind_me/core/utils/app_router.dart';
import 'package:remind_me/screens/home/home_screen.dart';
import 'package:remind_me/screens/onboarding/onboarding_screen.dart';
import 'package:remind_me/screens/splash/splash_screen.dart';
import 'package:remind_me/services/storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('App startup', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
      StorageService.instance.clearCacheForTesting();
      AppRouter.router.go(AppRoutes.splash);
    });

    testWidgets('navigates to onboarding when user is not registered',
        (WidgetTester tester) async {
      await tester.pumpWidget(const RemindMeApp());

      expect(find.text('Kalpanik'), findsOneWidget);
      expect(find.text('Remind Me'), findsOneWidget);
      expect(find.byType(SplashScreen), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 5000));
      await tester.pumpAndSettle();

      expect(find.byType(OnboardingScreen), findsOneWidget);
      expect(find.byType(SplashScreen), findsNothing);
    });

    testWidgets('navigates to home when user is already registered',
        (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({
        PreferenceKeys.isRegistered: true,
        PreferenceKeys.contactsSynced: true,
        PreferenceKeys.name: 'Test User',
        PreferenceKeys.phone: '9876543210',
        PreferenceKeys.email: 'test@example.com',
        PreferenceKeys.contactsData: '[]',
      });
      StorageService.instance.clearCacheForTesting();

      await tester.pumpWidget(const RemindMeApp());

      expect(find.byType(SplashScreen), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 5000));
      await tester.pumpAndSettle();

      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.byType(SplashScreen), findsNothing);
      expect(find.byType(OnboardingScreen), findsNothing);
    });
  });
}
