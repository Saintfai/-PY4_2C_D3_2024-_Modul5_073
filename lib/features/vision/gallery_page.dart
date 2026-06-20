import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'pcd_editor_page.dart';

// ==========================================
// 1. HALAMAN GALERI UTAMA (GRID VIEW)
// ==========================================
class GalleryPage extends StatelessWidget {
  final List<XFile> photos;

  const GalleryPage({super.key, required this.photos});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Sesi Patroli (Galeri)"),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: photos.isEmpty
          ? const Center(
              child: Text(
                "Belum ada foto yang diambil.",
                style: TextStyle(color: Colors.white70),
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: photos.length,
              itemBuilder: (context, index) {
                final file = File(photos[index].path);

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FullScreenPhotoPage(
                          imageFile: file,
                          heroTag: 'photo_$index',
                        ),
                      ),
                    );
                  },
                  child: Hero(
                    tag: 'photo_$index',
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(file, fit: BoxFit.cover),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

// ==========================================
// 2. HALAMAN DETAIL (FULL SCREEN & ZOOM)
// ==========================================
class FullScreenPhotoPage extends StatelessWidget {
  final File imageFile;
  final String heroTag;

  const FullScreenPhotoPage({
    super.key,
    required this.imageFile,
    required this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black54,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text("Detail Foto"),
        actions: [
          // TOMBOL MENUJU LABORATROIUM PCD
          IconButton(
            icon: const Icon(Icons.auto_fix_high, color: Colors.blueAccent),
            tooltip: 'Buka Lab PCD',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      PcdEditorPage(imagePath: imageFile.path),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.1,
          maxScale: 4.0,
          child: Hero(
            tag: heroTag,
            child: Image.file(imageFile, fit: BoxFit.contain),
          ),
        ),
      ),
    );
  }
}
