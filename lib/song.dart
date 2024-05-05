import 'package:isar/isar.dart';

part 'song.g.dart';

@Collection()
class Song {
  Id id = Isar.autoIncrement;
  String title;
  String lyrics;
  @Index(unique: true)
  int position;
  Song({required this.title, required this.lyrics, required this.position});
}
