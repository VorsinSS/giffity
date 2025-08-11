import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';

abstract class ThemeEvent {}

class ToggleThemeEvent extends ThemeEvent {
  final bool isDarkMode;
  ToggleThemeEvent(this.isDarkMode);
}

class ThemeState {
  final bool isDarkMode;
  ThemeState(this.isDarkMode);
}

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  final Box settingsBox;

  ThemeBloc(this.settingsBox)
    : super(ThemeState(settingsBox.get('isDarkMode', defaultValue: false))) {
    on<ToggleThemeEvent>(_onToggleTheme);
  }

  Future<void> _onToggleTheme(
    ToggleThemeEvent event,
    Emitter<ThemeState> emit,
  ) async {
    await settingsBox.put('isDarkMode', event.isDarkMode);
    emit(ThemeState(event.isDarkMode));
  }
}
