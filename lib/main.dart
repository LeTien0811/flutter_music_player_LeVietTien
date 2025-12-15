import 'package:flutter/material.dart';
import 'package:offline_music_player/providers/audio_provider.dart';
import 'package:offline_music_player/providers/playlist_provider.dart';
import 'package:offline_music_player/screens/home_screens.dart';
import 'package:offline_music_player/services/my_audio_handle.dart';
import 'package:offline_music_player/services/storage_service.dart';
import 'package:provider/provider.dart';
late MyAudioHandler audioHandler;
Future<void> main()  async{
  WidgetsFlutterBinding.ensureInitialized();
  StorageService  storageService = StorageService();
  audioHandler = await initAudioService();
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => AudioProvider(audioHandler, storageService)),
      ChangeNotifierProvider(create: (_) => PlaylistProvider()),
    ],
    child: const MainApp(),
  ));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}
