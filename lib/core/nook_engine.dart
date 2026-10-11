import 'dart:math';

import 'anime_title.dart';
import 'nook_data.dart';

/// Pure-Dart picker engine: filters the catalogue by genre and chooses a title
/// at random. No Flutter imports, so it is fully unit-testable.
class NookEngine {
  NookEngine({List<AnimeTitle>? pool, Random? random})
      : _pool = List<AnimeTitle>.unmodifiable(pool ?? NookData.titles),
        _random = random ?? Random();

  final List<AnimeTitle> _pool;
  final Random _random;

  List<AnimeTitle> get all => _pool;

  /// Titles matching [genreId] (use [NookData.allGenres] for everything).
  List<AnimeTitle> poolFor(String genreId) => genreId == NookData.allGenres
      ? List<AnimeTitle>.of(_pool)
      : _pool
          .where((AnimeTitle t) => t.genres.contains(genreId))
          .toList(growable: false);

  int countFor(String genreId) => poolFor(genreId).length;

  /// Picks a random title from [genreId]. Returns null if the pool is empty.
  AnimeTitle? pick(String genreId) {
    final List<AnimeTitle> pool = poolFor(genreId);
    if (pool.isEmpty) return null;
    return pool[_random.nextInt(pool.length)];
  }

  /// Picks a random title that is different from [previous] when possible.
  AnimeTitle? pickDifferent(String genreId, AnimeTitle? previous) {
    final List<AnimeTitle> pool = poolFor(genreId);
    if (pool.isEmpty) return null;
    if (previous == null || pool.length == 1) {
      return pool[_random.nextInt(pool.length)];
    }
    final List<AnimeTitle> others =
        pool.where((AnimeTitle t) => t.id != previous.id).toList();
    if (others.isEmpty) return pool[_random.nextInt(pool.length)];
    return others[_random.nextInt(others.length)];
  }

  /// A stable list of genres, plus a computed count per genre.
  Map<String, int> get counts {
    final Map<String, int> out = <String, int>{};
    for (final Genre g in NookData.genres) {
      out[g.id] = countFor(g.id);
    }
    return out;
  }
}
