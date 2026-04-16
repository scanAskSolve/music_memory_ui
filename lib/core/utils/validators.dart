class Validators {
  Validators._();

  static final _youtubeRegex = RegExp(
    r'^(https?://)?(www\.)?(youtube\.com/watch\?v=|youtu\.be/|music\.youtube\.com/watch\?v=)[\w-]+',
  );

  static bool isValidYouTubeUrl(String url) {
    return _youtubeRegex.hasMatch(url.trim());
  }

  static String? validateYouTubeUrl(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '請輸入 YouTube 網址';
    }
    if (!isValidYouTubeUrl(value)) {
      return '請輸入有效的 YouTube 網址';
    }
    return null;
  }
}
