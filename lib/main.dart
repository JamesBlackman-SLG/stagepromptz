import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'song_list_provider.dart';
import 'song_list.dart';

void main() {
  runApp(
    ChangeNotifierProvider<SongListProvider>(
      create: (context) => SongListProvider(),
      child: const StagePromptz(),
    ),
  );
}

class StagePromptz extends StatelessWidget {
  const StagePromptz({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StagePromptz',
      home: SongList(
        songListProvider: Provider.of<SongListProvider>(context),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
