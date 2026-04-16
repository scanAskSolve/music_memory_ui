import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/playlist_provider.dart';
import '../../../core/models/music.dart';
import '../../../core/widgets/music_card.dart';
import '../../../core/widgets/error_view.dart';

class PlaylistPage extends ConsumerStatefulWidget {
  const PlaylistPage({super.key});

  @override
  ConsumerState<PlaylistPage> createState() => _PlaylistPageState();
}

class _PlaylistPageState extends ConsumerState<PlaylistPage> {
  bool _isGridView = false;
  bool _isSelectionMode = false;
  final Set<String> _selectedIds = {};
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final playlistState = ref.watch(playlistControllerProvider);
    final controller = ref.read(playlistControllerProvider.notifier);

    final filteredList = playlistState.musicList.where((m) {
      if (_searchQuery.isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      return m.title.toLowerCase().contains(q) ||
          m.artist.toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: _isSelectionMode
            ? Text('已選擇 ${_selectedIds.length} 首')
            : const Text('我的清單'),
        leading: _isSelectionMode
            ? IconButton(
                onPressed: () => setState(() {
                  _isSelectionMode = false;
                  _selectedIds.clear();
                }),
                icon: const Icon(Icons.close_rounded),
              )
            : null,
        actions: [
          if (_isSelectionMode) ...[
            IconButton(
              onPressed: _selectedIds.isEmpty
                  ? null
                  : () {
                      controller.deleteMultiple(_selectedIds.toList());
                      setState(() {
                        _isSelectionMode = false;
                        _selectedIds.clear();
                      });
                    },
              icon: const Icon(Icons.delete_outline_rounded),
            ),
          ] else ...[
            IconButton(
              onPressed: () => setState(() => _isGridView = !_isGridView),
              icon: Icon(
                _isGridView
                    ? Icons.view_list_rounded
                    : Icons.grid_view_rounded,
              ),
            ),
            PopupMenuButton<SortType>(
              icon: const Icon(Icons.sort_rounded),
              onSelected: (type) => controller.sortBy(type),
              itemBuilder: (_) => const [
                PopupMenuItem(
                  value: SortType.releaseDate,
                  child: Text('發行時間'),
                ),
                PopupMenuItem(
                  value: SortType.createdAt,
                  child: Text('上傳時間'),
                ),
                PopupMenuItem(
                  value: SortType.playCount,
                  child: Text('聽歌次數'),
                ),
                PopupMenuItem(
                  value: SortType.aiCategory,
                  child: Text('AI 分類'),
                ),
                PopupMenuItem(
                  value: SortType.isCover,
                  child: Text('原曲 / Cover'),
                ),
              ],
            ),
          ],
        ],
      ),
      body: Column(
        children: [
          // 搜尋框
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: InputDecoration(
                hintText: '搜尋歌名或演出者...',
                prefixIcon: const Icon(Icons.search_rounded),
                isDense: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          // 篩選器
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _FilterChip(
                  label: '全部',
                  isSelected: playlistState.filter == FilterType.all,
                  onTap: () => controller.filterBy(FilterType.all),
                ),
                _FilterChip(
                  label: '原曲',
                  isSelected: playlistState.filter == FilterType.original,
                  onTap: () => controller.filterBy(FilterType.original),
                ),
                _FilterChip(
                  label: 'Cover',
                  isSelected: playlistState.filter == FilterType.cover,
                  onTap: () => controller.filterBy(FilterType.cover),
                ),
                _FilterChip(
                  label: '收藏',
                  isSelected: playlistState.filter == FilterType.favorite,
                  onTap: () => controller.filterBy(FilterType.favorite),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // 音樂列表
          Expanded(
            child: playlistState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : playlistState.error != null
                    ? ErrorView(
                        message: playlistState.error!,
                        onRetry: () =>
                            ref.invalidate(playlistControllerProvider),
                      )
                    : filteredList.isEmpty
                        ? const Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.queue_music_rounded,
                                    size: 64, color: Colors.grey),
                                SizedBox(height: 16),
                                Text('清單是空的',
                                    style: TextStyle(color: Colors.grey)),
                              ],
                            ),
                          )
                        : _isGridView
                            ? _buildGridView(filteredList, theme)
                            : _buildListView(filteredList, theme),
          ),
        ],
      ),
    );
  }

  Widget _buildListView(List<Music> list, ThemeData theme) {
    return RefreshIndicator(
      onRefresh: () async =>
          ref.invalidate(playlistControllerProvider),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: list.length,
        itemBuilder: (context, index) {
          final music = list[index];
          return GestureDetector(
            onLongPress: () => setState(() {
              _isSelectionMode = true;
              _selectedIds.add(music.id);
            }),
            child: MusicCard(
              music: music,
              onTap: _isSelectionMode
                  ? () => setState(() {
                        if (_selectedIds.contains(music.id)) {
                          _selectedIds.remove(music.id);
                        } else {
                          _selectedIds.add(music.id);
                        }
                      })
                  : () => context.push('/player'),
              onPlay: _isSelectionMode ? null : () => context.push('/player'),
              trailing: _isSelectionMode
                  ? Checkbox(
                      value: _selectedIds.contains(music.id),
                      onChanged: (_) => setState(() {
                        if (_selectedIds.contains(music.id)) {
                          _selectedIds.remove(music.id);
                        } else {
                          _selectedIds.add(music.id);
                        }
                      }),
                    )
                  : null,
            ),
          );
        },
      ),
    );
  }

  Widget _buildGridView(List<Music> list, ThemeData theme) {
    return RefreshIndicator(
      onRefresh: () async =>
          ref.invalidate(playlistControllerProvider),
      child: GridView.builder(
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: list.length,
        itemBuilder: (context, index) {
          final music = list[index];
          return _GridMusicCard(
            music: music,
            isSelected: _selectedIds.contains(music.id),
            isSelectionMode: _isSelectionMode,
            onTap: () {
              if (_isSelectionMode) {
                setState(() {
                  if (_selectedIds.contains(music.id)) {
                    _selectedIds.remove(music.id);
                  } else {
                    _selectedIds.add(music.id);
                  }
                });
              } else {
                context.push('/player');
              }
            },
            onLongPress: () => setState(() {
              _isSelectionMode = true;
              _selectedIds.add(music.id);
            }),
          );
        },
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onTap(),
      ),
    );
  }
}

class _GridMusicCard extends StatelessWidget {
  final Music music;
  final bool isSelected;
  final bool isSelectionMode;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _GridMusicCard({
    required this.music,
    required this.isSelected,
    required this.isSelectionMode,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 3,
                  child: Container(
                    color: theme.colorScheme.surfaceContainerHighest,
                    child: music.coverUrl != null
                        ? Image.network(music.coverUrl!, fit: BoxFit.cover)
                        : const Icon(Icons.music_note_rounded, size: 48),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
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
                      ],
                    ),
                  ),
                ),
              ],
            ),
            if (isSelectionMode)
              Positioned(
                top: 8,
                right: 8,
                child: Icon(
                  isSelected
                      ? Icons.check_circle_rounded
                      : Icons.circle_outlined,
                  color: isSelected
                      ? theme.colorScheme.primary
                      : Colors.white70,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
