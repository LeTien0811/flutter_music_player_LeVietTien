import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:offline_music_player/providers/audio_provider.dart';
import 'package:provider/provider.dart';

class VolumeSliderWidget extends StatefulWidget {
  const VolumeSliderWidget({super.key});

  @override
  State<VolumeSliderWidget> createState() => _VolumeSliderWidgetState();
}

class _VolumeSliderWidgetState extends State<VolumeSliderWidget> {
  @override
  Widget build(BuildContext context) {
    return Consumer<AudioProvider>(
        builder: (context, provider, child) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                provider.volume == 0 ? Icons.volume_off : Icons.volume_mute,
                color: Colors.grey,
                size: 20,
              ),
              Expanded(
                  child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 2,
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                        overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                        activeTrackColor: Colors.white,
                        inactiveTrackColor: Colors.grey,
                        thumbColor: Colors.white,
                      ),
                      child: Slider(
                          value: provider.volume,
                          min: 0.0,
                          max: 1.0,
                          onChanged: (value) {
                            provider.setVolume(value);
                          }
                      )
                  )
              )
            ],
          );
        }
    );
  }
}
