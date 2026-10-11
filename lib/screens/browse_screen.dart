import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/anime_title.dart';
import '../core/nook_data.dart';
import '../state/nook_state.dart';
import '../theme/app_theme.dart';
import '../widgets/brand.dart';
import 'picker_screen.dart' show GenreSelector;

/// Browse the catalogue for the selected genre, grouped by year.
class BrowseScreen extends StatelessWidget {
  const BrowseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final NookState state = context.watch<NookState>();
    final List<AnimeTitle> pool = List<AnimeTitle>.of(state.pool)
      ..sort((a, b) => b.year.compareTo(a.year));

    return Column(
      children: <Widget>[
        GenreSelector(
          selected: state.genreId,
          onSelect: state.selectGenre,
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 6, 20, 6),
          child: Row(
            children: <Widget>[
              Text(
                '${pool.length} ${pool.length == 1 ? 'title' : 'titles'}',
                style: const TextStyle(
                  color: AppTheme.muted,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              const Pill(label: 'Bundled offline'),
            ],
          ),
        ),
        Expanded(
          child: pool.isEmpty
              ? const Center(child: Text('No titles in this genre.'))
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                  itemCount: pool.length,
                  separatorBuilder: (_, _) =>
                      const Divider(height: 1, color: AppTheme.divider),
                  itemBuilder: (BuildContext context, int i) =>
                      _TitleRow(title: pool[i]),
                ),
        ),
      ],
    );
  }
}

class _TitleRow extends StatelessWidget {
  const _TitleRow({required this.title});

  final AnimeTitle title;

  Color _tone() {
    const List<Color> tones = <Color>[
      AppTheme.accent,
      AppTheme.accent2,
      AppTheme.warm,
      Color(0xFFB07CFF),
    ];
    int h = 0;
    for (final int c in title.title.codeUnits) {
      h = (h * 31 + c) & 0x7fffffff;
    }
    return tones[h % tones.length];
  }

  @override
  Widget build(BuildContext context) {
    final Color tone = _tone();
    final String genreLabels = title.genres
        .map((String id) {
          for (final Genre g in NookData.genres) {
            if (g.id == id) return g.name;
          }
          return id;
        })
        .join(' · ');

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: tone.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: tone.withValues(alpha: 0.4)),
            ),
            child: const Icon(Icons.local_movies_rounded,
                size: 22, color: Colors.white),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title.title,
                  style: const TextStyle(
                      fontWeight: FontWeight.w800, fontSize: 15),
                ),
                const SizedBox(height: 3),
                Text(
                  '${title.year} · ${title.studio}',
                  style: const TextStyle(
                      color: AppTheme.muted, fontSize: 12.5),
                ),
                const SizedBox(height: 3),
                Text(
                  genreLabels,
                  style: TextStyle(
                      color: tone, fontSize: 11.5, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
