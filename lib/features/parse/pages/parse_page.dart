import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../providers/parse_provider.dart';
import '../../../core/utils/validators.dart';
import '../../../core/utils/duration_formatter.dart';

class ParsePage extends ConsumerStatefulWidget {
  const ParsePage({super.key});

  @override
  ConsumerState<ParsePage> createState() => _ParsePageState();
}

class _ParsePageState extends ConsumerState<ParsePage> {
  final _urlController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null) {
      _urlController.text = data!.text!;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final parseState = ref.watch(parseControllerProvider);
    final parseController = ref.read(parseControllerProvider.notifier);

    ref.listen<ParseState>(parseControllerProvider, (_, state) {
      if (state.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(state.error!), backgroundColor: Colors.red),
        );
      }
      if (state.isSaved) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('音樂已成功儲存！'),
            backgroundColor: Colors.green,
          ),
        );
        _urlController.clear();
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('解析 YouTube 音樂')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // URL 輸入區域
            Form(
              key: _formKey,
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _urlController,
                      decoration: InputDecoration(
                        hintText: '貼上 YouTube 網址...',
                        prefixIcon: const Icon(Icons.link_rounded),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.content_paste_rounded),
                          onPressed: _pasteFromClipboard,
                          tooltip: '從剪貼簿貼上',
                        ),
                      ),
                      validator: Validators.validateYouTubeUrl,
                      keyboardType: TextInputType.url,
                    ),
                  ),
                  const SizedBox(width: 12),
                  FilledButton(
                    onPressed: parseState.isLoading
                        ? null
                        : () {
                            if (_formKey.currentState!.validate()) {
                              parseController
                                  .parseUrl(_urlController.text.trim());
                            }
                          },
                    child: parseState.isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('解析'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 解析結果
            if (parseState.result != null) ...[
              Card(
                clipBehavior: Clip.antiAlias,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 封面圖
                    if (parseState.result!.coverUrl != null)
                      AspectRatio(
                        aspectRatio: 16 / 9,
                        child: CachedNetworkImage(
                          imageUrl: parseState.result!.coverUrl!,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Container(
                            color: theme.colorScheme.surfaceContainerHighest,
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                        ),
                      ),

                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 歌名
                          Text(
                            parseState.result!.title,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),

                          // 演出者
                          Text(
                            parseState.result!.artist,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 8),

                          // 時長
                          Row(
                            children: [
                              Icon(Icons.access_time_rounded,
                                  size: 16,
                                  color:
                                      theme.colorScheme.onSurfaceVariant),
                              const SizedBox(width: 4),
                              Text(
                                DurationFormatter.format(
                                  Duration(
                                    seconds:
                                        parseState.result!.durationSeconds,
                                  ),
                                ),
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
                          ),
                          const Divider(height: 24),

                          // Cover 曲標記
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('這是 Cover 曲'),
                            subtitle: const Text('標記後可選擇同步原曲資訊'),
                            value: parseState.result!.isCover,
                            onChanged: (val) =>
                                parseController.toggleCover(val),
                          ),

                          const SizedBox(height: 16),

                          // 儲存按鈕
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
                              onPressed: parseState.isSaving
                                  ? null
                                  : () => parseController.saveMusic(),
                              icon: parseState.isSaving
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Icon(Icons.save_rounded),
                              label: Text(
                                parseState.isSaving ? '儲存中...' : '儲存至我的清單',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
