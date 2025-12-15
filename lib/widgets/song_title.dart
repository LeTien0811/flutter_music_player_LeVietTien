import 'dart:io';

import 'package:flutter/material.dart';
import 'package:offline_music_player/models/song_model.dart';
import 'package:offline_music_player/widgets/add_to_widget_bottom_sheet.dart';


class SongTile extends StatelessWidget {
  final SongModel song;
  final VoidCallback onTap;

  const SongTile({required this.song, required this.onTap});

  @override
  Widget build(BuildContext context) {

    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: _buildAlbumArt(),
      title: Text(
        song.title,
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        song.artist,
        style: TextStyle(color: Colors.grey),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: IconButton(
        icon: Icon(Icons.more_vert, color: Colors.grey),
        onPressed: () {
          _showOptionsMenu(context);
        },
      ),
      onTap: onTap,
    );
  }

  Widget _buildAlbumArt() {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: Color(0xFF282828),
      ),
      child: song.albumArt != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Image.file(File(song.albumArt!), fit: BoxFit.cover),
            )
          : Icon(Icons.music_note, color: Colors.grey),
    );
  }

  void _showOptionsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Color(0xFF282828),
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.playlist_add, color: Colors.white),
              title: Text(
                'Add to playlist',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                showAddToPlaylistBottomSheet(context, song);
              },
            ),
            ListTile(
              leading: Icon(Icons.share, color: Colors.white),
              title: Text('Share', style: TextStyle(color: Colors.white)),
              onTap: () {
                // Share song
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.info_outline, color: Colors.white),
              title: Text('Song info', style: TextStyle(color: Colors.white)),
              onTap: () {
                // Show song info
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
}
