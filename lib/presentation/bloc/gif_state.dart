import 'package:giffity/data/models/gif_model.dart';

abstract class GifState {}

// Начальное состояние (пустой экран)
class GifInitialState extends GifState {}

// Идёт загрузка (показываем индикатор)
class GifLoadingState extends GifState {}

// Успешная загрузка (передаём список GIF)
class GifLoadedState extends GifState {
  final List<GifModel> gifs;

  GifLoadedState(this.gifs);
}

// Ошибка (передаём текст ошибки)
class GifErrorState extends GifState {
  final String error;

  GifErrorState(this.error);
}
