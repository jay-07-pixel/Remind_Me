import 'package:flutter/material.dart';
import 'package:remind_me/app.dart';
import 'package:remind_me/services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService.instance.initialize();
  runApp(const RemindMeApp());
}
