import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:remind_me/core/constants/message_template_catalog.dart';
import 'package:remind_me/core/constants/preference_keys.dart';
import 'package:remind_me/models/contact_model.dart';
import 'package:remind_me/models/user_profile.dart';
import 'package:shared_preferences/shared_preferences.dart';
class StorageService {
  StorageService._();

  static final StorageService instance = StorageService._();

  SharedPreferences? _prefs;

  Future<SharedPreferences> get _preferences async {
    return _prefs ??= await SharedPreferences.getInstance();
  }

  Future<void> initialize() async {
    await _preferences;
  }

  Future<bool> isRegistered() async {
    final prefs = await _preferences;
    return prefs.getBool(PreferenceKeys.isRegistered) ?? false;
  }

  Future<String?> getName() async {
    final prefs = await _preferences;
    return prefs.getString(PreferenceKeys.name);
  }

  Future<String?> getPhone() async {
    final prefs = await _preferences;
    return prefs.getString(PreferenceKeys.phone);
  }

  Future<String?> getEmail() async {
    final prefs = await _preferences;
    return prefs.getString(PreferenceKeys.email);
  }

  Future<UserProfile?> getUserProfile() async {
    final prefs = await _preferences;
    final name = prefs.getString(PreferenceKeys.name);
    final phone = prefs.getString(PreferenceKeys.phone);
    final email = prefs.getString(PreferenceKeys.email);

    if (name == null || phone == null || email == null) {
      return null;
    }

    return UserProfile(name: name, phone: phone, email: email);
  }

  Future<void> saveRegistration(UserProfile profile) async {
    final prefs = await _preferences;
    await prefs.setString(PreferenceKeys.name, profile.name);
    await prefs.setString(PreferenceKeys.phone, profile.phone);
    await prefs.setString(PreferenceKeys.email, profile.email);
    await prefs.setBool(PreferenceKeys.isRegistered, true);
  }

  Future<void> updateUserProfile({
    required String name,
    required String phone,
    required String email,
  }) async {
    final prefs = await _preferences;
    await prefs.setString(PreferenceKeys.name, name);
    await prefs.setString(PreferenceKeys.phone, phone);
    await prefs.setString(PreferenceKeys.email, email);
  }

  Future<bool> isContactsSynced() async {
    final prefs = await _preferences;
    return prefs.getBool(PreferenceKeys.contactsSynced) ?? false;
  }

  Future<void> setContactsSynced(bool value) async {
    final prefs = await _preferences;
    await prefs.setBool(PreferenceKeys.contactsSynced, value);
  }

  Future<void> saveContacts(List<ContactModel> contacts) async {
    final prefs = await _preferences;
    final encoded = jsonEncode(contacts.map((contact) => contact.toJson()).toList());
    await prefs.setString(PreferenceKeys.contactsData, encoded);
  }

  Future<List<ContactModel>> getContacts() async {
    final prefs = await _preferences;
    final raw = prefs.getString(PreferenceKeys.contactsData);
    if (raw == null || raw.isEmpty) return [];

    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((item) => ContactModel.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();
  }

  Future<void> clearContacts() async {
    final prefs = await _preferences;
    await prefs.remove(PreferenceKeys.contactsData);
    await prefs.setBool(PreferenceKeys.contactsSynced, false);
  }

  Future<Map<String, String>> getMessageTemplates() async {
    final prefs = await _preferences;
    final defaults = MessageTemplateCatalog.defaultTemplatesMap();
    final raw = prefs.getString(PreferenceKeys.messageTemplates);
    if (raw == null || raw.isEmpty) {
      return defaults;
    }

    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    final stored = <String, String>{
      for (final entry in decoded.entries)
        entry.key: (entry.value as String?) ?? '',
    };

    return {
      ...defaults,
      ...stored,
    };
  }

  Future<String> getMessageTemplate(String key) async {
    final templates = await getMessageTemplates();
    return templates[key] ?? '';
  }

  Future<void> saveMessageTemplate({
    required String key,
    required String template,
  }) async {
    final prefs = await _preferences;
    final templates = await getMessageTemplates();
    templates[key] = template;
    await prefs.setString(
      PreferenceKeys.messageTemplates,
      jsonEncode(templates),
    );
  }

  /// Development utility — clears all persisted app data so the
  /// onboarding → registration → permissions flow can be tested again.
  ///
  /// Example (run from a debug console or temporary dev hook):
  /// `await StorageService.instance.resetApp();`
  ///
  /// Do not expose this in production UI.
  Future<void> resetApp() async {
    final prefs = await _preferences;
    await prefs.clear();
  }

  @visibleForTesting
  void clearCacheForTesting() {
    _prefs = null;
  }
}
