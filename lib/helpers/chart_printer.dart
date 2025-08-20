import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:share_plus/share_plus.dart';

class ChartPrinter {
  final GlobalKey chartKey;
  final double pixelRatio;

  const ChartPrinter({
    required this.chartKey,
    this.pixelRatio = 3.0,
  });

  Future<Uint8List?> _capturePngBytes({
    double rightPadding = 0,
    Color? backgroundColor,
  }) async {
    final context = chartKey.currentContext;
    if (context == null) return null;

    await WidgetsBinding.instance.endOfFrame;
    if (!context.mounted) return null;

    final boundary = context.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) return null;

    final image = await boundary.toImage(pixelRatio: pixelRatio);

    if (rightPadding <= 0) {
      final byteData = await image.toByteData(format: ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    }

    final padPx = (rightPadding * pixelRatio).ceil();
    final newW = image.width + padPx;
    final newH = image.height;

    final recorder = PictureRecorder();
    final canvas = Canvas(recorder);

    if (backgroundColor != null) {
      final paint = Paint()..color = backgroundColor;
      canvas.drawRect(Rect.fromLTWH(0, 0, newW.toDouble(), newH.toDouble()), paint);
    }

    canvas.drawImage(image, Offset.zero, Paint());

    final picture = recorder.endRecording();
    final composed = await picture.toImage(newW, newH);
    final byteData = await composed.toByteData(format: ImageByteFormat.png);
    return byteData?.buffer.asUint8List();
  }

  Future<File?> exportChartAsPng({
    double rightPadding = 0,
    Color? backgroundColor,
    String? fileName,
  }) async {
    final bytes = await _capturePngBytes(
      rightPadding: rightPadding,
      backgroundColor: backgroundColor,
    );
    if (bytes == null) return null;

    final directory = Directory.systemTemp;
    final name = fileName ?? 'chart_${DateTime.now().millisecondsSinceEpoch}.png';
    final file = File('${directory.path}/$name');
    await file.writeAsBytes(bytes);
    return file;
  }

  Future<void> shareChart({
    double rightPadding = 0,
    Color? backgroundColor,
    String? subject,
    String? text,
  }) async {
    final file = await exportChartAsPng(
      rightPadding: rightPadding,
      backgroundColor: backgroundColor,
    );
    if (file != null) {
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          text: text ?? 'Check out this chart!',
          subject: subject ?? 'Chart Export',
        ),
      );
    }
  }

  Future<String?> saveToGallery({
    String? name,
    double rightPadding = 0,
    Color? backgroundColor,
  }) async {
    final bytes = await _capturePngBytes(
      rightPadding: rightPadding,
      backgroundColor: backgroundColor,
    );
    if (bytes == null) return null;

    final result = await ImageGallerySaverPlus.saveImage(
      bytes,
      name: name ?? 'pr_chart_${DateTime.now().millisecondsSinceEpoch}',
      quality: 100,
    );

    final isSuccess = (result['isSuccess'] == true) || (result['isSuccess'] == 1);
    if (!isSuccess) return null;

    return result['filePath']?.toString();
  }
}