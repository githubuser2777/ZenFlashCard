import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'features/deck/deck_viewmodel.dart';
import 'features/card/card_viewmodel.dart';
import 'features/study/study_viewmodel.dart';
import 'features/study/quiz_viewmodel.dart';
import 'features/stats/stats_viewmodel.dart';
import 'features/settings/settings_viewmodel.dart';

import 'core/di/service_locator.dart';
import 'app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  setupServiceLocator();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (_) => getIt<DeckViewModel>()..loadDecks()),
        ChangeNotifierProvider(create: (_) => getIt<CardViewModel>()),
        ChangeNotifierProvider(create: (_) => getIt<StudyViewModel>()),
        ChangeNotifierProvider(create: (_) => getIt<QuizViewModel>()),
        ChangeNotifierProvider(create: (_) => getIt<StatsViewModel>()),
        ChangeNotifierProvider(create: (_) => getIt<SettingsViewModel>()),
      ],
      child: const ZenFlashCardsApp(),
    ),
  );
}
