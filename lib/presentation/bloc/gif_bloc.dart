import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:giffity/data/datasources/giphy_data_source.dart';
import 'package:giffity/data/models/gif_model.dart';
import 'package:giffity/presentation/bloc/gif_event.dart';
import 'package:giffity/presentation/bloc/gif_state.dart';
import 'package:hive/hive.dart';

class GifBloc extends Bloc<GifEvent, GifState> {
  final GiphyDataSource dataSource;
  final Box<GifModel> favoritesBox;
  final int itemsPerPage = 20;

  GifBloc(this.dataSource)
    : favoritesBox = Hive.box<GifModel>('favorites'),
      super(GifInitialState()) {
    on<SearchGifsEvent>(_onSearch);
    on<LoadMoreGifsEvent>(_onLoadMore);
    on<ToggleFavoriteEvent>(_onToggleFavorite);
  }

  Future<void> _onSearch(SearchGifsEvent event, Emitter<GifState> emit) async {
    emit(GifLoadingState());
    try {
      final gifs = await dataSource.searchGifs(event.query, page: 1);
      emit(
        GifLoadedState(
          gifs: gifs,
          query: event.query,
          currentPage: 1,
          hasReachedMax: gifs.length < itemsPerPage,
        ),
      );
    } catch (e) {
      emit(GifErrorState('Ошибка поиска: $e'));
    }
  }

  Future<void> _onLoadMore(
    LoadMoreGifsEvent event,
    Emitter<GifState> emit,
  ) async {
    if (state is! GifLoadedState) return;
    final currentState = state as GifLoadedState;

    if (currentState.hasReachedMax) return;

    try {
      final newGifs = await dataSource.searchGifs(
        currentState.query,
        page: currentState.currentPage + 1,
      );

      emit(
        currentState.copyWith(
          gifs: [...currentState.gifs, ...newGifs],
          currentPage: currentState.currentPage + 1,
          hasReachedMax: newGifs.length < itemsPerPage,
        ),
      );
    } catch (e) {
      // Можно добавить обработку ошибки
    }
  }

  Future<void> _onToggleFavorite(
    ToggleFavoriteEvent event,
    Emitter<GifState> emit,
  ) async {
    try {
      if (favoritesBox.containsKey(event.gif.id)) {
        await favoritesBox.delete(event.gif.id);
      } else {
        await favoritesBox.put(event.gif.id, event.gif);
      }

      if (state is GifLoadedState) {
        emit((state as GifLoadedState).copyWith());
      }
    } catch (e) {
      print('Ошибка при обновлении избранного: $e');
    }
  }

  bool isFavorite(String gifId) {
    return favoritesBox.containsKey(gifId);
  }
}
