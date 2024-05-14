import 'dart:convert';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:stagepromptz/settings.dart';

import 'song.dart';

class SongService {
  late Future<Isar> db;

  SongService() {
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
    final isar = await db;
    isar.writeTxnSync<void>(() {
      // increment positions of songs after the inserted one
      List<Song> songs =
          isar.songs.filter().positionGreaterThan(position).findAllSync();
      List<Song> updatedSongs = [];

      for (var s in songs) {
        s.position++;
        updatedSongs.add(s);
      }
      isar.songs.putAllSync(updatedSongs);
      Song insertedSong = Song(
        title: song.title,
        lyrics: song.lyrics,
        position: position,
      );
      insertedSong.position = position;
      isar.songs.putSync(insertedSong);
    });
  }

  Future<void> reorderSongs(List<Song> updatedSongs) async {
    if (updatedSongs.isEmpty) {
      return;
    }

    // Ensure the updatedSongs list is not modified after awaiting db
    List<Song> songsToReorder = List.from(updatedSongs);
    final isar = await db;
    for (int i = 0; i < songsToReorder.length; i++) {
      isar.writeTxnSync(() {
        songsToReorder[i].position = i + 1;
        isar.songs.putSync(songsToReorder[i]);
      });
    }
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
        [SongSchema, SettingsSchema],
        inspector: true,
        directory: dir.path,
      );
    }

    return Future.value(Isar.getInstance());
  }

  Future<String> exportSongsToFile() async {
    final isar = await db;
    final songs = await isar.songs.where().sortByPosition().findAll();
    String jsonData = jsonEncode(songs.map((song) => song.toJson()).toList());
    return jsonData;
  }

  Future<void> importSongsFromFile(String jsonData) async {
    final isar = await db;
    List<dynamic> songsData = jsonDecode(jsonData);
    List<Song> songs =
        songsData.map((songData) => Song.fromJson(songData)).toList();
    isar.writeTxnSync(() {
      isar.songs.clearSync();
      isar.songs.putAllSync(songs);
    });
  }
}
