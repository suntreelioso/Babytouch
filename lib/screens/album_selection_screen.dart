import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:permission_handler/permission_handler.dart';
import '../widgets/album_tile.dart';
import '../l10n/app_localizations.dart';
import 'media_browser_screen.dart';

class AlbumSelectionScreen extends StatefulWidget {
  const AlbumSelectionScreen({super.key});

  @override
  State<AlbumSelectionScreen> createState() => _AlbumSelectionScreenState();
}

class _AlbumSelectionScreenState extends State<AlbumSelectionScreen> {
  List<AssetPathEntity> _albums = [];
  AssetPathEntity? _videoAlbum; // Video-only album
  int _videoCount = 0;
  bool _isLoading = true;
  bool _hasPermission = false;

  @override
  void initState() {
    super.initState();
    _requestPermissionAndLoadAlbums();
  }

  Future<void> _requestPermissionAndLoadAlbums() async {
    // Request album permission
    final PermissionState ps = await PhotoManager.requestPermissionExtend();

    if (ps.isAuth || ps.hasAccess) {
      setState(() {
        _hasPermission = true;
      });
      await _loadAlbums();
    } else {
      // Try using permission_handler
      final status = await Permission.photos.request();
      if (status.isGranted) {
        setState(() {
          _hasPermission = true;
        });
        await _loadAlbums();
      } else {
        setState(() {
          _isLoading = false;
          _hasPermission = false;
        });
      }
    }
  }

  Future<void> _loadAlbums() async {
    // Load common albums (images + videos)
    final List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
      type: RequestType.common,
      filterOption: FilterOptionGroup(
        imageOption: const FilterOption(
          sizeConstraint: SizeConstraint(ignoreSize: true),
        ),
        videoOption: const FilterOption(
          sizeConstraint: SizeConstraint(ignoreSize: true),
        ),
        orders: [
          const OrderOption(type: OrderOptionType.createDate, asc: false),
        ],
      ),
    );

    // Load video-only albums
    final List<AssetPathEntity> videoAlbums =
        await PhotoManager.getAssetPathList(
          type: RequestType.video, // Only videos
          filterOption: FilterOptionGroup(
            videoOption: const FilterOption(
              sizeConstraint: SizeConstraint(ignoreSize: true),
            ),
            orders: [
              const OrderOption(type: OrderOptionType.createDate, asc: false),
            ],
          ),
        );

    // Get video album (usually the first "Recent" contains all videos)
    AssetPathEntity? videoAlbum;
    int videoCount = 0;
    if (videoAlbums.isNotEmpty) {
      videoAlbum = videoAlbums.first;
      videoCount = await videoAlbum.assetCountAsync;
    }

    // Filter out empty albums
    List<AssetPathEntity> nonEmptyAlbums = [];
    for (var album in albums) {
      final count = await album.assetCountAsync;
      if (count > 0) {
        nonEmptyAlbums.add(album);
      }
    }

    setState(() {
      _albums = nonEmptyAlbums;
      _videoAlbum = videoAlbum;
      _videoCount = videoCount;
      _isLoading = false;
    });
  }

  void _onAlbumSelected(AssetPathEntity album, {bool videoOnly = false}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            MediaBrowserScreen(album: album, videoOnly: videoOnly),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          AppLocalizations.of(context)!.selectAlbum,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.purple),
      );
    }

    if (!_hasPermission) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.photo_library, size: 80, color: Colors.white24),
            SizedBox(height: 20),
            Text(
              AppLocalizations.of(context)!.permissionRequired,
              style: const TextStyle(color: Colors.white54, fontSize: 18),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _requestPermissionAndLoadAlbums,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 15,
                ),
              ),
              child: Text(
                AppLocalizations.of(context)!.grantPermission,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      );
    }

    if (_albums.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.photo_album_outlined, size: 80, color: Colors.white24),
            SizedBox(height: 20),
            Text(
              AppLocalizations.of(context)!.noAlbumsFound,
              style: const TextStyle(color: Colors.white54, fontSize: 18),
            ),
          ],
        ),
      );
    }

    // Calculate total items (Video option + Albums)
    final int totalItems =
        (_videoAlbum != null && _videoCount > 0 ? 1 : 0) + _albums.length;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.0,
        ),
        itemCount: totalItems,
        itemBuilder: (context, index) {
          // First item is the video option (if videos present)
          if (_videoAlbum != null && _videoCount > 0 && index == 0) {
            return AlbumTile(
              album: _videoAlbum!,
              isVideoOnly: true,
              itemCount: _videoCount,
              onTap: () => _onAlbumSelected(_videoAlbum!, videoOnly: true),
            );
          }

          // Adjust index (if video option present, albums start from index-1)
          final albumIndex = (_videoAlbum != null && _videoCount > 0)
              ? index - 1
              : index;
          return AlbumTile(
            album: _albums[albumIndex],
            onTap: () => _onAlbumSelected(_albums[albumIndex]),
          );
        },
      ),
    );
  }
}
