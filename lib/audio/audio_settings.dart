import 'package:flutter/material.dart';

import '../audio/game_audio.dart';

class AudioSettings {
  static Future<void> show(
      BuildContext context, {
        required Color background,
        required GameAudio audio,
        VoidCallback? onChanged,
      }) async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheet) {
            return Container(
              decoration: BoxDecoration(
                color: background,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(30),
                ),
                border: Border.all(
                  color: Colors.cyanAccent.withValues(
                    alpha: .25,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.cyanAccent.withValues(
                      alpha: .10,
                    ),
                    blurRadius: 30,
                  ),
                ],
              ),
              child: SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    20,
                    14,
                    20,
                    24,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 42,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius:
                          BorderRadius.circular(10),
                        ),
                      ),

                      const SizedBox(height: 20),

                      Row(
                        children: [
                          Container(
                            width: 54,
                            height: 54,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.cyanAccent
                                  .withValues(alpha: .10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.cyanAccent
                                      .withValues(alpha: .18),
                                  blurRadius: 20,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.volume_up_rounded,
                              color: Colors.cyanAccent,
                              size: 30,
                            ),
                          ),

                          const SizedBox(width: 14),

                          const Expanded(
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'AUDIO SETTINGS',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 23,
                                    fontWeight:
                                    FontWeight.w900,
                                    letterSpacing: 1,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Control your Star Catch audio',
                                  style: TextStyle(
                                    color: Colors.white60,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 25),

                      // 🔊 SOUND EFFECTS
                      _sectionCard(
                        icon: Icons.volume_up_rounded,
                        color: Colors.cyanAccent,
                        title: 'Sound Effects',
                        subtitle:
                        'Catch, bomb, power-up and game sounds',
                        trailing: Switch(
                          value: audio.soundEnabled,
                          activeColor: Colors.cyanAccent,
                          onChanged: (value) async {
                            await audio.setSoundEnabled(value);

                            setSheet(() {});
                            onChanged?.call();
                          },
                        ),
                      ),

                      const SizedBox(height: 14),

                      _volumeCard(
                        icon: Icons.graphic_eq_rounded,
                        color: Colors.cyanAccent,
                        title: 'Sound Volume',
                        value: audio.soundVolume,
                        enabled: audio.soundEnabled,
                        onChanged: (value) async {
                          await audio.setSoundVolume(value);

                          setSheet(() {});
                          onChanged?.call();
                        },
                      ),

                      const SizedBox(height: 14),

                      // 🎵 MUSIC
                      _sectionCard(
                        icon: Icons.music_note_rounded,
                        color: Colors.purpleAccent,
                        title: 'Background Music',
                        subtitle:
                        'Music while playing the game',
                        trailing: Switch(
                          value: audio.musicEnabled,
                          activeColor: Colors.purpleAccent,
                          onChanged: (value) async {
                            await audio.setMusicEnabled(value);

                            if (value) {
                              await audio.startMusic();
                            }

                            setSheet(() {});
                            onChanged?.call();
                          },
                        ),
                      ),

                      const SizedBox(height: 14),

                      _volumeCard(
                        icon: Icons.tune_rounded,
                        color: Colors.purpleAccent,
                        title: 'Music Volume',
                        value: audio.musicVolume,
                        enabled: audio.musicEnabled,
                        onChanged: (value) async {
                          await audio.setMusicVolume(value);

                          setSheet(() {});
                          onChanged?.call();
                        },
                      ),

                      const SizedBox(height: 22),

                      // RESET
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            await audio.resetToDefaults();

                            setSheet(() {});
                            onChanged?.call();
                          },
                          icon: const Icon(
                            Icons.restore_rounded,
                          ),
                          label: const Text(
                            'RESET AUDIO SETTINGS',
                          ),
                          style:
                          OutlinedButton.styleFrom(
                            foregroundColor:
                            Colors.white70,
                            side: BorderSide(
                              color: Colors.white24,
                            ),
                            padding:
                            const EdgeInsets.symmetric(
                              vertical: 14,
                            ),
                            shape:
                            RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      const Text(
                        'Settings are saved automatically',
                        style: TextStyle(
                          color: Colors.white38,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  static Widget _sectionCard({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required Widget trailing,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .055),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withValues(alpha: .20),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: .10),
            ),
            child: Icon(
              icon,
              color: color,
              size: 23,
            ),
          ),

          const SizedBox(width: 13),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),

          trailing,
        ],
      ),
    );
  }

  static Widget _volumeCard({
    required IconData icon,
    required Color color,
    required String title,
    required double value,
    required bool enabled,
    required ValueChanged<double> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        16,
        14,
        16,
        12,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .035),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withValues(alpha: .14),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: enabled
                    ? color
                    : Colors.white24,
                size: 22,
              ),

              const SizedBox(width: 10),

              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: enabled
                        ? Colors.white
                        : Colors.white38,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

              Text(
                '${(value * 100).round()}%',
                style: TextStyle(
                  color: enabled
                      ? color
                      : Colors.white30,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),

          Slider(
            value: value,
            min: 0,
            max: 1,
            divisions: 20,
            activeColor:
            enabled ? color : Colors.white24,
            inactiveColor: Colors.white12,
            onChanged: enabled
                ? onChanged
                : null,
          ),
        ],
      ),
    );
  }
}