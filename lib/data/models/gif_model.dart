class GifModel {
  final String id;
  final String url;
  final String title;

  GifModel({required this.id, required this.url, required this.title});

  factory GifModel.fromJson(Map<String, dynamic> json) {
    return GifModel(
      id: json['id'] as String, // явное приведение типа
      url: json['images']['fixed_height']['url'] as String,
      title: json['title'] as String? ?? 'Без названия', // обработка null
    );
  }
}
