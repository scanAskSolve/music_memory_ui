import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/player/widgets/mini_player.dart';

class AppShell extends ConsumerWidget {
  final Widget child;

  const AppShell({super.key, required this.child});

  static const _navItems = [
    BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: '首頁'),
    BottomNavigationBarItem(icon: Icon(Icons.link_rounded), label: '解析'),
    BottomNavigationBarItem(icon: Icon(Icons.explore_rounded), label: '探索'),
    BottomNavigationBarItem(icon: Icon(Icons.queue_music_rounded), label: '清單'),
    BottomNavigationBarItem(icon: Icon(Icons.settings_rounded), label: '設定'),
  ];

  static const _routes = ['/', '/parse', '/explore', '/playlist', '/settings'];

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final idx = _routes.indexOf(location);
    return idx >= 0 ? idx : 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: child,
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const MiniPlayer(),
          BottomNavigationBar(
            currentIndex: _currentIndex(context),
            items: _navItems,
            onTap: (i) => context.go(_routes[i]),
          ),
        ],
      ),
    );
  }
}
