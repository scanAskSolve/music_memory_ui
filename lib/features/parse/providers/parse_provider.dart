import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/models/parse_result.dart';

final parseControllerProvider =
    StateNotifierProvider<ParseController, ParseState>((ref) {
  return ParseController(ref);
});

class ParseState {
  final bool isLoading;
  final bool isSaving;
  final bool isSaved;
  final ParseResult? result;
  final String? error;

  const ParseState({
    this.isLoading = false,
    this.isSaving = false,
    this.isSaved = false,
    this.result,
    this.error,
  });

  ParseState copyWith({
    bool? isLoading,
    bool? isSaving,
    bool? isSaved,
    ParseResult? result,
    String? error,
  }) {
    return ParseState(
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      isSaved: isSaved ?? false,
      result: result ?? this.result,
      error: error,
    );
  }
}

class ParseController extends StateNotifier<ParseState> {
  final Ref _ref;

  ParseController(this._ref) : super(const ParseState());

  ApiClient get _apiClient => _ref.read(apiClientProvider);

  Future<void> parseUrl(String url) async {
    state = const ParseState(isLoading: true);
    try {
      final response = await _apiClient.post(
        ApiEndpoints.musicParse,
        data: {'url': url},
      );
      final result =
          ParseResult.fromJson(response.data['data'] as Map<String, dynamic>);
      state = ParseState(result: result);
    } catch (e) {
      state = ParseState(error: '解析失敗，請確認網址是否正確: $e');
    }
  }

  void toggleCover(bool isCover) {
    if (state.result == null) return;
    state = state.copyWith(result: state.result!.copyWith(isCover: isCover));
  }

  void updateArtist(String newArtist) {
    if (state.result == null) return;
    state = state.copyWith(result: state.result!.copyWith(artist: newArtist));
  }

  Future<void> saveMusic() async {
    if (state.result == null) return;
    state = state.copyWith(isSaving: true);
    try {
      await _apiClient.post(
        ApiEndpoints.musicSave,
        data: state.result!.toJson(),
      );
      state = const ParseState(isSaved: true);
    } catch (e) {
      state = state.copyWith(isSaving: false, error: '儲存失敗: $e');
    }
  }
}
