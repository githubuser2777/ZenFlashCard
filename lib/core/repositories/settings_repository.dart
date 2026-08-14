import 'package:fpdart/fpdart.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/failure.dart';

abstract class SettingsRepository {
  Future<Either<Failure, ThemeMode>> getThemeMode();
  Future<Either<Failure, void>> setThemeMode(ThemeMode mode);
}

class LocalSettingsRepository implements SettingsRepository {
  static const String _themeModeKey = 'theme_mode_key';

  @override
  Future<Either<Failure, ThemeMode>> getThemeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final index = prefs.getInt(_themeModeKey);
      if (index != null && index >= 0 && index < ThemeMode.values.length) {
        return Right(ThemeMode.values[index]);
      }
      return const Right(ThemeMode.system);
    } catch (e) {
      return Left(Failure('Failed to get theme mode: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> setThemeMode(ThemeMode mode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_themeModeKey, mode.index);
      return const Right(null);
    } catch (e) {
      return Left(Failure('Failed to set theme mode: $e'));
    }
  }
}
