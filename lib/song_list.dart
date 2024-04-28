import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'action_intents.dart';
import 'slideshow.dart';
import 'song_editor.dart';
import 'song_list_provider.dart';

class SongList extends StatefulWidget {
  final SongListProvider songListProvider;

  const SongList({super.key, required this.songListProvider});

  @override
  State<SongList> createState() => _SongListState();
}

class _SongListState extends State<SongList> {
  FocusNode focusNode = FocusNode();
  void _editSong(int index) {
    widget.songListProvider.editingSong = widget.songListProvider.songs[index];
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SongEditor(
          createNew: false,
          widget.songListProvider,
        ),
      ),
    );
  }

  void _createSong() {
    widget.songListProvider.editingSong = null;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SongEditor(
          createNew: true,
          widget.songListProvider,
        ),
      ),
    );
  }

  void _cutSong(int index) {
    widget.songListProvider.editingSong = widget.songListProvider.songs[index];
    widget.songListProvider.removeSong(index);
  }

  void _pasteSong() {
    widget.songListProvider.pasteSong();
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
        LeftKeyAction: CallbackAction<LeftKeyAction>(
          onInvoke: (Intent intent) {
            focusNode.nextFocus();
            return true;
          },
        ),
        RightKeyAction: CallbackAction<RightKeyAction>(
          onInvoke: (Intent intent) {
            focusNode.previousFocus();
            return true;
          },
        ),
        EditAction: CallbackAction<EditAction>(
          onInvoke: (Intent intent) {
            _editSong(widget.songListProvider.currentIndex);
            return true;
          },
        ),
        DeleteAction: CallbackAction<DeleteAction>(
          onInvoke: (Intent intent) {
            _cutSong(widget.songListProvider.currentIndex);
            return true;
          },
        ),
        CreateAction: CallbackAction<CreateAction>(
          onInvoke: (Intent intent) {
            _createSong();
            return true;
          },
        ),
        PasteAction: CallbackAction<PasteAction>(
          onInvoke: (Intent intent) {
            _pasteSong();
            return true;
          },
        ),
      },
      child: Shortcuts(
        shortcuts: const {
          SingleActivator(LogicalKeyboardKey.escape): PopAction(),
          SingleActivator(LogicalKeyboardKey.arrowLeft): LeftKeyAction(),
          SingleActivator(LogicalKeyboardKey.arrowRight): RightKeyAction(),
          // SingleActivator(LogicalKeyboardKey.arrowUp): LeftKeyAction(),
          // SingleActivator(LogicalKeyboardKey.arrowDown): RightKeyAction(),
          CharacterActivator("h"): LeftKeyAction(),
          CharacterActivator("l"): RightKeyAction(),
          CharacterActivator("j"): LeftKeyAction(),
          CharacterActivator("k"): RightKeyAction(),
          CharacterActivator("e"): EditAction(),
          CharacterActivator("x"): DeleteAction(),
          CharacterActivator("i"): CreateAction(),
          CharacterActivator("v"): PasteAction(),
        },
        child: Focus(
          focusNode: focusNode,
          autofocus: true,
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Song List'),
            ),
            body: ListView.builder(
              itemCount: widget.songListProvider.songs.length,
              itemBuilder: (context, index) {
                return ListTile(
                  onFocusChange: (v) {
                    if (v) widget.songListProvider.currentIndex = index;
                  },
                  title: Text(widget.songListProvider.songs[index].title),
                  // subtitle: Text(songListProvider.songs[index].lyrics),
                  // trailing: IconButton.outlined(
                  //   onPressed: () {
                  //     songListProvider.removeSong(index);
                  //   },
                  //   icon: const Icon(Icons.delete),
                  // ),
                  leading: Text('${widget.songListProvider.songs[index].id}'),

                  onLongPress: () {
                    _editSong(index);
                  },
                  onTap: () {
                    widget.songListProvider.currentIndex = index;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Slideshow(
                          widget.songListProvider,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                _createSong();
              },
              child: const Icon(Icons.add),
            ),
          ),
        ),
      ),
    );
  }
}
