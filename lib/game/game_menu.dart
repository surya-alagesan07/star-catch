import 'package:flutter/material.dart';

import '../audio/game_audio.dart';
import '../audio/audio_settings.dart';
import '../features/achievements.dart';
import '../features/coin_wallet.dart';
import '../features/daily_rewards.dart';
import '../features/game_modes.dart';
import '../features/leaderboard.dart';
import '../features/missions.dart';

class GameMenu {
  static void show(
      BuildContext context, {
        required Color background,
        required int score,
        required int best,
        required int level,
        required int starsCaught,
        required int powerUps,
        required int bestCombo,
        required int avoidedBombs,
        required int survivedSeconds,
        required GameMode gameMode,
        required Map<String, MissionProgress> missionData,
        required Set<String> achievements,
        required GameAudio audio,
        required ValueChanged<GameMode> onGameModeChanged,
        required ValueChanged<int> onCoinsChanged,
        required VoidCallback onDifficulty,
        required VoidCallback onCustomization,
        required VoidCallback onAudioChanged,
      }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (menuContext) => Container(
        decoration: BoxDecoration(
          color: background,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          border: Border.all(color: Colors.white.withValues(alpha: .10)),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
            child: Column(
              children: [
                _handle(),
                const SizedBox(height: 18),
                const Icon(Icons.menu_rounded, color: Colors.cyanAccent, size: 42),
                const SizedBox(height: 6),
                const Text(
                  'GAME MENU',
                  style: TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 22),
                _item(
                  Icons.bar_chart_rounded,
                  'Statistics',
                  'View your game statistics',
                  Colors.cyanAccent,
                      () {
                    Navigator.pop(menuContext);
                    _statistics(
                      context,
                      background: background,
                      score: score,
                      best: best,
                      level: level,
                      starsCaught: starsCaught,
                      powerUps: powerUps,
                      bestCombo: bestCombo,
                      avoidedBombs: avoidedBombs,
                      survivedSeconds: survivedSeconds,
                    );
                  },
                ),
                _item(
                  Icons.sports_esports_rounded,
                  'Game Modes',
                  'Normal, Time Attack, Survival & more',
                  Colors.cyanAccent,
                      () async {
                    Navigator.pop(menuContext);
                    final selected = await GameModes.show(context, current: gameMode);
                    if (selected != null) onGameModeChanged(selected);
                  },
                ),
                _item(
                  Icons.track_changes_rounded,
                  'Missions',
                  'Complete missions and earn rewards',
                  Colors.orangeAccent,
                      () {
                    Navigator.pop(menuContext);
                    Missions.show(context, background, missionData, () async {
                      onCoinsChanged(await CoinWallet.getCoins());
                    });
                  },
                ),
                _item(
                  Icons.card_giftcard_rounded,
                  'Daily Rewards',
                  'Collect your daily reward',
                  Colors.amberAccent,
                      () {
                    Navigator.pop(menuContext);
                    DailyRewards.show(
                      context,
                      background: background,
                      onChanged: () async {
                        onCoinsChanged(await CoinWallet.getCoins());
                      },
                    );
                  },
                ),
                _item(
                  Icons.emoji_events_rounded,
                  'Achievements',
                  'View your achievements',
                  Colors.amber,
                      () {
                    Navigator.pop(menuContext);
                    Achievements.show(context, background, achievements);
                  },
                ),
                _item(
                  Icons.leaderboard_rounded,
                  'Leaderboard',
                  'View your scores',
                  Colors.greenAccent,
                      () {
                    Navigator.pop(menuContext);
                    Leaderboard.show(context, background);
                  },
                ),
                _item(
                  Icons.palette_rounded,
                  'Themes & Skins',
                  'Customize your game',
                  Colors.pinkAccent,
                      () {
                    Navigator.pop(menuContext);
                    onCustomization();
                  },
                ),
                _item(
                  Icons.speed_rounded,
                  'Difficulty',
                  'Change game difficulty',
                  Colors.cyanAccent,
                      () {
                    Navigator.pop(menuContext);
                    onDifficulty();
                  },
                ),
                _item(
                  Icons.volume_up_rounded,
                  'Audio',
                  'Sound and music settings',
                  Colors.purpleAccent,
                      () {
                    Navigator.pop(menuContext);
                    AudioSettings.show(
                      context,
                      background: background,
                      audio: audio,
                      onChanged: onAudioChanged,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Widget _handle() => Container(
    width: 42,
    height: 4,
    decoration: BoxDecoration(
      color: Colors.white24,
      borderRadius: BorderRadius.circular(4),
    ),
  );

  static Widget _item(
      IconData icon,
      String title,
      String subtitle,
      Color color,
      VoidCallback onTap,
      ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: .045),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: color.withValues(alpha: .18)),
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: .10),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(color: Colors.white54, fontSize: 11),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: color.withValues(alpha: .65)),
            ],
          ),
        ),
      ),
    );
  }

  static void _statistics(
      BuildContext context, {
        required Color background,
        required int score,
        required int best,
        required int level,
        required int starsCaught,
        required int powerUps,
        required int bestCombo,
        required int avoidedBombs,
        required int survivedSeconds,
      }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) => Container(
        decoration: BoxDecoration(
          color: background,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          border: Border.all(color: Colors.white.withValues(alpha: .10)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _handle(),
                const SizedBox(height: 18),
                const Icon(Icons.bar_chart_rounded, color: Colors.cyanAccent, size: 42),
                const SizedBox(height: 6),
                const Text(
                  'STATISTICS',
                  style: TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 20),
                _stat('Current Score', '$score', Icons.star_rounded, Colors.amber),
                _stat('Best Score', '$best', Icons.emoji_events_rounded, Colors.orangeAccent),
                _stat('Level', '$level', Icons.trending_up_rounded, Colors.cyanAccent),
                _stat('Stars Caught', '$starsCaught', Icons.auto_awesome_rounded, Colors.amberAccent),
                _stat('Power-Ups', '$powerUps', Icons.bolt_rounded, Colors.purpleAccent),
                _stat('Best Combo', '${bestCombo}×', Icons.local_fire_department_rounded, Colors.deepPurpleAccent),
                _stat('Bombs Avoided', '$avoidedBombs', Icons.warning_amber_rounded, Colors.orangeAccent),
                _stat('Survival Time', '${survivedSeconds}s', Icons.timer_rounded, Colors.greenAccent),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => Navigator.pop(sheetContext),
                  child: const Text(
                    'CLOSE',
                    style: TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.w900),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Widget _stat(String title, String value, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: .045),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: .18)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w700),
              ),
            ),
            Text(
              value,
              style: TextStyle(color: color, fontSize: 15, fontWeight: FontWeight.w900),
            ),
          ],
        ),
      ),
    );
  }
}
