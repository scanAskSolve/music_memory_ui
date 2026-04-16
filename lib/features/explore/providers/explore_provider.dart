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
      final response = await _apiClient.get(
        ApiEndpoints.exploreRecommend,
        queryParameters: {'limit': 20},
      );
      final list = response.data['data'] as List<dynamic>? ?? [];
      final cards =
          list.map((e) => Music.fromJson(e as Map<String, dynamic>)).toList();
      state = ExploreState(cards: cards);
    } catch (e) {
      state = ExploreState(error: '載入推薦失敗: $e');
    }
  }

  Future<void> like(Music music) async {
    try {
      await _apiClient.post(
        ApiEndpoints.exploreLike,
        data: {'musicId': music.id},
      );
    } catch (_) {}
    _removeCard(music);
    _checkAndReload();
  }

  Future<void> skip(Music music) async {
    try {
      await _apiClient.post(
        ApiEndpoints.exploreSkip,
        data: {'musicId': music.id},
      );
    } catch (_) {}
    _removeCard(music);
    _checkAndReload();
  }

  Future<void> favorite(Music music) async {
    try {
      await _apiClient.post(
        ApiEndpoints.exploreFavorite,
        data: {'musicId': music.id},
      );
    } catch (_) {}
  }

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
