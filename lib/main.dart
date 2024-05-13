import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'settings_provider.dart';
import 'song_list_provider.dart';
import 'song_list.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<SongListProvider>(
          create: (context) => SongListProvider(),
        ),
        ChangeNotifierProvider<SettingsProvider>(
          create: (context) => SettingsProvider(),
        ),
      ],
      child: const StagePromptz(),
    ),
  );
}

class StagePromptz extends StatelessWidget {
  const StagePromptz({super.key});

  @override
  Widget build(BuildContext context) {
    double textScaleFactor =
        Provider.of<SettingsProvider>(context).settings.textScaleFactor;
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: TextScaler.linear(textScaleFactor),
      ),
      child: MaterialApp(
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
      ),
    );
  }
}
