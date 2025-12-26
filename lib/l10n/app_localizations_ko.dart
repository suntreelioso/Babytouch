// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appTitle => '베이비 터치';

  @override
  String get selectAlbum => '앨범 선택';

  @override
  String get permissionRequired => '앨범 접근 권한이 필요합니다';

  @override
  String get grantPermission => '권한 허용';

  @override
  String get noAlbumsFound => '앨범을 찾을 수 없습니다';

  @override
  String get noMediaFound => '미디어를 찾을 수 없습니다';

  @override
  String get allVideos => '모든 비디오';

  @override
  String videosCount(int count) {
    return '$count개의 비디오';
  }

  @override
  String itemsCount(int count) {
    return '$count개의 항목';
  }

  @override
  String get menu => '메뉴';

  @override
  String get changeAlbum => '앨범 변경';

  @override
  String get exitApp => '앱 종료';

  @override
  String get cancel => '취소';

  @override
  String get language => '언어';

  @override
  String get systemDefault => '시스템 기본값';
}
