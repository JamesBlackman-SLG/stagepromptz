import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'action_intents.dart';
import 'song_list_provider.dart';

class Slideshow extends StatefulWidget {
  final SongListProvider _songListProvider;

  const Slideshow(this._songListProvider, {super.key});

  @override
  SlideshowState createState() => SlideshowState();
}

class SlideshowState extends State<Slideshow> {
  late int _currentIndex;
  @override
  initState() {
    _currentIndex = widget._songListProvider.currentIndex;

    super.initState();
  }

  void _previousSong() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
      });
    }
  }

  void _nextSong() {
    if (_currentIndex < widget._songListProvider.songs.length - 1) {
      setState(() {
        _currentIndex++;
      });
    }
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
            _previousSong();
            return true;
          },
        ),
        RightKeyAction: CallbackAction<RightKeyAction>(
          onInvoke: (Intent intent) {
            _nextSong();
            return true;
          },
        ),
      },
      child: Shortcuts(
        shortcuts: const {
          SingleActivator(LogicalKeyboardKey.escape): PopAction(),
          SingleActivator(LogicalKeyboardKey.arrowLeft): LeftKeyAction(),
          SingleActivator(LogicalKeyboardKey.arrowRight): RightKeyAction(),
          SingleActivator(LogicalKeyboardKey.arrowUp): LeftKeyAction(),
          SingleActivator(LogicalKeyboardKey.arrowDown): RightKeyAction(),
          CharacterActivator("h"): LeftKeyAction(),
          CharacterActivator("l"): RightKeyAction(),
          CharacterActivator("k"): LeftKeyAction(),
          CharacterActivator("j"): RightKeyAction(),
        },
        child: Focus(
          autofocus: true,
          child: Scaffold(
            body: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: widget._songListProvider.songs.length,
                    itemBuilder: (context, index) {
                      if (index == _currentIndex) {
                        return ListTile(
                          title:
                              Text(widget._songListProvider.songs[index].title),
                          subtitle: Text(
                              widget._songListProvider.songs[index].lyrics),
                        );
                      }
                      return Container();
                    },
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                      onPressed: _previousSong,
                      child: const Icon(Icons.arrow_left),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Icon(Icons.list),
                    ),
                    ElevatedButton(
                      onPressed: _nextSong,
                      child: const Icon(Icons.arrow_right),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
