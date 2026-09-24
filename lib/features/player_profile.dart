import 'package:flutter/material.dart';
import '../utils/game_storage.dart';

class PlayerProfile {
  static Future<void> show(
      BuildContext context, {
        required Color background,
        String playerName = 'Star Catcher',
        int bestScore = 0,
        int bestCombo = 0,
        int starsCaught = 0,
        int coins = 0,
        int gamesPlayed = 0,
        int level = 1,
        int totalStars = 0,
        int totalCoins = 0,
        int progressBestCombo = 0,
        int progressLevel = 1,
      }) async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _ProfileSheet(
        background: background,
        playerName: playerName,
        bestScore: bestScore,
        bestCombo: bestCombo,
        starsCaught: starsCaught,
        coins: coins,
        gamesPlayed: gamesPlayed,
        level: level,
        totalStars: totalStars,
        totalCoins: totalCoins,
        progressBestCombo: progressBestCombo,
        progressLevel: progressLevel,

      ),
    );
  }
}

class _ProfileSheet extends StatefulWidget {
  final Color background;
  final String playerName;
  final int bestScore;
  final int bestCombo;
  final int starsCaught;
  final int coins;
  final int gamesPlayed;
  final int level;
  final int totalStars;
  final int totalCoins;
  final int progressBestCombo;
  final int progressLevel;

  const _ProfileSheet({
    required this.background,
    required this.playerName,
    required this.bestScore,
    required this.bestCombo,
    required this.starsCaught,
    required this.coins,
    required this.gamesPlayed,
    required this.level,
    required this.totalStars,
    required this.totalCoins,
    required this.progressBestCombo,
    required this.progressLevel,
  });

  @override
  State<_ProfileSheet> createState() => _ProfileSheetState();

}

class _ProfileSheetState extends State<_ProfileSheet> {
  late String name;
  late int avatar;
  late int totalStars;
  late int totalCoins;
  late int progressBestCombo;
  late int progressLevel;

  static const avatars = [
    Icons.person_rounded,
    Icons.face_rounded,
    Icons.emoji_emotions_rounded,
    Icons.rocket_launch_rounded,
    Icons.star_rounded,
    Icons.auto_awesome_rounded,
    Icons.sports_esports_rounded,
    Icons.shield_rounded,
  ];

  static const avatarColors = [
    Colors.cyanAccent,
    Colors.pinkAccent,
    Colors.amberAccent,
    Colors.orangeAccent,
    Colors.yellowAccent,
    Colors.purpleAccent,
    Colors.greenAccent,
    Colors.lightBlueAccent,
  ];

