import 'package:hive/hive.dart';
part 'song_model.g.dart';

@HiveType(typeId: 0)
class Song {
  @HiveField(0)
  final int id;
  @HiveField(1)
  final String title;
  @HiveField(2)
  final String lyrics;

  Song({
    required this.id,
    required this.title,
    required this.lyrics,
  });
}
