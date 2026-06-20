import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';

import 'vision_controller.dart';
import 'damage_painter.dart';
import 'gallery_page.dart';

class VisionView extends StatefulWidget {
  const VisionView({super.key});

  @override
  State<VisionView> createState() => _VisionViewState();
}

class _VisionViewState extends State<VisionView> {
  late VisionController _visionController;

  @override
  void initState() {
    super.initState();
    _visionController = VisionController();
    _visionController.startMockDetection();
  }

  @override
  void dispose() {
    _visionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Smart-Patrol Vision"),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(
              _visionController.isOverlayVisible
                  ? Icons.visibility
                  : Icons.visibility_off,
            ),
            onPressed: _visionController.toggleOverlay,
            tooltip: 'Toggle Overlay',
          ),
        ],
      ),
      // Menggunakan ListenableBuilder untuk efisiensi render
      body: ListenableBuilder(
        listenable: _visionController,
        builder: (context, child) {
          if (!_visionController.isInitialized) {
            return _buildLoadingState();
          }
          return _buildVisionStack();
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: Colors.white),
          const SizedBox(height: 16),
          const Text(
            "Menghubungkan ke Sensor Visual...",
            style: TextStyle(color: Colors.white),
          ),
          if (_visionController.errorMessage != null) ...[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                _visionController.errorMessage!,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ),
            ElevatedButton(
              onPressed: () => openAppSettings(),
              child: const Text("Buka Pengaturan"),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildVisionStack() {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Kamera Preview
        Center(
          child: AspectRatio(
            aspectRatio: 1 / _visionController.controller!.value.aspectRatio,
            child: CameraPreview(_visionController.controller!),
          ),
        ),

        // Overlay Deteksi
        if (_visionController.isOverlayVisible)
          Positioned.fill(
            child: CustomPaint(
              painter: DamagePainter(_visionController.currentDetections),
            ),
          ),

        // Panel Kontrol
        Positioned(
          bottom: 40,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Senter
              FloatingActionButton(
                heroTag: "flash_btn",
                onPressed: _visionController.toggleFlashlight,
                backgroundColor: _visionController.isFlashlightOn
                    ? Colors.amber
                    : Colors.white24,
                elevation: 0,
                child: Icon(
                  _visionController.isFlashlightOn
                      ? Icons.flash_on
                      : Icons.flash_off,
                  color: Colors.white,
                ),
              ),

              // Tombol Shutter
              GestureDetector(
                onTap: () async {
                  final image = await _visionController.takePhoto();
                  if (image != null && mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('📸 Tersimpan di galeri sementara.'),
                        backgroundColor: Colors.green,
                        duration: Duration(seconds: 1),
                      ),
                    );
                  }
                },
                child: Container(
                  height: 80,
                  width: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                    color: Colors.white24,
                  ),
                  child: Center(
                    child: Container(
                      height: 60,
                      width: 60,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),

              // Tombol Galeri
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          GalleryPage(photos: _visionController.capturedPhotos),
                    ),
                  );
                },
                child: Container(
                  height: 56,
                  width: 56,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white24,
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const Icon(Icons.photo_library, color: Colors.white),
                      if (_visionController.capturedPhotos.isNotEmpty)
                        Positioned(
                          right: 4,
                          top: 4,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '${_visionController.capturedPhotos.length}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
