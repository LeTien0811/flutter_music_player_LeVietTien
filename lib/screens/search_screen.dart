// lib/screenshots/search_screen.dart
import 'package:flutter/material.dart';
import 'package:offline_music_player/services/search_service.dart';
import 'package:offline_music_player/utils/constants.dart';
import 'package:provider/provider.dart';
import 'package:offline_music_player/models/song_model.dart';
import 'package:offline_music_player/providers/audio_provider.dart';
import 'package:offline_music_player/widgets/song_title.dart';

class SearchScreen extends StatefulWidget {
  final List<SongModel> allSongs;

  const SearchScreen({Key? key, required this.allSongs}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  List<SongModel> _filteredSongs = [];
  final TextEditingController _searchController = TextEditingController();
  SortOption _currentSortOption = SortOption.title;
  SearchFilter _currentFilter = SearchFilter.all;

  @override
  void initState() {
    super.initState();
    _filteredSongs = widget.allSongs;
  }

  void _runFilter(String keyword) {
    final searchText = keyword.isEmpty && _searchController.text.isNotEmpty
        ? _searchController.text
        : keyword;
    setState(() {
      _filteredSongs = SearchService.searchSongs(
          widget.allSongs,
          searchText,
          filter: _currentFilter
      );

      SearchService.sortSongs(_filteredSongs, _currentSortOption);
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF191414), // Màu nền Spotify-like
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: Colors.white),
        title: TextField(
          controller: _searchController,
          onChanged: (value) => _runFilter(value),
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Tìm tên bài hát, nghệ sĩ...',
            hintStyle: TextStyle(color: Colors.grey[400]),
            border: InputBorder.none,
          ),
          autofocus: true, // Tự động bật bàn phím
        ),
        actions: [
          if (_searchController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear, color: Colors.white),
              onPressed: () {
                _searchController.clear();
                _runFilter('');
              },
            ),

          PopupMenuButton<SortOption>(
            icon: Icon(Icons.sort, color: Colors.white),
            color: Colors.grey[850],
            onSelected: (SortOption result) {
              setState(() {
                _currentSortOption = result;
                SearchService.sortSongs(widget.allSongs, _currentSortOption);
              });
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<SortOption>>[
              const PopupMenuItem<SortOption>(
                value: SortOption.title,
                child: Text('Tên bài hát', style: TextStyle(color: Colors.white)),
              ),
              const PopupMenuItem<SortOption>(
                value: SortOption.artist,
                child: Text('Nghệ sĩ', style: TextStyle(color: Colors.white)),
              ),
              const PopupMenuItem<SortOption>(
                value: SortOption.album,
                child: Text('Album', style: TextStyle(color: Colors.white)),
              ),
              const PopupMenuItem<SortOption>(
                value: SortOption.dateAdded,
                child: Text('Ngày thêm', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildFilterChip('Tất cả', SearchFilter.all),
                const SizedBox(width: 8),
                _buildFilterChip('Tên bài', SearchFilter.title),
                const SizedBox(width: 8),
                _buildFilterChip('Nghệ sĩ', SearchFilter.artist),
                const SizedBox(width: 8),
                _buildFilterChip('Album', SearchFilter.album),
              ],
            ),
          ),
          Expanded(child: _filteredSongs.isEmpty
              ? Center(
            child: Text(
              'Không tìm thấy bài hát nào',
              style: TextStyle(color: Colors.grey),
            ),
          )
              : ListView.builder(
            itemCount: _filteredSongs.length,
            itemBuilder: (context, index) {
              final song = _filteredSongs[index];
              return SongTile(
                song: song,
                onTap: () {
                  // Khi bấm vào kết quả tìm kiếm, set playlist là danh sách tìm được
                  // hoặc tìm vị trí của bài hát trong playlist gốc để play
                  final originalIndex = widget.allSongs.indexOf(song);
                  if (originalIndex != -1) {
                    context.read<AudioProvider>().setPlaylist(widget.allSongs, originalIndex);
                  }
                  Navigator.pop(context); // Đóng màn hình tìm kiếm
                },
              );
            },
          ),
          )
        ],
      )
    );
  }
  Widget _buildFilterChip(String label, SearchFilter filter) {
    final isSelected = _currentFilter == filter;
    return ChoiceChip(
      label: Text(label),
      labelStyle: TextStyle(
        color: isSelected ? Colors.black : Colors.white,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      selected: isSelected,
      selectedColor: Colors.green, // Màu xanh Spotify
      backgroundColor: Colors.grey[800],
      onSelected: (bool selected) {
        setState(() {
          _currentFilter = filter;
          _runFilter(label); // Chạy lại bộ lọc khi bấm chọn
        });
      },
    );
  }
}