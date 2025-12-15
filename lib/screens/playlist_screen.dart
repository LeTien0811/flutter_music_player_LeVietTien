// lib/screenshots/library_screen.dart
import 'package:flutter/material.dart';
import 'package:offline_music_player/screens/playlist_detail_screen.dart';
import 'package:offline_music_player/widgets/playlist_dialog.dart';
import 'package:provider/provider.dart';
import 'package:offline_music_player/providers/playlist_provider.dart';
import 'package:offline_music_player/widgets/playlist_card.dart';


class PlaylistScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF191414), // Màu nền tối chủ đạo
      appBar: AppBar(
        leading: const BackButton(color: Colors.white),
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Thư viện của tôi', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          // Nút TẠO MỚI (+)
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white, size: 28),
            onPressed: () {
              // Gọi dialog tạo mới (không truyền currentName)
              PlaylistDialogs.showInputNameDialog(context);
            },
          ),
          const SizedBox(width: 8),
        ],
      ),

      // Consumer lắng nghe thay đổi danh sách
      body: Consumer<PlaylistProvider>(
        builder: (context, provider, child) {
          final playlists = provider.playlists;

          // 1. Nếu chưa có playlist nào
          if (playlists.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.queue_music, size: 80, color: Colors.grey[800]),
                  const SizedBox(height: 16),
                  const Text('Chưa có playlist nào', style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    onPressed: () => PlaylistDialogs.showInputNameDialog(context),
                    child: const Text('Tạo ngay', style: TextStyle(color: Colors.white)),
                  )
                ],
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: GridView.builder(
              itemCount: playlists.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // 2 cột
                childAspectRatio: 0.85, // Tỷ lệ chiều rộng/cao
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemBuilder: (context, index) {
                final playlist = playlists[index];

                return PlaylistCard(
                  playlist: playlist,
                  onTap: () {
                    // Chuyển sang màn hình chi tiết
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PlaylistDetailScreen(playlistId: playlist.id),
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}