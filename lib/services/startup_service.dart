import 'package:remind_me/core/constants/app_routes.dart';
import 'package:remind_me/services/storage_service.dart';

class StartupService {
  StartupService._();

  static final StartupService instance = StartupService._();

  final _storage = StorageService.instance;

  /// Resolves where the user should land after the splash screen.
  ///
  /// Registered users skip onboarding, registration, and permissions.
  Future<String> resolvePostSplashRoute() async {
    final registered = await _storage.isRegistered();
    if (!registered) return AppRoutes.onboarding;

    final contactsSynced = await _storage.isContactsSynced();
    if (!contactsSynced) return AppRoutes.contactSync;

    return AppRoutes.home;
  }
}
