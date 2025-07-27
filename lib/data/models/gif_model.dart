import 'package:hive/hive.dart';

part 'gif_model.g.dart';

@HiveType(typeId: 0)
class GifModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String url;

  @HiveField(2)
  final String title;

  GifModel({required this.id, required this.url, required this.title});

  // Сохраняем factory для JSON-парсинга
  factory GifModel.fromJson(Map<String, dynamic> json) {
    return GifModel(
      id: json['id'] as String,
      url: json['images']['fixed_height']['url'] as String,
      title: json['title'] as String? ?? 'Без названия',
    );
  }

  // Добавим метод для удобства (опционально)
  Map<String, dynamic> toJson() {
    return {'id': id, 'url': url, 'title': title};
  }
}
