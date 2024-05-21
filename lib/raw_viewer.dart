import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'settings_provider.dart';
import 'song_list_provider.dart';

class RawViewer extends StatefulWidget {
  const RawViewer({super.key});

  @override
  State<RawViewer> createState() => _RawViewerState();
}

class _RawViewerState extends State<RawViewer> {
  bool loading = true;
  final TextEditingController _controller = TextEditingController();
  @override
  initState() {
    super.initState();
    _load(context);
  }

  void _load(BuildContext context) async {
    final songListProvider = context.read<SongListProvider>();
    // final settingsProvider = context.read<SettingsProvider>();
    _controller.text = await songListProvider.rawSongs();
    setState(() {
      loading = false;
    });
  }

  void _import(BuildContext context) async {
    final songListProvider = context.read<SongListProvider>();
    final settingsProvider = context.read<SettingsProvider>();
    // final currentFileName = settingsProvider.settings.fileName ?? "songs.json";
    if (await songListProvider.rawImport(_controller.text)) {
      settingsProvider.setFileName("songs.json");
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Imported successfully')));
        Navigator.pop(context);
      });
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Import failed')));
      });
    }
    //   const String fileName = "raw.json";
    //   if (fileName.isNotEmpty) {
    //     WidgetsBinding.instance.addPostFrameCallback((_) {
    //       settingsProvider.setFileName(fileName);
    //       Navigator.pop(context);
    //     });
    //   }
  }

  void copyTextControllerToBuffer(BuildContext context) {
    Clipboard.setData(ClipboardData(text: _controller.text));
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Copied to clipboard')));
  }

  void pasteTextControllerFromBuffer(BuildContext context) async {
    final ClipboardData? data = await Clipboard.getData('text/plain');
    if (data != null) {
      _controller.text = data.text ?? "";
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Pasted from clipboard')));
    });
  }

  // void _loadFile(BuildContext context) async {
  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Stagepromptz Raw Viewer'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text(
            'Stagepromptz Raw Viewer - just for copying the json and storing somewhere else...'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: TextField(
          controller: _controller,
          minLines: 30,
          maxLines: 30,
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            IconButton(
              icon: const Icon(Icons.copy),
              onPressed: () {
                copyTextControllerToBuffer(context);
              },
            ),
            IconButton(
              icon: const Icon(Icons.paste),
              onPressed: () {
                pasteTextControllerFromBuffer(context);
              },
            ),
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: () {
                _import(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
