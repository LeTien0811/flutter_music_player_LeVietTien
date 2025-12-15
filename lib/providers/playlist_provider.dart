// lib/providers/playlist_provider.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:offline_music_player/models/playlist_model.dart';

class PlaylistProvider extends ChangeNotifier {
  List<PlaylistModel> _playlists = [];

  List<PlaylistModel> get playlists => _playlists;

  PlaylistProvider() {
    _loadPlaylists();
  }

  Future<void> _loadPlaylists() async {
    final prefs = await SharedPreferences.getInstance();
    final String? playlistString = prefs.getString('playlists');

    if (playlistString != null) {
      final List<dynamic> decoded = jsonDecode(playlistString);
      _playlists = decoded.map((item) => PlaylistModel.fromJson(item)).toList();
      notifyListeners();
    }
  }

  Future<void> _saveToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(_playlists.map((e) => e.toJson()).toList());
    await prefs.setString('playlists', encoded);
    notifyListeners();
  }

  void createPlaylist(String name) {
    final now = DateTime.now();
    final newPlaylist = PlaylistModel(
      id: now.millisecondsSinceEpoch.toString(),
      name: name,
      songIds: [],
      createdAt: now,
      updatedAt: now,
    );

    _playlists.add(newPlaylist);
    _saveToStorage();
  }

  void deletePlaylist(String playlistId) {
    _playlists.removeWhere((item) => item.id == playlistId);
    _saveToStorage();
  }

  void addSongToPlaylist(String playlistId, String songId) {
    final index = _playlists.indexWhere((item) => item.id == playlistId);

    if (index != -1) {
      final currentPlaylist = _playlists[index];

      // Kiểm tra trùng bài hát
      if (!currentPlaylist.songIds.contains(songId)) {
        // Tạo danh sách ID mới (Copy list cũ + bài mới)
        final List<String> newSongIds = List.from(currentPlaylist.songIds)..add(songId);

        // Cập nhật playlist bằng copyWith (tự động update thời gian)
        _playlists[index] = currentPlaylist.copyWith(
          songIds: newSongIds,
          updatedAt: DateTime.now(), // Cập nhật thời gian sửa
        );
        _saveToStorage();
      }
    }
  }

  void removeSongFromPlaylist(String playlistId, String songId) {
    final index = _playlists.indexWhere((item) => item.id == playlistId);

    if (index != -1) {
      final currentPlaylist = _playlists[index];

      // Tạo danh sách ID mới (loại bỏ bài cần xóa)
      final List<String> newSongIds = List.from(currentPlaylist.songIds)..remove(songId);

      _playlists[index] = currentPlaylist.copyWith(
        songIds: newSongIds,
        updatedAt: DateTime.now(),
      );

      _saveToStorage();
    }
  }

  void renamePlaylist(String playlistId, String newName) {
    final index = _playlists.indexWhere((item) => item.id == playlistId);

    if (index != -1) {
      _playlists[index] = _playlists[index].copyWith(
        name: newName,
        updatedAt: DateTime.now(),
      );
      _saveToStorage();
    }
  }
}