import 'package:flutter/material.dart' hide RepeatMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../providers/player_provider.dart';
import '../../../core/utils/duration_formatter.dart';

class PlayerPage extends ConsumerWidget {
  const PlayerPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final playerState = ref.watch(playerControllerProvider);
    final controller = ref.read(playerControllerProvider.notifier);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.primary.withOpacity(0.3),
              theme.colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // 頂部列
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.keyboard_arrow_down_rounded),
                      iconSize: 32,
                    ),
                    const Spacer(),
                    Text('正在播放',
                        style: theme.textTheme.titleSmall),
                    const Spacer(),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.more_vert_rounded),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // 封面圖
              Expanded(
                flex: 4,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: playerState.currentMusic?.coverUrl != null
                          ? CachedNetworkImage(
                              imageUrl:
                                  playerState.currentMusic!.coverUrl!,
                              fit: BoxFit.cover,
                            )
                          : Container(
                              decoration: BoxDecoration(
                                color: theme
                                    .colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Icon(
                                Icons.music_note_rounded,
                                size: 80,
                              ),
                            ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // 歌曲資訊
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  children: [
                    Text(
                      playerState.currentMusic?.title ?? '未選擇歌曲',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      playerState.currentMusic?.artist ?? '',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 進度條
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  children: [
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 4,
                        thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: 6,
                        ),
                      ),
                      child: Slider(
                        value: playerState.position.inMilliseconds
                            .toDouble()
                            .clamp(
                              0,
                              playerState.duration.inMilliseconds
                                  .toDouble()
                                  .clamp(1, double.infinity),
                            ),
                        max: playerState.duration.inMilliseconds
                            .toDouble()
                            .clamp(1, double.infinity),
                        onChanged: (val) {
                          controller.seek(
                            Duration(milliseconds: val.toInt()),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            DurationFormatter.format(
                              playerState.position,
                            ),
                            style: theme.textTheme.labelSmall,
                          ),
                          Text(
                            DurationFormatter.format(
                              playerState.duration,
                            ),
                            style: theme.textTheme.labelSmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 控制按鈕
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      onPressed: controller.toggleShuffle,
                      icon: Icon(
                        Icons.shuffle_rounded,
                        color: playerState.isShuffle
                            ? theme.colorScheme.primary
                            : null,
                      ),
                    ),
                    IconButton(
                      onPressed: controller.previous,
                      icon: const Icon(Icons.skip_previous_rounded),
                      iconSize: 40,
                    ),
                    FilledButton(
                      onPressed: controller.togglePlayPause,
                      style: FilledButton.styleFrom(
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(16),
                      ),
                      child: Icon(
                        playerState.isPlaying
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        size: 36,
                      ),
                    ),
                    IconButton(
                      onPressed: controller.next,
                      icon: const Icon(Icons.skip_next_rounded),
                      iconSize: 40,
                    ),
                    IconButton(
                      onPressed: controller.toggleRepeat,
                      icon: Icon(
                        playerState.repeatMode == RepeatMode.one
                            ? Icons.repeat_one_rounded
                            : Icons.repeat_rounded,
                        color: playerState.repeatMode != RepeatMode.off
                            ? theme.colorScheme.primary
                            : null,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 歌詞按鈕
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton.icon(
                    onPressed: () => _showLyricsSheet(context, ref),
                    icon: const Icon(Icons.lyrics_rounded),
                    label: const Text('歌詞'),
                  ),
                  const SizedBox(width: 16),
                  TextButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.favorite_border_rounded),
                    label: const Text('收藏'),
                  ),
                ],
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _showLyricsSheet(BuildContext context, WidgetRef ref) {
    final playerState = ref.read(playerControllerProvider);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          maxChildSize: 0.9,
          minChildSize: 0.3,
          expand: false,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('歌詞',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 16),
                  Expanded(
                    child: playerState.lyrics.isEmpty
                        ? const Center(
                            child: Text('暫無歌詞',
                                style: TextStyle(color: Colors.grey)),
                          )
                        : ListView.builder(
                            controller: scrollController,
                            itemCount: playerState.lyrics.length,
                            itemBuilder: (context, index) {
                              final line = playerState.lyrics[index];
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                child: Text(
                                  line.text,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: index ==
                                            playerState.currentLyricIndex
                                        ? Theme.of(context)
                                            .colorScheme
                                            .primary
                                        : null,
                                    fontWeight: index ==
                                            playerState.currentLyricIndex
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
