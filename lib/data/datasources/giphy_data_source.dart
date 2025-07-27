import 'dart:convert';

import 'package:giffity/config.dart';
import 'package:giffity/data/models/gif_model.dart';
import 'package:http/http.dart' as http;

class GiphyDataSource {
  final String apiKey = Config.giphyApiKey;
  final String baseUrl = 'https://api.giphy.com/v1/gifs';

  Future<List<GifModel>> searchGifs(String query, {int page = 1}) async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/search?api_key=$apiKey&q=$query&limit=20&offset=${(page - 1) * 20}',
      ),
    );

    print('Raw API response: ${response.body}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      // Преобразуем каждый элемент списка `data['data']` в `GifModel`
      return (data['data'] as List)
          .map((gifJson) => GifModel.fromJson(gifJson))
          .toList();
    } else {
      throw Exception('Ошибка загрузки GIF');
    }
  }
}
