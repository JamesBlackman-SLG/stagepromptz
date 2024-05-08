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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'lyrics': lyrics,
      'position': position,
    };
  }

  factory Song.fromJson(Map<String, dynamic> json) {
    return Song(
      title: json['title'],
      lyrics: json['lyrics'],
      position: json['position'],
    );
  }
}
