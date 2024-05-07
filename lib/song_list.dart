import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stagepromptz/keyboard_shortcut.dart';
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

  void _saveFile() async {
    widget.songListProvider.downloadSongs();
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

  void _cutSong() {
    widget.songListProvider.cutSong().then((value) {
      _refreshSongs();
    });
  }

  void _pasteSong() {
    widget.songListProvider.pasteSong().then((value) {
      _refreshSongs();
    });
  }

  void _refreshSongs() {
    widget.songListProvider.loadSongs();
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardShortcut(
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
            _cutSong();
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
        RefreshAction: CallbackAction<RefreshAction>(
          onInvoke: (Intent intent) {
            _refreshSongs();
            return true;
          },
        ),
      },
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
        CharacterActivator("r"): RefreshAction(),
      },
      child: Focus(
        focusNode: focusNode,
        autofocus: true,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Song List'),
            actions: <Widget>[
              IconButton(
                icon: const Icon(Icons.download),
                onPressed: () {
                  _saveFile();
                },
              ),
            ],
          ),
          body: listSongs(),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              _createSong();
            },
            child: const Icon(Icons.add),
          ),
        ),
      ),
    );
  }

  // StreamBuilder<List<Song>> streamSongs() {
  //   return StreamBuilder<List<Song>>(
  //     stream: widget.songListProvider.songService.listenToSongs(),
  //     builder: (context, snapshot) {
  //       if (snapshot.hasData) {
  //         return ListView.builder(
  //           itemCount: snapshot.data!.length,
  //           itemBuilder: (context, index) {
  //             return ListTile(
  //               title: Text(snapshot.data![index].title),
  //               leading: Text('${snapshot.data![index].position}'),
  //               onLongPress: () {
  //                 _editSong(index);
  //               },
  //               onTap: () {
  //                 widget.songListProvider.currentIndex = index;
  //                 Navigator.push(
  //                   context,
  //                   MaterialPageRoute(
  //                     builder: (context) => Slideshow(
  //                       widget.songListProvider,
  //                     ),
  //                   ),
  //                 );
  //               },
  //             );
  //           },
  //         );
  //       }
  //       return const CircularProgressIndicator();
  //     },
  //   );
  // }

  ListView listSongs() {
    return ListView.builder(
      itemCount: widget.songListProvider.songs.length,
      itemBuilder: (context, index) {
        print(index);
        return ListTile(
          key: Key(widget.songListProvider.songs[index].id.toString()),
          onFocusChange: (v) {
            if (v) widget.songListProvider.currentIndex = index;
          },
          title: Text(
            widget.songListProvider.songs[index].title,
          ),
          leading: Text('${widget.songListProvider.songs[index].position}'),
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
    );
  }
}
