// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => '幼教触控';

  @override
  String get selectAlbum => '选择相册';

  @override
  String get permissionRequired => '需要相册访问权限';

  @override
  String get grantPermission => '授予权限';

  @override
  String get noAlbumsFound => '未找到相册';

  @override
  String get noMediaFound => '未找到媒体文件';

  @override
  String get allVideos => '所有视频';

  @override
  String videosCount(int count) {
    return '$count 个视频';
  }

  @override
  String itemsCount(int count) {
    return '$count 个项目';
  }

  @override
  String get menu => '菜单';

  @override
  String get changeAlbum => '更改相册';

  @override
  String get exitApp => '退出应用';

  @override
  String get cancel => '取消';

  @override
  String get language => '语言';

  @override
  String get systemDefault => '系统默认';
}

/// The translations for Chinese, using the Han script (`zh_Hant`).
class AppLocalizationsZhHant extends AppLocalizationsZh {
  AppLocalizationsZhHant() : super('zh_Hant');

  @override
  String get appTitle => '幼教觸控';

  @override
  String get selectAlbum => '選擇相簿';

  @override
  String get permissionRequired => '需要相簿存取權限';

  @override
  String get grantPermission => '授予權限';

  @override
  String get noAlbumsFound => '未找到相簿';

  @override
  String get noMediaFound => '未找到媒體檔案';

  @override
  String get allVideos => '所有影片';

  @override
  String videosCount(int count) {
    return '$count 個影片';
  }

  @override
  String itemsCount(int count) {
    return '$count 個項目';
  }

  @override
  String get menu => '菜單';

  @override
  String get changeAlbum => '更改相簿';

  @override
  String get exitApp => '退出應用';

  @override
  String get cancel => '取消';

  @override
  String get language => '語言';

  @override
  String get systemDefault => '系統預設';
}
