import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'features/deck/deck_viewmodel.dart';
import 'features/card/card_viewmodel.dart';
import 'features/study/study_viewmodel.dart';
import 'features/study/quiz_viewmodel.dart';
import 'features/stats/stats_viewmodel.dart';
import 'features/settings/settings_viewmodel.dart';

import 'app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DeckViewModel()..loadDecks()),
        ChangeNotifierProvider(create: (_) => CardViewModel()),
        ChangeNotifierProvider(create: (_) => StudyViewModel()),
        ChangeNotifierProvider(create: (_) => QuizViewModel()),
        ChangeNotifierProvider(create: (_) => StatsViewModel()),
        ChangeNotifierProvider(create: (_) => SettingsViewModel()),
      ],
      child: const ZenFlashCardsApp(),
    ),
  );
}
