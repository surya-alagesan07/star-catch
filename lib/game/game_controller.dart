import 'dart:async';
import 'dart:math';
import 'game_item.dart';

class GameController {
  final random = Random();
  Timer? gameTimer;
  Timer? itemTimer;
  double x = .5, y = .5;

  Item nextItem() {
    x = .08 + random.nextDouble() * .84;
    y = .12 + random.nextDouble() * .76;
    final r = random.nextInt(100);
    if (r < 30) return Item.star;
    if (r < 45) return Item.clock;
    if (r < 60) return Item.bolt;
    if (r < 70) return Item.bomb;
    if (r < 80) return Item.shield;
    if (r < 90) return Item.freeze;
    return Item.multiplier;
  }

  int delay(int level, int freezeSeconds) {
    final base = max(700, 3000 - (level - 1) * 250);
    return freezeSeconds > 0 ? base * 2 : base;
  }

  void cancel() { gameTimer?.cancel(); itemTimer?.cancel(); }
}
