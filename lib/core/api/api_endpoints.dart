class ApiEndpoints {
  ApiEndpoints._();

  // Auth
  static const authSync = '/auth/sync';

  // Music
  static const musicParse = '/music/parse';
  static const musicList = '/music/list';
  static const musicDetail = '/music';
  static const musicDelete = '/music';

  // Explore / Recommendation
  static const exploreRecommend = '/explore/recommend';
  static const exploreLike = '/explore/like';
  static const exploreSkip = '/explore/skip';
  static const exploreFavorite = '/explore/favorite';

  // Playlist
  static const playlistList = '/playlist';
  static const playlistCreate = '/playlist';
  static const playlistDetail = '/playlist';

  // Lyrics
  static const lyrics = '/lyrics';

  // User
  static const userProfile = '/user/profile';
  static const userPreferences = '/user/preferences';

  // Download
  static const downloadUrl = '/download/url';
}
