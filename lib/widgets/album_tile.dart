import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import '../l10n/app_localizations.dart';

class AlbumTile extends StatefulWidget {
  final AssetPathEntity album;
  final VoidCallback onTap;
  final bool isVideoOnly;
  final int? itemCount;

  const AlbumTile({
    super.key,
    required this.album,
    required this.onTap,
    this.isVideoOnly = false,
    this.itemCount,
  });

  @override
  State<AlbumTile> createState() => _AlbumTileState();
}

class _AlbumTileState extends State<AlbumTile> {
  Uint8List? _thumbnail;
  int _assetCount = 0;

  @override
  void initState() {
    super.initState();
    _loadThumbnail();
  }

  Future<void> _loadThumbnail() async {
    final count = widget.itemCount ?? await widget.album.assetCountAsync;
    if (count > 0) {
      final assets = await widget.album.getAssetListRange(start: 0, end: 1);
      if (assets.isNotEmpty) {
        final thumb = await assets.first.thumbnailDataWithSize(
          const ThumbnailSize(300, 300),
        );
        if (mounted) {
          setState(() {
            _thumbnail = thumb;
            _assetCount = count;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final displayName = widget.isVideoOnly ? l10n.allVideos : widget.album.name;
    final countText = widget.isVideoOnly
        ? l10n.videosCount(_assetCount)
        : l10n.itemsCount(_assetCount);

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.grey[900],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Thumbnail
            if (_thumbnail != null)
              Image.memory(_thumbnail!, fit: BoxFit.cover)
            else
              Container(
                color: Colors.grey[800],
                child: Icon(
                  widget.isVideoOnly ? Icons.videocam : Icons.photo_library,
                  size: 50,
                  color: Colors.white24,
                ),
              ),
            // Video icon (displayed for video-only section)
            if (widget.isVideoOnly)
              const Center(
                child: Icon(Icons.videocam, size: 50, color: Colors.white70),
              ),
            // Gradient overlay
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.8),
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      displayName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      countText,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
