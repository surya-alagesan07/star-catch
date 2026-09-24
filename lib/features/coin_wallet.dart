import 'package:shared_preferences/shared_preferences.dart';

class CoinWallet {
  static const String _key = 'coins';

  static Future<int> getCoins() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_key) ?? 0;
  }

  static Future<void> addCoins(int amount) async {
    if (amount <= 0) return;

    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_key) ?? 0;

    await prefs.setInt(_key, current + amount);
  }

  static Future<bool> spendCoins(int amount) async {
    if (amount <= 0) return false;

    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_key) ?? 0;

    if (current < amount) {
      return false;
    }

    await prefs.setInt(_key, current - amount);
    return true;
  }

  static Future<bool> canAfford(int amount) async {
    final coins = await getCoins();
    return coins >= amount;
  }

  static Future<void> setCoins(int amount) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_key, amount < 0 ? 0 : amount);
  }
}