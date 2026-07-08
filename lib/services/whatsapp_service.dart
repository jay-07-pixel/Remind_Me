import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

class WhatsAppService {
  WhatsAppService._();

  static final WhatsAppService instance = WhatsAppService._();

  Future<WhatsAppLaunchResult> openChat({
    required String? rawPhoneNumber,
    required String messageTemplate,
    required String firstName,
  }) async {
    final message = _resolveMessage(
      template: messageTemplate,
      firstName: firstName,
    );
    return openChatWithMessage(
      rawPhoneNumber: rawPhoneNumber,
      message: message,
    );
  }

  Future<WhatsAppLaunchResult> openChatWithMessage({
    required String? rawPhoneNumber,
    required String message,
  }) async {
    final phone = _normalizePhone(rawPhoneNumber);
    if (phone == null) {
      return const WhatsAppLaunchResult.failure(
        'This contact does not have a valid phone number.',
      );
    }
    final url = Uri.parse(
      'https://wa.me/$phone?text=${Uri.encodeComponent(message)}',
    );

    debugPrint('WhatsApp normalized phone: $phone');
    debugPrint('WhatsApp launch URL: $url');

    try {
      final opened = await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );
      if (opened) {
        return const WhatsAppLaunchResult.success();
      }
      return const WhatsAppLaunchResult.failure(
        'Unable to open WhatsApp chat right now.',
      );
    } catch (_) {
      return const WhatsAppLaunchResult.failure(
        'Unable to open WhatsApp chat right now.',
      );
    }
  }

  String? _normalizePhone(String? rawPhoneNumber) {
    if (rawPhoneNumber == null || rawPhoneNumber.trim().isEmpty) {
      return null;
    }

    final trimmed = rawPhoneNumber.trim();
    final digitsOnly = trimmed.replaceAll(RegExp(r'[^0-9]'), '');

    if (digitsOnly.isEmpty) return null;

    // wa.me accepts only digits. Preserve full international digits.
    // Convert leading "00" international prefix to plain country code digits.
    if (digitsOnly.startsWith('00') && digitsOnly.length > 2) {
      return digitsOnly.substring(2);
    }
    return digitsOnly;
  }

  String _resolveMessage({
    required String template,
    required String firstName,
  }) {
    final safeFirstName = firstName.trim().isEmpty ? 'there' : firstName.trim();
    return template.replaceAll('{name}', safeFirstName);
  }
}

class WhatsAppLaunchResult {
  const WhatsAppLaunchResult._({
    required this.isSuccess,
    this.errorMessage,
  });

  const WhatsAppLaunchResult.success() : this._(isSuccess: true);

  const WhatsAppLaunchResult.failure(String message)
      : this._(isSuccess: false, errorMessage: message);

  final bool isSuccess;
  final String? errorMessage;
}
