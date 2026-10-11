import 'package:flutter/foundation.dart';

/// A genre used to filter the picker.
@immutable
class Genre {
  const Genre({required this.id, required this.name, required this.emoji});

  final String id;
  final String name;
  final String emoji;
}

/// A single anime entry in the offline catalogue.
///
/// Content is factual (title, year, studio, genre) plus a short original blurb
/// written by the developer. No copyrighted text or media is included.
@immutable
class AnimeTitle {
  const AnimeTitle({
    required this.id,
    required this.title,
    required this.year,
    required this.studio,
    required this.genres,
    required this.blurb,
  });

  final String id;
  final String title;
  final int year;
  final String studio;

  /// Genre ids; an entry can belong to more than one.
  final List<String> genres;

  /// Short original, factual description.
  final String blurb;

  @override
  bool operator ==(Object other) => other is AnimeTitle && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
