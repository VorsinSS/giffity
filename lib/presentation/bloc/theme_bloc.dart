// lib/presentation/bloc/theme_bloc.dart
import 'package:bloc/bloc.dart';
import 'package:hive/hive.dart';
import 'package:giffity/data/models/settings_model.dart';

class ThemeState {
  final bool isDarkMode;

  ThemeState({required this.isDarkMode});
}

class ThemeEvent {}

class ToggleThemeEvent extends ThemeEvent {}

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  final Box<SettingsModel> settingsBox;

  ThemeBloc({required this.settingsBox, required SettingsModel initialSettings})
    : super(ThemeState(isDarkMode: initialSettings.isDarkMode)) {
    on<ToggleThemeEvent>(_onToggleTheme);
  }

  Future<void> _onToggleTheme(
    ToggleThemeEvent event,
    Emitter<ThemeState> emit,
  ) async {
    final newState = ThemeState(isDarkMode: !state.isDarkMode);

    // Сохраняем в Hive
    await settingsBox.put(
      'settings',
      SettingsModel(isDarkMode: newState.isDarkMode),
    );

    emit(newState);
  }
}
