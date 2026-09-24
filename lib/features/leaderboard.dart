import 'package:flutter/material.dart';
import '../utils/game_storage.dart';

class Leaderboard {
  static Future<void> show(BuildContext context, Color background) async {
    final scores = await GameStorage.leaderboard();
    if (!context.mounted) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        height: MediaQuery.of(context).size.height * .78,
        decoration: BoxDecoration(
          color: background,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          border: Border.all(color: Colors.white.withValues(alpha: .1)),
        ),
        child: SafeArea(
          child: Column(children: [
            const SizedBox(height: 14),
            Container(width: 42, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(4))),
            const SizedBox(height: 18),
            const Text('🏆 LEADERBOARD', style: TextStyle(color: Colors.white, fontSize: 27, fontWeight: FontWeight.w900)),
            const SizedBox(height: 4),
            const Text('Your best runs, ranked', style: TextStyle(color: Colors.white60, fontSize: 13)),
            const SizedBox(height: 20),
            Expanded(
              child: scores.isEmpty
                  ? const Center(child: Text('No games played yet.', style: TextStyle(color: Colors.white60)))
                  : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: scores.length,
                itemBuilder: (_, i) {
                  final medal = i == 0 ? '🥇' : i == 1 ? '🥈' : i == 2 ? '🥉' : '${i + 1}';
                  final accent = i == 0 ? Colors.amber : i == 1 ? Colors.grey.shade300 : i == 2 ? Colors.orange.shade300 : Colors.white54;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: i < 3 ? .10 : .05),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: accent.withValues(alpha: i < 3 ? .38 : .10)),
                    ),
                    child: Row(children: [
                      SizedBox(width: 42, child: Text(medal, textAlign: TextAlign.center, style: const TextStyle(fontSize: 24))),
                      const SizedBox(width: 10),
                      Expanded(child: Text(i < 3 ? 'TOP ${i + 1}' : 'RANK ${i + 1}', style: TextStyle(color: accent, fontWeight: FontWeight.w900))),
                      Text('${scores[i]}', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),
                      const SizedBox(width: 5),
                      const Text('PTS', style: TextStyle(color: Colors.white38, fontSize: 9, fontWeight: FontWeight.bold)),
                    ]),
                  );
                },
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
