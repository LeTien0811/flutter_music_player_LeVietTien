// lib/widgets/playlist_card.dart
import 'package:flutter/material.dart';
import 'package:offline_music_player/models/playlist_model.dart';
import 'package:offline_music_player/widgets/playlist_dialog.dart';

class PlaylistCard extends StatelessWidget {
  final PlaylistModel playlist;
  final VoidCallback onTap;

  const PlaylistCard({Key? key, required this.playlist, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                  gradient: const LinearGradient(
                      colors: [Color(0xFF424242), Color(0xFF212121)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight),
                  image: playlist.coverImage != null
                      ? DecorationImage(image: NetworkImage(playlist.coverImage!), fit: BoxFit.cover)
                      : null,
                ),
                child: playlist.coverImage == null
                    ? const Icon(Icons.music_note, size: 50, color: Colors.white54)
                    : null,
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          playlist.name,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          maxLines: 1, overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${playlist.songIds.length} bài hát',
                          style: TextStyle(color: Colors.grey[400], fontSize: 12),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(
                    width: 30, height: 30,
                    child: PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert, color: Colors.grey, size: 20),
                      color: Colors.grey[800],
                      onSelected: (value) {
                        if (value == 'edit') {
                          PlaylistDialogs.showInputNameDialog(
                              context,
                              currentName: playlist.name,
                              playlistId: playlist.id
                          );
                        } else if (value == 'delete') {
                          PlaylistDialogs.showDeleteConfirmDialog(context, playlist.id, playlist.name);
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(children: [Icon(Icons.edit, size: 18), SizedBox(width: 8), Text("Đổi tên")]),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(children: [Icon(Icons.delete, size: 18, color: Colors.red), SizedBox(width: 8), Text("Xóa", style: TextStyle(color: Colors.red))]),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}