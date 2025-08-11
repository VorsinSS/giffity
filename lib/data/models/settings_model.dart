import 'package:hive/hive.dart';

class SettingsModelAdapter extends TypeAdapter<SettingsModel> {
  @override
  final typeId = 1; // Должен совпадать с @HiveType()

  @override
  SettingsModel read(BinaryReader reader) {
    return SettingsModel(isDarkMode: reader.readBool());
  }

  @override
  void write(BinaryWriter writer, SettingsModel obj) {
    writer.writeBool(obj.isDarkMode);
  }
}

@HiveType(typeId: 1)
class SettingsModel {
  @HiveField(0)
  final bool isDarkMode;

  SettingsModel({required this.isDarkMode});
}
