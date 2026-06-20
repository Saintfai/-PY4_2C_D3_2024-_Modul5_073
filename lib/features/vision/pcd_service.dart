import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

Uint8List? _processGrayscale(String imagePath) {
  final bytes = File(imagePath).readAsBytesSync();
  final image = img.decodeImage(bytes);
  if (image == null) return null;
  final grayscaleImage = img.grayscale(image);
  return Uint8List.fromList(img.encodeJpg(grayscaleImage));
}

Uint8List? _processThreshold(String imagePath) {
  final bytes = File(imagePath).readAsBytesSync();
  final image = img.decodeImage(bytes);
  if (image == null) return null;
  final gray = img.grayscale(image);
  for (var pixel in gray) {
    if (pixel.r > 128) {
      pixel.setRgb(255, 255, 255);
    } else {
      pixel.setRgb(0, 0, 0);
    }
  }
  return Uint8List.fromList(img.encodeJpg(gray));
}

Uint8List? _processBlur(String imagePath) {
  final bytes = File(imagePath).readAsBytesSync();
  final image = img.decodeImage(bytes);
  if (image == null) return null;
  final blurredImage = img.gaussianBlur(image, radius: 5);
  return Uint8List.fromList(img.encodeJpg(blurredImage));
}

Uint8List? _processEdgeDetection(String imagePath) {
  final bytes = File(imagePath).readAsBytesSync();
  final image = img.decodeImage(bytes);
  if (image == null) return null;
  final edgeImage = img.sobel(image);
  return Uint8List.fromList(img.encodeJpg(edgeImage));
}

Uint8List? _processSharpen(String imagePath) {
  final bytes = File(imagePath).readAsBytesSync();
  final image = img.decodeImage(bytes);
  if (image == null) return null;

  final result = img.Image.from(image);
  final w = image.width;
  final h = image.height;

  for (int y = 1; y < h - 1; y++) {
    for (int x = 1; x < w - 1; x++) {
      int r = 0, g = 0, b = 0;
      final pc = image.getPixel(x, y);
      r += pc.r.toInt() * 5;
      g += pc.g.toInt() * 5;
      b += pc.b.toInt() * 5;

      final pt = image.getPixel(x, y - 1);
      final pb = image.getPixel(x, y + 1);
      final pl = image.getPixel(x - 1, y);
      final pr = image.getPixel(x + 1, y);

      r -= (pt.r + pb.r + pl.r + pr.r).toInt();
      g -= (pt.g + pb.g + pl.g + pr.g).toInt();
      b -= (pt.b + pb.b + pl.b + pr.b).toInt();

      result.setPixelRgb(
        x,
        y,
        r.clamp(0, 255),
        g.clamp(0, 255),
        b.clamp(0, 255),
      );
    }
  }
  return Uint8List.fromList(img.encodeJpg(result));
}

Uint8List? _processHistogram(String imagePath) {
  final bytes = File(imagePath).readAsBytesSync();
  final image = img.decodeImage(bytes);
  if (image == null) return null;

  List<int> hist = List.filled(256, 0);
  int maxFreq = 0;

  final gray = img.grayscale(img.Image.from(image));
  for (var pixel in gray) {
    int val = pixel.r.toInt();
    hist[val]++;
    if (hist[val] > maxFreq) maxFreq = hist[val];
  }

  // Margin grafik
  final histImage = img.Image(width: 256, height: 200);
  img.fill(
    histImage,
    color: img.ColorRgb8(240, 240, 240),
  );

  // Buat grafik batang
  for (int x = 0; x < 256; x++) {
    int barHeight = maxFreq == 0 ? 0 : (hist[x] / maxFreq * 190).toInt();
    img.drawLine(
      histImage,
      x1: x,
      y1: 199,
      x2: x,
      y2: 199 - barHeight,
      color: img.ColorRgb8(255, 50, 50),
    );
  }

  // Sumbu X
  img.drawLine(
    histImage,
    x1: 0,
    y1: 199,
    x2: 255,
    y2: 199,
    color: img.ColorRgb8(0, 0, 0),
    thickness: 2,
  );
  // Sumbu Y
  img.drawLine(
    histImage,
    x1: 0,
    y1: 0,
    x2: 0,
    y2: 199,
    color: img.ColorRgb8(0, 0, 0),
    thickness: 2,
  );

  return Uint8List.fromList(img.encodePng(histImage));
}

// Filter Kecerahan / Brightness
Uint8List? _processBrightness(Map<String, dynamic> params) {
  final String imagePath = params['path'];
  final int brightnessValue = params['value'];

  final bytes = File(imagePath).readAsBytesSync();
  final image = img.decodeImage(bytes);
  if (image == null) return null;

  for (var pixel in image) {
    pixel.r = (pixel.r + brightnessValue).clamp(0, 255);
    pixel.g = (pixel.g + brightnessValue).clamp(0, 255);
    pixel.b = (pixel.b + brightnessValue).clamp(0, 255);
  }
  return Uint8List.fromList(img.encodeJpg(image));
}

class PcdService {
  static Future<Uint8List?> applyGrayscale(String imagePath) async =>
      await compute(_processGrayscale, imagePath);
  static Future<Uint8List?> applyThreshold(String imagePath) async =>
      await compute(_processThreshold, imagePath);
  static Future<Uint8List?> applyBlur(String imagePath) async =>
      await compute(_processBlur, imagePath);
  static Future<Uint8List?> applyEdgeDetection(String imagePath) async =>
      await compute(_processEdgeDetection, imagePath);
  static Future<Uint8List?> applySharpen(String imagePath) async =>
      await compute(_processSharpen, imagePath);
  static Future<Uint8List?> getHistogram(String imagePath) async =>
      await compute(_processHistogram, imagePath);

  static Future<Uint8List?> applyBrightness(String imagePath, int value) async {
    return await compute(_processBrightness, {
      'path': imagePath,
      'value': value,
    });
  }
}
