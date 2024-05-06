import 'package:isar/isar.dart';

part 'settings.g.dart';

@Collection()
class Settings {
  Id id = Isar.autoIncrement;
  double textScaleFactor = 1.0;
  Settings({
    required this.textScaleFactor,
  });
}
