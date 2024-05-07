import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:stagepromptz/keyboard_shortcut.dart';
import 'action_intents.dart';
import 'settings_provider.dart';
import 'song_list_provider.dart';

class Slideshow extends StatefulWidget {
  final SongListProvider _songListProvider;

  const Slideshow(this._songListProvider, {super.key});

  @override
  SlideshowState createState() => SlideshowState();
}

class SlideshowState extends State<Slideshow> {
  late int _currentIndex;
  final ScrollController _scrollController = ScrollController();
  Timer? _timer;
  final int durationMinutes = 3;
  final int durationSeconds = 0;
  @override
  initState() {
    _currentIndex = widget._songListProvider.currentIndex;

    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final totalDurationInSeconds = durationMinutes * 60 + durationSeconds;
      final maxScrollExtent = _scrollController.position.maxScrollExtent;
      final double scrollIncrement =
          maxScrollExtent / (totalDurationInSeconds / 0.002);

      _timer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
        if (_scrollController.position.pixels >= maxScrollExtent) {
          timer.cancel();
        } else {
          _scrollController
              .jumpTo(_scrollController.position.pixels + scrollIncrement);
        }
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _previousSong() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
        _scrollController.jumpTo(0);
      });
    }
  }

  void _nextSong() {
    if (_currentIndex < widget._songListProvider.songs.length - 1) {
      setState(() {
        _currentIndex++;
        _scrollController.jumpTo(0);
      });
    }
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
      },
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
        CharacterActivator('f'): IncrementTextScaleFactorAction(),
        CharacterActivator('d'): DecrementTextScaleFactorAction(),
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
          body: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  shrinkWrap: true,
                  itemCount: widget._songListProvider.songs.length,
                  itemBuilder: (context, index) {
                    if (index == _currentIndex) {
                      return ListTile(
                        title:
                            Text(widget._songListProvider.songs[index].title),
                        subtitle:
                            Text(widget._songListProvider.songs[index].lyrics),
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
    );
  }
}
