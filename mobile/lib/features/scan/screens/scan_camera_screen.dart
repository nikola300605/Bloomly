import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/router/app_router.dart';
import '../providers/scan_provider.dart';

/// Camera / image-picker entry screen for both identify and diagnose modes.
class ScanCameraScreen extends ConsumerStatefulWidget {
  final String mode; // "identify" | "diagnose"
  final String? plantId;

  const ScanCameraScreen({super.key, this.mode = 'identify', this.plantId});

  @override
  ConsumerState<ScanCameraScreen> createState() => _ScanCameraScreenState();
}

class _ScanCameraScreenState extends ConsumerState<ScanCameraScreen> {
  late String _mode;

  /// When set (identify mode only), we show the confirm/preview step.
  String? _previewPath;
  bool _identifying = false;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _mode = widget.mode;
  }

  Future<void> _shoot() async {
    await _pick(ImageSource.camera);
  }

  Future<void> _pickGallery() async {
    await _pick(ImageSource.gallery);
  }

  Future<void> _pick(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final file = await picker.pickImage(source: source, imageQuality: 85);
      if (file != null && mounted) {
        _onPicked(file.path);
      }
    } on PlatformException {
      // Permission denied (or no camera available).
      if (mounted) _showPermissionMessage(source);
    }
  }

  void _onPicked(String path) {
    if (_mode == 'diagnose') {
      // Diagnose flow continues to symptom selection (unchanged).
      context.push(
        AppRoutes.scanSymptoms + (widget.plantId != null ? '?plantId=${widget.plantId}' : ''),
        extra: path,
      );
    } else {
      // Identify flow: show the preview + confirm step.
      setState(() {
        _previewPath = path;
        _failed = false;
      });
    }
  }

  Future<void> _confirmIdentify() async {
    final path = _previewPath;
    if (path == null) return;
    setState(() {
      _identifying = true;
      _failed = false;
    });

    final result = await ref.read(scanProvider.notifier).identify(File(path));
    if (!mounted) return;

    setState(() => _identifying = false);
    if (result != null) {
      // Clear the preview so returning here lands on a fresh camera.
      setState(() => _previewPath = null);
      context.push(AppRoutes.scanResults, extra: {'__scan_result__': result});
    } else {
      setState(() => _failed = true);
    }
  }

  void _retake() {
    setState(() {
      _previewPath = null;
      _failed = false;
    });
  }

  void _showPermissionMessage(ImageSource source) {
    final what = source == ImageSource.camera ? 'camera' : 'photos';
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('${source == ImageSource.camera ? 'Camera' : 'Photo'} access needed'),
        content: Text(
          'To identify plants, allow $what access for Bloomly in your device '
          'Settings, then try again.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: _previewPath != null ? _buildPreview() : _buildCamera(),
      ),
    );
  }

  /// Preview + confirm step shown after an image is selected in identify mode.
  Widget _buildPreview() {
    return Stack(
      children: [
        // Image preview filling most of the screen.
        Positioned.fill(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 64, 16, 120),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: ColorFiltered(
                colorFilter: ColorFilter.mode(
                  Colors.black.withValues(alpha: _identifying ? 0.45 : 0.0),
                  BlendMode.darken,
                ),
                child: Image.file(
                  File(_previewPath!),
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ),

        // Close / back to camera.
        Positioned(
          top: 14,
          left: 14,
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: _identifying ? null : _retake,
          ),
        ),

        // Identifying overlay (spinner over the dimmed image).
        if (_identifying)
          const Positioned.fill(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: Colors.white),
                  SizedBox(height: 16),
                  Text(
                    'Identifying your plant…',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'SpaceGrotesk',
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),

        // Error state with retry.
        if (_failed && !_identifying)
          Positioned(
            left: 24,
            right: 24,
            bottom: 120,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Couldn't identify this plant. Try a clearer photo.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 14),
                ),
              ],
            ),
          ),

        // Bottom action buttons.
        if (!_identifying)
          Positioned(
            bottom: 32,
            left: 24,
            right: 24,
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _retake,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: BorderSide(color: Colors.white.withValues(alpha: 0.6)),
                    ),
                    child: Text(_failed ? 'Try again' : 'Retake'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _confirmIdentify,
                    child: const Text('Identify'),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  /// The original camera viewfinder UI (capture + gallery + mode tabs).
  Widget _buildCamera() {
    return Stack(
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
