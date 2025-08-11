import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:giffity/presentation/bloc/theme_bloc.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeBloc = BlocProvider.of<ThemeBloc>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Настройки')),
      body: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, state) {
          return SwitchListTile(
            title: const Text('Темная тема'),
            value: context.watch<ThemeBloc>().state.isDarkMode,
            onChanged: (value) {
              context.read<ThemeBloc>().add(ToggleThemeEvent());
            },
          );
        },
      ),
    );
  }
}
