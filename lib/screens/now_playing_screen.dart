import 'dart:io';

import 'package:flutter/material.dart';
import 'package:offline_music_player/models/song_model.dart';
import 'package:offline_music_player/providers/audio_provider.dart';
import 'package:offline_music_player/widgets/play_back_speed_widget.dart';
import 'package:offline_music_player/widgets/player_controls.dart';
import 'package:offline_music_player/widgets/progress_bar.dart';
import 'package:offline_music_player/widgets/volume_slider_widget.dart';
import 'package:provider/provider.dart';

class NowPlayingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF191414),
      body: Consumer<AudioProvider>(
        builder: (context, provider, child) {
          final song = provider.currentSong;

          if (song == null) {
            return Center(child: Text('No song playing'));
          }

          return SafeArea(
            child: Column(
              children: [
                // App Bar
                _buildAppBar(context),

                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Album Art
                        Flexible(
                          flex: 5,
                          child: _buildAlbumArt(song),
                        ),

                        SizedBox(height: 40),

                        // Song Info
                        _buildSongInfo(song),

                        SizedBox(height: 10),

                        // Progress Bar
                        StreamBuilder<Duration>(
                          stream: provider.positionStream,
                          builder: (context, snapshot) {
                            final position = snapshot.data ?? Duration.zero;
                            final duration = provider.duration;
                            return ProgressBar(
                              position: position,
                              duration: duration,
                              onSeek: (position) {
                                provider.seek(position);
                              },
                            );
                          },
                        ),

                        SizedBox(height: 5),
                        Row(
                          children: [
                            PlayBackSpeedWidget(),
                            const SizedBox(width: 10),
                            Expanded(child: VolumeSliderWidget()),
                          ],
                        ),
                        SizedBox(height: 5),
                        // Player Controls
                        PlayerControls(provider: provider),
                        SizedBox(height: 5),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(
              Icons.keyboard_arrow_down,
              color: Colors.white,
              size: 32,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          Text(
            'Now Playing',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          IconButton(
            icon: Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {
              // Show options menu
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAlbumArt(SongModel song) {
    return Container(
      width: 250,
      height: 250,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: song.albumArt != null
            ? Image.file(File(song.albumArt!), fit: BoxFit.cover)
            : Container(
                color: Color(0xFF282828),
                child: Icon(Icons.music_note, size: 100, color: Colors.grey),
              ),
      ),
    );
  }

  Widget _buildSongInfo(SongModel song) {
    return Column(
      children: [
        Text(
          song.title,
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: 8),
        Text(
          song.artist,
          style: TextStyle(color: Colors.grey, fontSize: 16),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
