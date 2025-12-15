// lib/screenshots/home_screen.dart
import 'package:flutter/material.dart';
import 'package:offline_music_player/models/song_model.dart';
import 'package:offline_music_player/providers/audio_provider.dart';
import 'package:offline_music_player/screens/playlist_screen.dart';
import 'package:offline_music_player/screens/search_screen.dart';
import 'package:offline_music_player/screens/settings_screen.dart';
import 'package:offline_music_player/services/permission_service.dart';
import 'package:offline_music_player/services/playlist_service.dart';
import 'package:offline_music_player/widgets/mini_player.dart';
import 'package:offline_music_player/widgets/song_title.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PlaylistService _playlistService = PlaylistService();

  List<SongModel> _songs = [];
  bool _isLoading = true;
  bool _hasPermission = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkPermissionAndLoadSongs();
    });
  }
  Future<void> _checkPermissionAndLoadSongs() async {
    final permissionService = PermissionService(); // Hoặc lấy từ Provider/DI

    // Gọi hàm thông minh mới viết
    final hasPermission = await permissionService.requestPermission();

    if (hasPermission) {
      await _loadSongs();
      print("Đã cấp quyền, bắt đầu load nhạc");
    } else {
      print("Người dùng từ chối cấp quyền");

    }
    if (mounted) {

      setState(() {
        _hasPermission = hasPermission;
        _isLoading = false;
      });
    }
  }

  Future<void> _loadSongs() async {
    try {
      final songs = await _playlistService.getAllSongs();
      if (mounted) {
        context.read<AudioProvider>().setAllSongs(songs);
      }
      setState(() {
        _songs = songs;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading songs: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF191414),
      body: SafeArea(
        child: Column(
          children: [
            // App Bar
            _buildAppBar(),

            // Content
            Expanded(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : !_hasPermission
                  ? _buildPermissionDenied()
                  : _songs.isEmpty
                  ? _buildNoSongs()
                  : _buildSongList(),
            ),

            // Mini Player
            Consumer<AudioProvider>(
              builder: (context, provider, child) {
                if (provider.currentSong == null) return SizedBox.shrink();
                return MiniPlayer();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'My Music',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: Icon(Icons.search, color: Colors.white),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SearchScreen(allSongs: _songs),
                    ),
                  );
                },
              ),

              IconButton(
                icon: Icon(Icons.featured_play_list, color: Colors.white),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PlaylistScreen()),
                  );
                },
              ),

              IconButton(
                icon: Icon(Icons.settings, color: Colors.white),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SettingsScreen()),
                  );
                },
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildSongList() {
    return ListView.builder(
      itemCount: _songs.length,
      itemBuilder: (context, index) {
        final song = _songs[index];
        return SongTile(
          song: song,
          onTap: () {
            context.read<AudioProvider>().setPlaylist(_songs, index);
          },
        );
      },
    );
  }

  Widget _buildPermissionDenied() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.music_off, size: 80, color: Colors.grey),
          SizedBox(height: 20),
          Text(
            'Storage Permission Required',
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          SizedBox(height: 10),
          Text(
            'Please grant storage permission to access music',
            style: TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              await openAppSettings();
            },
            child: Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  Widget _buildNoSongs() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.music_note, size: 80, color: Colors.grey),
          SizedBox(height: 20),
          Text(
            'No Music Found',
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          SizedBox(height: 10),
          Text(
            'Add some music files to your device',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
