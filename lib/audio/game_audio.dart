import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GameAudio {
  final AudioPlayer fx = AudioPlayer();
  final AudioPlayer music = AudioPlayer();

  static const String soundEnabledKey = 'audio_sound_enabled';
  static const String musicEnabledKey = 'audio_music_enabled';
  static const String soundVolumeKey = 'audio_sound_volume';
  static const String musicVolumeKey = 'audio_music_volume';

  bool soundEnabled = true;
  bool musicEnabled = true;

  double soundVolume = 1.0;
  double musicVolume = 0.7;

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    final prefs = await SharedPreferences.getInstance();

    soundEnabled = prefs.getBool(soundEnabledKey) ?? true;
    musicEnabled = prefs.getBool(musicEnabledKey) ?? true;

    soundVolume = prefs.getDouble(soundVolumeKey) ?? 1.0;
    musicVolume = prefs.getDouble(musicVolumeKey) ?? 0.7;

    await music.setReleaseMode(ReleaseMode.loop);

    await fx.setVolume(soundEnabled ? soundVolume : 0.0);
    await music.setVolume(musicEnabled ? musicVolume : 0.0);

    _initialized = true;
  }

  // 🔊 Sound effects
  Future<void> sound(String name) async {
    if (!soundEnabled || soundVolume <= 0) return;

    try {
      await fx.stop();
      await fx.setVolume(soundVolume);
      await fx.play(
        AssetSource('audio/$name'),
      );
    } catch (_) {}
  }

  // 🎵 Background music
  Future<void> startMusic() async {
    if (!musicEnabled || musicVolume <= 0) return;

    try {
      await music.stop();
      await music.setVolume(musicVolume);
      await music.play(
        AssetSource('audio/background_music.mp3'),
      );
    } catch (_) {}
  }

  Future<void> pauseMusic() async {
    try {
      await music.pause();
    } catch (_) {}
  }

  Future<void> resumeMusic() async {
    if (!musicEnabled || musicVolume <= 0) return;

    try {
      await music.setVolume(musicVolume);
      await music.resume();
    } catch (_) {}
  }

  Future<void> stopMusic() async {
    try {
      await music.stop();
    } catch (_) {}
  }

  // 🔊 Enable / disable sound effects
  Future<void> setSoundEnabled(bool value) async {
    soundEnabled = value;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(soundEnabledKey, value);

    await fx.setVolume(
      value ? soundVolume : 0.0,
    );
  }

  // 🎵 Enable / disable background music
  Future<void> setMusicEnabled(bool value) async {
    musicEnabled = value;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(musicEnabledKey, value);

    if (!value) {
      await music.setVolume(0.0);
      await music.stop();
    } else {
      await music.setVolume(musicVolume);
    }
  }

  // 🔉 Sound-effect volume
  Future<void> setSoundVolume(double value) async {
    soundVolume = value.clamp(0.0, 1.0);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(
      soundVolumeKey,
      soundVolume,
    );

    await fx.setVolume(
      soundEnabled ? soundVolume : 0.0,
    );
  }

  // 🎵 Music volume
  Future<void> setMusicVolume(double value) async {
    musicVolume = value.clamp(0.0, 1.0);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(
      musicVolumeKey,
      musicVolume,
    );

    await music.setVolume(
      musicEnabled ? musicVolume : 0.0,
    );
  }

  Future<void> resetToDefaults() async {
    soundEnabled = true;
    musicEnabled = true;
    soundVolume = 1.0;
    musicVolume = 0.7;

    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(soundEnabledKey, true);
    await prefs.setBool(musicEnabledKey, true);
    await prefs.setDouble(soundVolumeKey, 1.0);
    await prefs.setDouble(musicVolumeKey, 0.7);

    await fx.setVolume(soundVolume);
    await music.setVolume(musicVolume);
  }

  void dispose() {
    fx.dispose();
    music.dispose();
  }
}