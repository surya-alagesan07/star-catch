import 'package:flutter/material.dart';
import '../game/game_item.dart';

class Themes {
  static Color background(ThemeType t) => switch (t) {
    ThemeType.space => const Color(0xFF101B3D),
    ThemeType.ocean => const Color(0xFF063B5C),
    ThemeType.forest => const Color(0xFF123524),
    ThemeType.sunset => const Color(0xFF54243A),
  };
  static String name(ThemeType t) => switch (t) {
    ThemeType.space => 'Space', ThemeType.ocean => 'Ocean', ThemeType.forest => 'Forest', ThemeType.sunset => 'Sunset',
  };
  static String text(ThemeType t) => switch (t) {
    ThemeType.space => '🌌 Space — Always unlocked', ThemeType.ocean => '🌊 Ocean — Best 10', ThemeType.forest => '🌲 Forest — Best 25', ThemeType.sunset => '🌅 Sunset — Best 50',
  };
  static Color color(ThemeType t) => switch (t) {
    ThemeType.space => Colors.indigoAccent, ThemeType.ocean => Colors.cyan, ThemeType.forest => Colors.green, ThemeType.sunset => Colors.orange,
  };
  static bool unlocked(ThemeType t, int best) => switch (t) {
    ThemeType.space => true, ThemeType.ocean => best >= 10, ThemeType.forest => best >= 25, ThemeType.sunset => best >= 50,
  };
}
