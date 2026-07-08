import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  PermissionService._();

  static final PermissionService instance = PermissionService._();

  Future<bool> isContactsGranted() async {
    return (await Permission.contacts.status).isGranted;
  }

  Future<bool> isNotificationGranted() async {
    return (await Permission.notification.status).isGranted;
  }

  Future<bool> requestContacts() async {
    final status = await Permission.contacts.request();
    return status.isGranted;
  }

  Future<bool> requestNotifications() async {
    final status = await Permission.notification.request();
    return status.isGranted;
  }
}
