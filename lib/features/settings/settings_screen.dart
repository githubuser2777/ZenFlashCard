import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../settings/settings_viewmodel.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Consumer<SettingsViewModel>(
        builder: (context, settingsVM, child) {
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const Text('Theme', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  ChoiceChip(
                    label: const Text('System 🤖'),
                    selected: settingsVM.themeMode == ThemeMode.system,
                    onSelected: (val) => settingsVM.setThemeMode(ThemeMode.system),
                  ),
                  ChoiceChip(
                    label: const Text('Dark 🌙'),
                    selected: settingsVM.themeMode == ThemeMode.dark,
                    onSelected: (val) => settingsVM.setThemeMode(ThemeMode.dark),
                  ),
                  ChoiceChip(
                    label: const Text('Light ☀️'),
                    selected: settingsVM.themeMode == ThemeMode.light,
                    onSelected: (val) => settingsVM.setThemeMode(ThemeMode.light),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
