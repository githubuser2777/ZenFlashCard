import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'shared/theme/app_theme.dart';
import 'features/settings/settings_viewmodel.dart';
import 'core/routing/app_router.dart';

class ZenFlashCardsApp extends StatelessWidget {
  const ZenFlashCardsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsViewModel>(
      builder: (context, settingsVM, child) {
        return MaterialApp.router(
          title: 'ZenFlashCards',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: settingsVM.themeMode,
          routerConfig: appRouter,
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
