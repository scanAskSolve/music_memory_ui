class ParseResult {
  final String title;
  final String artist;
  final String? album;
  final String? coverUrl;
  final String youtubeUrl;
  final int durationSeconds;
  final bool isCover;

  const ParseResult({
    required this.title,
    required this.artist,
    this.album,
    this.coverUrl,
    required this.youtubeUrl,
    required this.durationSeconds,
    this.isCover = false,
  });

  factory ParseResult.fromJson(Map<String, dynamic> json) {
    return ParseResult(
      title: json['title'] as String,
      artist: json['artist'] as String,
      album: json['album'] as String?,
      coverUrl: json['coverUrl'] as String?,
      youtubeUrl: json['youtubeUrl'] as String,
      durationSeconds: json['durationSeconds'] as int? ?? 0,
      isCover: json['isCover'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'artist': artist,
      'album': album,
      'coverUrl': coverUrl,
      'youtubeUrl': youtubeUrl,
      'durationSeconds': durationSeconds,
      'isCover': isCover,
    };
  }

  ParseResult copyWith({
    String? title,
    String? artist,
    String? album,
    String? coverUrl,
    bool? isCover,
  }) {
    return ParseResult(
      title: title ?? this.title,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      coverUrl: coverUrl ?? this.coverUrl,
      youtubeUrl: youtubeUrl,
      durationSeconds: durationSeconds,
      isCover: isCover ?? this.isCover,
    );
  }
}
