import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'settings_provider.dart';
import 'song_list_provider.dart';

class Config extends StatelessWidget {
  const Config({super.key});

  void _newFile(BuildContext context) async {
    final songListProvider = context.read<SongListProvider>();
    final settingsProvider = context.read<SettingsProvider>();

    try {
      // Create a new songbook
      await songListProvider.newSongBook();

      // Reset the file name
      await settingsProvider.setFileName(null);

      // Navigate back to the previous screen
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pop(context);
      });
    } catch (e) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to create a new file. Please try again.'),
          ),
        );
      });
    }
  }

  void _saveFile(BuildContext context) async {
    final songListProvider = context.read<SongListProvider>();
    final settingsProvider = context.read<SettingsProvider>();
    final currentFileName = settingsProvider.settings.fileName ?? "songs.json";

    final fileName =
        await songListProvider.exportSongs(context, currentFileName);

    if (fileName.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        settingsProvider.setFileName(fileName);
        Navigator.pop(context);
      });
    }
  }

  // void _saveFile(BuildContext context) async {
  //   String currentFileName =
  //       Provider.of<SettingsProvider>(context, listen: false)
  //               .settings
  //               .fileName ??
  //           "songs.json";
  //   String fileName =
  //       await context.read<SongListProvider>().exportSongs(currentFileName);
  //
  //   WidgetsBinding.instance.addPostFrameCallback((_) {
  //     Provider.of<SettingsProvider>(context, listen: false)
  //         .setFileName(fileName);
  //     Navigator.pop(context);
  //   });
  //}

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
