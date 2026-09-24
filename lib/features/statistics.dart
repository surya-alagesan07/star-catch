import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GameStatistics {
  static const String _gamesPlayed = 'stats_games_played';
  static const String _totalStars = 'stats_total_stars';
  static const String _totalItems = 'stats_total_items';
  static const String _bombsAvoided = 'stats_bombs_avoided';
  static const String _powerUps = 'stats_power_ups';
  static const String _highestCombo = 'stats_highest_combo';
  static const String _highestScore = 'stats_highest_score';
  static const String _totalPlayTime = 'stats_total_play_time';
  static const String _totalScore = 'stats_total_score';
  static const String _missionsCompleted = 'stats_missions_completed';

  static Future<Map<String, int>> load() async {
    final prefs = await SharedPreferences.getInstance();

    return {
      'gamesPlayed': prefs.getInt(_gamesPlayed) ?? 0,
      'totalStars': prefs.getInt(_totalStars) ?? 0,
      'totalItems': prefs.getInt(_totalItems) ?? 0,
      'bombsAvoided': prefs.getInt(_bombsAvoided) ?? 0,
      'powerUps': prefs.getInt(_powerUps) ?? 0,
      'highestCombo': prefs.getInt(_highestCombo) ?? 0,
      'highestScore': prefs.getInt(_highestScore) ?? 0,
      'totalPlayTime': prefs.getInt(_totalPlayTime) ?? 0,
      'totalScore': prefs.getInt(_totalScore) ?? 0,
      'missionsCompleted':
      prefs.getInt(_missionsCompleted) ?? 0,
    };
  }

  static Future<void> recordGame({
    required int score,
    required int starsCaught,
    required int itemsCaught,
    required int bombsAvoided,
    required int powerUps,
    required int bestCombo,
    required int survivedSeconds,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    final games =
        (prefs.getInt(_gamesPlayed) ?? 0) + 1;

    final oldStars =
        prefs.getInt(_totalStars) ?? 0;

    final oldItems =
        prefs.getInt(_totalItems) ?? 0;

    final oldBombs =
        prefs.getInt(_bombsAvoided) ?? 0;

    final oldPowerUps =
        prefs.getInt(_powerUps) ?? 0;

    final oldHighestCombo =
        prefs.getInt(_highestCombo) ?? 0;

    final oldHighestScore =
        prefs.getInt(_highestScore) ?? 0;

    final oldTime =
        prefs.getInt(_totalPlayTime) ?? 0;

    final oldTotalScore =
        prefs.getInt(_totalScore) ?? 0;

    await prefs.setInt(
      _gamesPlayed,
      games,
    );

    await prefs.setInt(
      _totalStars,
      oldStars + starsCaught,
    );

    await prefs.setInt(
      _totalItems,
      oldItems + itemsCaught,
    );

    await prefs.setInt(
      _bombsAvoided,
      oldBombs + bombsAvoided,
    );

    await prefs.setInt(
      _powerUps,
      oldPowerUps + powerUps,
    );

    await prefs.setInt(
      _highestCombo,
      bestCombo > oldHighestCombo
          ? bestCombo
          : oldHighestCombo,
    );

    await prefs.setInt(
      _highestScore,
      score > oldHighestScore
          ? score
          : oldHighestScore,
    );

    await prefs.setInt(
      _totalPlayTime,
      oldTime + survivedSeconds,
    );

    await prefs.setInt(
      _totalScore,
      oldTotalScore + score,
    );
  }

  static Future<void> addMissionsCompleted(
      int count,
      ) async {
    if (count <= 0) return;

    final prefs = await SharedPreferences.getInstance();

    final current =
        prefs.getInt(_missionsCompleted) ?? 0;

    await prefs.setInt(
      _missionsCompleted,
      current + count,
    );
  }

  static Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_gamesPlayed);
    await prefs.remove(_totalStars);
    await prefs.remove(_totalItems);
    await prefs.remove(_bombsAvoided);
    await prefs.remove(_powerUps);
    await prefs.remove(_highestCombo);
    await prefs.remove(_highestScore);
    await prefs.remove(_totalPlayTime);
    await prefs.remove(_totalScore);
    await prefs.remove(_missionsCompleted);
  }

  static Future<void> show(
      BuildContext context, {
        required Color background,
      }) async {
    final stats = await load();

    if (!context.mounted) return;

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * .90,
          ),
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
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 45,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius:
                      BorderRadius.circular(10),
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Icon(
                    Icons.bar_chart_rounded,
                    color: Colors.cyanAccent,
                    size: 48,
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'GAME STATISTICS',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),

                  const SizedBox(height: 5),

                  const Text(
                    'Your Star Catch progress',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 13,
                    ),
                  ),

                  const SizedBox(height: 22),

                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics:
                    const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.55,
                    children: [
                      _statCard(
                        Icons.sports_esports_rounded,
                        'Games Played',
                        '${stats['gamesPlayed']}',
                        Colors.cyanAccent,
                      ),
                      _statCard(
                        Icons.star_rounded,
                        'Stars Caught',
                        '${stats['totalStars']}',
                        Colors.amberAccent,
                      ),
                      _statCard(
                        Icons.ads_click_rounded,
                        'Items Caught',
                        '${stats['totalItems']}',
                        Colors.greenAccent,
                      ),
                      _statCard(
                        Icons.shield_rounded,
                        'Bombs Avoided',
                        '${stats['bombsAvoided']}',
                        Colors.orangeAccent,
                      ),
                      _statCard(
                        Icons.bolt_rounded,
                        'Power-Ups',
                        '${stats['powerUps']}',
                        Colors.purpleAccent,
                      ),
                      _statCard(
                        Icons.local_fire_department_rounded,
                        'Best Combo',
                        '${stats['highestCombo']}×',
                        Colors.deepOrangeAccent,
                      ),
                      _statCard(
                        Icons.emoji_events_rounded,
                        'Highest Score',
                        '${stats['highestScore']}',
                        Colors.amber,
                      ),
                      _statCard(
                        Icons.flag_rounded,
                        'Missions',
                        '${stats['missionsCompleted']}',
                        Colors.orangeAccent,
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  _wideStatCard(
                    Icons.timer_rounded,
                    'Total Play Time',
                    _formatTime(
                      stats['totalPlayTime'] ?? 0,
                    ),
                    Colors.lightBlueAccent,
                  ),

                  const SizedBox(height: 12),

                  _wideStatCard(
                    Icons.trending_up_rounded,
                    'Average Score',
                    _averageScore(stats),
                    Colors.greenAccent,
                  ),

                  const SizedBox(height: 22),

                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        await _confirmReset(context);
                      },
                      icon: const Icon(
                        Icons.restart_alt_rounded,
                      ),
                      label: const Text(
                        'RESET STATISTICS',
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white70,
                        side: const BorderSide(
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
                    'Statistics are saved automatically',
                    style: TextStyle(
                      color: Colors.white30,
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
  }

  static Widget _statCard(
      IconData icon,
      String title,
      String value,
      Color color,
      ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .045),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: color.withValues(alpha: .18),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: color,
            size: 28,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment:
              MainAxisAlignment.center,
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: color,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _wideStatCard(
      IconData icon,
      String title,
      String value,
      Color color,
      ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 16,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .045),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: color.withValues(alpha: .18),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: color,
            size: 30,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  static String _averageScore(
      Map<String, int> stats,
      ) {
    final games = stats['gamesPlayed'] ?? 0;

    if (games == 0) {
      return '0';
    }

    final total = stats['totalScore'] ?? 0;
    return (total / games).toStringAsFixed(1);
  }

  static String _formatTime(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }

    if (minutes > 0) {
      return '${minutes}m ${secs}s';
    }

    return '${secs}s';
  }

  static Future<void> _confirmReset(
      BuildContext context,
      ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF101936),
          title: const Text(
            'Reset Statistics?',
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            'All game statistics will be permanently deleted.',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('CANCEL'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text(
                'RESET',
                style: TextStyle(
                  color: Colors.redAccent,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    await reset();

    if (!context.mounted) return;

    Navigator.pop(context);

    await show(
      context,
      background: const Color(0xFF070B1A),
    );
  }
}