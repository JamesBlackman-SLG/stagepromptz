import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:stagepromptz/keyboard_shortcut.dart';
import 'action_intents.dart';
import 'config.dart';
import 'settings.dart';
import 'settings_provider.dart';
import 'slideshow.dart';
import 'song.dart';
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

  void _copySong() {
    widget.songListProvider.copySong();
  }

  void _cutSong() {
    widget.songListProvider.cutSong().then((value) {
      widget.songListProvider.reorderSongs(widget.songListProvider.songs);
      _refreshSongs();
    });
  }

  void _pasteSong() {
    widget.songListProvider.pasteSong().then((value) {
      widget.songListProvider.reorderSongs(widget.songListProvider.songs);
      _refreshSongs();
    });
  }

  void _refreshSongs() {
    widget.songListProvider.loadSongs();
  }

  @override
  Widget build(BuildContext context) {
    Settings settings =
        Provider.of<SettingsProvider>(context, listen: true).settings;
    return KeyboardShortcut(
      actions: {
        PopAction: CallbackAction<PopAction>(
          onInvoke: (Intent intent) {
            return Navigator.maybePop(context);
          },
        ),
        LeftKeyAction: CallbackAction<LeftKeyAction>(
          onInvoke: (Intent intent) {
            focusNode.previousFocus();
            return true;
          },
        ),
        RightKeyAction: CallbackAction<RightKeyAction>(
          onInvoke: (Intent intent) {
            focusNode.nextFocus();
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
        CopyAction: CallbackAction<CopyAction>(
          onInvoke: (Intent intent) {
            _copySong();
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
            widget.songListProvider.reorderSongs(widget.songListProvider.songs);
            return true;
          },
        ),
        IncrementTextScaleFactorAction:
            CallbackAction<IncrementTextScaleFactorAction>(
          onInvoke: (action) {
            Provider.of<SettingsProvider>(context, listen: false)
                .increaseTextScaleFactor();
            return null;
          },
        ),
        DecrementTextScaleFactorAction:
            CallbackAction<DecrementTextScaleFactorAction>(
          onInvoke: (action) {
            Provider.of<SettingsProvider>(context, listen: false)
                .decreaseTextScaleFactor();
            return null;
          },
        ),
        SelectSongAction: CallbackAction<SelectSongAction>(
          onInvoke: (Intent intent) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Slideshow(
                  widget.songListProvider,
                ),
              ),
            );
            return true;
          },
        ),
      },
      shortcuts: const {
        SingleActivator(LogicalKeyboardKey.escape): PopAction(),
        SingleActivator(LogicalKeyboardKey.arrowLeft): LeftKeyAction(),
        SingleActivator(LogicalKeyboardKey.arrowRight): RightKeyAction(),
        SingleActivator(LogicalKeyboardKey.arrowUp): LeftKeyAction(),
        SingleActivator(LogicalKeyboardKey.arrowDown): SelectSongAction(),
        CharacterActivator("h"): LeftKeyAction(),
        CharacterActivator("l"): RightKeyAction(),
        CharacterActivator("k"): LeftKeyAction(),
        CharacterActivator("j"): RightKeyAction(),
        CharacterActivator("e"): EditAction(),
        CharacterActivator("c"): CopyAction(),
        CharacterActivator("x"): DeleteAction(),
        CharacterActivator("i"): CreateAction(),
        CharacterActivator("v"): PasteAction(),
        CharacterActivator("r"): RefreshAction(),
        CharacterActivator('f'): IncrementTextScaleFactorAction(),
        CharacterActivator('d'): DecrementTextScaleFactorAction(),
      },
      child: Focus(
        focusNode: focusNode,
        autofocus: true,
        child: Scaffold(
          appBar: AppBar(
            title: settings.fileName == null
                ? const Text('stagepromptz')
                : Text(settings.fileName!),
            actions: <Widget>[
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return Dialog(
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width * 0.8,
                          height: MediaQuery.of(context).size.height * 0.8,
                          child: const Config(),
                        ),
                      );
                    },
                  );
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

  Widget listSongs() {
    return RefreshIndicator(
      onRefresh: () async {
        List<Song> songs = widget.songListProvider.songs;
        widget.songListProvider.reorderSongs(songs);
        _refreshSongs();
      },
      child: ReorderableListView.builder(
        onReorder: (oldIndex, newIndex) {
          if (oldIndex < newIndex) {
            newIndex -= 1;
          }
          List<Song> songs = widget.songListProvider.songs;
          final Song song = songs.removeAt(oldIndex);
          songs.insert(newIndex, song);
          widget.songListProvider.reorderSongs(songs);
          _refreshSongs();
        },
        buildDefaultDragHandles: true,
        itemCount: widget.songListProvider.songs.length,
        itemBuilder: (context, index) {
          return ListTile(
            key: Key(widget.songListProvider.songs[index].id.toString()),
            onFocusChange: (v) {
              if (v) widget.songListProvider.currentIndex = index;
            },
            title: Text(
              widget.songListProvider.songs[index].title,
            ),
            leading: Text('${widget.songListProvider.songs[index].position}'),
            trailing: ReorderableDragStartListener(
              index: index,
              child: const Icon(Icons.drag_handle, color: Colors.white),
            ),
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
    );
  }
}
