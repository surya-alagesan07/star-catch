import 'package:flutter/material.dart';

enum Item { star, clock, bolt, bomb, shield, freeze, multiplier }
enum ThemeType { space, ocean, forest, sunset }
enum SkinType { classic, diamond, fire, ice, neon }

Widget itemWidget(Item item, SkinType skin, Color skinColor) {
  if (item == Item.star) {
    return Icon(Icons.star_rounded, color: skinColor, size: 70);
  }
  const data = <Item, List<Object>>{
    Item.clock: [Icons.timer_rounded, Colors.greenAccent, 70.0],
    Item.bolt: [Icons.bolt_rounded, Colors.purpleAccent, 75.0],
    Item.bomb: [Icons.dangerous_rounded, Colors.redAccent, 72.0],
    Item.shield: [Icons.shield_rounded, Colors.cyanAccent, 72.0],
    Item.freeze: [Icons.ac_unit_rounded, Colors.lightBlueAccent, 72.0],
    Item.multiplier: [Icons.close_rounded, Colors.orangeAccent, 72.0],
  };
  final d = data[item]!;
  return Icon(d[0] as IconData, color: d[1] as Color, size: d[2] as double);
}
