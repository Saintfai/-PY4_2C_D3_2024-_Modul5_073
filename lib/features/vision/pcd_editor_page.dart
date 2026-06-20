import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'pcd_service.dart';

class PcdEditorPage extends StatefulWidget {
  final String imagePath;

  const PcdEditorPage({super.key, required this.imagePath});

  @override
  State<PcdEditorPage> createState() => _PcdEditorPageState();
}

class _PcdEditorPageState extends State<PcdEditorPage> {
  Uint8List? _currentImageBytes;
  bool _isProcessing = false;
  String _activeFilter = 'Original';

  // Kecerahan
  double _brightnessValue = 0;

  @override
  void initState() {
    super.initState();
    _currentImageBytes = File(widget.imagePath).readAsBytesSync();
  }

  Future<void> _applyFilter(String filterName) async {
    if (_activeFilter == filterName && filterName != 'Brightness') return;

    setState(() {
      _isProcessing = true;
      _activeFilter = filterName;
      // Reset slider kecerahan saat filter berubah
      if (filterName != 'Brightness') _brightnessValue = 0;
    });

    Uint8List? resultBytes;

    try {
      await Future.delayed(const Duration(milliseconds: 50));

      switch (filterName) {
        case 'Original':
          resultBytes = File(widget.imagePath).readAsBytesSync();
          break;
        case 'Brightness':
          resultBytes = await PcdService.applyBrightness(
            widget.imagePath,
            _brightnessValue.toInt(),
          );
          break;
        case 'Grayscale':
          resultBytes = await PcdService.applyGrayscale(widget.imagePath);
          break;
        case 'Biner':
          resultBytes = await PcdService.applyThreshold(widget.imagePath);
          break;
        case 'Blur':
          resultBytes = await PcdService.applyBlur(widget.imagePath);
          break;
        case 'Edge Detect':
          resultBytes = await PcdService.applyEdgeDetection(widget.imagePath);
          break;
        case 'Sharpen':
          resultBytes = await PcdService.applySharpen(widget.imagePath);
          break;
        case 'Histogram':
          resultBytes = await PcdService.getHistogram(widget.imagePath);
          break;
      }

      if (resultBytes != null && mounted) {
        setState(() {
          _currentImageBytes = resultBytes;
        });
      }
    } catch (e) {
      debugPrint("Gagal memproses gambar: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  void _onSavePressed() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ Modifikasi berhasil diterapkan!'),
        backgroundColor: Colors.green,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Laboratorium PCD", style: TextStyle(fontSize: 18)),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _isProcessing ? null : _onSavePressed,
            icon: const Icon(Icons.check, color: Colors.greenAccent, size: 28),
            tooltip: 'Selesai',
          ),
        ],
      ),
      body: Column(
        children: [
          // Foto Utama
          Expanded(
            child: Center(
              child: _currentImageBytes == null
                  ? const CircularProgressIndicator(color: Colors.red)
                  : Stack(
                      alignment: Alignment.center,
                      children: [
                        InteractiveViewer(
                          minScale: 0.5,
                          maxScale: 4.0,
                          child: Image.memory(
                            _currentImageBytes!,
                            fit: BoxFit.contain,
                          ),
                        ),

                        if (_isProcessing)
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.black87,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircularProgressIndicator(color: Colors.red),
                                SizedBox(height: 16),
                                Text(
                                  "Memproses...",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
            ),
          ),

          // Keterangan Histogram
          if (_activeFilter == 'Histogram' && !_isProcessing)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              color: Colors.grey[900],
              child: const Column(
                children: [
                  Text(
                    "Grafik Sebaran Cahaya Citra Grayscale",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Sumbu Y: Frekuensi Kemunculan Piksel",
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  Text(
                    "Sumbu X: Intensitas Warna (0 Hitam - 255 Putih)",
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),

          // Panel Filter
          SafeArea(
            top: false,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black54,
                    blurRadius: 10,
                    offset: Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min, // Sesuaikan tinggi dengan isi
                children: [
                  // Slider Brightness
                  if (_activeFilter == 'Brightness')
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 16.0,
                        left: 16.0,
                        right: 16.0,
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.brightness_low, color: Colors.grey),
                          Expanded(
                            child: Slider(
                              value: _brightnessValue,
                              min: -100,
                              max: 100,
                              divisions: 200,
                              activeColor: Colors.red,
                              label: _brightnessValue > 0
                                  ? "+${_brightnessValue.toInt()}"
                                  : "${_brightnessValue.toInt()}",
                              // Ubah label slider tanpa proses
                              onChanged: (value) {
                                setState(() {
                                  _brightnessValue = value;
                                });
                              },
                              // Terapkan filter saat selesai digeser
                              onChangeEnd: (value) {
                                _applyFilter('Brightness');
                              },
                            ),
                          ),
                          const Icon(Icons.brightness_high, color: Colors.grey),
                        ],
                      ),
                    ),

                  // Menu Filter
                  SizedBox(
                    height: 120, // Tinggi panel scroll tombol
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      children: [
                        _buildFilterButton('Original', Icons.image_outlined),
                        _buildFilterButton('Brightness', Icons.light_mode),
                        _buildFilterButton('Grayscale', Icons.tonality),
                        _buildFilterButton('Biner', Icons.contrast),
                        _buildFilterButton('Blur', Icons.blur_on),
                        _buildFilterButton('Edge Detect', Icons.polyline),
                        _buildFilterButton(
                          'Sharpen',
                          Icons.filter_center_focus,
                        ),
                        _buildFilterButton('Histogram', Icons.bar_chart),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButton(String title, IconData icon) {
    final isActive = _activeFilter == title;

    return GestureDetector(
      onTap: _isProcessing ? null : () => _applyFilter(title),
      child: Container(
        width: 80,
        margin: const EdgeInsets.only(right: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isActive ? Colors.red : Colors.transparent,
                  width: 2.5,
                ),
                color: isActive
                    ? Colors.red.withOpacity(0.1)
                    : Colors.grey[100],
              ),
              child: Icon(
                icon,
                color: isActive ? Colors.red : Colors.grey[700],
                size: 26,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isActive ? Colors.red : Colors.grey[800],
                fontSize: 11,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
