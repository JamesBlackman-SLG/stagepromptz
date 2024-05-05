import 'package:flutter/material.dart' show ChangeNotifier;

import 'isar_service.dart';
import 'song.dart';

class SongListProvider with ChangeNotifier {
  final service = IsarService();

  SongListProvider() {
    loadSongs();
  }

  final List<Song> _songs = [];

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

  void loadSongs() async {
    _songs.clear();
    notifyListeners();
    _songs.addAll(await loadSongsFromDb());
    notifyListeners();
  }

  Future<List<Song>> loadSongsFromDb() async {
    return await service.loadSongs();
  }

  Future<void> addSong(Song song) {
    int position = songs.isEmpty ? 0 : songs[_currentIndex].position;
    return service.insertSong(song, position);
  }

  Future<void> cutSong() {
    editingSong = _songs[_currentIndex];
    return service.removeSong(_songs[_currentIndex]);
  }

  Future<void> pasteSong() {
    if (_editingSong == null) {
      return Future.value();
    }
    int position = songs.isEmpty ? 0 : songs[_currentIndex].position;
    return service.insertSong(_editingSong!, position);
  }

  Future<void> updateSong(Song song) {
    return service.updateSong(song);
  }
}
