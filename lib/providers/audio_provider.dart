import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:offline_music_player/models/song_model.dart';
import 'package:offline_music_player/services/storage_service.dart';

import 'package:offline_music_player/services/my_audio_handle.dart' as custom_audio;

class AudioProvider extends ChangeNotifier {
  final AudioHandler _audioHandler;
  final StorageService _storageService;

  AudioProvider(this._audioHandler, this._storageService) {
    _init();
    _listenToHandlerEvents();
  }

  AudioPlayer get _player => (_audioHandler as custom_audio.MyAudioHandler).player;

  List<SongModel> _allSongs = [];
  List<SongModel> _playlist = [];
  int _currentIndex = 0;

  bool _isPlaying = false;
  bool _isShuffleEnabled = false;
  LoopMode _loopMode = LoopMode.off;
  Duration _duration = Duration.zero;

  double _volume = 1.0;
  double _speed = 1.0;

  Timer? _sleepTimer;


  List<SongModel> get allSongs => _allSongs;
  List<SongModel> get playlist => _playlist;
  int get currentIndex => _currentIndex;

  SongModel? get currentSong =>
      (_playlist.isNotEmpty && _currentIndex < _playlist.length)
          ? _playlist[_currentIndex]
          : null;

  bool get isPlaying => _isPlaying;
  bool get isShuffleEnabled => _isShuffleEnabled;
  LoopMode get loopMode => _loopMode;
  double get volume => _volume;
  double get speed => _speed;
  bool get isSleepTimerActive => _sleepTimer != null && _sleepTimer!.isActive;
  Duration get duration => _duration;

  Stream<bool> get playingStream => _audioHandler.playbackState
      .map((state) => state.playing)
      .distinct();

  Stream<PlaybackState> get playbackStateStream => _audioHandler.playbackState;

  Stream<Duration> get positionStream => _player.createPositionStream(
    minPeriod: const Duration(milliseconds: 200),
    maxPeriod: const Duration(milliseconds: 200),
  );

  Future<void> _init() async {
    _isShuffleEnabled = await _storageService.getShuffleState();
    final repeatIndex = await _storageService.getRepeatMode();
    _loopMode = LoopMode.values[repeatIndex];
    _volume = await _storageService.getVolume();

    if (_isShuffleEnabled) {
      await _audioHandler.setShuffleMode(AudioServiceShuffleMode.all);
    }
    await _audioHandler.setRepeatMode(_mapLoopModeToRepeatMode(_loopMode));
    await _player.setVolume(_volume);
    await _audioHandler.setSpeed(_speed);
  }

  void _listenToHandlerEvents() {
    _audioHandler.playbackState.listen((state) {
      _isPlaying = state.playing;

      if (state.queueIndex != null && state.queueIndex != _currentIndex) {
        _currentIndex = state.queueIndex!;
        notifyListeners();
      }
      notifyListeners();
    });

    _audioHandler.mediaItem.listen((item) {
      if (item != null) {
        _duration = item.duration ?? Duration.zero;
        notifyListeners();
      }
    });

    _player.durationStream.listen((d) {
      if (d != null && d != _duration) {
        _duration = d;
        notifyListeners();
      }
    });
  }

  // --- ACTIONS ---
  void setAllSongs(List<SongModel> songs) {
    _allSongs = songs;
    notifyListeners();
    _restoreLastSession();
  }

  Future<void> _restoreLastSession() async {
    if (_allSongs.isEmpty) return;

    final lastSongId = await _storageService.getLastPlayed();
    final lastPosition = await _storageService.getPosition();

    if (lastSongId != null) {
      final index = _allSongs.indexWhere((s) => s.id == lastSongId);

      if (index != -1) {
        print("Restoring: $lastSongId at $lastPosition");

        await setPlaylist(_allSongs, index);

        if (lastPosition > 0) {
          if (_player.duration == null) {
            try {
              await _player.processingStateStream.firstWhere((state) =>
              state == ProcessingState.ready || state == ProcessingState.buffering
              ).timeout(const Duration(seconds: 2));
            } catch (e) {
            }
          }
          await seek(Duration(milliseconds: lastPosition));
        }

        await _audioHandler.pause();
      }
    }
  }

  Future<void> setPlaylist(List<SongModel> songs, int startIndex) async {
    _playlist = songs;
    _currentIndex = startIndex;
    notifyListeners();

    final mediaItems = songs.map((song) => MediaItem(
      id: song.filePath,
      album: song.album,
      title: song.title,
      artist: song.artist,
      duration: null,
      artUri: song.albumArt != null
          ? Uri.file(song.albumArt!)
          : Uri.parse("android.resource://com.example.offline_music_player/drawable/ic_launcher"),
      extras: {'id': song.id},
    )).toList();

    await (_audioHandler as dynamic).setPlaylist(mediaItems, startIndex);

    if (startIndex < songs.length) {
      await _storageService.saveLastPlayed(songs[startIndex].id);
    }
  }

  Future<void> playPause() async {
    if (_isPlaying) {
      final currentPos = _player.position.inMilliseconds;
      await _storageService.savePosition(currentPos);
      await _audioHandler.pause();
    } else {
      await _audioHandler.play();
    }
  }

  Future<void> next() async => await _audioHandler.skipToNext();
  Future<void> previous() async => await _audioHandler.skipToPrevious();

  Future<void> seek(Duration position) async {
    await _audioHandler.seek(position);
    await _storageService.savePosition(position.inMilliseconds);
  }

  Future<void> setVolume(double value) async {
    _volume = value;
    notifyListeners();
    await _player.setVolume(value);
    await _storageService.saveVolume(value);
  }

  Future<void> setSpeed(double value) async {
    _speed = value;
    await _audioHandler.setSpeed(value);
    notifyListeners();
  }

  Future<void> toggleShuffle() async {
    _isShuffleEnabled = !_isShuffleEnabled;
    await _audioHandler.setShuffleMode(
        _isShuffleEnabled ? AudioServiceShuffleMode.all : AudioServiceShuffleMode.none
    );
    await _storageService.saveShuffleState(_isShuffleEnabled);
    notifyListeners();
  }

  Future<void> toggleRepeat() async {
    switch (_loopMode) {
      case LoopMode.off: _loopMode = LoopMode.all; break;
      case LoopMode.all: _loopMode = LoopMode.one; break;
      case LoopMode.one: _loopMode = LoopMode.off; break;
    }
    await _audioHandler.setRepeatMode(_mapLoopModeToRepeatMode(_loopMode));
    await _storageService.saveRepeatMode(_loopMode.index);
    notifyListeners();
  }

  void startSleepTimer(int minutes) {
    cancelSleepTimer();
    _sleepTimer = Timer(Duration(minutes: minutes), () {
      if (_isPlaying) playPause();
      _sleepTimer = null;
      notifyListeners();
    });
    notifyListeners();
  }

  void cancelSleepTimer() {
    _sleepTimer?.cancel();
    _sleepTimer = null;
    notifyListeners();
  }

  AudioServiceRepeatMode _mapLoopModeToRepeatMode(LoopMode mode) {
    switch (mode) {
      case LoopMode.all: return AudioServiceRepeatMode.all;
      case LoopMode.one: return AudioServiceRepeatMode.one;
      default: return AudioServiceRepeatMode.none;
    }
  }
}