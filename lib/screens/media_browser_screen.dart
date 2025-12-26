import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:provider/provider.dart';
import '../widgets/media_item_view.dart';
import '../l10n/app_localizations.dart';
import '../providers/locale_provider.dart';

class MediaBrowserScreen extends StatefulWidget {
  final AssetPathEntity album;
  final bool videoOnly;

  const MediaBrowserScreen({
    super.key,
    required this.album,
    this.videoOnly = false,
  });

  @override
  State<MediaBrowserScreen> createState() => _MediaBrowserScreenState();
}

class _MediaBrowserScreenState extends State<MediaBrowserScreen> {
  List<AssetEntity> _mediaList = [];
  int _currentIndex = 0;
  bool _isLoading = true;
  late PageController _pageController;

  // Menu state
  bool _showExitDialog = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
    _enterImmersiveMode();
    _loadMedia();
  }

  /// Enter immersive full-screen mode
  void _enterImmersiveMode() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.immersiveSticky,
      overlays: [],
    );
  }

  /// Exit immersive mode
  void _exitImmersiveMode() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
      overlays: SystemUiOverlay.values,
    );
  }

  /// Load media from album
  Future<void> _loadMedia() async {
    final count = await widget.album.assetCountAsync;
    if (count > 0) {
      final List<AssetEntity> media = await widget.album.getAssetListRange(
        start: 0,
        end: count,
      );
      setState(() {
        _mediaList = media;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Show sequence for selecting language
  void _showLanguageDialog() {
    final l10n = AppLocalizations.of(context)!;
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(l10n.language, style: const TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(
                l10n.systemDefault,
                style: const TextStyle(color: Colors.white),
              ),
              onTap: () {
                localeProvider.clearLocale();
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              title: const Text(
                'English',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                localeProvider.setLocale(const Locale('en'));
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              title: const Text('简体中文', style: TextStyle(color: Colors.white)),
              onTap: () {
                localeProvider.setLocale(const Locale('zh'));
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              title: const Text('繁體中文', style: TextStyle(color: Colors.white)),
              onTap: () {
                localeProvider.setLocale(const Locale('zh', 'Hant'));
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              title: const Text('日本語', style: TextStyle(color: Colors.white)),
              onTap: () {
                localeProvider.setLocale(const Locale('ja'));
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              title: const Text('한국어', style: TextStyle(color: Colors.white)),
              onTap: () {
                localeProvider.setLocale(const Locale('ko'));
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Show exit menu
  void _showExitMenu() {
    if (_showExitDialog) return;
    setState(() {
      _showExitDialog = true;
    });

    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(l10n.menu, style: const TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_album, color: Colors.purple),
              title: Text(
                l10n.changeAlbum,
                style: const TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.of(context).pop();
                _exitImmersiveMode();
                Navigator.of(this.context).pop();
              },
            ),
            ListTile(
              leading: const Icon(Icons.language, color: Colors.blue),
              title: Text(
                l10n.language,
                style: const TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.of(context).pop();
                _showLanguageDialog();
              },
            ),
            ListTile(
              leading: const Icon(Icons.exit_to_app, color: Colors.red),
              title: Text(
                l10n.exitApp,
                style: const TextStyle(color: Colors.white),
              ),
              onTap: () {
                SystemNavigator.pop();
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _showExitDialog = false;
              });
            },
            child: Text(l10n.cancel),
          ),
        ],
      ),
    ).then((_) {
      setState(() {
        _showExitDialog = false;
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Intercept back button
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        // Do nothing to prevent popping
      },
      child: Scaffold(backgroundColor: Colors.black, body: _buildContent()),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    if (_mediaList.isEmpty) {
      return Center(
        child: Text(
          AppLocalizations.of(context)!.noMediaFound,
          style: const TextStyle(color: Colors.white54, fontSize: 16),
        ),
      );
    }

    return Stack(
      children: [
        // Media content - TikTok style vertical scrolling
        PageView.builder(
          scrollDirection: Axis.vertical,
          controller: _pageController,
          itemCount: _mediaList.length,
          onPageChanged: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          itemBuilder: (context, index) {
            final asset = _mediaList[index];
            return MediaItemView(
              key: ValueKey(asset.id),
              asset: asset,
              isPlaying: index == _currentIndex,
            );
          },
        ),
        // Top right menu button
        Positioned(
          right: 16,
          top: 16,
          child: GestureDetector(
            onTap: _showExitMenu,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.more_vert,
                color: Colors.white70,
                size: 28,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
