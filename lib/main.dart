import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:stagepromptz/song.dart';
import 'song_list_provider.dart';
import 'song_list.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final dir = await getApplicationDocumentsDirectory();
  final Isar isar = await Isar.open(
    [SongSchema],
    directory: dir.path,
  );

  runApp(
    ChangeNotifierProvider<SongListProvider>(
      create: (context) => SongListProvider(isar),
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