  Widget _progressCard(
      IconData icon,
      String title,
      String value,
      Color color,
      ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .045),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: .07),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 25),
          const SizedBox(height: 7),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 9,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  @override
  @override
  void initState() {
    super.initState();

    name = widget.playerName;
    avatar = 0;

    totalStars = widget.totalStars;
    totalCoins = widget.totalCoins;
    progressBestCombo = widget.progressBestCombo;
    progressLevel = widget.progressLevel;

    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final data = await GameStorage.load();

    if (!mounted) return;

    setState(() {
      name = data['playerName'] ?? widget.playerName;

      avatar = data['avatar'] ?? 0;
      if (avatar < 0 || avatar >= avatars.length) {
        avatar = 0;
      }

      totalStars = data['totalStars'] ?? 0;
      totalCoins = data['totalCoins'] ?? 0;
      progressBestCombo = data['bestCombo'] ?? 0;
      progressLevel = data['level'] ?? widget.level;
    });
  }

  Future<void> _editName() async {
    final controller = TextEditingController(text: name);

    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: widget.background,
          title: const Text(
            'EDIT NAME',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            maxLength: 20,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Enter player name',
              hintStyle: const TextStyle(color: Colors.white38),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.white.withValues(alpha: .15),
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.cyanAccent,
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('CANCEL'),
            ),
            ElevatedButton(
              onPressed: () {
                final value = controller.text.trim();
                if (value.isNotEmpty) {
                  Navigator.pop(dialogContext, value);
                }
              },
              child: const Text('SAVE'),
            ),
          ],
        );
      },
    );

    controller.dispose();

    if (result == null || result.trim().isEmpty) return;

    await GameStorage.savePlayerName(result.trim());

    if (!mounted) return;

    setState(() {
      name = result.trim();
    });
  }

  Future<void> _selectAvatar() async {
    final selected = await showDialog<int>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: widget.background,
          title: const Text(
            'CHOOSE AVATAR',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
          content: SizedBox(
            width: 360,
            child: GridView.builder(
              shrinkWrap: true,
              itemCount: avatars.length,
              gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemBuilder: (_, index) {
                final selectedAvatar = index == avatar;

                return GestureDetector(
                  onTap: () => Navigator.pop(dialogContext, index),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: avatarColors[index]
                          .withValues(alpha: .12),
                      border: Border.all(
                        color: selectedAvatar
                            ? avatarColors[index]
                            : Colors.white.withValues(alpha: .10),
                        width: selectedAvatar ? 2 : 1,
                      ),
                    ),
                    child: Icon(
                      avatars[index],
                      color: avatarColors[index],
                      size: 32,
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );

    if (selected == null) return;

    await GameStorage.saveAvatar(selected);

    if (!mounted) return;

    setState(() {
      avatar = selected;
    });
  }

  @override
  Widget build(BuildContext context) {
    final avatarColor = avatarColors[avatar];

    return Container(
      decoration: BoxDecoration(
        color: widget.background,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(30),
        ),
        border: Border.all(
          color: Colors.white.withValues(alpha: .10),
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 25),
          child: Column(
            children: [
              Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),

              const SizedBox(height: 20),

              // 👤 AVATAR
              GestureDetector(
                onTap: _selectAvatar,
                child: Container(
                  width: 92,
                  height: 92,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: avatarColor.withValues(alpha: .12),
                    border: Border.all(
                      color: avatarColor.withValues(alpha: .65),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: avatarColor.withValues(alpha: .20),
                        blurRadius: 25,
                      ),
                    ],
                  ),
                  child: Icon(
                    avatars[avatar],
                    color: avatarColor,
                    size: 52,
                  ),
                ),
              ),

              const SizedBox(height: 10),

              Text(
                name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),

              TextButton.icon(
                onPressed: _editName,
                icon: const Icon(
                  Icons.edit_rounded,
                  size: 16,
                ),
                label: const Text('EDIT NAME'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.cyanAccent,
                ),
              ),

              OutlinedButton.icon(
                onPressed: _selectAvatar,
                icon: const Icon(Icons.face_rounded),
                label: const Text('CHANGE AVATAR'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: avatarColor,
                  side: BorderSide(
                    color: avatarColor.withValues(alpha: .35),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              Text(
                'LEVEL ${widget.level}',
                style: const TextStyle(
                  color: Colors.cyanAccent,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2,
                ),
              ),

              const SizedBox(height: 24),

              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'PLAYER STATS',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
              ),

              const SizedBox(height: 22),

              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'PROGRESS',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
              ),

              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(
                    child: _progressCard(
                      Icons.auto_awesome_rounded,
                      'STARS',
                      '$totalStars',
                      Colors.cyanAccent,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _progressCard(
                      Icons.monetization_on_rounded,
                      'COINS',
                      '$totalCoins',
                      Colors.amberAccent,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              Row(
                children: [
                  Expanded(
                    child: _progressCard(
                      Icons.local_fire_department_rounded,
                      'BEST COMBO',
                      '${progressBestCombo}×',
                      Colors.deepPurpleAccent,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _progressCard(
                      Icons.trending_up_rounded,
                      'LEVEL',
                      '$progressLevel',
                      Colors.greenAccent,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              _stat(
                Icons.star_rounded,
                'Best Score',
                '${widget.bestScore}',
                Colors.amber,
              ),

              _stat(
                Icons.local_fire_department_rounded,
                'Best Combo',
                '${widget.bestCombo}×',
                Colors.deepPurpleAccent,
              ),

              _stat(
                Icons.auto_awesome_rounded,
                'Stars Caught',
                '${widget.starsCaught}',
                Colors.cyanAccent,
              ),

              _stat(
                Icons.monetization_on_rounded,
                'Coins',
                '${widget.coins}',
                Colors.amberAccent,
              ),

              _stat(
                Icons.sports_esports_rounded,
                'Games Played',
                '${widget.gamesPlayed}',
                Colors.greenAccent,
              ),

              const SizedBox(height: 18),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                  label: const Text('CLOSE'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white70,
                    side: BorderSide(
                      color: Colors.white.withValues(alpha: .15),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _stat(
      IconData icon,
      String title,
      String value,
      Color color,
      ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 13,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .045),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: .07),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 23),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}