import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:offline_music_player/models/playlist_model.dart';
import 'package:offline_music_player/models/song_model.dart';
import 'package:offline_music_player/providers/audio_provider.dart';
import 'package:offline_music_player/providers/playlist_provider.dart';
import 'package:offline_music_player/widgets/song_title.dart'; // Widget hiển thị bài hát cũ của bạn

class PlaylistDetailScreen extends StatelessWidget {
  final String playlistId;

  const PlaylistDetailScreen({Key? key, required this.playlistId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer2<PlaylistProvider, AudioProvider>(
      builder: (context, playlistProvider, audioProvider, child) {

        // 1. Tìm playlist hiện tại theo ID
        // Dùng firstWhere để tìm, nếu lỡ playlist bị xóa thì trả về null
        final PlaylistModel? playlist = playlistProvider.playlists
            .cast<PlaylistModel?>()
            .firstWhere((p) => p!.id == playlistId, orElse: () => null);
        final List<SongModel> playlistSongs = audioProvider.allSongs
            .where((s) => playlist!.songIds.contains(s.id.toString()))
            .toList();
        print(PlaylistModel);
        if (playlist == null) {
          return const Scaffold(
              backgroundColor: Color(0xFF191414),
              body: Center(child: Text("Playlist không tồn tại", style: TextStyle(color: Colors.white))));
        }



        return Scaffold(
          backgroundColor: const Color(0xFF191414),
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 280.0,
                pinned: true, // Giữ lại thanh AppBar khi cuộn
                backgroundColor: const Color(0xFF191414),
                leading: const BackButton(color: Colors.white),
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    playlist.name,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  centerTitle: true,
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Ảnh nền
                      playlist.coverImage != null
                          ? Image.network(playlist.coverImage!, fit: BoxFit.cover)
                          : Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.grey[800]!, const Color(0xFF191414)],
                          ),
                        ),
                        child: const Icon(Icons.music_note, size: 80, color: Colors.white24),
                      ),
                      // Lớp phủ mờ dần xuống dưới
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.transparent, Color(0xFF191414)],
                            stops: [0.6, 1.0],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Nút Play to đùng ở góc
                actions: [
                  if (playlistSongs.isNotEmpty)
                    IconButton(
                      icon: const CircleAvatar(
                        radius: 24,
                        backgroundColor: Colors.green,
                        child: Icon(Icons.play_arrow, color: Colors.black),
                      ),
                      onPressed: () {
                        // Phát toàn bộ playlist từ bài đầu tiên
                        audioProvider.setPlaylist(playlistSongs, 0);
                      },
                    ),
                  const SizedBox(width: 16),
                ],
              ),

              // --- DANH SÁCH BÀI HÁT ---
              playlistSongs.isEmpty
                  ? SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 50),
                  child: Column(
                    children: [
                      const Text("Chưa có bài hát nào", style: TextStyle(color: Colors.grey)),
                      TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Thêm bài hát từ thư viện")
                      )
                    ],
                  ),
                ),
              )
                  : SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    final song = playlistSongs[index];

                    // Dùng Dismissible để vuốt sang trái xóa bài
                    return Dismissible(
                      key: Key('${playlist.id}_${song.id}'),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (direction) {
                        // Gọi hàm xóa khỏi playlist
                        playlistProvider.removeSongFromPlaylist(playlist.id, song.id.toString());

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Đã xóa "${song.title}" khỏi playlist')),
                        );
                      },
                      child: SongTile(
                        song: song,
                        onTap: () {
                          // QUAN TRỌNG: Khi bấm vào bài trong playlist
                          // Phải set Playlist hiện tại là danh sách này
                          audioProvider.setPlaylist(playlistSongs, index);
                        },
                        // Tùy chỉnh icon trailing (mặc định SongTile của bạn có thể khác)
                        // Nếu SongTile của bạn ko hỗ trợ tham số trailing, bạn có thể bọc nó lại
                      ),
                    );
                  },
                  childCount: playlistSongs.length,
                ),
              ),

              // Khoảng trống dưới cùng để không bị che bởi MiniPlayer
              const SliverToBoxAdapter(child: SizedBox(height: 80)),
            ],
          ),
        );
      },
    );
  }
}