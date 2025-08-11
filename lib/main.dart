import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:giffity/data/datasources/giphy_data_source.dart';
import 'package:giffity/data/models/settings_model.dart'; // Добавляем импорт
import 'package:giffity/presentation/theme/app_theme.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:giffity/data/models/gif_model.dart';
import 'package:giffity/presentation/bloc/theme_bloc.dart';
import 'package:giffity/presentation/bloc/gif_bloc.dart';
import 'package:giffity/presentation/pages/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(GifModelAdapter());
  Hive.registerAdapter(SettingsModelAdapter()); // Регистрируем новый адаптер

  // Открываем коробки с явным указанием типов
  final favoritesBox = await Hive.openBox<GifModel>('favorites');
  final settingsBox = await Hive.openBox<SettingsModel>('settings');

  // Загружаем сохраненные настройки или используем светлую тему по умолчанию
  final settings =
      settingsBox.get('settings') ?? SettingsModel(isDarkMode: false);

  runApp(
    MyApp(
      settingsBox: settingsBox,
      favoritesBox: favoritesBox,
      initialSettings: settings, // Передаем начальные настройки
    ),
  );
}

class MyApp extends StatelessWidget {
  final Box<SettingsModel> settingsBox;
  final Box<GifModel> favoritesBox;
  final SettingsModel initialSettings;

  const MyApp({
    Key? key,
    required this.settingsBox,
    required this.favoritesBox,
    required this.initialSettings,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ThemeBloc>(
          create:
              (context) => ThemeBloc(
                settingsBox: settingsBox,
                initialSettings: initialSettings,
              ),
        ),
        BlocProvider<GifBloc>(
          create:
              (context) => GifBloc(
                dataSource: GiphyDataSource(),
                favoritesBox: favoritesBox,
              ),
        ),
      ],
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, state) {
          return MaterialApp(
            theme: state.isDarkMode ? AppTheme.darkTheme : AppTheme.lightTheme,
            home: const HomePage(),
          );
        },
      ),
    );
  }
}
