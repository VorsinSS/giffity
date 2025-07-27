import 'package:giffity/data/models/gif_model.dart';

abstract class GifState {}

// Начальное состояние
class GifInitialState extends GifState {}

// Загрузка первой страницы
class GifLoadingState extends GifState {}

// Успешная загрузка (теперь храним текущую страницу)
class GifLoadedState extends GifState {
  final List<GifModel> gifs;
  final int currentPage;
  final bool hasReachedMax;
  final String query; // Добавляем хранение текущего запроса

  GifLoadedState({
    required this.gifs,
    this.currentPage = 1,
    this.hasReachedMax = false,
    required this.query, // Обязательный параметр
  });

  GifLoadedState copyWith({
    List<GifModel>? gifs,
    int? currentPage,
    bool? hasReachedMax,
    String? query,
  }) {
    return GifLoadedState(
      gifs: gifs ?? this.gifs,
      currentPage: currentPage ?? this.currentPage,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      query: query ?? this.query,
    );
  }
}

// Ошибка
class GifErrorState extends GifState {
  final String error;
  GifErrorState(this.error);
}
