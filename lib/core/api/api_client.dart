import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import 'device_id.dart';

/// 是否啟用會員登入（F0）。現行階段預設關閉；
/// 需要時透過 `flutter run --dart-define=AUTH_ENABLED=true` 開啟。
const bool kAuthEnabled = bool.fromEnvironment(
  'AUTH_ENABLED',
  defaultValue: false,
);

/// API base URL 來源優先序：
///   1. `--dart-define=API_BASE=...`（Web/CI 推薦）
///   2. `.env` 內 `BASE_URL`
///   3. fallback：`http://localhost:8080/api/v1`
const String _kApiBaseFromEnv = String.fromEnvironment(
  'API_BASE',
  defaultValue: '',
);

String resolveApiBaseUrl() {
  if (_kApiBaseFromEnv.isNotEmpty) return _kApiBaseFromEnv;
  final fromDotenv = dotenv.maybeGet('BASE_URL');
  if (fromDotenv != null && fromDotenv.isNotEmpty) return fromDotenv;
  
  // 處理 Android 模擬器無法存取 localhost 的問題
  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
    return 'http://10.0.2.2:8080/api/v1';
  }
  return 'http://localhost:8080/api/v1';
}

final apiClientProvider = Provider<ApiClient>(
  (ref) => ApiClient(deviceIdService: ref.read(deviceIdServiceProvider)),
);

class ApiClient {
  late final Dio _dio;
  final _logger = Logger();

  ApiClient({DeviceIdService? deviceIdService}) {
    _dio = Dio(
      BaseOptions(
        baseUrl: resolveApiBaseUrl(),
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 30),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    _dio.interceptors.add(_logInterceptor());
    _dio.interceptors.add(DeviceIdInterceptor(deviceIdService ?? DeviceIdService()));
    if (kAuthEnabled) {
      _dio.interceptors.add(FirebaseTokenInterceptor());
    }
  }

  Dio get dio => _dio;

  InterceptorsWrapper _logInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) {
        _logger.d('→ ${options.method} ${options.path}');
        handler.next(options);
      },
      onResponse: (response, handler) {
        _logger.d('← ${response.statusCode} ${response.requestOptions.path}');
        handler.next(response);
      },
      onError: (error, handler) {
        _logger.e('✗ ${error.requestOptions.path}', error: error);
        handler.next(error);
      },
    );
  }

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) =>
      _dio.get<T>(path, queryParameters: queryParameters);

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
  }) =>
      _dio.post<T>(path, data: data);

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
  }) =>
      _dio.put<T>(path, data: data);

  Future<Response<T>> delete<T>(String path) => _dio.delete<T>(path);
}

/// Firebase ID Token 注入；僅在 [kAuthEnabled] 為 true 時被掛載。
/// F0 階段（會員登入暫緩）預設不會走到這裡。
class FirebaseTokenInterceptor extends Interceptor {
  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final token = await user.getIdToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
      }
    } catch (_) {
      // Firebase 尚未初始化（例如 F0 暫緩時）就靜默略過
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      try {
        FirebaseAuth.instance.currentUser?.getIdToken(true);
      } catch (_) {/* ignored */}
    }
    handler.next(err);
  }
}
