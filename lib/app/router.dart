import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/pages/login_page.dart';
import '../features/auth/providers/auth_provider.dart';
import '../features/auth/providers/local_auth_provider.dart';
import '../features/home/pages/home_page.dart';
import '../features/parse/pages/parse_page.dart';
import '../features/explore/pages/explore_page.dart';
import '../features/playlist/pages/playlist_page.dart';
import '../features/player/pages/player_page.dart';
import '../features/settings/pages/settings_page.dart';
import 'shell.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  final isAnonymous = ref.watch(localAuthProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      // F0 暫緩中：直接無使用者直接通過
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: '/',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HomePage(),
            ),
          ),
          GoRoute(
            path: '/parse',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ParsePage(),
            ),
          ),
          GoRoute(
            path: '/explore',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ExplorePage(),
            ),
          ),
          GoRoute(
            path: '/playlist',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: PlaylistPage(),
            ),
          ),
          GoRoute(
            path: '/settings',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: SettingsPage(),
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/player',
        builder: (context, state) => const PlayerPage(),
      ),
    ],
  );
});
