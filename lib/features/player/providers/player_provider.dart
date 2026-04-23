import 'dart:math' as math;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

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
  final bool isLoading;
  final Duration position;
  final Duration duration;
  final bool isShuffle;
  final RepeatMode repeatMode;
  final List<LyricLine> lyrics;
  final int currentLyricIndex;
  final List<Music> queue;
  final String? error;

  const PlayerState({
    this.currentMusic,
    this.isPlaying = false,
    this.isLoading = false,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.isShuffle = false,
    this.repeatMode = RepeatMode.off,
    this.lyrics = const [],
    this.currentLyricIndex = 0,
    this.queue = const [],
    this.error,
  });

  PlayerState copyWith({
    Music? currentMusic,
    bool? isPlaying,
    bool? isLoading,
    Duration? position,
    Duration? duration,
    bool? isShuffle,
    RepeatMode? repeatMode,
    List<LyricLine>? lyrics,
    int? currentLyricIndex,
    List<Music>? queue,
    String? error,
  }) {
    return PlayerState(
      currentMusic: currentMusic ?? this.currentMusic,
      isPlaying: isPlaying ?? this.isPlaying,
      isLoading: isLoading ?? this.isLoading,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      isShuffle: isShuffle ?? this.isShuffle,
      repeatMode: repeatMode ?? this.repeatMode,
      lyrics: lyrics ?? this.lyrics,
      currentLyricIndex: currentLyricIndex ?? this.currentLyricIndex,
      queue: queue ?? this.queue,
      error: error,
    );
  }
}

class PlayerController extends StateNotifier<PlayerState> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final YoutubeExplode _yt = YoutubeExplode();

  PlayerController() : super(const PlayerState()) {
    _init();
  }

  void _init() {
    _audioPlayer.playerStateStream.listen((playerState) {
      final isPlaying = playerState.playing;
      final processingState = playerState.processingState;

      if (processingState == ProcessingState.completed) {
        if (state.repeatMode == RepeatMode.one) {
          _audioPlayer.seek(Duration.zero);
          _audioPlayer.play();
        } else {
          next();
        }
      } else {
        state = state.copyWith(
          isPlaying: isPlaying && processingState != ProcessingState.completed,
          isLoading: processingState == ProcessingState.buffering ||
              processingState == ProcessingState.loading,
        );
      }
    });

    _audioPlayer.positionStream.listen((position) {
      state = state.copyWith(position: position);
      _updateCurrentLyricIndex();
    });

    _audioPlayer.durationStream.listen((duration) {
      if (duration != null) {
        state = state.copyWith(duration: duration);
      }
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _yt.close();
    super.dispose();
  }

  Future<void> play(Music music) async {
    state = state.copyWith(
      currentMusic: music,
      isPlaying: false,
      isLoading: true,
      position: Duration.zero,
      duration: music.duration,
      error: null,
    );

    try {
      final videoId = VideoId(music.youtubeUrl).value;
      final manifest = await _yt.videos.streamsClient.getManifest(videoId);
      final audioInfo = manifest.audioOnly.withHighestBitrate();
      final streamUrl = audioInfo.url.toString();

      await _audioPlayer.setUrl(streamUrl);
      _audioPlayer.play();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: '無法播放此首音樂: $e',
      );
    }
  }

  void togglePlayPause() {
    if (state.isPlaying) {
      pause();
    } else {
      resume();
    }
  }

  void pause() {
    _audioPlayer.pause();
  }

  void resume() {
    if (state.currentMusic != null) {
      _audioPlayer.play();
    }
  }

  void seek(Duration position) {
    _audioPlayer.seek(position);
  }

  void next() {
    if (state.queue.isEmpty) return;
    final currentIdx = state.queue.indexWhere(
      (m) => m.id == state.currentMusic?.id,
    );
    
    int nextIdx;
    if (state.isShuffle) {
      nextIdx = math.Random().nextInt(state.queue.length);
    } else {
      nextIdx = (currentIdx + 1) % state.queue.length;
    }
    
    play(state.queue[nextIdx]);
  }

  void previous() {
    if (state.queue.isEmpty) return;
    final currentIdx = state.queue.indexWhere(
      (m) => m.id == state.currentMusic?.id,
    );
    
    int prevIdx;
    if (state.isShuffle) {
      prevIdx = math.Random().nextInt(state.queue.length);
    } else {
      prevIdx = (currentIdx - 1 + state.queue.length) % state.queue.length;
    }
    
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
    seek(position);
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
