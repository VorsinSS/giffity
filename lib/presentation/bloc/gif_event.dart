import 'package:giffity/data/models/gif_model.dart';

abstract class GifEvent {}

class SearchGifsEvent extends GifEvent {
  final String query;
  SearchGifsEvent(this.query);
}

class LoadMoreGifsEvent extends GifEvent {}

class ToggleFavoriteEvent extends GifEvent {
  final GifModel gif;
  ToggleFavoriteEvent(this.gif);
}
