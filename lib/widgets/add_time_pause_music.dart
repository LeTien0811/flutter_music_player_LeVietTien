import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:offline_music_player/providers/audio_provider.dart';

void showSleepTimerBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: const Color(0xFF191414),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) {
      return Consumer<AudioProvider>(
        builder: (context, audioProvider, child) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  'Hẹn giờ tắt nhạc',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Divider(color: Colors.grey, height: 1),

              if (audioProvider.isSleepTimerActive)
                ListTile(
                  leading: const Icon(Icons.timer_off, color: Colors.redAccent),
                  title: const Text('Tắt hẹn giờ', style: TextStyle(color: Colors.redAccent)),
                  onTap: () {
                    audioProvider.cancelSleepTimer();
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Đã hủy hẹn giờ')),
                    );
                  },
                ),

              _buildTimerOption(context, 15),
              _buildTimerOption(context, 30),
              _buildTimerOption(context, 45),
              _buildTimerOption(context, 60),

              const SizedBox(height: 20),
            ],
          );
        },
      );
    },
  );
}

Widget _buildTimerOption(BuildContext context, int minutes) {
  return ListTile(
    leading: const Icon(Icons.access_time, color: Colors.white),
    title: Text('$minutes phút', style: const TextStyle(color: Colors.white)),
    onTap: () {
      context.read<AudioProvider>().startSleepTimer(minutes);

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Nhạc sẽ tắt sau $minutes phút')),
      );
    },
  );
}