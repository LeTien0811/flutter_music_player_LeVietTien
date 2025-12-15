package com.example.offline_music_player;

import androidx.annotation.NonNull;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugins.GeneratedPluginRegistrant;
import com.ryanheise.audioservice.AudioServiceActivity; // Import cái này

// Phải kế thừa AudioServiceActivity
public class MainActivity extends AudioServiceActivity {
    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine);
    }
}