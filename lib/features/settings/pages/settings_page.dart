import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../auth/providers/auth_provider.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final authState = ref.watch(authStateProvider);
    final authController = ref.read(authControllerProvider.notifier);

    final user = authState.valueOrNull;

    return Scaffold(
      appBar: AppBar(title: const Text('設定')),
      body: ListView(
        children: [
          // 用戶資訊卡片
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundImage: user?.photoURL != null
                        ? NetworkImage(user!.photoURL!)
                        : null,
                    child: user?.photoURL == null
                        ? const Icon(Icons.person_rounded, size: 32)
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.displayName ?? '匿名用戶',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (user?.email != null)
                          Text(
                            user!.email!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const _SectionTitle(title: '一般設定'),

          _SettingsTile(
            icon: Icons.language_rounded,
            title: '語言',
            subtitle: '繁體中文',
            onTap: () {},
          ),
          _SettingsTile(
            icon: Icons.dark_mode_rounded,
            title: '深色模式',
            subtitle: '跟隨系統',
            onTap: () {},
          ),
          _SettingsTile(
            icon: Icons.notifications_rounded,
            title: '通知設定',
            onTap: () {},
          ),

          const _SectionTitle(title: '音樂設定'),

          _SettingsTile(
            icon: Icons.high_quality_rounded,
            title: '音質設定',
            subtitle: '高品質',
            onTap: () {},
          ),
          _SettingsTile(
            icon: Icons.download_rounded,
            title: '下載設定',
            subtitle: '僅在 Wi-Fi 下載',
            onTap: () {},
          ),
          _SettingsTile(
            icon: Icons.storage_rounded,
            title: '快取管理',
            subtitle: '已使用 0 MB',
            onTap: () {},
          ),

          const _SectionTitle(title: '備份'),

          _SettingsTile(
            icon: Icons.cloud_upload_rounded,
            title: '雲端備份',
            subtitle: 'Google Drive / iCloud',
            onTap: () {},
          ),
          _SettingsTile(
            icon: Icons.cloud_download_rounded,
            title: '還原備份',
            onTap: () {},
          ),

          const _SectionTitle(title: '關於'),

          _SettingsTile(
            icon: Icons.info_outline_rounded,
            title: '關於音樂記憶',
            subtitle: 'v1.0.0',
            onTap: () {},
          ),
          _SettingsTile(
            icon: Icons.privacy_tip_outlined,
            title: '隱私權政策',
            onTap: () {},
          ),
          _SettingsTile(
            icon: Icons.description_outlined,
            title: '服務條款',
            onTap: () {},
          ),

          const SizedBox(height: 16),

          // 登出按鈕
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: OutlinedButton.icon(
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('確認登出'),
                    content: const Text('確定要登出嗎？'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('取消'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('登出'),
                      ),
                    ],
                  ),
                );
                if (confirm == true) {
                  await authController.signOut();
                }
              },
              icon: const Icon(Icons.logout_rounded),
              label: const Text('登出'),
              style: OutlinedButton.styleFrom(
                foregroundColor: theme.colorScheme.error,
                side: BorderSide(color: theme.colorScheme.error),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: onTap,
    );
  }
}
