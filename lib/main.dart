import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'song_list_provider.dart';
import 'song_list.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        textTheme: GoogleFonts.robotoMonoTextTheme().copyWith(
          bodyLarge: GoogleFonts.robotoMono().copyWith(
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
