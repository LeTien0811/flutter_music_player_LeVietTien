// lib/widgets/mini_player.dart
import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:offline_music_player/providers/audio_provider.dart';
import 'package:offline_music_player/screens/now_playing_screen.dart';
import 'package:provider/provider.dart';

class MiniPlayer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => NowPlayingScreen()),
        );
      },
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          color: Color(0xFF282828),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: Offset(0, -5),
            ),
          ],
        ),
        child: Consumer<AudioProvider>(
          builder: (context, provider, child) {
            final song = provider.currentSong;

            if (song == null) return SizedBox.shrink();

            return Column(
              children: [
                // Progress indicator
                StreamBuilder<PlaybackState>(

                  stream: provider.playbackStateStream,
                  builder: (context, snapshot) {
                    final state = snapshot.data;
                    final current = state?.position.inMilliseconds ?? 0;
                    final total = provider.duration.inMilliseconds;
                    double progress = 0.0;
                    if (total > 0) {
                      progress = current / total;
                      // Kẹp giá trị để không bị lỗi quá giới hạn
                      if (progress > 1.0) progress = 1.0;
                      if (progress < 0.0) progress = 0.0;
                    }
                    return LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.grey[800],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFF1DB954),
                      ),
                      minHeight: 2,
                    );
                  },
                ),

                // Player content
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        // Album art
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: Colors.grey[800],
                          ),
                          child: song.albumArt != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: Image.file(
                                    File(song.albumArt!),
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Icon(Icons.music_note, color: Colors.grey),
                        ),

                        SizedBox(width: 12),

                        // Song info
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                song.title,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                song.artist,
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),

                        // Play/Pause button
                        StreamBuilder<bool>(
                          stream: provider.playingStream,
                          builder: (context, snapshot) {
                            final isPlaying = snapshot.data ?? false;
                            return IconButton(
                              icon: Icon(
                                isPlaying ? Icons.pause : Icons.play_arrow,
                                color: Colors.white,
                                size: 32,
                              ),
                              onPressed: () => provider.playPause(),
                            );
                          },
                        ),

                        // Next button
                        IconButton(
                          icon: Icon(Icons.skip_next, color: Colors.white),
                          onPressed: () => provider.next(),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
