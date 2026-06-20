import 'package:flutter/material.dart';
import 'vision_controller.dart';

class DamagePainter extends CustomPainter {
  final List<DetectionResult> detections;

  DamagePainter(this.detections);

  @override
  void paint(Canvas canvas, Size size) {
    // ====== TASK 3: STATIC ANCHOR & VISION LABEL ======
    final center = Offset(size.width / 2, size.height / 2);
    final anchorPaint = Paint()
      ..color = Colors.greenAccent.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Crosshair
    canvas.drawLine(Offset(center.dx - 20, center.dy), Offset(center.dx + 20, center.dy), anchorPaint);
    canvas.drawLine(Offset(center.dx, center.dy - 20), Offset(center.dx, center.dy + 20), anchorPaint);

    // Area Pemindaian
    final scanRect = Rect.fromCenter(center: center, width: 250, height: 250);
    canvas.drawRect(scanRect, anchorPaint);

    // Label "Searching for Road Damage..."
    final searchSpan = TextSpan(
      text: "Searching for Road Damage...",
      style: TextStyle(
        color: Colors.greenAccent,
        fontSize: 14,
        fontWeight: FontWeight.bold,
        shadows: const [
          Shadow(color: Colors.black, blurRadius: 5, offset: Offset(1, 1)),
        ],
      ),
    );
    final searchPainter = TextPainter(text: searchSpan, textDirection: TextDirection.ltr);
    searchPainter.layout();
    searchPainter.paint(canvas, Offset(center.dx - (searchPainter.width / 2), center.dy - 140));

    // ====== TASK 4 & HOMEWORK: DETECTIONS ======
    for (final detection in detections) {
      // Branding Warna Berdasarkan Tipe
      Color boxColor = Colors.orangeAccent;
      if (detection.label.contains('D40')) {
        boxColor = Colors.redAccent; // Kerusakan Berat
      } else if (detection.label.contains('D00')) {
        boxColor = Colors.yellowAccent; // Kerusakan Ringan
      }

      final paint = Paint()
        ..color = boxColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0;

      // Scaling Logic
      final rect = Rect.fromLTWH(
        detection.box.left * size.width,
        detection.box.top * size.height,
        detection.box.width * size.width,
        detection.box.height * size.height,
      );

      canvas.drawRect(rect, paint);

      // Label dengan Shadow agar tetap terbaca (UX Enhancement)
      final textStyle = TextStyle(
        color: Colors.white,
        fontSize: 14,
        fontWeight: FontWeight.bold,
        shadows: const [
          Shadow(color: Colors.black, blurRadius: 4, offset: Offset(-1, -1)),
          Shadow(color: Colors.black, blurRadius: 4, offset: Offset(1, -1)),
          Shadow(color: Colors.black, blurRadius: 4, offset: Offset(1, 1)),
          Shadow(color: Colors.black, blurRadius: 4, offset: Offset(-1, 1)),
        ],
      );

      final textSpan = TextSpan(
        text: ' ${detection.label} ${(detection.score * 100).toStringAsFixed(1)}% ',
        style: textStyle,
      );

      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();
      
      // Berikan background color dengan alpha agar makin jelas
      final labelBgRect = Rect.fromLTWH(rect.left, rect.top - 20, textPainter.width, textPainter.height);
      final bgPaint = Paint()..color = boxColor.withOpacity(0.6)..style = PaintingStyle.fill;
      canvas.drawRect(labelBgRect, bgPaint);

      textPainter.paint(canvas, Offset(rect.left, rect.top - 20));
    }
  }

  @override
  bool shouldRepaint(covariant DamagePainter oldDelegate) => true;
}
