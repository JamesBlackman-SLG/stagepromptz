import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart' show ChangeNotifier;

import 'song_service.dart';
import 'song.dart';

class SongListProvider with ChangeNotifier {
  final songService = SongService();

  final List<Song> _songs = [];

  int _currentIndex = 0;

  Song? _editingSong;
  SongListProvider() {
    loadSongs();
  }

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

  Future<void> addSong(Song song) {
    int position = songs.isEmpty ? 0 : songs[_currentIndex].position;
    return songService.insertSong(song, position);
  }

  Future<void> cutSong() {
    editingSong = _songs[_currentIndex];
    return songService.removeSong(_songs[_currentIndex]);
  }

  void loadSongs() async {
    _songs.clear();
    notifyListeners();
    _songs.addAll(await loadSongsFromDb());
    notifyListeners();
  }

  Future<List<Song>> loadSongsFromDb() async {
    return await songService.loadSongs();
  }

  Future<void> pasteSong() {
    if (_editingSong == null) {
      return Future.value();
    }
    int position = songs.isEmpty ? 0 : songs[_currentIndex].position;
    return songService.insertSong(_editingSong!, position);
  }

  Future<void> updateSong(Song song) {
    return songService.updateSong(song);
  }

  void downloadSongs() async {
    String fileContents = await songService.exportSongsToFile();
    String? selectedPath = await FilePicker.platform.saveFile(
      dialogTitle: 'Please select an output file:',
      fileName: 'saved_text.txt', // Suggested file name and extension
    );

    if (selectedPath != null) {
      final file = File(selectedPath);
      await file.writeAsString(fileContents);
    } else {}
  }
}
