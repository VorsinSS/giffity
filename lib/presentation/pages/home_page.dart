import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:giffity/presentation/bloc/gif_bloc.dart';
import 'package:giffity/presentation/bloc/gif_event.dart';
import 'package:giffity/presentation/bloc/gif_state.dart';

class HomePage extends StatelessWidget {
  final TextEditingController _searchController = TextEditingController();

  HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('GIF Search')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Поле ввода поиска
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Например, "cats"',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    final query = _searchController.text.trim();
                    if (query.isNotEmpty) {
                      // Отправляем событие поиска в BLoC
                      context.read<GifBloc>().add(SearchGifsEvent(query));
                    }
                  },
                ),
              ),
              onSubmitted: (query) {
                if (query.trim().isNotEmpty) {
                  context.read<GifBloc>().add(SearchGifsEvent(query));
                }
              },
            ),
            const SizedBox(height: 20),
            // BlocBuilder для отображения состояний
            Expanded(
              child: BlocBuilder<GifBloc, GifState>(
                builder: (context, state) {
                  if (state is GifLoadingState) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is GifErrorState) {
                    return Center(child: Text(state.error));
                  } else if (state is GifLoadedState) {
                    return GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                          ),
                      itemCount: state.gifs.length,
                      itemBuilder: (context, index) {
                        final gif = state.gifs[index];
                        return Image.network(gif.url, fit: BoxFit.cover);
                      },
                    );
                  } else {
                    // Начальное состояние (GifInitialState)
                    return const Center(
                      child: Text('Введите запрос для поиска GIF'),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
