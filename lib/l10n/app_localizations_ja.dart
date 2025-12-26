// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'ベビータッチ';

  @override
  String get selectAlbum => 'アルバムを選択';

  @override
  String get permissionRequired => 'アルバムへのアクセス権限が必要です';

  @override
  String get grantPermission => '権限を許可';

  @override
  String get noAlbumsFound => 'アルバムが見つかりません';

  @override
  String get noMediaFound => 'メディアが見つかりません';

  @override
  String get allVideos => 'すべてのビデオ';

  @override
  String videosCount(int count) {
    return '$count 個のビデオ';
  }

  @override
  String itemsCount(int count) {
    return '$count 個の項目';
  }

  @override
  String get menu => 'メニュー';

  @override
  String get changeAlbum => 'アルバムを変更';

  @override
  String get exitApp => 'アプリを終了';

  @override
  String get cancel => 'キャンセル';

  @override
  String get language => '言語';

  @override
  String get systemDefault => 'システムデフォルト';
}
