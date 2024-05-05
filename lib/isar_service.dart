import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import 'song.dart';

class IsarService {
  late Future<Isar> db;

  IsarService() {
    db = openDB();
  }

  Future<void> addSong(Song newSong) async {
    final isar = await db;
    isar.writeTxnSync<int>(() => isar.songs.putSync(newSong));
  }

  Future<void> updateSong(Song song) async {
    final isar = await db;
    isar.writeTxnSync<void>(() => isar.songs.putSync(song));
  }

  Future<List<Song>> loadSongs() async {
    final isar = await db;
    return isar.songs.where().sortByPosition().findAll();
  }

  // Future<void> saveSongs(List<Song> songs) async {
  //   final isar = await db;
  //   isar.songs.clear();
  //   isar.writeTxnSync<void>(() => isar.songs.putAllSync(songs));
  // }

  Future<void> removeSong(Song song) async {
    final isar = await db;
    isar.writeTxnSync<bool>(() => isar.songs.deleteSync(song.id));
    // increment positions of songs after the deleted one
    List<Song> songs =
        await isar.songs.filter().positionGreaterThan(song.position).findAll();
    isar.writeTxnSync<void>(() {
      for (var s in songs) {
        s.position -= 1;
        isar.songs.putSync(s);
      }
    });
  }

  Future<void> insertSong(Song song, int position) async {
    // set the new position to the song
    final isar = await db;
    isar.writeTxnSync<void>(() {
      // increment positions of songs after the inserted one
      List<Song> songs =
          isar.songs.filter().positionGreaterThan(position - 1).findAllSync();
      for (var s in songs) {
        s.position += 1;
        isar.songs.putSync(s);
      }
      song.position = position;
      isar.songs.putSync(song);
    });
  }

  Stream<List<Song>> listenToSongs() async* {
    final isar = await db;
    yield* isar.songs.where().watch(
          fireImmediately: true,
        );
  }

  Future<void> cleanDb() async {
    final isar = await db;
    await isar.writeTxn(() => isar.clear());
  }

  Future<int> getLastPosition() async {
    final isar = await db;
    final lastSong =
        await isar.songs.where().sortByPositionDesc().limit(1).findFirst();
    return lastSong?.position ?? 0;
  }

  Future<Isar> openDB() async {
    if (Isar.instanceNames.isEmpty) {
      final dir = await getApplicationDocumentsDirectory();
      return await Isar.open(
        [SongSchema],
        inspector: true,
        directory: dir.path,
      );
    }

    return Future.value(Isar.getInstance());
  }
}
