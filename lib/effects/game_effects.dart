import 'package:flutter/material.dart';

class GameEffects {
  static Widget particles(bool show, double w, double h, double x, double y) {
    if (!show) return const SizedBox();
    const dirs = [
      Offset(-1, -1), Offset(0, -1), Offset(1, -1), Offset(-1, 0),
      Offset(1, 0), Offset(-1, 1), Offset(0, 1), Offset(1, 1),
    ];
    return Stack(children: dirs.map((d) => Positioned(
      left: w * x - 4, top: h * y - 4,
      child: TweenAnimationBuilder<Offset>(
        key: ValueKey('${d.dx}-${d.dy}-$x-$y'),
        tween: Tween(begin: Offset.zero, end: d * 42),
        duration: const Duration(milliseconds: 400),
        builder: (_, v, child) => Transform.translate(offset: v, child: child),
        child: const Icon(Icons.circle, size: 8, color: Colors.amber),
      ),
    )).toList());
  }

  static Widget levelUp(bool show) => show
      ? const Center(child: AnimatedScale(
    scale: 1,
    duration: Duration(milliseconds: 250),
    child: Text('🎉 LEVEL UP!', style: TextStyle(color: Colors.amber, fontSize: 32, fontWeight: FontWeight.bold, shadows: [Shadow(blurRadius: 12, color: Colors.black)])),
  ))
      : const SizedBox();
}
