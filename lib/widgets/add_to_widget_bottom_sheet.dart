import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:offline_music_player/models/song_model.dart';
import 'package:offline_music_player/providers/playlist_provider.dart';

void _showCreatePlaylistDialog(BuildContext context) {
  final TextEditingController _controller = TextEditingController();

  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: Colors.grey[900],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),

      title: const Text(
        'Tạo Playlist mới',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),

      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _controller,
            autofocus: true,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: 'Nhập tên playlist...',
              hintStyle: TextStyle(color: Colors.grey),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.grey),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.green),
              ),
            ),
            onSubmitted: (_) => _submitCreate(ctx, _controller),
          ),
        ],
      ),

      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
        ),
        TextButton(
          onPressed: () => _submitCreate(ctx, _controller),
          child: const Text(
            'Tạo',
            style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    ),
  );
}

void _submitCreate(BuildContext context, TextEditingController controller) {
  final name = controller.text.trim();

  if (name.isNotEmpty) {
    context.read<PlaylistProvider>().createPlaylist(name);

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã tạo playlist "$name"'),
        backgroundColor: Colors.grey[800],
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

void showAddToPlaylistBottomSheet(BuildContext context, SongModel song) {
  showModalBottomSheet(
    context: context,
    backgroundColor: const Color(0xFF191414),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) {
      return Consumer<PlaylistProvider>(
        builder: (context, provider, child) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  'Thêm vào Playlist',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Divider(color: Colors.grey, height: 1),

              ListTile(
                leading: Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Icon(Icons.add, color: Colors.white),
                ),
                title: const Text('Tạo Playlist mới', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  _showCreatePlaylistDialog(context);
                },
              ),

              ...provider.playlists.map((playlist) {
                final bool isAlreadyIn = playlist.songIds.contains(song.id.toString());

                return ListTile(
                  leading: Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      image: playlist.coverImage != null
                          ? DecorationImage(image: NetworkImage(playlist.coverImage!), fit: BoxFit.cover)
                          : null,
                      color: Colors.grey[800],
                    ),
                    child: playlist.coverImage == null
                        ? const Icon(Icons.music_note, color: Colors.white)
                        : null,
                  ),
                  title: Text(
                    playlist.name,
                    style: TextStyle(
                      color: isAlreadyIn ? Colors.green : Colors.white,
                      fontWeight: isAlreadyIn ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  subtitle: Text('${playlist.songIds.length} bài hát', style: const TextStyle(color: Colors.grey)),
                  trailing: isAlreadyIn
                      ? const Icon(Icons.check_circle, color: Colors.green, size: 20)
                      : null,
                  onTap: () {
                    if (isAlreadyIn) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Bài này đã có trong ${playlist.name} rồi!')),
                      );
                    } else {
                      provider.addSongToPlaylist(playlist.id, song.id.toString());
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Đã thêm vào ${playlist.name}')),
                      );
                    }
                  },
                );
              }).toList(),

              const SizedBox(height: 20),
            ],
          );
        },
      );
    },
  );
}