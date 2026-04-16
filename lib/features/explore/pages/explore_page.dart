import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../providers/explore_provider.dart';
import '../../../core/models/music.dart';
import '../../../core/widgets/error_view.dart';

class ExplorePage extends ConsumerStatefulWidget {
  const ExplorePage({super.key});

  @override
  ConsumerState<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends ConsumerState<ExplorePage>
    with TickerProviderStateMixin {
  final CardSwiperController _swiperController = CardSwiperController();
  late AnimationController _heartAnimController;

  @override
  void initState() {
    super.initState();
    _heartAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
  }

  @override
  void dispose() {
    _swiperController.dispose();
    _heartAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final exploreState = ref.watch(exploreControllerProvider);
    final exploreController = ref.read(exploreControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('探索新音樂'),
        actions: [
          IconButton(
            onPressed: () => ref.invalidate(exploreControllerProvider),
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: exploreState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : exploreState.error != null
              ? ErrorView(
                  message: exploreState.error!,
                  onRetry: () =>
                      ref.invalidate(exploreControllerProvider),
                )
              : exploreState.cards.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.explore_off_rounded,
                              size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text('暫無更多推薦',
                              style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    )
                  : Column(
                      children: [
                        Expanded(
                          child: CardSwiper(
                            controller: _swiperController,
                            cardsCount: exploreState.cards.length,
                            numberOfCardsDisplayed:
                                exploreState.cards.length.clamp(1, 3),
                            onSwipe: (prevIdx, currentIdx, direction) {
                              final music = exploreState.cards[prevIdx];
                              if (direction ==
                                  CardSwiperDirection.right) {
                                exploreController.like(music);
                              } else if (direction ==
                                  CardSwiperDirection.left) {
                                exploreController.skip(music);
                              }
                              return true;
                            },
                            cardBuilder: (context, index, _, __) {
                              return _ExploreCard(
                                music: exploreState.cards[index],
                                theme: theme,
                              );
                            },
                          ),
                        ),

                        // 操作按鈕列
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 48,
                            vertical: 24,
                          ),
                          child: Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceEvenly,
                            children: [
                              // 左滑 - 跳過
                              _CircleActionButton(
                                icon: Icons.close_rounded,
                                color: Colors.red,
                                size: 56,
                                onTap: () => _swiperController.swipe(
                                    CardSwiperDirection.left),
                              ),

                              // 愛心 - 收藏
                              _CircleActionButton(
                                icon: Icons.favorite_rounded,
                                color: const Color(0xFFFF6584),
                                size: 64,
                                onTap: () {
                                  _heartAnimController.forward(from: 0);
                                  if (exploreState.cards.isNotEmpty) {
                                    exploreController.favorite(
                                        exploreState.cards.first);
                                    _swiperController.swipe(
                                        CardSwiperDirection.right);
                                  }
                                },
                              ),

                              // 右滑 - 喜歡
                              _CircleActionButton(
                                icon: Icons.thumb_up_rounded,
                                color: Colors.green,
                                size: 56,
                                onTap: () => _swiperController.swipe(
                                    CardSwiperDirection.right),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
    );
  }
}

class _ExploreCard extends StatelessWidget {
  final Music music;
  final ThemeData theme;

  const _ExploreCard({required this.music, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 封面背景
          if (music.coverUrl != null)
            CachedNetworkImage(
              imageUrl: music.coverUrl!,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(
                color: theme.colorScheme.surfaceContainerHighest,
              ),
            )
          else
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.colorScheme.primaryContainer,
                    theme.colorScheme.secondaryContainer,
                  ],
                ),
              ),
              child: const Icon(Icons.music_note_rounded,
                  size: 80, color: Colors.white54),
            ),

          // 漸層覆蓋
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black87],
                stops: [0.5, 1.0],
              ),
            ),
          ),

          // 資訊
          Positioned(
            bottom: 24,
            left: 20,
            right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  music.title,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  music.artist,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 12),
                // 預覽播放按鈕
                FilledButton.icon(
                  onPressed: () {
                    // TODO: 預覽播放
                  },
                  icon: const Icon(Icons.play_arrow_rounded, size: 20),
                  label: const Text('預覽試聽'),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white24,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;
  final VoidCallback onTap;

  const _CircleActionButton({
    required this.icon,
    required this.color,
    required this.size,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withOpacity(0.1),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(icon, color: color, size: size * 0.5),
        ),
      ),
    );
  }
}
