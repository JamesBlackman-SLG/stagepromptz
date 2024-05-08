import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart' show ChangeNotifier;

import 'song_service.dart';
import 'song.dart';

class SongListProvider with ChangeNotifier {
  final songService = SongService();

  final List<Song> _songs = [];

  int currentIndex = 0;

  Song? _editingSong;
  SongListProvider() {
    loadSongs();
  }

  Song? get editingSong => _editingSong;
  set editingSong(Song? song) {
    _editingSong = song;
    notifyListeners();
  }

  List<Song> get songs => _songs;

  Future<void> addSong(Song song) {
    int position = songs.isEmpty ? 0 : songs[currentIndex].position;
    return songService.insertSong(song, position);
  }

  Future<void> cutSong() {
    editingSong = _songs[currentIndex];
    return songService.removeSong(_songs[currentIndex]);
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
    int position = songs.isEmpty ? 0 : songs[currentIndex].position;
    return songService.insertSong(_editingSong!, position);
  }

  Future<void> updateSong(Song song) {
    return songService.updateSong(song);
  }

  void downloadSongs() async {
    String fileContents = await songService.exportSongsToFile();
    String? selectedPath = await FilePicker.platform.saveFile(
      dialogTitle: 'Please select a json file:',
      fileName: 'songs.json',
      allowedExtensions: ['json'],
    );

    if (selectedPath != null) {
      final file = File(selectedPath);
      await file.writeAsString(fileContents);
    } else {}
  }

  void importSongs() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    if (result != null) {
      File file = File(result.files.single.path!);
      String fileContents = await file.readAsString();
      await songService.importSongsFromFile(fileContents);
      loadSongs();
    } else {}
  }
}
