import 'package:flutter/material.dart' show ChangeNotifier;
import 'package:isar/isar.dart';

import 'song.dart';

class SongListProvider with ChangeNotifier {
  final Isar isar;
  SongListProvider(this.isar) {
    loadSongs();
  }

  final List<Song> _songs = [
    //   Song(id: 1, title: "Hey Jude", lyrics: "Hey Jude, Don't make it bad..."),
    //   Song(
    //       id: 2,
    //       title: "Yesterday",
    //       lyrics: "Yesterday, all my troubles seemed so far away..."),
    //   Song(
    //       id: 3,
    //       title: "Let It Be",
    //       lyrics: "When I find myself in times of trouble..."),
    //   Song(
    //       id: 4,
    //       title: "Yellow Submarine",
    //       lyrics: "In the town where I was born..."),
  ];

  int _currentIndex = 0;
  Song? _editingSong;

  int get currentIndex => _currentIndex;

  set currentIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  Song? get editingSong => _editingSong;
  set editingSong(Song? song) {
    _editingSong = song;
    notifyListeners();
  }

  List<Song> get songs => _songs;

  void saveSongsToDb() async {
    await isar.writeTxn(() async {
      isar.songs.clear();
      for (final song in _songs) {
        isar.songs.put(song);
      }
    });
  }

  void loadSongs() async {
    _songs.clear();
    final List<Song> songs = await loadSongsFromDb();
    _songs.addAll(songs);
    notifyListeners();
  }

  Future<List<Song>> loadSongsFromDb() async {
    _songs.clear();
    return await isar.songs.where().findAll();
  }

  void addSong(Song song) {
    if (_songs.where((element) => element.id == song.id).isEmpty) {
      _songs.add(song);
      notifyListeners();
      return;
    }
    final index = _songs.indexWhere((element) => element.id == song.id);
    _songs[index] = song;
    notifyListeners();
    saveSongsToDb();
  }

  void cutSong(int index) {
    if (index >= 0 && index < _songs.length) {
      _editingSong = _songs[index];
      _songs.removeAt(index);
      notifyListeners();
      saveSongsToDb();
    }
  }

  void pasteSong() {
    if (_editingSong != null) {
      _songs.insert(_currentIndex, _editingSong!);
      _editingSong = null;
      notifyListeners();
      saveSongsToDb();
    }
  }

  void removeSong(int index) {
    if (index >= 0 && index < _songs.length) {
      _songs.removeAt(index);
      notifyListeners();
      saveSongsToDb();
    }
  }

  void updateSong(Song song) {
    final index = _songs.indexWhere((element) => element.id == song.id);
    if (index >= 0) {
      _songs[index] = song;
      notifyListeners();
      saveSongsToDb();
    }
  }
}
