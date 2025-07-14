abstract class GifEvent {}

// Событие поиска GIF (передаём текст запроса)
class SearchGifsEvent extends GifEvent {
  final String query;

  SearchGifsEvent(this.query);
}
