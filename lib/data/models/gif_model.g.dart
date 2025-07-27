// lib/data/models/gif_model.g.dart
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gif_model.dart';

class GifModelAdapter extends TypeAdapter<GifModel> {
  @override
  final int typeId = 0;

  @override
  GifModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GifModel(
      id: fields[0] as String,
      url: fields[1] as String,
      title: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, GifModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.url)
      ..writeByte(2)
      ..write(obj.title);
  }
}
