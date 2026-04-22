import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/models/music.dart';

final exploreControllerProvider =
    StateNotifierProvider<ExploreController, ExploreState>((ref) {
  final controller = ExploreController(ref);
  controller.loadRecommendations();
  return controller;
});

class ExploreState {
  final bool isLoading;
  final List<Music> cards;
  final String? error;

  const ExploreState({
    this.isLoading = false,
    this.cards = const [],
    this.error,
  });

  ExploreState copyWith({
    bool? isLoading,
    List<Music>? cards,
    String? error,
  }) {
    return ExploreState(
      isLoading: isLoading ?? this.isLoading,
      cards: cards ?? this.cards,
      error: error,
    );
  }
}

class ExploreController extends StateNotifier<ExploreState> {
  final Ref _ref;

  ExploreController(this._ref) : super(const ExploreState(isLoading: true));

  ApiClient get _apiClient => _ref.read(apiClientProvider);

  Future<void> loadRecommendations() async {
    state = const ExploreState(isLoading: true);
    try {
      final response = await _apiClient.get(ApiEndpoints.recommendCards);
      final list = response.data['data'] as List<dynamic>? ?? [];
      final cards =
          list.map((e) => Music.fromJson(e as Map<String, dynamic>)).toList();
      state = ExploreState(cards: cards);
    } catch (e) {
      state = ExploreState(error: '載入推薦失敗: $e');
    }
  }

  Future<void> like(Music music) => _swipe(music, SwipeAction.like);
  Future<void> skip(Music music) => _swipe(music, SwipeAction.dislike);
  Future<void> favorite(Music music) => _swipe(music, SwipeAction.love);

  Future<void> _swipe(Music music, String action) async {
    try {
      await _apiClient.post(
        ApiEndpoints.recommendSwipe,
        data: {
          'musicId': _toMusicId(music.id),
          'action': action,
        },
      );
    } catch (_) {
      // 容錯：滑動失敗不阻斷 UI 流程，避免使用者卡關
    }
    if (action != SwipeAction.love) {
      // love 留在卡堆上方便使用者繼續操作；like / dislike 才把卡片移除
      _removeCard(music);
      _checkAndReload();
    }
  }

  /// 後端 [SwipeDTO] 的 `musicId` 是 `Long`，UI 模型則用 `String`，
  /// 這裡集中轉型，未來改 freezed 模型時統一處理。
  int _toMusicId(String id) => int.tryParse(id) ?? 0;

  void _removeCard(Music music) {
    state = state.copyWith(
      cards: state.cards.where((c) => c.id != music.id).toList(),
    );
  }

  void _checkAndReload() {
    if (state.cards.length <= 5) {
      loadRecommendations();
    }
  }
}
