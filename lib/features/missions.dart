import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'coin_wallet.dart';

enum MissionType {
  catchStars,
  reachCombo,
  collectPowerUps,
  avoidBombs,
  reachScore,
  surviveTime,
}

class Mission {
  final String id;
  final String title;
  final String description;
  final MissionType type;
  final int target;
  final int reward;

  const Mission({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.target,
    required this.reward,
  });
}

class MissionProgress {
  final int value;
  final bool completed;
  final bool claimed;

  const MissionProgress({
    this.value = 0,
    this.completed = false,
    this.claimed = false,
  });

  MissionProgress copyWith({
    int? value,
    bool? completed,
    bool? claimed,
  }) {
    return MissionProgress(
      value: value ?? this.value,
      completed: completed ?? this.completed,
      claimed: claimed ?? this.claimed,
    );
  }
}

class Missions {
  static const List<Mission> all = [
    Mission(
      id: 'stars_20',
      title: '⭐ Star Collector',
      description: 'Catch 20 stars',
      type: MissionType.catchStars,
      target: 20,
      reward: 10,
    ),
    Mission(
      id: 'combo_10',
      title: '🔥 Combo Master',
      description: 'Reach a 10× combo',
      type: MissionType.reachCombo,
      target: 10,
      reward: 15,
    ),
    Mission(
      id: 'powerups_5',
      title: '⚡ Power Collector',
      description: 'Collect 5 power-ups',
      type: MissionType.collectPowerUps,
      target: 5,
      reward: 10,
    ),
    Mission(
      id: 'bombs_5',
      title: '💣 Bomb Dodger',
      description: 'Avoid 5 bombs',
      type: MissionType.avoidBombs,
      target: 5,
      reward: 15,
    ),
    Mission(
      id: 'score_50',
      title: '🏆 High Scorer',
      description: 'Reach 50 points',
      type: MissionType.reachScore,
      target: 50,
      reward: 20,
    ),
    Mission(
      id: 'survive_60',
      title: '⏱️ Survivor',
      description: 'Survive for 60 seconds',
      type: MissionType.surviveTime,
      target: 60,
      reward: 25,
    ),
  ];

  static int currentValue(
      Mission mission, {
        required int stars,
        required int combo,
        required int powerUps,
        required int avoidedBombs,
        required int score,
        required int survivedSeconds,
      }) {
    switch (mission.type) {
      case MissionType.catchStars:
        return stars;
      case MissionType.reachCombo:
        return combo;
      case MissionType.collectPowerUps:
        return powerUps;
      case MissionType.avoidBombs:
        return avoidedBombs;
      case MissionType.reachScore:
        return score;
      case MissionType.surviveTime:
        return survivedSeconds;
    }
  }

  static Map<String, MissionProgress> update({
    required Map<String, MissionProgress> oldData,
    required int stars,
    required int combo,
    required int powerUps,
    required int avoidedBombs,
    required int score,
    required int survivedSeconds,
  }) {
    final result = Map<String, MissionProgress>.from(oldData);

    for (final mission in all) {
      final old = result[mission.id] ?? const MissionProgress();

      if (old.claimed) continue;

      final value = currentValue(
        mission,
        stars: stars,
        combo: combo,
        powerUps: powerUps,
        avoidedBombs: avoidedBombs,
        score: score,
        survivedSeconds: survivedSeconds,
      );

      final safeValue = value.clamp(0, mission.target);

      result[mission.id] = old.copyWith(
        value: safeValue,
        completed: safeValue >= mission.target,
      );
    }

    return result;
  }

  static Future<void> save(
      Map<String, MissionProgress> data,
      ) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = <String, dynamic>{};

    for (final entry in data.entries) {
      encoded[entry.key] = {
        'value': entry.value.value,
        'completed': entry.value.completed,
        'claimed': entry.value.claimed,
      };
    }

    await prefs.setString('missions', jsonEncode(encoded));
  }

  static Future<Map<String, dynamic>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('missions');

    if (raw == null || raw.isEmpty) return {};

    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }
    } catch (_) {}

    return {};
  }

  static Map<String, MissionProgress> decode(
      Map<String, dynamic> data,
      ) {
    final result = <String, MissionProgress>{};

    for (final entry in data.entries) {
      final value = entry.value;
      if (value is Map) {
        result[entry.key] = MissionProgress(
          value: (value['value'] as num?)?.toInt() ?? 0,
          completed: value['completed'] == true,
          claimed: value['claimed'] == true,
        );
      }
    }

    return result;
  }

  static Future<int> claim(
      String missionId,
      Map<String, MissionProgress> data,
      ) async {
    Mission? mission;

    for (final m in all) {
      if (m.id == missionId) {
        mission = m;
        break;
      }
    }

    if (mission == null) return 0;

    final progress = data[missionId];

    if (progress == null ||
        !progress.completed ||
        progress.claimed) {
      return 0;
    }

    data[missionId] = progress.copyWith(claimed: true);
    await save(data);

    return mission.reward;
  }

  static void show(
      BuildContext context,
      Color background,
      Map<String, MissionProgress> data,
      VoidCallback onChanged,
      ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: background,
      isScrollControlled: true,
      builder: (sheetContext) {
        return SafeArea(
          child: StatefulBuilder(
            builder: (context, setSheetState) {
              final completed = all.where((mission) {
                final p = data[mission.id];
                return p != null && p.completed;
              }).length;

              return SizedBox(
                height: MediaQuery.of(context).size.height * .85,
                child: Column(
                  children: [
                    const SizedBox(height: 18),
                    const Text(
                      '🎯 MISSIONS',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 27,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '$completed / ${all.length} completed',
                      style: const TextStyle(
                        color: Colors.amber,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                        itemCount: all.length,
                        itemBuilder: (context, index) {
                          final mission = all[index];
                          final progress =
                              data[mission.id] ??
                                  const MissionProgress();

                          final value =
                          progress.value.clamp(0, mission.target);
                          final percentage = mission.target == 0
                              ? 0.0
                              : value / mission.target;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: .06),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: progress.completed
                                    ? Colors.amber.withValues(alpha: .45)
                                    : Colors.white.withValues(alpha: .08),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        mission.title,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      '+${mission.reward}',
                                      style: const TextStyle(
                                        color: Colors.amber,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  mission.description,
                                  style: const TextStyle(
                                    color: Colors.white60,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: LinearProgressIndicator(
                                    value: percentage.toDouble(),
                                    minHeight: 9,
                                    backgroundColor: Colors.white12,
                                  ),
                                ),
                                const SizedBox(height: 9),
                                Row(
                                  children: [
                                    Text(
                                      '$value / ${mission.target}',
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const Spacer(),
                                    if (progress.claimed)
                                      const Text(
                                        'CLAIMED ✓',
                                        style: TextStyle(
                                          color: Colors.greenAccent,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      )
                                    else if (progress.completed)
                                      ElevatedButton(
                                        onPressed: () async {
                                          final reward = await claim(
                                            mission.id,
                                            data,
                                          );
                                          if (reward > 0) {
                                            // Add the claimed reward to the same
                                            // wallet used by the upper game HUD.
                                            await CoinWallet.addCoins(reward);
                                            onChanged();
                                            setSheetState(() {});
                                          }
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.amber,
                                          foregroundColor: Colors.black,
                                        ),
                                        child: Text(
                                          'CLAIM +${mission.reward}',
                                        ),
                                      )
                                    else
                                      const Text(
                                        'IN PROGRESS',
                                        style: TextStyle(
                                          color: Colors.white38,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
