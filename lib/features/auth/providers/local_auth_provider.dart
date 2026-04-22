import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../../../core/api/device_id.dart';

/// F0 會員登入暫緩期間，使用者點「匿名試用」後我們不打 Firebase，
/// 而是把選擇本地持久化到 Hive，並 pre-warm 一個 device-id；
/// 後續所有 API 由 [DeviceIdInterceptor] 自動帶上 `X-Device-Id`，
/// 後端的 `DeviceIdFilter` 會解析成 `anon:<uuid>` principal。
///
/// router.dart 會把這個值跟 `firebaseAuth.currentUser` 一起當作
/// 「已登入」判斷，避免 redirect loop。
class LocalAuthNotifier extends StateNotifier<bool> {
  LocalAuthNotifier(this._deviceIdService) : super(false) {
    _restore();
  }

  static const String _kBoxName = 'app';
  static const String _kKey = 'local_auth_anonymous';

  final DeviceIdService _deviceIdService;

  Future<void> _restore() async {
    try {
      final box = await Hive.openBox(_kBoxName);
      state = (box.get(_kKey) as bool?) ?? false;
    } catch (_) {
      state = false;
    }
  }

  /// 點「先逛逛再說（匿名試用）」時呼叫；
  /// 1) 確保 device-id 已存在（之後 Dio interceptor 會帶上）
  /// 2) 在 Hive 標記匿名模式為 true
  Future<void> enableAnonymous() async {
    await _deviceIdService.getOrCreate();
    final box = await Hive.openBox(_kBoxName);
    await box.put(_kKey, true);
    state = true;
  }

  /// 登出：同時清掉匿名旗標。
  /// （device-id 保留，下次重新進入仍是同一個 anon:<uuid>）
  Future<void> clear() async {
    final box = await Hive.openBox(_kBoxName);
    await box.delete(_kKey);
    state = false;
  }
}

final localAuthProvider =
    StateNotifierProvider<LocalAuthNotifier, bool>((ref) {
  return LocalAuthNotifier(ref.read(deviceIdServiceProvider));
});
