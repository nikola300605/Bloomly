import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/router/app_router.dart';

/// Camera / image-picker entry screen for both identify and diagnose modes.
class ScanCameraScreen extends StatefulWidget {
  final String mode; // "identify" | "diagnose"
  final String? plantId;

  const ScanCameraScreen({super.key, this.mode = 'identify', this.plantId});

  @override
  State<ScanCameraScreen> createState() => _ScanCameraScreenState();
}

class _ScanCameraScreenState extends State<ScanCameraScreen> {
  late String _mode;

  @override
  void initState() {
    super.initState();
    _mode = widget.mode;
  }

  Future<void> _shoot() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.camera, imageQuality: 85);
    if (file != null && mounted) {
      _navigate(file.path);
    }
  }

  Future<void> _pickGallery() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (file != null && mounted) {
      _navigate(file.path);
    }
  }

  void _navigate(String path) {
    if (_mode == 'diagnose') {
      context.push(
        AppRoutes.scanSymptoms + (widget.plantId != null ? '?plantId=${widget.plantId}' : ''),
        extra: path,
      );
    } else {
      // Identify: go straight to results
      // TODO: call identify API and push results
      context.push(AppRoutes.scanResults, extra: {'photo_path': path, 'mode': _mode});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Viewfinder placeholder — swap for camera_preview widget in production
            Container(
              color: const Color(0xFF0A0A0A),
              child: const Center(
                child: Text('📷', style: TextStyle(fontSize: 80)),
              ),
            ),

            // Top controls
            Positioned(
              top: 14,
              left: 14,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            Positioned(
              top: 14,
              right: 14,
              child: Row(
                children: [
                  IconButton(icon: const Icon(Icons.flash_off, color: Colors.white), onPressed: () {}),
                  IconButton(icon: const Icon(Icons.help_outline, color: Colors.white), onPressed: () {}),
                ],
              ),
            ),

            // Mode heading
            Positioned(
              top: 60,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  Text(
                    _mode == 'diagnose' ? 'Snap a sick leaf' : 'Frame the whole plant',
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'SpaceGrotesk',
                      fontWeight: FontWeight.w600,
                      fontSize: 22,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _mode == 'diagnose' ? 'Get close — fill the frame' : 'AI will identify the species',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // Circular focus ring
            Center(
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withValues(alpha: 0.7), width: 2),
                ),
              ),
            ),

            // Mode tabs
            Positioned(
              bottom: 110,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _ModeTab(label: 'identify', active: _mode == 'identify', onTap: () => setState(() => _mode = 'identify')),
                  const SizedBox(width: 20),
                  _ModeTab(label: 'diagnose', active: _mode == 'diagnose', onTap: () => setState(() => _mode = 'diagnose')),
                ],
              ),
            ),

            // Shutter row
            Positioned(
              bottom: 32,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.photo_library_outlined, color: Colors.white, size: 28),
                    onPressed: _pickGallery,
                  ),
                  GestureDetector(
                    onTap: _shoot,
                    child: Container(
                      width: 68,
                      height: 68,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4),
                      ),
                      child: Container(
                        margin: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                      ),
                    ),
                  ),
                  if (widget.plantId != null)
                    const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.eco_outlined, color: Colors.white),
                        Text('which plant?', style: TextStyle(color: Colors.white, fontSize: 10)),
                      ],
                    )
                  else
                    const SizedBox(width: 48),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModeTab extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _ModeTab({required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color: active ? Colors.white : Colors.white60,
              fontFamily: active ? 'SpaceGrotesk' : 'Inter',
              fontWeight: active ? FontWeight.w600 : FontWeight.normal,
              fontSize: active ? 15 : 12,
            ),
          ),
          if (active)
            Container(height: 2, width: 40, margin: const EdgeInsets.only(top: 2), color: Colors.white),
        ],
      ),
    );
  }
}
