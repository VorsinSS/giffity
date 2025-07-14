import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:giffity/data/datasources/giphy_data_source.dart';

import 'package:giffity/presentation/bloc/gif_event.dart';
import 'package:giffity/presentation/bloc/gif_state.dart';

class GifBloc extends Bloc<GifEvent, GifState> {
  final GiphyDataSource dataSource;

  GifBloc(this.dataSource) : super(GifInitialState()) {
    on<SearchGifsEvent>(_onSearchGifs);
  }

  Future<void> _onSearchGifs(
    SearchGifsEvent event,
    Emitter<GifState> emit,
  ) async {
    emit(GifLoadingState());

    try {
      final gifs = await dataSource.searchGifs(event.query);
      emit(GifLoadedState(gifs)); // передаём List<GifModel>
    } catch (e) {
      emit(GifErrorState('Ошибка: $e')); // можно вывести саму ошибку
    }
  }
}
