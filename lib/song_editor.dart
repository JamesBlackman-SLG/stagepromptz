import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'action_intents.dart';
import 'song_model.dart';
import 'song_list_provider.dart';

class SongEditor extends StatefulWidget {
  final SongListProvider _songListProvider;
  final bool createNew;
  const SongEditor(this._songListProvider,
      {super.key, required this.createNew});

  @override
  SongEditorState createState() => SongEditorState();
}

class SongEditorState extends State<SongEditor> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _lyricsController = TextEditingController();
  late final Song? song;
  @override
  void initState() {
    song = widget._songListProvider.editingSong;
    if (song != null) {
      _titleController.text = song!.title;
      _lyricsController.text = song!.lyrics;
    }
    super.initState();
  }

  @override
  dispose() {
    _titleController.dispose();
    _lyricsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Actions(
      actions: {
        PopAction: CallbackAction<PopAction>(
          onInvoke: (Intent intent) {
            return Navigator.maybePop(context);
          },
        ),
      },
      child: Shortcuts(
        shortcuts: const {
          SingleActivator(LogicalKeyboardKey.escape): PopAction(),
        },
        child: Focus(
          autofocus: true,
          child: Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(labelText: 'Title'),
                  ),
                  TextField(
                    controller: _lyricsController,
                    decoration: const InputDecoration(labelText: 'Lyrics'),
                    minLines: 10,
                    maxLines: 200,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          if (_titleController.text.isNotEmpty) {
                            widget._songListProvider.addSong(Song(
                              id: widget.createNew
                                  ? widget._songListProvider.nextId
                                  : song!.id,
                              title: _titleController.text,
                              lyrics: _lyricsController.text,
                            ));
                            _titleController.clear();
                            _lyricsController.clear();
                            Navigator.pop(context);
                          }
                        },
                        child: const Text('Save Song'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('Cancel'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
