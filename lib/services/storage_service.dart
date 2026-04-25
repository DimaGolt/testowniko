import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _keyTargetReps = 'target_repetitions';
  static const String _keyMaxExtraReps = 'max_extra_repetitions';
  static const String _keyMaxActive = 'max_active_questions';
  static const String _keyDarkMode = 'dark_mode';
  static const String _keyShuffleAnswers = 'shuffle_answers';
  static const String _keyRecentFiles = 'recent_files_v2'; // New key for map

  Future<void> saveSettings({
    required int targetReps,
    required int maxExtraReps,
    required int maxActive,
    required bool isDarkMode,
    required bool shuffleAnswers,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyTargetReps, targetReps);
    await prefs.setInt(_keyMaxExtraReps, maxExtraReps);
    await prefs.setInt(_keyMaxActive, maxActive);
    await prefs.setBool(_keyDarkMode, isDarkMode);
    await prefs.setBool(_keyShuffleAnswers, shuffleAnswers);
  }

  Future<Map<String, dynamic>> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'targetReps': prefs.getInt(_keyTargetReps) ?? 2,
      'maxExtraReps': prefs.getInt(_keyMaxExtraReps) ?? 4,
      'maxActiveQuestions': prefs.getInt(_keyMaxActive) ?? 8,
      'isDarkMode': prefs.getBool(_keyDarkMode) ?? false,
      'shuffleAnswers': prefs.getBool(_keyShuffleAnswers) ?? true,
    };
  }

  Future<void> saveFileContent(String name, String content) async {
    final prefs = await SharedPreferences.getInstance();
    Map<String, String> files = await _getFilesMap();
    files[name] = content;
    
    // Keep only last 5 files to save space
    if (files.length > 5) {
      var keys = files.keys.toList();
      files.remove(keys.first);
    }
    
    await prefs.setString(_keyRecentFiles, jsonEncode(files));
  }

  Future<Map<String, String>> _getFilesMap() async {
    final prefs = await SharedPreferences.getInstance();
    String? json = prefs.getString(_keyRecentFiles);
    if (json == null) return {};
    return Map<String, String>.from(jsonDecode(json));
  }

  Future<List<String>> getRecentFilesNames() async {
    Map<String, String> files = await _getFilesMap();
    return files.keys.toList().reversed.toList();
  }

  Future<String?> getFileContent(String name) async {
    Map<String, String> files = await _getFilesMap();
    return files[name];
  }
}
