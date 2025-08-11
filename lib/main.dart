import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:giffity/data/datasources/giphy_data_source.dart';
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

  // Открываем коробку ОДИН раз с явным указанием типа
  final favoritesBox = await Hive.openBox<GifModel>('favorites');
  final settingsBox = await Hive.openBox('settings');

  runApp(
    MyApp(
      settingsBox: settingsBox,
      favoritesBox: favoritesBox, // Передаем в MyApp
    ),
  );
}

class MyApp extends StatelessWidget {
  final Box settingsBox;
  final Box<GifModel> favoritesBox;

  const MyApp({Key? key, required this.settingsBox, required this.favoritesBox})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ThemeBloc>(create: (context) => ThemeBloc(settingsBox)),
        BlocProvider<GifBloc>(
          create:
              (context) => GifBloc(
                dataSource: GiphyDataSource(),
                favoritesBox: favoritesBox, // Используем уже открытую коробку
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
