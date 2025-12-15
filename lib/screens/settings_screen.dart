// lib/screenshots/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:offline_music_player/providers/audio_provider.dart';
import 'package:offline_music_player/widgets/add_time_pause_music.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF191414),
      appBar: AppBar(
        title: const Text('Cài đặt', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        leading: const BackButton(color: Colors.white),
      ),
      body: ListView(
        children: [
          _buildSectionHeader('Chung'),
          _buildSettingItem(
            icon: Icons.timer,
            title: 'Hẹn giờ tắt nhạc',
            subtitle: context.watch<AudioProvider>().isSleepTimerActive
                ? 'Đang bật'
                : 'Tự động tắt nhạc sau một khoảng thời gian',
            onTap: () {
              showSleepTimerBottomSheet(context);
            },
          ),
          _buildSettingItem(
            icon: Icons.equalizer,
            title: 'Bộ chỉnh âm (Equalizer)',
            subtitle: 'Điều chỉnh bass, treble',
            onTap: () {
              // TODO: Open System Equalizer
            },
          ),

          _buildSectionHeader('Dữ liệu & Quyền'),
          _buildSettingItem(
            icon: Icons.storage,
            title: 'Quyền truy cập bộ nhớ',
            subtitle: 'Quản lý quyền đọc file nhạc',
            onTap: () async {
              await openAppSettings();
            },
          ),

          _buildSectionHeader('Thông tin ứng dụng'),
          _buildSettingItem(
            icon: Icons.person_outline,
            title: 'Tác giả',
            subtitle: 'Lê Việt Tiến',
            onTap: null,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      subtitle: subtitle != null
          ? Text(subtitle, style: TextStyle(color: Colors.grey[400]))
          : null,
      trailing: onTap != null
          ? const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey)
          : null,
      onTap: onTap,
    );
  }
}