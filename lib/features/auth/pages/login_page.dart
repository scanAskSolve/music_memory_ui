import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_provider.dart';
import '../../../core/widgets/loading_overlay.dart';

class LoginPage extends ConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final authController = ref.read(authControllerProvider.notifier);
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    ref.listen<AuthState>(authControllerProvider, (_, state) {
      if (state.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(state.error!), backgroundColor: Colors.red),
        );
      }
    });

    return Scaffold(
      body: LoadingOverlay(
        isLoading: authState.isLoading,
        message: '登入中...',
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.music_note_rounded,
                    size: 80,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '音樂記憶',
                    style: theme.textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '探索、收藏、聆聽你的音樂世界',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: size.height * 0.08),

                  // Google 登入
                  _OAuthButton(
                    onPressed: authController.signInWithGoogle,
                    icon: Icons.g_mobiledata_rounded,
                    label: '以 Google 帳號登入',
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black87,
                    borderColor: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 12),

                  // Apple 登入 (iOS / Web only)
                  if (defaultTargetPlatform == TargetPlatform.iOS || kIsWeb)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _OAuthButton(
                        onPressed: authController.signInWithApple,
                        icon: Icons.apple_rounded,
                        label: '以 Apple 帳號登入',
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                      ),
                    ),

                  // Facebook 登入
                  _OAuthButton(
                    onPressed: authController.signInWithFacebook,
                    icon: Icons.facebook_rounded,
                    label: '以 Facebook 帳號登入',
                    backgroundColor: const Color(0xFF1877F2),
                    foregroundColor: Colors.white,
                  ),
                  const SizedBox(height: 32),

                  // 分隔線
                  Row(
                    children: [
                      const Expanded(child: Divider()),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          '或',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      const Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // 匿名試用
                  TextButton(
                    onPressed: authController.signInAnonymously,
                    child: const Text('先逛逛再說（匿名試用）'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _OAuthButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String label;
  final Color backgroundColor;
  final Color foregroundColor;
  final Color? borderColor;

  const _OAuthButton({
    required this.onPressed,
    required this.icon,
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 24),
        label: Text(label, style: const TextStyle(fontSize: 16)),
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: borderColor != null
                ? BorderSide(color: borderColor!)
                : BorderSide.none,
          ),
        ),
      ),
    );
  }
}
