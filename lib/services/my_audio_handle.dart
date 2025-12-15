import 'dart:ui';

import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

Future<MyAudioHandler> initAudioService() async {
  return await AudioService.init(
    builder: () => MyAudioHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.example.offline_music_player.channel.audio',
      androidNotificationChannelName: 'Music Playback',
      notificationColor: Color(0xFF1DB954),
      androidNotificationIcon: 'mipmap/ic_launcher',
      androidNotificationOngoing: true,
      androidStopForegroundOnPause: true,
    ),
  );
}

class MyAudioHandler extends BaseAudioHandler with QueueHandler, SeekHandler {
  final _player = AudioPlayer();

  AudioPlayer get player => _player;

  MyAudioHandler() {
    _init();
  }

  void _init() {
    _player.playbackEventStream.listen(_broadcastState);

    _player.currentIndexStream.listen((index) {
      if (index != null && queue.value.isNotEmpty) {
        if (index < queue.value.length) {
          mediaItem.add(queue.value[index]);
        }
      }
    });

    _player.durationStream.listen((duration) {
      final index = _player.currentIndex;
      final newDuration = duration ?? Duration.zero;

      if (index != null && queue.value.isNotEmpty && index < queue.value.length) {
        final oldMediaItem = queue.value[index];
        final newMediaItem = oldMediaItem.copyWith(duration: newDuration);

        final newQueue = List<MediaItem>.from(queue.value);
        newQueue[index] = newMediaItem;
        queue.add(newQueue);

        mediaItem.add(newMediaItem);
      }
    });

    _player.processingStateStream.listen((state) {
      if (state == ProcessingState.completed) {
        skipToNext();
      }
    });
  }

  void _broadcastState(PlaybackEvent event) {
    final playing = _player.playing;
    final queueIndex = event.currentIndex;

    playbackState.add(playbackState.value.copyWith(
      controls: [
        MediaControl.skipToPrevious,
        if (playing) MediaControl.pause else MediaControl.play,
        MediaControl.skipToNext,
      ],
      systemActions: const {
        MediaAction.seek,
      },
      androidCompactActionIndices: const [0, 1, 2],
      processingState: const {
        ProcessingState.idle: AudioProcessingState.idle,
        ProcessingState.loading: AudioProcessingState.loading,
        ProcessingState.buffering: AudioProcessingState.buffering,
        ProcessingState.ready: AudioProcessingState.ready,
        ProcessingState.completed: AudioProcessingState.completed,
      }[_player.processingState]!,
      playing: playing,
      updatePosition: _player.position,
      bufferedPosition: _player.bufferedPosition,
      speed: _player.speed,
      queueIndex: queueIndex,
    ));
  }

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> stop() => _player.stop();

  @override
  Future<void> setSpeed(double speed) async {
    await _player.setSpeed(speed);
    _broadcastState(_player.playbackEvent);
  }

  Future<void> setPlaylist(List<MediaItem> mediaItems, int initialIndex) async {
    queue.add(mediaItems);
    mediaItem.add(mediaItems[initialIndex]);

    final audioSource = ConcatenatingAudioSource(
      children: mediaItems.map((item) => AudioSource.uri(
        Uri.parse(item.id),
        tag: item,
      )).toList(),
    );

    try {
      await _player.setAudioSource(audioSource, initialIndex: initialIndex);
    } catch (e) {
      print("Error loading playlist: $e");
    }
  }

  @override
  Future<void> setShuffleMode(AudioServiceShuffleMode shuffleMode) async {
    final enabled = shuffleMode == AudioServiceShuffleMode.all;
    if (enabled) {
      await _player.shuffle();
    }
    await _player.setShuffleModeEnabled(enabled);
  }

  @override
  Future<void> setRepeatMode(AudioServiceRepeatMode repeatMode) async {
    final loopMode = {
      AudioServiceRepeatMode.none: LoopMode.off,
      AudioServiceRepeatMode.one: LoopMode.one,
      AudioServiceRepeatMode.all: LoopMode.all,
    }[repeatMode]!;
    await _player.setLoopMode(loopMode);
  }

  @override
  Future<void> skipToNext() => _player.seekToNext();

  @override
  Future<void> skipToPrevious() => _player.seekToPrevious();
}