import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:giffity/data/models/gif_model.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';

class GifDetailPage extends StatefulWidget {
  final GifModel gif;

  const GifDetailPage({Key? key, required this.gif}) : super(key: key);

  @override
  State<GifDetailPage> createState() => _GifDetailPageState();
}

class _GifDetailPageState extends State<GifDetailPage> {
  bool _isDownloading = false;
  final Dio _dio = Dio();

  Future<void> _shareGif() async {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.link),
                title: const Text('Поделиться ссылкой'),
                onTap: () async {
                  Navigator.pop(context);
                  await _shareLink();
                },
              ),
              ListTile(
                leading: const Icon(Icons.file_download),
                title: const Text('Поделиться файлом GIF'),
                onTap: () async {
                  Navigator.pop(context);
                  await _shareFile();
                },
              ),
            ],
          ),
    );
  }

  Future<void> _shareLink() async {
    try {
      // Проверка URL
      if (!Uri.parse(widget.gif.url).isAbsolute) {
        throw Exception('Invalid URL');
      }

      await Share.share(widget.gif.url);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Не удалось поделиться ссылкой')),
      );
    }
  }

  Future<void> _shareFile() async {
    setState(() => _isDownloading = true);

    try {
      // Проверка URL
      if (!widget.gif.url.startsWith('http')) {
        throw Exception('Invalid URL');
      }

      // Скачивание файла
      final response = await _dio.get<Uint8List>(
        widget.gif.url,
        options: Options(responseType: ResponseType.bytes),
      );

      // Сохранение во временный файл
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/share.gif');
      await file.writeAsBytes(response.data!);

      // Шаринг файла
      await Share.shareXFiles([XFile(file.path)]);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Не удалось поделиться файлом')),
      );
    } finally {
      if (mounted) {
        setState(() => _isDownloading = false);
      }
    }
  }

  @override
  void dispose() {
    _dio.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_isDownloading)
            const Padding(
              padding: EdgeInsets.all(12.0),
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.share, color: Colors.white),
              onPressed: _shareGif,
            ),
        ],
      ),
      body: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Center(
          child: Hero(
            tag: 'gif-${widget.gif.id}',
            child: CachedNetworkImage(
              imageUrl: widget.gif.url,
              fit: BoxFit.contain,
              placeholder: (context, url) => Container(color: Colors.grey[800]),
              errorWidget: (context, url, error) => const Icon(Icons.error),
            ),
          ),
        ),
      ),
    );
  }
}
