# ⭐ Star Catch

A fast-paced Flutter game where players catch falling stars, build combos, collect coins, and challenge their best score.

## 🎮 About the Game

Star Catch is a Flutter-based arcade game designed around quick reflexes and score-based gameplay.

Players can catch stars, build combos, manage lives, collect coins, and progress through different levels while using power-ups and unlocking additional game features.

## ✨ Features

- ⭐ Star-catching gameplay
- 🏆 Score and best-score tracking
- 📈 Level progression
- ❤️ Lives system
- 🪙 Coin wallet
- 🔥 Combo system
- ⚡ Power-ups
- 🎯 Missions
- 🏅 Achievements
- 🎁 Daily rewards
- 👤 Player profile
- 📊 Player statistics
- 🎮 Multiple game modes
- 🎨 Skins
- 🌈 Themes
- 🏆 Leaderboard
- 🔊 Background music and sound effects
- ⏸️ Pause and resume gameplay
- 💾 Local game-data storage

## 🖥️ Gameplay UI

The game includes a dedicated HUD displaying:

- Score
- Best score
- Current level
- Remaining lives
- Coins
- Combo
- Current game mode
- Pause control
- Player profile
- Game menu

## 🛠️ Technologies Used

- **Flutter**
- **Dart**
- **Android**
- **SharedPreferences / Local Storage**
- **Material UI**
- **Audio assets**

## 📂 Project Structure

```text
lib/
├── audio/
│   ├── audio_settings.dart
│   └── game_audio.dart
│
├── effects/
│   └── game_effects.dart
│
├── features/
│   ├── achievements.dart
│   ├── coin_wallet.dart
│   ├── daily_rewards.dart
│   ├── game_modes.dart
│   ├── leaderboard.dart
│   ├── missions.dart
│   ├── player_profile.dart
│   ├── skins.dart
│   ├── statistics.dart
│   └── themes.dart
│
├── game/
│   ├── difficulty.dart
│   ├── game_controller.dart
│   ├── game_item.dart
│   ├── game_menu.dart
│   └── star_game.dart
│
├── utils/
│   └── game_storage.dart
│
└── main.dart

assets/
├── audio/
└── images/

