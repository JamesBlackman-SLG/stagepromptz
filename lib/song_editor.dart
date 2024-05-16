import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'action_intents.dart';
import 'song.dart';
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

  Future<void> _addNewSong() async {
    widget._songListProvider
        .addSong(Song(
      title: _titleController.text,
      lyrics: _lyricsController.text,
      position: 0,
    ))
        .then((value) {
      widget._songListProvider.loadSongs();
      widget._songListProvider.reorderSongs(widget._songListProvider.songs);
      _titleController.clear();
      _lyricsController.clear();
      Navigator.pop(context);
    });
  }

  Future<void> _updateSong() async {
    song!.title = _titleController.text;
    song!.lyrics = _lyricsController.text;

    widget._songListProvider.updateSong(song!).then((value) {
      widget._songListProvider.loadSongs();
      widget._songListProvider.reorderSongs(widget._songListProvider.songs);
      _titleController.clear();
      _lyricsController.clear();
      Navigator.pop(context);
    });
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
        child: Scaffold(
          appBar: AppBar(
            title: Text(widget.createNew ? 'New Song' : 'Edit Song'),
            actions: [
              if (!widget.createNew)
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    widget._songListProvider.cutSong(song!);
                    widget._songListProvider.loadSongs();
                    Navigator.pop(context);
                  },
                ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  autofocus: true,
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                ),
                Expanded(
                  child: TextField(
                    controller: _lyricsController,
                    decoration: const InputDecoration(labelText: 'Lyrics'),
                    minLines: 10,
                    maxLines: 200,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        if (_titleController.text.isNotEmpty) {
                          if (widget.createNew) {
                            _addNewSong();
                          } else {
                            _updateSong();
                          }
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
                )
              ],
            ),
          ),
          // bottomNavigationBar: BottomAppBar(
          //   color: Colors.black,
          //   child: Row(
          //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          //     children: [
          //       ElevatedButton(
          //         onPressed: () async {
          //           if (_titleController.text.isNotEmpty) {
          //             if (widget.createNew) {
          //               _addNewSong();
          //             } else {
          //               _updateSong();
          //             }
          //           }
          //         },
          //         child: const Text('Save Song'),
          //       ),
          //       ElevatedButton(
          //         onPressed: () {
          //           Navigator.pop(context);
          //         },
          //         child: const Text('Cancel'),
          //       ),
          //     ],
          //   ),
          // ),
        ),
      ),
    );
  }
}
