import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:stagepromptz/settings.dart';

import 'song.dart';

class SettingsService {
  late Future<Isar> db;

  SettingsService() {
    db = openDB();
  }
  final Settings initialSettings = Settings(
    textScaleFactor: 1.0,
  );

  Future<void> saveSettings(Settings settings) async {
    final isar = await db;
    isar.writeTxnSync<int>(() => isar.settings.putSync(settings));
  }

  Future<Settings> loadSettings() async {
    final isar = await db;
    if (await isar.settings.where().isEmpty()) {
      await isar.writeTxn(() => isar.settings.put(initialSettings));
      return initialSettings;
    }

    return isar.settings.where().findFirst().then((settings) => settings!);
  }

  Future<Isar> openDB() async {
    if (Isar.instanceNames.isEmpty) {
      final dir = await getApplicationDocumentsDirectory();
      return await Isar.open(
        [SongSchema, SettingsSchema],
        inspector: true,
        directory: dir.path,
      );
    }

    return Future.value(Isar.getInstance());
  }
}
