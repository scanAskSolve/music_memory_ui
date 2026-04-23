import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/models/music.dart';

final recentMusicProvider = FutureProvider<List<Music>>((ref) async {
  final apiClient = ref.watch(apiClientProvider);
  try {
    final response = await apiClient.get(
      ApiEndpoints.musicList,
      queryParameters: {'sort': 'updatedAt', 'order': 'desc', 'limit': 20},
    );
    final responseData = response.data['data'];
    final list = (responseData != null && responseData['records'] != null)
        ? responseData['records'] as List<dynamic>
        : [];
    return list.map((e) => Music.fromJson(e as Map<String, dynamic>)).toList();
  } catch (_) {
    return [];
  }
});
