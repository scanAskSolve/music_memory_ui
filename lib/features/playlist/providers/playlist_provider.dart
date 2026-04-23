import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/models/music.dart';

enum SortType { releaseDate, createdAt, playCount, aiCategory, isCover }

enum FilterType { all, original, cover, favorite }

final playlistControllerProvider =
    StateNotifierProvider<PlaylistController, PlaylistState>((ref) {
  final controller = PlaylistController(ref);
  controller.loadPlaylist();
  return controller;
});

class PlaylistState {
  final bool isLoading;
  final List<Music> musicList;
  final SortType sort;
  final bool ascending;
  final FilterType filter;
  final String? error;

  const PlaylistState({
    this.isLoading = false,
    this.musicList = const [],
    this.sort = SortType.createdAt,
    this.ascending = false,
    this.filter = FilterType.all,
    this.error,
  });

  PlaylistState copyWith({
    bool? isLoading,
    List<Music>? musicList,
    SortType? sort,
    bool? ascending,
    FilterType? filter,
    String? error,
  }) {
    return PlaylistState(
      isLoading: isLoading ?? this.isLoading,
      musicList: musicList ?? this.musicList,
      sort: sort ?? this.sort,
      ascending: ascending ?? this.ascending,
      filter: filter ?? this.filter,
      error: error,
    );
  }
}

class PlaylistController extends StateNotifier<PlaylistState> {
  final Ref _ref;
  List<Music> _allMusic = [];

  PlaylistController(this._ref) : super(const PlaylistState(isLoading: true));

  ApiClient get _apiClient => _ref.read(apiClientProvider);

  Future<void> loadPlaylist() async {
    state = state.copyWith(isLoading: true);
    try {
      final response = await _apiClient.get(ApiEndpoints.musicList);
      final responseData = response.data['data'];
      final list = (responseData != null && responseData['records'] != null)
          ? responseData['records'] as List<dynamic>
          : [];
      _allMusic =
          list.map((e) => Music.fromJson(e as Map<String, dynamic>)).toList();
      state = state.copyWith(isLoading: false, musicList: _applyFilter());
    } catch (e) {
      state = state.copyWith(isLoading: false, error: '載入清單失敗: $e');
    }
  }

  void sortBy(SortType type) {
    final ascending = state.sort == type ? !state.ascending : false;
    state = state.copyWith(sort: type, ascending: ascending);
    _applySortAndFilter();
  }

  void filterBy(FilterType filter) {
    state = state.copyWith(filter: filter);
    _applySortAndFilter();
  }

  void _applySortAndFilter() {
    final filtered = _applyFilter();
    state = state.copyWith(musicList: filtered);
  }

  List<Music> _applyFilter() {
    var list = List<Music>.from(_allMusic);

    switch (state.filter) {
      case FilterType.original:
        list = list.where((m) => !m.isCover).toList();
        break;
      case FilterType.cover:
        list = list.where((m) => m.isCover).toList();
        break;
      case FilterType.favorite:
        list = list.where((m) => m.isFavorite).toList();
        break;
      case FilterType.all:
        break;
    }

    list.sort((a, b) {
      int cmp;
      switch (state.sort) {
        case SortType.releaseDate:
          cmp = (a.releaseDate ?? DateTime(2000))
              .compareTo(b.releaseDate ?? DateTime(2000));
          break;
        case SortType.createdAt:
          cmp = a.createdAt.compareTo(b.createdAt);
          break;
        case SortType.playCount:
          cmp = a.playCount.compareTo(b.playCount);
          break;
        case SortType.aiCategory:
          cmp = (a.aiCategory ?? '').compareTo(b.aiCategory ?? '');
          break;
        case SortType.isCover:
          cmp = a.isCover == b.isCover ? 0 : (a.isCover ? 1 : -1);
          break;
      }
      return state.ascending ? cmp : -cmp;
    });

    return list;
  }

  Future<void> deleteMultiple(List<String> ids) async {
    for (final id in ids) {
      final numeric = int.tryParse(id);
      if (numeric == null) continue;
      try {
        await _apiClient.delete(ApiEndpoints.musicDelete(numeric));
      } catch (_) {}
    }
    _allMusic = _allMusic.where((m) => !ids.contains(m.id)).toList();
    _applySortAndFilter();
  }
}
