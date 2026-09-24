import 'package:flutter/material.dart';

class Achievements {
  static const String comboBeginner = 'combo_beginner';
  static const String comboMaster = 'combo_master';
  static const String comboLegend = 'combo_legend';

  static const String starHunter = 'star_hunter';
  static const String perfectCatch = 'perfect_catch';
  static const String highScorer = 'high_scorer';
  static const String powerCollector = 'power_collector';
  static const String multiplierMaster = 'multiplier_master';

  static void check(
      Set<String> unlocked,
      int starsCaught,
      int perfectCatchCount,
      int score,
      int powerUps,
      int multiplierSeconds, {
        int combo = 0,
      }) {
    if (starsCaught >= 10) {
      unlocked.add(starHunter);
    }

    if (perfectCatchCount >= 20) {
      unlocked.add(perfectCatch);
    }

    if (score >= 25) {
      unlocked.add(highScorer);
    }

    if (powerUps >= 5) {
      unlocked.add(powerCollector);
    }

    if (multiplierSeconds > 0 && score >= 10) {
      unlocked.add(multiplierMaster);
    }

    // 🎯 Combo achievements
    if (combo >= 5) {
      unlocked.add(comboBeginner);
    }

    if (combo >= 10) {
      unlocked.add(comboMaster);
    }

    if (combo >= 20) {
      unlocked.add(comboLegend);
    }
  }

  static String name(String id) {
    switch (id) {
      case starHunter:
        return 'Star Hunter';

      case perfectCatch:
        return 'Perfect Catch';

      case highScorer:
        return 'High Scorer';

      case powerCollector:
        return 'Power Collector';

      case multiplierMaster:
        return 'Multiplier Master';

      case comboBeginner:
        return 'Combo Beginner';

      case comboMaster:
        return 'Combo Master';

      case comboLegend:
        return 'Combo Legend';

      default:
        return 'Achievement';
    }
  }

  static String description(String id) {
    switch (id) {
      case starHunter:
        return 'Catch 10 stars';

      case perfectCatch:
        return 'Catch 20 items without missing';

      case highScorer:
        return 'Reach 25 points';

      case powerCollector:
        return 'Collect 5 power-ups';

      case multiplierMaster:
        return 'Use multiplier and reach 10 points';

      case comboBeginner:
        return 'Reach a 5× combo';

      case comboMaster:
        return 'Reach a 10× combo';

      case comboLegend:
        return 'Reach a 20× combo';

      default:
        return '';
    }
  }

  static void show(
      BuildContext context,
      Color background,
      Set<String> unlocked,
      ) {
    final all = [
      starHunter,
      perfectCatch,
      highScorer,
      powerCollector,
      multiplierMaster,
      comboBeginner,
      comboMaster,
      comboLegend,
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: background,
      isScrollControlled: true,
      builder: (_) {
        return SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const Text(
                '🏆 ACHIEVEMENTS',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              ...all.map(
                    (id) {
                  final isUnlocked = unlocked.contains(id);

                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(.06),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: ListTile(
                      leading: Text(
                        isUnlocked ? '🏆' : '🔒',
                        style: const TextStyle(fontSize: 28),
                      ),
                      title: Text(
                        name(id),
                        style: TextStyle(
                          color: isUnlocked
                              ? Colors.amber
                              : Colors.white70,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        description(id),
                        style: const TextStyle(
                          color: Colors.white54,
                        ),
                      ),
                      trailing: isUnlocked
                          ? const Text(
                        'UNLOCKED ✓',
                        style: TextStyle(
                          color: Colors.greenAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      )
                          : null,
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}