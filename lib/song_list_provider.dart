import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart'
    show
        BuildContext,
        ChangeNotifier,
        ScaffoldMessenger,
        SnackBar,
        Text,
        WidgetsBinding;
import 'package:permission_handler/permission_handler.dart';
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
    // return songService.insertSong(song, position);
    return songService.addSong(song);
  }

  Future<void> copySong() {
    editingSong = _songs[currentIndex];
    return Future.value();
  }

  Future<void> cutSong(Song song) {
    editingSong = song;
    return songService.removeSong(song);
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

  Future<void> newSongBook() async {
    songService.cleanDb().then((value) {
      songs.clear();
      notifyListeners();
      return;
    });
  }

  Future<String> rawSongs() async {
    return await songService.toJson();
  }

  Future<String> exportSongs(BuildContext context, String fileName) async {
    // Request storage permissions
    if (!await Permission.storage.request().isGranted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Storage permission is required to save files.')));
      });
    }

    try {
      String fileContents = await songService.toJson();
      String? selectedPath = await FilePicker.platform.saveFile(
        dialogTitle: 'Please select a json file to export songs to :',
        fileName: fileName,
        allowedExtensions: ['json'],
      );
      if (selectedPath != null) {
        final file = File(selectedPath);
        await file.writeAsString(fileContents);
        String fileName = selectedPath.split(Platform.pathSeparator).last;
        return fileName;
      } else {
        return "";
      }
    } catch (e) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Failed to save the file. Please try again.')));
      });
      return "";
    }
  }

  // Future<String> exportSongs(String fileName) async {
  //   String fileContents = await songService.exportSongsToFile();
  //   String? selectedPath = await FilePicker.platform.saveFile(
  //     dialogTitle: 'Please select a json file:',
  //     fileName: fileName,
  //     allowedExtensions: ['json'],
  //   );
  //   print(selectedPath);
  //   if (selectedPath != null) {
  //     final file = File(selectedPath);
  //     //await file.writeAsString(fileContents);
  //     //String fileName = selectedPath.split(Platform.pathSeparator).last;
  //     //return fileName;
  //     return "";
  //   } else {
  //     return "";
  //   }
  // }
  //
  Future<bool> rawImport(String fileContents) async {
    bool result = await songService.importSongsFromFile(fileContents);
    if (result) {
      loadSongs();
      return true;
    } else {
      return false;
    }
  }

  Future<String> importSongs() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    if (result != null) {
      File file = File(result.files.single.path!);
      String fileContents = await file.readAsString();
      await songService.importSongsFromFile(fileContents);
      loadSongs();
      String fileName =
          result.files.single.path!.split(Platform.pathSeparator).last;
      return fileName;
    } else {
      return "";
    }
  }

  void reorderSongs(List<Song> songs) async {
    await songService.reorderSongs(songs);
  }
}
