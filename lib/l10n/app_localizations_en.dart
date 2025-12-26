// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'BabyTouch';

  @override
  String get selectAlbum => 'Select Album';

  @override
  String get permissionRequired => 'Album permission required';

  @override
  String get grantPermission => 'Grant Permission';

  @override
  String get noAlbumsFound => 'No albums found';

  @override
  String get noMediaFound => 'No media found';

  @override
  String get allVideos => 'All Videos';

  @override
  String videosCount(int count) {
    return '$count Videos';
  }

  @override
  String itemsCount(int count) {
    return '$count Items';
  }

  @override
  String get menu => 'Menu';

  @override
  String get changeAlbum => 'Change Album';

  @override
  String get exitApp => 'Exit App';

  @override
  String get cancel => 'Cancel';

  @override
  String get language => 'Language';

  @override
  String get systemDefault => 'System Default';
}
