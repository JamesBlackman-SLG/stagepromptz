import 'package:isar/isar.dart';

part 'song.g.dart';

@Collection()
class Song {
  Id id = Isar.autoIncrement;
  final String title;
  final String lyrics;
  Song({required this.title, required this.lyrics});
}
