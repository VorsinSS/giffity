import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:giffity/presentation/bloc/gif_event.dart';
import 'package:giffity/presentation/bloc/gif_state.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:giffity/data/models/gif_model.dart';
import 'package:giffity/presentation/bloc/gif_bloc.dart';
import 'package:giffity/presentation/pages/gif_detail_page.dart';
import 'package:hive_flutter/hive_flutter.dart'; // Добавлен импорт

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  _FavoritesPageState createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  late Box<GifModel> _favoritesBox;

  @override
  void initState() {
    super.initState();
    _favoritesBox = Hive.box<GifModel>('favorites');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Избранное'),
        actions: [
          if (_favoritesBox.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _confirmClearAll,
            ),
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: _favoritesBox.listenable(),
        builder: (context, Box<GifModel> box, _) {
          final favorites = box.values.toList();

          if (favorites.isEmpty) {
            return const Center(
              child: Text('Нет избранных GIF', style: TextStyle(fontSize: 18)),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1,
            ),
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              final gif = favorites[index];
              return Dismissible(
                key: Key(gif.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                confirmDismiss: (_) => _confirmDelete(gif),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => GifDetailPage(
                              gif: gif,
                              heroTag:
                                  'fav-gif-${gif.id}-$index', // Уникальный тег для избранного
                            ),
                      ),
                    );
                  },
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Hero(
                        tag: 'fav-gif-${gif.id}-$index',
                        child: CachedNetworkImage(
                          imageUrl: gif.url,
                          fit: BoxFit.cover,
                          placeholder:
                              (context, url) =>
                                  Container(color: Colors.grey[200]),
                          errorWidget:
                              (context, url, error) => const Icon(Icons.error),
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: IconButton(
                          icon: const Icon(Icons.favorite, color: Colors.red),
                          onPressed: () => _removeFromFavorites(gif),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<bool> _confirmDelete(GifModel gif) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Удалить из избранного?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Отмена'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'Удалить',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
    return confirmed ?? false;
  }

  Future<void> _confirmClearAll() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Очистить избранное?'),
            content: const Text('Все GIF будут удалены'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Отмена'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'Очистить',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      await _favoritesBox.clear();
      final bloc = context.read<GifBloc>();
      if (bloc.state is GifLoadedState) {
        bloc.add(LoadMoreGifsEvent());
      }
    }
  }

  Future<void> _removeFromFavorites(GifModel gif) async {
    await _favoritesBox.delete(gif.id);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Удалено из избранного')));
  }
}
