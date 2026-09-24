import 'package:flutter/material.dart';
import '../game/game_item.dart';
class Skins {
  static String text(SkinType s) => switch (s) {
    SkinType.classic => 'Classic — Always unlocked', SkinType.diamond => '💎 Diamond — Best 10', SkinType.fire => '🔥 Fire — Best 25', SkinType.ice => '❄️ Ice — Best 40', SkinType.neon => '⚡ Neon — Best 60',
  };
  static Color color(SkinType s) => switch (s) {
    SkinType.classic => Colors.amber, SkinType.diamond => Colors.cyanAccent, SkinType.fire => Colors.redAccent, SkinType.ice => Colors.lightBlueAccent, SkinType.neon => Colors.purpleAccent,
  };
  static bool unlocked(SkinType s, int best) => switch (s) {
    SkinType.classic => true, SkinType.diamond => best >= 10, SkinType.fire => best >= 25, SkinType.ice => best >= 40, SkinType.neon => best >= 60,
  };
}
