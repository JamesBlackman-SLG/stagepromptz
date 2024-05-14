import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'settings_provider.dart';
import 'song_list_provider.dart';

class Config extends StatelessWidget {
  const Config({super.key});

  void _newFile(BuildContext context) async {
    Provider.of<SongListProvider>(context, listen: false).newSongBook();
    Provider.of<SettingsProvider>(context, listen: false).setFileName(null);

    Navigator.pop(context);
  }

  void _saveFile(BuildContext context) async {
    String currentFileName =
        Provider.of<SettingsProvider>(context, listen: false)
                .settings
                .fileName ??
            "songs.json";
    String fileName =
        await Provider.of<SongListProvider>(context, listen: false)
            .downloadSongs(currentFileName);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SettingsProvider>(context, listen: false)
          .setFileName(fileName);
      Navigator.pop(context);
    });
  }

  void _loadFile(BuildContext context) async {
    String fileName =
        await Provider.of<SongListProvider>(context, listen: false)
            .importSongs();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SettingsProvider>(context, listen: false)
          .setFileName(fileName);
      Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stagepromptz Config'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: ListView(
          children: [
            const SizedBox(
              height: 30,
            ),
            SizedBox(
              height: 100,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.new_label),
                onPressed: () {
                  _newFile(context);
                },
                label: const Text("New Song Book"),
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            SizedBox(
              height: 100,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.save),
                onPressed: () {
                  _saveFile(context);
                },
                label: const Text("Save Song Book"),
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            SizedBox(
              height: 100,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.file_open),
                onPressed: () {
                  _loadFile(context);
                },
                label: const Text("Load Song Book"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
