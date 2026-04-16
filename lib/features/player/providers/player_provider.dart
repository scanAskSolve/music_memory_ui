import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/music.dart';

enum RepeatMode { off, all, one }

class LyricLine {
  final Duration time;
  final String text;

  const LyricLine({required this.time, required this.text});
}

final playerControllerProvider =
    StateNotifierProvider<PlayerController, PlayerState>((ref) {
  return PlayerController();
});

class PlayerState {
  final Music? currentMusic;
  final bool isPlaying;
  final Duration position;
  final Duration duration;
  final bool isShuffle;
  final RepeatMode repeatMode;
  final List<LyricLine> lyrics;
  final int currentLyricIndex;
  final List<Music> queue;

  const PlayerState({
    this.currentMusic,
    this.isPlaying = false,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.isShuffle = false,
    this.repeatMode = RepeatMode.off,
    this.lyrics = const [],
    this.currentLyricIndex = 0,
    this.queue = const [],
  });

  PlayerState copyWith({
    Music? currentMusic,
    bool? isPlaying,
    Duration? position,
    Duration? duration,
    bool? isShuffle,
    RepeatMode? repeatMode,
    List<LyricLine>? lyrics,
    int? currentLyricIndex,
    List<Music>? queue,
  }) {
    return PlayerState(
      currentMusic: currentMusic ?? this.currentMusic,
      isPlaying: isPlaying ?? this.isPlaying,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      isShuffle: isShuffle ?? this.isShuffle,
      repeatMode: repeatMode ?? this.repeatMode,
      lyrics: lyrics ?? this.lyrics,
      currentLyricIndex: currentLyricIndex ?? this.currentLyricIndex,
      queue: queue ?? this.queue,
    );
  }
}

class PlayerController extends StateNotifier<PlayerState> {
  PlayerController() : super(const PlayerState());

  // TODO: 整合 just_audio 實際播放邏輯
  // 目前提供 UI 狀態管理框架

  void play(Music music) {
    state = state.copyWith(
      currentMusic: music,
      isPlaying: true,
      position: Duration.zero,
      duration: music.duration,
    );
  }

  void togglePlayPause() {
    state = state.copyWith(isPlaying: !state.isPlaying);
  }

  void pause() {
    state = state.copyWith(isPlaying: false);
  }

  void resume() {
    state = state.copyWith(isPlaying: true);
  }

  void seek(Duration position) {
    state = state.copyWith(position: position);
  }

  void next() {
    if (state.queue.isEmpty) return;
    final currentIdx = state.queue.indexWhere(
      (m) => m.id == state.currentMusic?.id,
    );
    final nextIdx = (currentIdx + 1) % state.queue.length;
    play(state.queue[nextIdx]);
  }

  void previous() {
    if (state.queue.isEmpty) return;
    final currentIdx = state.queue.indexWhere(
      (m) => m.id == state.currentMusic?.id,
    );
    final prevIdx =
        (currentIdx - 1 + state.queue.length) % state.queue.length;
    play(state.queue[prevIdx]);
  }

  void toggleShuffle() {
    state = state.copyWith(isShuffle: !state.isShuffle);
  }

  void toggleRepeat() {
    final modes = RepeatMode.values;
    final nextIdx = (state.repeatMode.index + 1) % modes.length;
    state = state.copyWith(repeatMode: modes[nextIdx]);
  }

  void setQueue(List<Music> queue) {
    state = state.copyWith(queue: queue);
  }

  void updatePosition(Duration position) {
    state = state.copyWith(position: position);
    _updateCurrentLyricIndex();
  }

  void setLyrics(List<LyricLine> lyrics) {
    state = state.copyWith(lyrics: lyrics);
  }

  void _updateCurrentLyricIndex() {
    if (state.lyrics.isEmpty) return;
    int idx = 0;
    for (int i = 0; i < state.lyrics.length; i++) {
      if (state.lyrics[i].time <= state.position) {
        idx = i;
      } else {
        break;
      }
    }
    if (idx != state.currentLyricIndex) {
      state = state.copyWith(currentLyricIndex: idx);
    }
  }
}
