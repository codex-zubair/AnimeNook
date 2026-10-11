import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:watchanime/core/anime_title.dart';
import 'package:watchanime/core/nook_data.dart';
import 'package:watchanime/core/nook_engine.dart';

void main() {
  group('NookData integrity', () {
    test('catalogue is non-empty and every id is unique', () {
      expect(NookData.titles.length, greaterThanOrEqualTo(30));
      final Set<String> ids =
          NookData.titles.map((AnimeTitle t) => t.id).toSet();
      expect(ids.length, NookData.titles.length);
    });

    test('every genre except "all" has at least 2 titles', () {
      for (final Genre g in NookData.genres) {
        if (g.id == NookData.allGenres) continue;
        expect(
          NookData.byGenre(g.id).length,
          greaterThanOrEqualTo(2),
          reason: 'genre ${g.id} needs enough titles',
        );
      }
    });

    test('every title references only known genres', () {
      final Set<String> known =
          NookData.genres.map((Genre g) => g.id).toSet();
      for (final AnimeTitle t in NookData.titles) {
        expect(t.genres, isNotEmpty);
        for (final String g in t.genres) {
          expect(known.contains(g), isTrue, reason: '${t.id} -> $g');
        }
      }
    });

    test('titles have sensible years and non-empty blurbs', () {
      for (final AnimeTitle t in NookData.titles) {
        expect(t.year, inInclusiveRange(1960, 2030));
        expect(t.blurb.trim(), isNotEmpty);
        expect(t.title.trim(), isNotEmpty);
        expect(t.studio.trim(), isNotEmpty);
      }
    });
  });

  group('NookEngine', () {
    test('poolFor(all) returns everything', () {
      final NookEngine engine = NookEngine(random: Random(1));
      expect(engine.poolFor(NookData.allGenres).length, NookData.titles.length);
    });

    test('poolFor filters by genre', () {
      final NookEngine engine = NookEngine(random: Random(1));
      final List<AnimeTitle> sports = engine.poolFor('sports');
      expect(sports, isNotEmpty);
      expect(sports.every((AnimeTitle t) => t.genres.contains('sports')), isTrue);
    });

    test('pick returns a title from the genre pool', () {
      final NookEngine engine = NookEngine(random: Random(2));
      for (int i = 0; i < 20; i++) {
        final AnimeTitle? t = engine.pick('romance');
        expect(t, isNotNull);
        expect(t!.genres.contains('romance'), isTrue);
      }
    });

    test('pickDifferent avoids the previous title across the pool', () {
      final NookEngine engine = NookEngine(random: Random(3));
      final AnimeTitle? first = engine.pick(NookData.allGenres);
      expect(first, isNotNull);
      for (int i = 0; i < 50; i++) {
        final AnimeTitle next = engine.pickDifferent(NookData.allGenres, first)!;
        expect(next.id, isNot(first!.id));
      }
    });

    test('pickDifferent with a single-title pool still returns it', () {
      final NookEngine engine = NookEngine(
        pool: NookData.titles.take(1).toList(),
        random: Random(4),
      );
      final AnimeTitle only = NookData.titles.first;
      expect(engine.pickDifferent(NookData.allGenres, only)?.id, only.id);
    });

    test('counts cover every genre', () {
      final NookEngine engine = NookEngine(random: Random(5));
      final Map<String, int> counts = engine.counts;
      for (final Genre g in NookData.genres) {
        expect(counts[g.id], engine.countFor(g.id));
      }
      expect(counts[NookData.allGenres], NookData.titles.length);
    });
  });
}
