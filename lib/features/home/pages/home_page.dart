import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../auth/providers/auth_provider.dart';
import '../providers/home_provider.dart';
import '../../../core/widgets/music_card.dart';
import '../../../core/widgets/error_view.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final recentMusic = ref.watch(recentMusicProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('音樂記憶'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_outlined),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(recentMusicProvider);
        },
        child: CustomScrollView(
          slivers: [
            // 歡迎區域
            SliverToBoxAdapter(
              child: _WelcomeSection(theme: theme),
            ),

            // 快速操作
            SliverToBoxAdapter(
              child: _QuickActions(theme: theme),
            ),

            // 最近播放標題
            SliverToBoxAdapter(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text('最近播放', style: theme.textTheme.titleMedium),
              ),
            ),

            // 最近播放列表
            recentMusic.when(
              data: (musicList) {
                if (musicList.isEmpty) {
                  return const SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.library_music_outlined,
                              size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text('還沒有播放紀錄',
                              style: TextStyle(color: Colors.grey)),
                          SizedBox(height: 8),
                          Text('開始解析 YouTube 網址或探索新音樂吧！',
                              style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ),
                  );
                }
                return SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  sliver: SliverList.builder(
                    itemCount: musicList.length,
                    itemBuilder: (context, index) {
                      final music = musicList[index];
                      return MusicCard(
                        music: music,
                        onTap: () => context.push('/player'),
                        onPlay: () => context.push('/player'),
                      );
                    },
                  ),
                );
              },
              loading: () => const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => SliverFillRemaining(
                child: ErrorView(
                  message: '載入失敗',
                  onRetry: () => ref.invalidate(recentMusicProvider),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WelcomeSection extends StatelessWidget {
  final ThemeData theme;

  const _WelcomeSection({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primaryContainer,
            theme.colorScheme.secondaryContainer,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '歡迎回來 🎵',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '今天想聽什麼音樂呢？',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  final ThemeData theme;

  const _QuickActions({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _ActionCard(
            icon: Icons.link_rounded,
            label: '解析網址',
            color: theme.colorScheme.primary,
            onTap: () => context.go('/parse'),
          ),
          const SizedBox(width: 12),
          _ActionCard(
            icon: Icons.explore_rounded,
            label: '探索新歌',
            color: theme.colorScheme.secondary,
            onTap: () => context.go('/explore'),
          ),
          const SizedBox(width: 12),
          _ActionCard(
            icon: Icons.queue_music_rounded,
            label: '我的清單',
            color: theme.colorScheme.tertiary,
            onTap: () => context.go('/playlist'),
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              children: [
                Icon(icon, size: 32, color: color),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
