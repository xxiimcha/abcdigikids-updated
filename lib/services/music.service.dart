import 'package:audioplayers/audioplayers.dart';

class MusicService {
  late AudioPlayer _audioPlayer; // Use `late` to ensure it is initialized before being used

  MusicService() {
    _audioPlayer = AudioPlayer(); // Initialize here
  }

  // Start playing the music in the background
  Future<void> playBackgroundMusic() async {
    await _audioPlayer.play(AssetSource('assets/music/music.mp3'), volume: 0.5); // Path to your audio
    _audioPlayer.setReleaseMode(ReleaseMode.loop); // Loop the music indefinitely
  }

  // Stop the music
  Future<void> stopMusic() async {
    await _audioPlayer.stop();
  }

  // Pause the music
  Future<void> pauseMusic() async {
    await _audioPlayer.pause();
  }
}
