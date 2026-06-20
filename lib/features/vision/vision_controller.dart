import 'dart:async';
import 'dart:math';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class VisionController extends ChangeNotifier with WidgetsBindingObserver {
  CameraController? controller;
  bool isInitialized = false;
  String? errorMessage;

  List<DetectionResult> currentDetections = [];
  Timer? _mockDetectionTimer;

  bool isFlashlightOn = false;
  bool isOverlayVisible = true;

  // Daftar foto untuk galeri
  List<XFile> capturedPhotos = [];

  VisionController() {
    WidgetsBinding.instance.addObserver(this);
    initCamera();
  }

  Future<void> initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        errorMessage = "No camera detected on device.";
        notifyListeners();
        return;
      }

      controller = CameraController(
        cameras[0],
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await controller!.initialize();
      isInitialized = true;
      errorMessage = null;
    } catch (e) {
      errorMessage = "Failed to initialize camera: $e";
    }
    notifyListeners();
  }

  Future<XFile?> takePhoto() async {
    if (controller == null || !controller!.value.isInitialized) return null;
    if (controller!.value.isTakingPicture) return null; // Cegah double capture

    try {
      final image = await controller!.takePicture();

      capturedPhotos.add(image);
      notifyListeners();

      return image;
    } catch (e) {
      errorMessage = "Failed to capture photo: $e";
      notifyListeners();
      return null;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final cameraController = controller;
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
      isInitialized = false;
      notifyListeners();
    } else if (state == AppLifecycleState.resumed) {
      initCamera();
    }
  }

  Future<void> toggleFlashlight() async {
    if (controller == null || !controller!.value.isInitialized) return;
    isFlashlightOn = !isFlashlightOn;
    try {
      await controller!.setFlashMode(
        isFlashlightOn ? FlashMode.torch : FlashMode.off,
      );
    } catch (e) {
      errorMessage = "Failed to toggle flashlight: $e";
    }
    notifyListeners();
  }

  void toggleOverlay() {
    isOverlayVisible = !isOverlayVisible;
    notifyListeners();
  }

  void startMockDetection() {
    _mockDetectionTimer = Timer.periodic(
      const Duration(seconds: 3),
      (timer) => _generateMockDetection(),
    );
  }

  void _generateMockDetection() {
    final random = Random();
    final x = random.nextDouble() * 0.8 + 0.1;
    final y = random.nextDouble() * 0.8 + 0.1;
    final width = 0.2 + random.nextDouble() * 0.2;
    final height = 0.1 + random.nextDouble() * 0.1;

    currentDetections = [
      DetectionResult(
        box: Rect.fromLTWH(x, y, width, height),
        label: _getRandomDamageType(),
        score: 0.85 + random.nextDouble() * 0.14,
      ),
    ];
    notifyListeners();
  }

  String _getRandomDamageType() {
    final types = ['D00', 'D10', 'D20', 'D40'];
    final labels = {
      'D00': 'Longitudinal Crack',
      'D10': 'Transverse Crack',
      'D20': 'Alligator Crack',
      'D40': 'Pothole',
    };
    final type = types[Random().nextInt(types.length)];
    return '[$type] ${labels[type]!}';
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _mockDetectionTimer?.cancel();
    controller?.dispose();
    super.dispose();
  }
}

// Data Transfer Object Deteksi
class DetectionResult {
  final Rect box;
  final String label;
  final double score;

  DetectionResult({
    required this.box,
    required this.label,
    required this.score,
  });
}
