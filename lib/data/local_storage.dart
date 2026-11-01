import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class DownloadedLessonsManager {
  final Future<SharedPreferences> _prefsFuture;
  static const String _downloadedKey = 'downloaded_lessons';

  DownloadedLessonsManager(this._prefsFuture);

  Future<void> saveDownload(String lessonId, String localPath, int size, String? url) async {
    final prefs = await _prefsFuture;
    final List<String> lessons = _getLessons(prefs);
    final Map<String, dynamic> newLesson = {
      'lessonId': lessonId,
      'localPath': localPath,
      'size': size,
      'downloadedAt': DateTime.now().millisecondsSinceEpoch,
      'url': url,
    };
    lessons.add(jsonEncode(newLesson));
    await prefs.setStringList(_downloadedKey, lessons);
  }

  Future<List<Map<String, dynamic>>> getDownloadedLessons() async {
    final prefs = await _prefsFuture;
    final List<String> lessons = _getLessons(prefs);
    return lessons
        .map((json) => jsonDecode(json) as Map<String, dynamic>)
        .toList();
  }

  Future<String?> getLocalPath(String lessonId) async {
    final prefs = await _prefsFuture;
    final lessons = await getDownloadedLessons();
    final lesson = lessons.firstWhere(
      (l) => l['lessonId'] == lessonId,
      orElse: () => {},
    );
    return lesson.isNotEmpty ? lesson['localPath'] as String? : null;
  }

  Future<bool> isDownloaded(String lessonId) async {
    final lessons = await getDownloadedLessons();
    return lessons.any((l) => l['lessonId'] == lessonId);
  }

  Future<void> deleteDownload(String lessonId) async {
    final prefs = await _prefsFuture;
    final lessons = _getLessons(prefs);
    final filtered = lessons
        .where((json) => jsonDecode(json)['lessonId'] != lessonId)
        .map((json) => json)
        .toList();
    await prefs.setStringList(_downloadedKey, filtered);
  }

  Future<void> clearAll() async {
    final prefs = await _prefsFuture;
    await prefs.remove(_downloadedKey);
  }

  List<String> _getLessons(SharedPreferences prefs) {
    final stored = prefs.getStringList(_downloadedKey) ?? [];
    return List<String>.from(stored);
  }
}