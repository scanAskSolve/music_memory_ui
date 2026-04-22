/// API endpoint 常數，對齊 music_memory 後端 controller 的實際路徑。
///
/// Base URL 由 [ApiClient.resolveApiBaseUrl] 解析（預設 `http://localhost:8080/api/v1`），
/// 故下方常數一律不包含 `/api/v1` 前綴。
class ApiEndpoints {
  ApiEndpoints._();

  // ─────────────── F0 認證（暫緩，留著以便未來啟用） ───────────────

  static const authSync     = '/auth/sync';
  static const authMe       = '/auth/me';
  static const authAccount  = '/auth/account';

  // ─────────────── F1 音樂（解析 / 儲存 / 列表） ───────────────

  static const musicParse = '/music/parse';
  static const musicSave  = '/music/save';
  static const musicList  = '/music/list';
  static String musicDetail(int id) => '/music/$id';
  static String musicUpdate(int id) => '/music/$id';
  static String musicDelete(int id) => '/music/$id';
  static String musicCover(int id)  => '/music/$id/cover';
  static String musicCoverSync(int id) => '/music/$id/cover/sync';

  // ─────────────── F2 推薦（對齊 RecommendController） ───────────────

  /// `GET /recommend/cards` → `List<RecommendCardVO>`
  static const recommendCards     = '/recommend/cards';

  /// `POST /recommend/swipe` body: `{ musicId: Long, action: 'like'|'dislike'|'love', listenDuration?: int }`
  static const recommendSwipe     = '/recommend/swipe';

  /// `GET /recommend/favorites` → `List<MusicVO>`
  static const recommendFavorites = '/recommend/favorites';

  // ─────────────── F2 行為（播放統計） ───────────────

  static const playHistoryRecord = '/play-history/record';
  static const playHistoryStats  = '/play-history/stats';

  // ─────────────── F0 使用者（暫緩） ───────────────

  static const userProfile        = '/user/profile';
  static const userLinkedAccounts = '/user/linked-accounts';

  // ─────────────── 進階：歌詞 / 下載（暫緩） ───────────────

  static String lyric(int musicId)        => '/lyric/$musicId';
  static String lyricUpload(int musicId)  => '/lyric/$musicId/upload';
  static String lyricSearch(int musicId)  => '/lyric/$musicId/search';

  static const downloadRequest = '/download/request';
  static String downloadStatus(String taskId) => '/download/status/$taskId';
  static const downloadBackup  = '/download/backup';
}

/// Swipe action 常數，對齊 [SwipeActionEnum]（後端）。
class SwipeAction {
  SwipeAction._();
  static const like    = 'like';
  static const dislike = 'dislike';
  static const love    = 'love';
}
