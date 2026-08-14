import 'package:flutter/material.dart';
import '../../core/repositories/settings_repository.dart';

class SettingsViewModel extends ChangeNotifier {
  final SettingsRepository _repository;

  ThemeMode _themeMode = ThemeMode.system;
  String? _error;

  ThemeMode get themeMode => _themeMode;
  String? get error => _error;

  SettingsViewModel({required SettingsRepository repository})
      : _repository = repository {
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    final result = await _repository.getThemeMode();
    result.fold(
      (failure) => _error = failure.message,
      (mode) => _themeMode = mode,
    );
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();

    final result = await _repository.setThemeMode(mode);
    result.fold(
      (failure) {
        _error = failure.message;
        notifyListeners();
      },
      (_) => null,
    );
  }
}
