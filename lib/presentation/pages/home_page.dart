import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:giffity/presentation/bloc/gif_bloc.dart';
import 'package:giffity/presentation/bloc/gif_event.dart';
import 'package:giffity/presentation/bloc/gif_state.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:giffity/presentation/pages/favorites_page.dart';
import 'package:giffity/presentation/pages/gif_detail_page.dart'; // Добавьте этот импорт

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      context.read<GifBloc>().add(LoadMoreGifsEvent());
    }
  }

  void _searchGifs() {
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      context.read<GifBloc>().add(SearchGifsEvent(query));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GIF Search'),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FavoritesPage()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search GIFs...',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _searchGifs,
                ),
              ),
              onSubmitted: (_) => _searchGifs(),
            ),
          ),
          Expanded(
            child: BlocBuilder<GifBloc, GifState>(
              builder: (context, state) {
                if (state is GifInitialState) {
                  return const Center(
                    child: Text('Enter a search term to find GIFs'),
                  );
                } else if (state is GifLoadingState) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is GifErrorState) {
                  return Center(child: Text(state.error));
                } else if (state is GifLoadedState) {
                  if (state.gifs.isEmpty) {
                    return const Center(child: Text('No GIFs found'));
                  }

                  return GridView.builder(
                    controller: _scrollController,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                          childAspectRatio: 1,
                        ),
                    padding: const EdgeInsets.all(8),
                    itemCount:
                        state.hasReachedMax
                            ? state.gifs.length
                            : state.gifs.length + 1,
                    itemBuilder: (context, index) {
                      if (index >= state.gifs.length) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }
                      final gif = state.gifs[index];
                      final isFavorite = context.read<GifBloc>().isFavorite(
                        gif.id,
                      );

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => GifDetailPage(gif: gif),
                            ),
                          );
                        },
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Hero(
                              tag: 'gif-${gif.id}',
                              child: CachedNetworkImage(
                                imageUrl: gif.url,
                                fit: BoxFit.cover,
                                placeholder:
                                    (context, url) =>
                                        Container(color: Colors.grey[200]),
                                errorWidget:
                                    (context, url, error) =>
                                        const Icon(Icons.error),
                              ),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: IconButton(
                                icon: Icon(
                                  isFavorite
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: Colors.red,
                                ),
                                onPressed: () {
                                  context.read<GifBloc>().add(
                                    ToggleFavoriteEvent(gif),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }
                return Container();
              },
            ),
          ),
        ],
      ),
    );
  }
}
