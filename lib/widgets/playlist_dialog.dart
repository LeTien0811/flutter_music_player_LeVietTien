import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:offline_music_player/providers/playlist_provider.dart';

class PlaylistDialogs {

  static void showInputNameDialog(
      BuildContext context, {
        String? currentName,
        String? playlistId,
      }) {
    final isEditing = currentName != null;
    final controller = TextEditingController(text: currentName ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(
          isEditing ? 'Đổi tên Playlist' : 'Tạo Playlist mới',
          style: const TextStyle(color: Colors.white),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Nhập tên...',
            hintStyle: TextStyle(color: Colors.grey[600]),
            enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
            focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.green)),
          ),
        ),
        actions: [
          TextButton(
            child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
            onPressed: () => Navigator.pop(ctx),
          ),
          TextButton(
            child: Text(isEditing ? 'Lưu' : 'Tạo',
                style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
            onPressed: () {
              final text = controller.text.trim();
              if (text.isNotEmpty) {
                if (isEditing) {
                  context.read<PlaylistProvider>().renamePlaylist(playlistId!, text);
                } else {
                  context.read<PlaylistProvider>().createPlaylist(text);
                }
                Navigator.pop(ctx);
              }
            },
          ),
        ],
      ),
    );
  }

  static void showDeleteConfirmDialog(BuildContext context, String playlistId, String playlistName) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Xóa Playlist?', style: TextStyle(color: Colors.white)),
        content: Text('Bạn có chắc muốn xóa "$playlistName" không?\nThao tác này không thể hoàn tác.',
            style: const TextStyle(color: Colors.grey)),
        actions: [
          TextButton(
            child: const Text('Hủy', style: TextStyle(color: Colors.white)),
            onPressed: () => Navigator.pop(ctx),
          ),
          TextButton(
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
            onPressed: () {
              context.read<PlaylistProvider>().deletePlaylist(playlistId);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Đã xóa playlist $playlistName')),
              );
            },
          ),
        ],
      ),
    );
  }
}