import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';

import '../../../theme/app_theme.dart';

class CameraScreen extends StatefulWidget {
  final String title;
  final String subtitle;
  final bool showPoseGuide;
  final Function(XFile) onImageCaptured;

  const CameraScreen({
    super.key,
    this.title = 'Take Your Photo',
    this.subtitle = 'Position yourself in the frame',
    this.showPoseGuide = true,
    required this.onImageCaptured,
  });

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen>
    with WidgetsBindingObserver {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  bool _isInitialized = false;
  bool _isFrontCamera = true;
  bool _isFlashOn = false;
  bool _isCapturing = false;
  int _timerSeconds = 0;
  Timer? _countdownTimer;
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _countdownTimer?.cancel();
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_controller == null || !_controller!.value.isInitialized) return;

    if (state == AppLifecycleState.inactive) {
      _controller?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('No cameras available')));
        }
        return;
      }

      final camera = _isFrontCamera
          ? _cameras.firstWhere(
              (c) => c.lensDirection == CameraLensDirection.front,
              orElse: () => _cameras.first,
            )
          : _cameras.firstWhere(
              (c) => c.lensDirection == CameraLensDirection.back,
              orElse: () => _cameras.first,
            );

      _controller = CameraController(
        camera,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await _controller!.initialize();

      if (mounted) {
        setState(() => _isInitialized = true);
      }
    } catch (e) {
      debugPrint('Camera initialization error: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Camera error: $e')));
      }
    }
  }

  Future<void> _switchCamera() async {
    setState(() {
      _isFrontCamera = !_isFrontCamera;
      _isInitialized = false;
    });
    await _controller?.dispose();
    await _initializeCamera();
  }

  Future<void> _toggleFlash() async {
    if (_controller == null) return;

    try {
      _isFlashOn = !_isFlashOn;
      await _controller!.setFlashMode(
        _isFlashOn ? FlashMode.torch : FlashMode.off,
      );
      setState(() {});
    } catch (e) {
      debugPrint('Flash toggle error: $e');
    }
  }

  Future<void> _capturePhoto() async {
    if (_controller == null ||
        !_controller!.value.isInitialized ||
        _isCapturing) {
      return;
    }

    setState(() => _isCapturing = true);

    try {
      // Haptic feedback
      HapticFeedback.mediumImpact();

      final image = await _controller!.takePicture();

      if (mounted) {
        widget.onImageCaptured(image);
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint('Capture error: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to capture: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isCapturing = false);
      }
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (image != null && mounted) {
        widget.onImageCaptured(image);
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint('Gallery pick error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Camera preview
          if (_isInitialized && _controller != null)
            Center(
              child: AspectRatio(
                aspectRatio: 1 / _controller!.value.aspectRatio,
                child: CameraPreview(_controller!),
              ),
            )
          else
            const Center(
              child: CircularProgressIndicator(color: AppTheme.neonCyan),
            ),

          // Pose guide overlay
          if (widget.showPoseGuide && _isInitialized) _buildPoseGuide(),

          // Timer overlay
          if (_timerSeconds > 0)
            Center(
              child:
                  Text(
                    '$_timerSeconds',
                    style: const TextStyle(
                      fontSize: 120,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(color: AppTheme.neonCyan, blurRadius: 30),
                      ],
                    ),
                  ).animate().scale(
                    begin: const Offset(1.5, 1.5),
                    end: const Offset(1, 1),
                    duration: 300.ms,
                  ),
            ),

          // Top bar
          _buildTopBar(),

          // Bottom controls
          _buildBottomControls(),

          // Instructions
          _buildInstructions(),
        ],
      ),
    );
  }

  Widget _buildPoseGuide() {
    return Center(
      child:
          Container(
                width: MediaQuery.of(context).size.width * 0.7,
                height: MediaQuery.of(context).size.height * 0.7,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppTheme.neonCyan.withOpacity(0.5),
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Stack(
                  children: [
                    // Human silhouette guide
                    Center(
                      child: CustomPaint(
                        size: Size(
                          MediaQuery.of(context).size.width * 0.5,
                          MediaQuery.of(context).size.height * 0.6,
                        ),
                        painter: _PoseGuidePainter(),
                      ),
                    ),
                    // Corner markers
                    ..._buildCornerMarkers(),
                  ],
                ),
              )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .custom(
                duration: 2.seconds,
                builder: (context, value, child) {
                  return Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppTheme.neonCyan.withOpacity(0.3 + value * 0.3),
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.neonCyan.withOpacity(
                            0.1 + value * 0.1,
                          ),
                          blurRadius: 20,
                          spreadRadius: -5,
                        ),
                      ],
                    ),
                    child: child,
                  );
                },
              ),
    );
  }

  List<Widget> _buildCornerMarkers() {
    const markerSize = 20.0;
    const color = AppTheme.neonCyan;

    return [
      // Top left
      Positioned(
        top: 0,
        left: 0,
        child: _buildCornerMarker(color, markerSize, true, true),
      ),
      // Top right
      Positioned(
        top: 0,
        right: 0,
        child: _buildCornerMarker(color, markerSize, true, false),
      ),
      // Bottom left
      Positioned(
        bottom: 0,
        left: 0,
        child: _buildCornerMarker(color, markerSize, false, true),
      ),
      // Bottom right
      Positioned(
        bottom: 0,
        right: 0,
        child: _buildCornerMarker(color, markerSize, false, false),
      ),
    ];
  }

  Widget _buildCornerMarker(Color color, double size, bool isTop, bool isLeft) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _CornerMarkerPainter(
          color: color,
          isTop: isTop,
          isLeft: isLeft,
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.black.withOpacity(0.7), Colors.transparent],
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Close button
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 24),
                ),
              ),
              // Title
              Column(
                children: [
                  Text(
                    widget.title,
                    style: AppTheme.titleMedium.copyWith(color: Colors.white),
                  ),
                  Text(
                    widget.subtitle,
                    style: AppTheme.bodySmall.copyWith(
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
              // Flash toggle
              IconButton(
                onPressed: _toggleFlash,
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _isFlashOn
                        ? AppTheme.neonCyan.withOpacity(0.3)
                        : Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                    border: _isFlashOn
                        ? Border.all(color: AppTheme.neonCyan, width: 1)
                        : null,
                  ),
                  child: Icon(
                    _isFlashOn ? Icons.flash_on : Icons.flash_off,
                    color: _isFlashOn ? AppTheme.neonCyan : Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomControls() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [Colors.black.withOpacity(0.8), Colors.transparent],
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Gallery button
              _buildControlButton(
                icon: Icons.photo_library_outlined,
                label: 'Gallery',
                onTap: _pickFromGallery,
              ),

              // Capture button
              GestureDetector(
                    onTap: _timerSeconds > 0 ? null : _capturePhoto,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.neonCyan.withOpacity(0.5),
                            blurRadius: 20,
                            spreadRadius: -5,
                          ),
                        ],
                      ),
                      child: Container(
                        margin: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _isCapturing
                              ? AppTheme.neonCyan
                              : Colors.white.withOpacity(0.9),
                        ),
                        child: _isCapturing
                            ? const Center(
                                child: SizedBox(
                                  width: 30,
                                  height: 30,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 3,
                                  ),
                                ),
                              )
                            : null,
                      ),
                    ),
                  )
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .custom(
                    duration: 1500.ms,
                    builder: (context, value, child) {
                      return Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.neonCyan.withOpacity(
                                0.3 + value * 0.2,
                              ),
                              blurRadius: 25 + value * 10,
                              spreadRadius: -5,
                            ),
                          ],
                        ),
                        child: child,
                      );
                    },
                  ),

              // Switch camera button
              _buildControlButton(
                icon: Icons.flip_camera_ios_outlined,
                label: 'Flip',
                onTap: _switchCamera,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: AppTheme.labelMedium.copyWith(
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructions() {
    return Positioned(
      bottom: 160,
      left: 24,
      right: 24,
      child:
          Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.neonCyan.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.tips_and_updates_outlined,
                      color: AppTheme.neonCyan,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Stand in the frame for the best results',
                        style: AppTheme.bodySmall.copyWith(
                          color: Colors.white.withOpacity(0.9),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              )
              .animate()
              .fadeIn(delay: 500.ms, duration: 400.ms)
              .slideY(begin: 0.2, end: 0),
    );
  }
}

/// Custom painter for human silhouette pose guide
class _PoseGuidePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.neonCyan.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final centerX = size.width / 2;

    // Head
    final headRadius = size.width * 0.12;
    final headCenterY = size.height * 0.08;
    canvas.drawCircle(Offset(centerX, headCenterY), headRadius, paint);

    // Neck
    final neckTop = headCenterY + headRadius;
    final neckBottom = size.height * 0.15;
    canvas.drawLine(
      Offset(centerX, neckTop),
      Offset(centerX, neckBottom),
      paint,
    );

    // Shoulders
    final shoulderY = neckBottom;
    final shoulderWidth = size.width * 0.4;
    canvas.drawLine(
      Offset(centerX - shoulderWidth / 2, shoulderY),
      Offset(centerX + shoulderWidth / 2, shoulderY),
      paint,
    );

    // Body/Torso
    final bodyTop = shoulderY;
    final bodyBottom = size.height * 0.45;
    final bodyWidth = size.width * 0.3;

    // Left body line
    canvas.drawLine(
      Offset(centerX - shoulderWidth / 2, bodyTop),
      Offset(centerX - bodyWidth / 2, bodyBottom),
      paint,
    );
    // Right body line
    canvas.drawLine(
      Offset(centerX + shoulderWidth / 2, bodyTop),
      Offset(centerX + bodyWidth / 2, bodyBottom),
      paint,
    );
    // Hip line
    canvas.drawLine(
      Offset(centerX - bodyWidth / 2, bodyBottom),
      Offset(centerX + bodyWidth / 2, bodyBottom),
      paint,
    );

    // Arms
    final armLength = size.height * 0.25;
    // Left arm
    canvas.drawLine(
      Offset(centerX - shoulderWidth / 2, shoulderY),
      Offset(
        centerX - shoulderWidth / 2 - size.width * 0.05,
        shoulderY + armLength,
      ),
      paint,
    );
    // Right arm
    canvas.drawLine(
      Offset(centerX + shoulderWidth / 2, shoulderY),
      Offset(
        centerX + shoulderWidth / 2 + size.width * 0.05,
        shoulderY + armLength,
      ),
      paint,
    );

    // Legs
    final legTop = bodyBottom;
    final legBottom = size.height * 0.95;
    final legSpread = size.width * 0.15;

    // Left leg
    canvas.drawLine(
      Offset(centerX - bodyWidth / 4, legTop),
      Offset(centerX - legSpread, legBottom),
      paint,
    );
    // Right leg
    canvas.drawLine(
      Offset(centerX + bodyWidth / 4, legTop),
      Offset(centerX + legSpread, legBottom),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Custom painter for corner markers
class _CornerMarkerPainter extends CustomPainter {
  final Color color;
  final bool isTop;
  final bool isLeft;

  _CornerMarkerPainter({
    required this.color,
    required this.isTop,
    required this.isLeft,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final path = Path();

    if (isTop && isLeft) {
      path.moveTo(0, size.height);
      path.lineTo(0, 0);
      path.lineTo(size.width, 0);
    } else if (isTop && !isLeft) {
      path.moveTo(0, 0);
      path.lineTo(size.width, 0);
      path.lineTo(size.width, size.height);
    } else if (!isTop && isLeft) {
      path.moveTo(0, 0);
      path.lineTo(0, size.height);
      path.lineTo(size.width, size.height);
    } else {
      path.moveTo(0, size.height);
      path.lineTo(size.width, size.height);
      path.lineTo(size.width, 0);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
