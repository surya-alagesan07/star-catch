import 'package:flutter/material.dart';

enum GameMode {
  normal,
  timeAttack,
  survival,
  challenge,
  combo,
}

extension GameModeInfo on GameMode {
  String get title {
    switch (this) {
      case GameMode.normal:
        return 'NORMAL';
      case GameMode.timeAttack:
        return 'TIME ATTACK';
      case GameMode.survival:
        return 'SURVIVAL';
      case GameMode.challenge:
        return 'CHALLENGE';
      case GameMode.combo:
        return 'COMBO';
    }
  }

  String get description {
    switch (this) {
      case GameMode.normal:
        return 'Classic Star Catch gameplay.';
      case GameMode.timeAttack:
        return 'Catch as many stars as possible before time runs out!';
      case GameMode.survival:
        return 'Survive with limited lives as long as possible!';
      case GameMode.challenge:
        return 'Complete special gameplay objectives!';
      case GameMode.combo:
        return 'Build the longest combo without missing!';
    }
  }

  IconData get icon {
    switch (this) {
      case GameMode.normal:
        return Icons.star_rounded;
      case GameMode.timeAttack:
        return Icons.timer_rounded;
      case GameMode.survival:
        return Icons.favorite_rounded;
      case GameMode.challenge:
        return Icons.track_changes_rounded;
      case GameMode.combo:
        return Icons.local_fire_department_rounded;
    }
  }

  Color get iconColor {
    switch (this) {
      case GameMode.normal:
        return Colors.amber;
      case GameMode.timeAttack:
        return Colors.cyanAccent;
      case GameMode.survival:
        return Colors.redAccent;
      case GameMode.challenge:
        return Colors.orangeAccent;
      case GameMode.combo:
        return Colors.deepPurpleAccent;
    }
  }
}

class GameModes {
  static Future<GameMode?> show(
      BuildContext context, {
        GameMode current = GameMode.normal,
      }) {
    return showModalBottomSheet<GameMode>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return _GameModesSheet(current: current);
      },
    );
  }
}

class _GameModesSheet extends StatelessWidget {
  final GameMode current;

  const _GameModesSheet({
    required this.current,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF050A20),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(30),
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 22, 16, 18),
          child: Column(
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.amber.withValues(alpha: 0.12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.amber.withValues(alpha: 0.35),
                          blurRadius: 25,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.sports_esports_rounded,
                      color: Colors.amber,
                      size: 34,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'GAME MODES',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 6),

              const Text(
                'Choose how you want to play',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 15,
                ),
              ),

              const SizedBox(height: 24),

              ...GameMode.values.map(
                    (mode) => _ModeCard(
                  mode: mode,
                  selected: mode == current,
                  onTap: () {
                    Navigator.pop(context, mode);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  final GameMode mode;
  final bool selected;
  final VoidCallback onTap;

  const _ModeCard({
    required this.mode,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFF101D3F)
              : const Color(0xFF0D132F),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: selected
                ? Colors.cyanAccent.withValues(alpha: 0.9)
                : Colors.white.withValues(alpha: 0.12),
            width: selected ? 2 : 1,
          ),
          boxShadow: selected
              ? [
            BoxShadow(
              color: Colors.cyanAccent.withValues(alpha: 0.18),
              blurRadius: 22,
              spreadRadius: 1,
            ),
          ]
              : [],
        ),
        child: Row(
          children: [
            _ModeLogo(
              mode: mode,
              selected: selected,
            ),

            const SizedBox(width: 18),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mode.title,
                    style: TextStyle(
                      color: selected
                          ? Colors.cyanAccent
                          : mode.iconColor,
                      fontSize: 21,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.4,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    mode.description,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13.5,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            if (selected)
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.greenAccent,
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.greenAccent.withValues(alpha: 0.25),
                      blurRadius: 15,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.greenAccent,
                  size: 28,
                ),
              )
            else
              const Icon(
                Icons.chevron_right_rounded,
                color: Colors.white70,
                size: 34,
              ),
          ],
        ),
      ),
    );
  }
}

class _ModeLogo extends StatelessWidget {
  final GameMode mode;
  final bool selected;

  const _ModeLogo({
    required this.mode,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 78,
      height: 78,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: mode.iconColor.withValues(alpha: 0.10),
        boxShadow: [
          BoxShadow(
            color: mode.iconColor.withValues(alpha: 0.20),
            blurRadius: 20,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(
            mode.icon,
            color: mode.iconColor,
            size: 53,
          ),

          if (mode == GameMode.combo)
            Positioned(
              bottom: 7,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 7,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.65),
                  borderRadius: BorderRadius.circular(7),
                  border: Border.all(
                    color: Colors.orangeAccent,
                  ),
                ),
                child: const Text(
                  'x10',
                  style: TextStyle(
                    color: Colors.orangeAccent,
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}