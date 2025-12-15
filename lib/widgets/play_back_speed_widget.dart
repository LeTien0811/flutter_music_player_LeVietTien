import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:offline_music_player/providers/audio_provider.dart';
import 'package:provider/provider.dart';

class PlayBackSpeedWidget extends StatelessWidget {

  void _speedDialog(BuildContext context, AudioProvider provider) {
    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.white,
        shape:  RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        builder: (ctx) {
          final speeds = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text("Tốc độ phát",
                    style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              const Divider(color: Colors.grey),
              ...speeds.map((speed) => ListTile(
                  title: Text(
                      '${speed}x',
                      style: const TextStyle(
                          color: Colors.black
                      )
                  ),
                trailing: provider.speed == speed
                    ? const Icon(Icons.check, color: Colors.green)
                    : null,
                onTap: () {
                  provider.setSpeed(speed);
                  Navigator.pop(context);
                },
              )).toList(),
              const SizedBox(height: 20),
            ],
          );
        }
    );
  }

  @override
  Widget build(BuildContext context) {

    return Consumer<AudioProvider>(
        builder: (context, provider, child) {
          return TextButton(
              style: TextButton.styleFrom(
                padding: const EdgeInsets.all(10),
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onPressed: () {
                _speedDialog(context, provider);
              },
              child: Text(
                'Tốc độ phát: ${provider.speed}',
                style: TextStyle(
                  color: Colors.black
                ),
              )
          );
        }
    );
  }
}



