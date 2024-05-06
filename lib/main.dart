import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'action_intents.dart';
import 'settings_provider.dart';
import 'song_list_provider.dart';
import 'song_list.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    // ChangeNotifierProvider<SongListProvider>(
    //   create: (context) => SongListProvider(),
    //   child: const StagePromptz(),
    // ),
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
    return Actions(
      actions: {
        IncrementTextScaleFactorAction:
            CallbackAction<IncrementTextScaleFactorAction>(
          onInvoke: (action) {
            Provider.of<SettingsProvider>(context, listen: false)
                .increaseTextScaleFactor();
          },
        ),
        DecrementTextScaleFactorAction:
            CallbackAction<DecrementTextScaleFactorAction>(
          onInvoke: (action) {
            Provider.of<SettingsProvider>(context, listen: false)
                .decreaseTextScaleFactor();
          },
        ),
      },
      child: Shortcuts(
        shortcuts: const {
          CharacterActivator('f'): IncrementTextScaleFactorAction(),
          CharacterActivator('d'): DecrementTextScaleFactorAction(),
        },
        child: MediaQuery(
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
        ),
      ),
    );
  }
}
