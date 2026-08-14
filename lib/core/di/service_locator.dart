import 'package:get_it/get_it.dart';
import '../database/dao/deck_dao.dart';
import '../database/dao/card_dao.dart';
import '../database/dao/study_log_dao.dart';
import '../database/dao/review_history_dao.dart';
import '../repositories/deck_repository.dart';
import '../repositories/card_repository.dart';
import '../repositories/study_repository.dart';
import '../repositories/stats_repository.dart';
import '../repositories/settings_repository.dart';
import '../../features/deck/deck_viewmodel.dart';
import '../../features/card/card_viewmodel.dart';
import '../../features/study/study_viewmodel.dart';
import '../../features/study/quiz_viewmodel.dart';
import '../../features/stats/stats_viewmodel.dart';
import '../../features/settings/settings_viewmodel.dart';

final getIt = GetIt.instance;

void setupServiceLocator() {
  // DAOs
  getIt.registerLazySingleton<DeckDao>(() => DeckDao());
  getIt.registerLazySingleton<CardDao>(() => CardDao());
  getIt.registerLazySingleton<StudyLogDao>(() => StudyLogDao());
  getIt.registerLazySingleton<ReviewHistoryDao>(() => ReviewHistoryDao());

  // Repositories
  getIt.registerLazySingleton<DeckRepository>(
      () => LocalDeckRepository(getIt(), getIt()));
  getIt.registerLazySingleton<CardRepository>(
      () => LocalCardRepository(getIt()));
  getIt.registerLazySingleton<StudyRepository>(
      () => LocalStudyRepository(getIt(), getIt(), getIt()));
  getIt.registerLazySingleton<StatsRepository>(
      () => LocalStatsRepository(getIt(), getIt(), getIt(), getIt()));
  getIt.registerLazySingleton<SettingsRepository>(
      () => LocalSettingsRepository());

  // ViewModels
  getIt.registerFactory<DeckViewModel>(() => DeckViewModel(getIt()));
  getIt
      .registerFactory<CardViewModel>(() => CardViewModel(repository: getIt()));
  getIt.registerFactory<StudyViewModel>(
      () => StudyViewModel(repository: getIt()));
  getIt
      .registerFactory<QuizViewModel>(() => QuizViewModel(repository: getIt()));
  getIt.registerFactory<StatsViewModel>(
      () => StatsViewModel(repository: getIt()));
  getIt.registerFactory<SettingsViewModel>(
      () => SettingsViewModel(repository: getIt()));
}
