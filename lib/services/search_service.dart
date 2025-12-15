// lib/services/music_utils.dart
import 'package:offline_music_player/models/song_model.dart';
import 'package:offline_music_player/utils/constants.dart';

class SearchService {
  static List<SongModel> searchSongs(List<SongModel> songs, String query, {SearchFilter filter = SearchFilter.all}) {
    if (query.isEmpty) return songs;
    final lowerQuery = query.toLowerCase();

    return songs.where((song) {
      final title = (song.title).toLowerCase();
      final artist = (song.artist).toLowerCase();
      final album = (song.album ?? '').toLowerCase();

      switch (filter) {
        case SearchFilter.title:
          return title.contains(lowerQuery);
        case SearchFilter.artist:
          return artist.contains(lowerQuery);
        case SearchFilter.album:
          return album.contains(lowerQuery);
        default:
          return title.contains(lowerQuery) ||
              artist.contains(lowerQuery) ||
              album.contains(lowerQuery);
      }
    }).toList();
  }

  static void sortSongs(List<SongModel> songs, SortOption option) {
    switch (option) {
      case SortOption.title:
        songs.sort((a, b) => a.title.compareTo(b.title));
        break;
      case SortOption.artist:
        songs.sort((a, b) => a.artist.compareTo(b.artist));
        break;
      case SortOption.album:
        songs.sort((a, b) => a.album!.compareTo(b.album ?? ''));
        break;
      case SortOption.dateAdded:
        songs.sort((a, b) => b.id.compareTo(a.id));
        break;
    }
  }
}