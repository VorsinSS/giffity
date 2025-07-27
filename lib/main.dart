import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:giffity/data/datasources/giphy_data_source.dart';
import 'package:giffity/data/models/gif_model.dart';
import 'package:giffity/presentation/bloc/gif_bloc.dart';
import 'package:giffity/presentation/pages/home_page.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(GifModelAdapter());
  await Hive.openBox<GifModel>('favorites'); // Открываем Box при запуске

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BlocProvider(
        create: (context) => GifBloc(GiphyDataSource()),
        child: HomePage(),
      ),
    );
  }
}
