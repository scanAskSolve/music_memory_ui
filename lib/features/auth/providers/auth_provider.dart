import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../services/firebase_auth_service.dart';
import 'local_auth_provider.dart';

final firebaseAuthServiceProvider = Provider<FirebaseAuthService>(
  (ref) => FirebaseAuthService(),
);

final authStateProvider = StreamProvider<User?>((ref) {
  final authService = ref.watch(firebaseAuthServiceProvider);
  return authService.authStateChanges;
});

final authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController(ref);
});

class AuthState {
  final bool isLoading;
  final String? error;

  const AuthState({this.isLoading = false, this.error});

  AuthState copyWith({bool? isLoading, String? error}) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class AuthController extends StateNotifier<AuthState> {
  final Ref _ref;

  AuthController(this._ref) : super(const AuthState());

  FirebaseAuthService get _authService =>
      _ref.read(firebaseAuthServiceProvider);

  ApiClient get _apiClient => _ref.read(apiClientProvider);

  Future<void> signInWithGoogle() async {
    state = const AuthState(isLoading: true);
    try {
      final credential = await _authService.signInWithGoogle();
      await _syncUserToBackend(credential);
      state = const AuthState();
    } catch (e) {
      state = AuthState(error: '登入失敗: $e');
    }
  }

  Future<void> signInWithApple() async {
    state = const AuthState(isLoading: true);
    try {
      final credential = await _authService.signInWithApple();
      await _syncUserToBackend(credential);
      state = const AuthState();
    } catch (e) {
      state = AuthState(error: '登入失敗: $e');
    }
  }

  Future<void> signInWithFacebook() async {
    state = const AuthState(isLoading: true);
    try {
      final credential = await _authService.signInWithFacebook();
      await _syncUserToBackend(credential);
      state = const AuthState();
    } catch (e) {
      state = AuthState(error: '登入失敗: $e');
    }
  }

  /// F0 暫緩中：匿名試用不打 Firebase（會被無效 API key 拒絕），
  /// 改用本地旗標 + X-Device-Id（由 backend 的 DeviceIdFilter 解析）。
  Future<void> signInAnonymously() async {
    state = const AuthState(isLoading: true);
    try {
      await _ref.read(localAuthProvider.notifier).enableAnonymous();
      state = const AuthState();
    } catch (e) {
      state = AuthState(error: '匿名登入失敗: $e');
    }
  }

  Future<void> signOut() async {
    state = const AuthState(isLoading: true);
    try {
      await _ref.read(localAuthProvider.notifier).clear();
      // Firebase 登出：若使用者其實是匿名模式進來、從沒登入過，
      // 這裡仍 try/catch 包起來避免 placeholder API key 報錯。
      try {
        await _authService.signOut();
      } catch (_) {}
      state = const AuthState();
    } catch (e) {
      state = AuthState(error: '登出失敗: $e');
    }
  }

  Future<void> _syncUserToBackend(UserCredential credential) async {
    try {
      await _apiClient.post(
        ApiEndpoints.authSync,
        data: {
          'uid': credential.user?.uid,
          'displayName': credential.user?.displayName,
          'email': credential.user?.email,
          'photoUrl': credential.user?.photoURL,
          'provider': credential.credential?.providerId,
        },
      );
    } catch (_) {
      // 後端同步失敗不影響登入流程
    }
  }
}
