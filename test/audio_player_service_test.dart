import 'package:audio_service/audio_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:just_audio/just_audio.dart';
import 'package:offline_music_player/models/song_model.dart';
import 'package:offline_music_player/providers/audio_provider.dart';
import 'package:offline_music_player/services/storage_service.dart';
import 'package:rxdart/rxdart.dart';

import 'package:offline_music_player/services/my_audio_handle.dart' as custom_audio;

class MockAudioHandler extends Mock implements custom_audio.MyAudioHandler {}
class MockStorageService extends Mock implements StorageService {}

class MockAudioPlayer extends Mock implements AudioPlayer {}

class FakeMediaItem extends Fake implements MediaItem {}

void main() {
  late AudioProvider provider;
  late MockAudioHandler mockHandler;
  late MockStorageService mockStorage;
  late MockAudioPlayer mockPlayer;

  final mockSong = SongModel(
    id: "1",
    title: "Test Song",
    artist: "Test Artist",
    album: "Test Album",
    filePath: "path/to/song.mp3",
    albumArt: "path/to/art.jpg",
    duration: const Duration(seconds: 200),
  );

  setUpAll(() {
    registerFallbackValue(Duration.zero);
    registerFallbackValue(FakeMediaItem());
    registerFallbackValue(<MediaItem>[]);
    registerFallbackValue(AudioServiceRepeatMode.none);
    registerFallbackValue(AudioServiceShuffleMode.none);
  });

  setUp(() async {
    mockHandler = MockAudioHandler();
    mockStorage = MockStorageService();
    mockPlayer = MockAudioPlayer();


    final playbackStateSubject = BehaviorSubject<PlaybackState>.seeded(PlaybackState(playing: false));
    final mediaItemSubject = BehaviorSubject<MediaItem?>.seeded(null);

    final durationSubject = BehaviorSubject<Duration?>.seeded(Duration.zero);
    final positionSubject = BehaviorSubject<Duration>.seeded(Duration.zero);


    when(() => mockPlayer.durationStream).thenAnswer((_) => durationSubject.stream);
    when(() => mockPlayer.createPositionStream(
        minPeriod: any(named: 'minPeriod'),
        maxPeriod: any(named: 'maxPeriod')
    )).thenAnswer((_) => positionSubject.stream);

    when(() => mockPlayer.setVolume(any())).thenAnswer((_) async {});


    when(() => mockHandler.playbackState).thenAnswer((_) => playbackStateSubject);
    when(() => mockHandler.mediaItem).thenAnswer((_) => mediaItemSubject);

    when(() => mockHandler.player).thenReturn(mockPlayer);

    when(() => mockHandler.setRepeatMode(any())).thenAnswer((_) async {});
    when(() => mockHandler.setShuffleMode(any())).thenAnswer((_) async {});
    when(() => mockHandler.setPlaylist(any(), any())).thenAnswer((_) async {});
    when(() => mockHandler.setSpeed(any())).thenAnswer((_) async {});
    when(() => mockHandler.play()).thenAnswer((_) async {});
    when(() => mockHandler.pause()).thenAnswer((_) async {});
    when(() => mockHandler.seek(any())).thenAnswer((_) async {});
    when(() => mockHandler.skipToNext()).thenAnswer((_) async {});
    when(() => mockHandler.skipToPrevious()).thenAnswer((_) async {});

    when(() => mockStorage.getShuffleState()).thenAnswer((_) async => false);
    when(() => mockStorage.getRepeatMode()).thenAnswer((_) async => 0);
    when(() => mockStorage.getVolume()).thenAnswer((_) async => 1.0);
    when(() => mockStorage.saveLastPlayed(any())).thenAnswer((_) async {});
    when(() => mockStorage.saveVolume(any())).thenAnswer((_) async {});
    when(() => mockStorage.saveShuffleState(any())).thenAnswer((_) async {});
    when(() => mockStorage.saveRepeatMode(any())).thenAnswer((_) async {});

    when(() => mockStorage.getLastPlayed()).thenAnswer((_) async => null);
    when(() => mockStorage.getPosition()).thenAnswer((_) async => 0);

    provider = AudioProvider(mockHandler, mockStorage);

    await Future.delayed(const Duration(milliseconds: 50));
  });

  group('AudioProvider Tests', () {
    test('Khởi tạo ban đầu thành công', () {
      expect(provider.isPlaying, false);
      expect(provider.playlist, isEmpty);
      expect(provider.volume, 1.0);
    });

    test('Hàm setPlaylist cập nhật danh sách và gọi Handler', () async {
      await provider.setPlaylist([mockSong], 0);

      expect(provider.playlist.length, 1);
      expect(provider.currentIndex, 0);

      verify(() => mockHandler.setPlaylist(any(), 0)).called(1);
      verify(() => mockStorage.saveLastPlayed("1")).called(1);
    });

    test('Hàm playPause hoạt động đúng logic', () async {
      await provider.playPause();
      verify(() => mockHandler.play()).called(1);
    });

    test('Hàm setVolume cập nhật giá trị và lưu lại', () async {
      await provider.setVolume(0.5);

      expect(provider.volume, 0.5);

      verify(() => mockPlayer.setVolume(0.5)).called(1);

      verify(() => mockStorage.saveVolume(0.5)).called(1);
    });
  });
}