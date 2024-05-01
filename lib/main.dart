import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'song_list_provider.dart';
import 'song_list.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

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
