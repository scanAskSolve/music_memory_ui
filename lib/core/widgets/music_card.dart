import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../models/music.dart';
import '../utils/duration_formatter.dart';

class MusicCard extends StatelessWidget {
  final Music music;
  final VoidCallback? onTap;
  final VoidCallback? onPlay;
  final Widget? trailing;

  const MusicCard({
    super.key,
    required this.music,
    this.onTap,
    this.onPlay,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 56,
                  height: 56,
                  child: music.coverUrl != null
                      ? CachedNetworkImage(
                          imageUrl: music.coverUrl!,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Container(
                            color: theme.colorScheme.surfaceContainerHighest,
                            child: const Icon(Icons.music_note_rounded),
                          ),
                          errorWidget: (_, __, ___) => Container(
                            color: theme.colorScheme.surfaceContainerHighest,
                            child: const Icon(Icons.music_note_rounded),
                          ),
                        )
                      : Container(
                          color: theme.colorScheme.surfaceContainerHighest,
                          child: const Icon(Icons.music_note_rounded),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      music.title,
                      style: theme.textTheme.titleSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      music.artist,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          DurationFormatter.format(music.duration),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        if (music.isCover) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.tertiaryContainer,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Cover',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onTertiaryContainer,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              if (onPlay != null)
                IconButton(
                  onPressed: onPlay,
                  icon: const Icon(Icons.play_circle_fill_rounded),
                  iconSize: 36,
                  color: theme.colorScheme.primary,
                ),
              if (trailing != null) trailing!,
            ],
          ),
        ),
      ),
    );
  }
}
