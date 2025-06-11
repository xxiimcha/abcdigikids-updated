import 'package:audioplayers/audioplayers.dart';

class MusicService {
  late AudioPlayer _audioPlayer;

  MusicService() {
    _audioPlayer = AudioPlayer();
  }

  Future<void> playBackgroundMusic({double volume = 0.5}) async {
    await _audioPlayer.play(
      AssetSource('assets/music/music.mp3'),
      volume: volume,
    );
    await _audioPlayer.setReleaseMode(ReleaseMode.loop);
  }

  Future<void> stopMusic() async {
    await _audioPlayer.stop();
  }

  Future<void> pauseMusic() async {
    await _audioPlayer.pause();
  }

  // ✅ New: Set volume
  Future<void> setVolume(double value) async {
    await _audioPlayer.setVolume(value);
  }
}
