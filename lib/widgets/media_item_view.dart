import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:video_player/video_player.dart';
import 'package:palette_generator/palette_generator.dart';

class MediaItemView extends StatefulWidget {
  final AssetEntity asset;
  final bool isPlaying;

  const MediaItemView({
    super.key,
    required this.asset,
    required this.isPlaying,
  });

  @override
  State<MediaItemView> createState() => _MediaItemViewState();
}

class _MediaItemViewState extends State<MediaItemView> {
  VideoPlayerController? _videoController;
  bool _isVideo = false;
  bool _isVideoInitialized = false;
  ImageProvider? _imageProvider;
  ImageProvider? _thumbnailProvider;
  Color _dominantColor = Colors.black;
  Color _secondaryColor = Colors.black;

  @override
  void initState() {
    super.initState();
    _isVideo = widget.asset.type == AssetType.video;
    _loadThumbnailAndColors();
    if (_isVideo) {
      _initVideo();
    } else {
      _loadImage();
    }
  }

  /// Load thumbnail and extract dominant colors
  Future<void> _loadThumbnailAndColors() async {
    try {
      // 获取缩略图用于提取颜色
      final thumbData = await widget.asset.thumbnailDataWithSize(
        const ThumbnailSize(100, 100),
      );
      if (thumbData != null && mounted) {
        final thumbnailProvider = MemoryImage(thumbData);

        // Using PaletteGenerator to extract colors
        final paletteGenerator = await PaletteGenerator.fromImageProvider(
          thumbnailProvider,
          maximumColorCount: 16,
        );

        if (mounted) {
          setState(() {
            _thumbnailProvider = thumbnailProvider;
            // Get dominant color, fallback to dark muted
            _dominantColor =
                paletteGenerator.dominantColor?.color ??
                paletteGenerator.darkMutedColor?.color ??
                Colors.grey[900]!;
            // Get secondary color for gradient
            _secondaryColor =
                paletteGenerator.darkVibrantColor?.color ??
                paletteGenerator.darkMutedColor?.color ??
                _dominantColor.withValues(alpha: 0.8);
          });
        }
      }
    } catch (e) {
      // If extraction fails, keep default black background
      debugPrint('Failed to extract colors: $e');
    }
  }

  Future<void> _loadImage() async {
    final file = await widget.asset.file;
    if (file != null && mounted) {
      setState(() {
        _imageProvider = FileImage(file);
      });
    }
  }

  Future<void> _initVideo() async {
    final file = await widget.asset.file;
    if (file != null && mounted) {
      _videoController = VideoPlayerController.file(file);

      await _videoController!.initialize();

      // Force volume to 50%
      await _videoController!.setVolume(0.5);
      await _videoController!.setLooping(true);

      if (widget.isPlaying) {
        await _videoController!.play();
      }

      if (mounted) {
        setState(() {
          _isVideoInitialized = true;
        });
      }
    }
  }

  @override
  void didUpdateWidget(covariant MediaItemView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_videoController != null && _isVideoInitialized) {
      if (widget.isPlaying && !oldWidget.isPlaying) {
        _videoController!.play();
      } else if (!widget.isPlaying && oldWidget.isPlaying) {
        _videoController!.pause();
      }
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  /// Build dynamic background
  Widget _buildDynamicBackground() {
    return Stack(
      fit: StackFit.expand,
      children: [
        // 渐变背景色
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                _dominantColor,
                _secondaryColor,
                _dominantColor.withValues(alpha: 0.9),
              ],
            ),
          ),
        ),
        // Blurred thumbnail background (enhancement)
        if (_thumbnailProvider != null)
          ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
            child: Opacity(
              opacity: 0.5,
              child: Image(
                image: _thumbnailProvider!,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isVideo) {
      if (!_isVideoInitialized || _videoController == null) {
        return Stack(
          fit: StackFit.expand,
          children: [
            _buildDynamicBackground(),
            const Center(
              child: CircularProgressIndicator(color: Colors.white24),
            ),
          ],
        );
      }

      return Stack(
        fit: StackFit.expand,
        children: [
          _buildDynamicBackground(),
          Center(
            child: AspectRatio(
              aspectRatio: _videoController!.value.aspectRatio,
              child: VideoPlayer(_videoController!),
            ),
          ),
        ],
      );
    } else {
      // Image
      if (_imageProvider == null) {
        return Stack(
          fit: StackFit.expand,
          children: [
            _buildDynamicBackground(),
            const Center(
              child: CircularProgressIndicator(color: Colors.white24),
            ),
          ],
        );
      }

      return Stack(
        fit: StackFit.expand,
        children: [
          _buildDynamicBackground(),
          Center(
            child: Image(
              image: _imageProvider!,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.broken_image,
                  color: Colors.white24,
                  size: 64,
                );
              },
            ),
          ),
        ],
      );
    }
  }
}
