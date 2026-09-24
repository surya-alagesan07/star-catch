import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'coin_wallet.dart';

class DailyRewards {
  static const String _dayKey = 'daily_reward_day';
  static const String _lastClaimKey = 'daily_reward_last_claim';

  static const List<int> rewards = [10, 15, 20, 25, 30, 40, 50];

  static Future<int> getCoins() async {
    return CoinWallet.getCoins();
  }

  static Future<void> addCoins(int amount) async {
    await CoinWallet.addCoins(amount);
  }

  static Future<int> currentDay() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_dayKey) ?? 1;
  }

  static Future<bool> canClaim() async {
    final prefs = await SharedPreferences.getInstance();
    final last = prefs.getString(_lastClaimKey);

    if (last == null) return true;

    final lastDate = DateTime.tryParse(last);
    if (lastDate == null) return true;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final claimedDate =
    DateTime(lastDate.year, lastDate.month, lastDate.day);

    return today.isAfter(claimedDate);
  }

  static Future<int> claim() async {
    final prefs = await SharedPreferences.getInstance();

    if (!await canClaim()) return 0;

    int day = prefs.getInt(_dayKey) ?? 1;
    if (day < 1 || day > 7) day = 1;

    final reward = rewards[day - 1];

    await CoinWallet.addCoins(reward);
    await prefs.setString(
      _lastClaimKey,
      DateTime.now().toIso8601String(),
    );

    if (day >= 7) {
      await prefs.setInt(_dayKey, 1);
    } else {
      await prefs.setInt(_dayKey, day + 1);
    }

    return reward;
  }

  static Future<void> show(
      BuildContext context, {
        Color background = const Color(0xFF101B3D),
        VoidCallback? onChanged,
      }) async {
    int day = await currentDay();
    int coins = await getCoins();
    bool available = await canClaim();

    if (!context.mounted) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: background,
      isScrollControlled: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            Future<void> claimReward() async {
              final reward = await claim();

              if (reward > 0) {
                day = await currentDay();
                coins = await getCoins();
                available = await canClaim();

                onChanged?.call();

                setState(() {});
              }
            }

            return SafeArea(
              child: SizedBox(
                height: MediaQuery.of(context).size.height * .78,
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    children: [
                      const Text(
                        '🎁 DAILY REWARDS',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Coins: $coins',
                        style: const TextStyle(
                          color: Colors.amber,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Expanded(
                        child: GridView.builder(
                          itemCount: 7,
                          gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 1.15,
                          ),
                          itemBuilder: (context, index) {
                            final reward = rewards[index];
                            final rewardDay = index + 1;
                            final claimedOrPast =
                                rewardDay < day;
                            final today =
                                rewardDay == day;

                            return Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: today
                                    ? Colors.amber.withValues(alpha: .15)
                                    : Colors.white.withValues(alpha: .06),
                                borderRadius:
                                BorderRadius.circular(18),
                                border: Border.all(
                                  color: today
                                      ? Colors.amber
                                      : Colors.white12,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment:
                                MainAxisAlignment.center,
                                children: [
                                  Text(
                                    rewardDay == 1
                                        ? '🥇'
                                        : rewardDay == 2
                                        ? '🥈'
                                        : rewardDay == 3
                                        ? '🥉'
                                        : '🎁',
                                    style:
                                    const TextStyle(fontSize: 32),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    'DAY $rewardDay',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '+$reward coins',
                                    style: const TextStyle(
                                      color: Colors.amber,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (claimedOrPast)
                                    const Text(
                                      '✓',
                                      style: TextStyle(
                                        color: Colors.greenAccent,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: available ? claimReward : null,
                          icon: const Icon(Icons.card_giftcard),
                          label: Text(
                            available
                                ? 'CLAIM DAY $day  +${rewards[day - 1]}'
                                : 'COME BACK TOMORROW',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber,
                            foregroundColor: Colors.black,
                            padding:
                            const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
