import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../../core/constants/app_constants.dart';

part 'theme_provider.g.dart';

@riverpod
class ThemeNotifier extends _$ThemeNotifier {
  @override
  ThemeMode build() {
    final box = Hive.box(AppConstants.settingsBox);
    final isDark = box.get('isDark', defaultValue: false);
    return isDark ? ThemeMode.dark : ThemeMode.light;
  }

  void toggleTheme() {
    final box = Hive.box(AppConstants.settingsBox);
    final isDark = state == ThemeMode.dark;
    box.put('isDark', !isDark);
    state = !isDark ? ThemeMode.dark : ThemeMode.light;
  }
}
