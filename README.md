# Star Catch

A 30-second Flutter tap game. Flutter UI and game logic are in Dart; the Android native integration is Java.

## Use

1. Create the Android/iOS platform folders if they do not exist: `flutter create .`
2. This preserves `lib/main.dart`; if Flutter replaces the Java activity, restore the provided `android/app/src/main/java/com/example/flutter_java_game/MainActivity.java`.
3. Run with `flutter run`.

The Java bridge adds a short Android vibration whenever a star is caught. Add `<uses-permission android:name="android.permission.VIBRATE" />` directly under the `<manifest>` line in `android/app/src/main/AndroidManifest.xml`.
