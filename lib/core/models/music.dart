class Music {
  final String id;
  final String title;
  final String artist;
  final String? album;
  final String? coverUrl;
  final String youtubeUrl;
  final Duration duration;
  final bool isCover;
  final String? originalMusicId;
  final String? aiCategory;
  final int playCount;
  final bool isFavorite;
  final DateTime? releaseDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Music({
    required this.id,
    required this.title,
    required this.artist,
    this.album,
    this.coverUrl,
    required this.youtubeUrl,
    required this.duration,
    this.isCover = false,
    this.originalMusicId,
    this.aiCategory,
    this.playCount = 0,
    this.isFavorite = false,
    this.releaseDate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Music.fromJson(Map<String, dynamic> json) {
    return Music(
      id: json['id'] as String,
      title: json['title'] as String,
      artist: json['artist'] as String,
      album: json['album'] as String?,
      coverUrl: json['coverUrl'] as String?,
      youtubeUrl: json['youtubeUrl'] as String,
      duration: Duration(seconds: json['durationSeconds'] as int? ?? 0),
      isCover: json['isCover'] as bool? ?? false,
      originalMusicId: json['originalMusicId'] as String?,
      aiCategory: json['aiCategory'] as String?,
      playCount: json['playCount'] as int? ?? 0,
      isFavorite: json['isFavorite'] as bool? ?? false,
      releaseDate: json['releaseDate'] != null
          ? DateTime.parse(json['releaseDate'] as String)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'album': album,
      'coverUrl': coverUrl,
      'youtubeUrl': youtubeUrl,
      'durationSeconds': duration.inSeconds,
      'isCover': isCover,
      'originalMusicId': originalMusicId,
      'aiCategory': aiCategory,
      'playCount': playCount,
      'isFavorite': isFavorite,
      'releaseDate': releaseDate?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Music copyWith({
    String? title,
    String? artist,
    String? album,
    String? coverUrl,
    bool? isCover,
    String? originalMusicId,
    bool? isFavorite,
    int? playCount,
  }) {
    return Music(
      id: id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      coverUrl: coverUrl ?? this.coverUrl,
      youtubeUrl: youtubeUrl,
      duration: duration,
      isCover: isCover ?? this.isCover,
      originalMusicId: originalMusicId ?? this.originalMusicId,
      aiCategory: aiCategory,
      playCount: playCount ?? this.playCount,
      isFavorite: isFavorite ?? this.isFavorite,
      releaseDate: releaseDate,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
