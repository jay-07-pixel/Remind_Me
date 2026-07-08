import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:remind_me/core/constants/message_template_catalog.dart';
import 'package:remind_me/models/greeting_card_model.dart';
import 'package:remind_me/repositories/greeting_card_repository.dart';
import 'package:share_plus/share_plus.dart';

class GreetingCardService {
  GreetingCardService._();

  static final GreetingCardService instance = GreetingCardService._();

  final _repository = const GreetingCardRepository();

  Future<List<GreetingCardModel>> getCards(MessageTemplateSection section) {
    return _repository.getCards(section);
  }

  Future<Uint8List> renderPngFromBoundary(GlobalKey repaintKey) async {
    final boundary =
        repaintKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) {
      throw Exception('Unable to capture card preview.');
    }
    final image = await boundary.toImage(pixelRatio: 3);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) {
      throw Exception('Unable to convert card preview to PNG.');
    }
    return byteData.buffer.asUint8List();
  }

  Future<File> savePngToCache(Uint8List pngBytes) async {
    final temp = await getTemporaryDirectory();
    final file = File(
      '${temp.path}/kalpanik_card_${DateTime.now().millisecondsSinceEpoch}.png',
    );
    await file.writeAsBytes(pngBytes, flush: true);
    return file;
  }

  Future<bool> savePngToGallery(Uint8List pngBytes) async {
    final result = await ImageGallerySaver.saveImage(
      pngBytes,
      quality: 100,
      name: 'kalpanik_card_${DateTime.now().millisecondsSinceEpoch}',
    );

    if (result is Map) {
      final success = result['isSuccess'];
      if (success is bool) return success;
      final value = result['filePath'] ?? result['savedPath'];
      return value != null;
    }
    return false;
  }

  Future<void> shareCard({
    required File imageFile,
    required String caption,
  }) async {
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(imageFile.path)],
        text: caption,
      ),
    );
  }
}
