// lib/services/playlist_service.dart
import 'package:on_audio_query/on_audio_query.dart' as query; // tk playlist service voi thu vien nay dat ten trung nhau ne phai them query de phan bt

// 2. Import file SongModel của bạn (nhớ sửa đường dẫn cho đúng vị trí file của bạn)
import '../models/song_model.dart';

class PlaylistService {
  final query.OnAudioQuery _audioQuery = query.OnAudioQuery();

  // Get all songs from device
  Future<List<SongModel>> getAllSongs() async {
    try {
      final List<query.SongModel> audioList = await _audioQuery.querySongs(
        sortType: query.SongSortType.TITLE,
        orderType: query.OrderType.ASC_OR_SMALLER,
        uriType: query.UriType.EXTERNAL,
        ignoreCase: true,
      );

      return audioList
          .map((audio) => SongModel.fromAudioQuery(audio))
          .toList();
    } catch (e) {
      throw Exception('Error loading songs: $e');
    }
  }

  // Get songs by artist
  Future<List<SongModel>> getSongsByArtist(String artist) async {
    final allSongs = await getAllSongs();
    return allSongs.where((song) => song.artist == artist).toList();
  }

  // Get songs by album
  Future<List<SongModel>> getSongsByAlbum(String album) async {
    final allSongs = await getAllSongs();
    return allSongs.where((song) => song.album == album).toList();
  }

  // Search songs
  Future<List<SongModel>> searchSongs(String query) async {
    final allSongs = await getAllSongs();
    final lowerQuery = query.toLowerCase();

    return allSongs.where((song) {
      return song.title.toLowerCase().contains(lowerQuery) ||
          song.artist.toLowerCase().contains(lowerQuery) ||
          (song.album?.toLowerCase().contains(lowerQuery) ?? false);
    }).toList();
  }
}
