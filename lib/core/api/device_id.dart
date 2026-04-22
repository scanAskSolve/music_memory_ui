import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

/// F0 會員登入暫緩期間，每個瀏覽器/裝置生成一個穩定的 UUID 並透過
/// `X-Device-Id` header 帶到後端，由 backend 的 `DeviceIdFilter`
/// 映射成 `anon:<uuid>` principal，用於行為記錄與推薦個人化。
class DeviceIdService {
  DeviceIdService({String boxName = _kDefaultBox}) : _boxName = boxName;

  static const String _kDefaultBox = 'app';
  static const String _kKey = 'device_id';

  final String _boxName;
  String? _cached;

  /// 第一次呼叫會生成並寫入 Hive；之後同步回傳快取值。
  Future<String> getOrCreate() async {
    if (_cached != null) return _cached!;
    final box = await Hive.openBox(_boxName);
    final existing = box.get(_kKey) as String?;
    if (existing != null && existing.isNotEmpty) {
      _cached = existing;
      return existing;
    }
    final created = const Uuid().v4();
    await box.put(_kKey, created);
    _cached = created;
    return created;
  }

  /// 主要給測試使用：清掉快取並重新讀取。
  void resetCache() => _cached = null;
}

final deviceIdServiceProvider = Provider<DeviceIdService>(
  (_) => DeviceIdService(),
);

/// Dio interceptor：在每個 request 加上 `X-Device-Id`。
///
/// 第一次的 onRequest 會 await Hive，之後直接從快取讀取，幾乎零成本。
class DeviceIdInterceptor extends Interceptor {
  DeviceIdInterceptor(this._service);

  static const String headerName = 'X-Device-Id';

  final DeviceIdService _service;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      final id = await _service.getOrCreate();
      options.headers[headerName] = id;
    } catch (_) {
      // Hive 尚未初始化或寫入失敗 → 不阻斷請求，後端會 fallback 為 anon:guest
    }
    handler.next(options);
  }
}
