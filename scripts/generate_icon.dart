import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

Future<void> main() async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  const size = 1024.0;

  // Background
  final bgPaint = Paint()..color = const Color(0xFF3D3BF3);
  canvas.drawRRect(
    RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size, size),
      const Radius.circular(200),
    ),
    bgPaint,
  );

  // Letter A
  final textPainter = TextPainter(
    text: const TextSpan(
      text: 'A',
      style: TextStyle(
        color: Colors.white,
        fontSize: 640,
        fontWeight: FontWeight.bold,
      ),
    ),
    textDirection: TextDirection.ltr,
  );
  textPainter.layout();
  textPainter.paint(
    canvas,
    Offset(
      (size - textPainter.width) / 2,
      (size - textPainter.height) / 2,
    ),
  );

  final picture = recorder.endRecording();
  final img = await picture.toImage(size.toInt(), size.toInt());
  final bytes = await img.toByteData(format: ui.ImageByteFormat.png);

  await Directory('assets/icon').create(recursive: true);
  await File('assets/icon/icon.png').writeAsBytes(bytes!.buffer.asUint8List());
  await File('assets/icon/icon_foreground.png').writeAsBytes(bytes.buffer.asUint8List());

  print('Icons generated at assets/icon/');
  exit(0);
}
