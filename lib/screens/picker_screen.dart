import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/anime_title.dart';
import '../core/nook_data.dart';
import '../state/nook_state.dart';
import '../theme/app_theme.dart';
import '../widgets/brand.dart';

/// Home: pick a genre, roll a random title, and spin again.
class PickerScreen extends StatelessWidget {
  const PickerScreen({super.key, required this.onBrowse});

  final VoidCallback onBrowse;

  @override
  Widget build(BuildContext context) {
    final NookState state = context.watch<NookState>();

    return Column(
      children: <Widget>[
        GenreSelector(
          selected: state.genreId,
          onSelect: state.selectGenre,
        ),
        Expanded(
          child: state.hasPick
              ? _ResultView(state: state, onBrowse: onBrowse)
              : _IdleView(state: state),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: state.pick,
              icon: const Icon(Icons.casino_rounded),
              label: Text(state.hasPick ? 'Spin again' : 'Pick for me'),
            ),
          ),
        ),
      ],
    );
  }
}

class _IdleView extends StatelessWidget {
  const _IdleView({required this.state});

  final NookState state;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                gradient: AppTheme.brandGradient,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.local_movies_rounded,
                  size: 46, color: Colors.white),
            ),
            const SizedBox(height: 24),
            const Text(
              'What should I watch?',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            Text(
              'Tap "Pick for me" and AnimeNook will choose from '
              '${state.countForGenre} ${state.genreName == 'All' ? 'titles' : '${state.genreName} titles'} — '
              'all offline.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppTheme.muted, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultView extends StatelessWidget {
  const _ResultView({required this.state, required this.onBrowse});

  final NookState state;
  final VoidCallback onBrowse;

  @override
  Widget build(BuildContext context) {
    final AnimeTitle t = state.current!;
    final List<Genre> matched = NookData.genres
        .where((Genre g) => g.id != NookData.allGenres && t.genres.contains(g.id))
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
      child: Column(
        children: <Widget>[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[
                  AppTheme.accent.withValues(alpha: 0.26),
                  AppTheme.accent2.withValues(alpha: 0.18),
                ],
              ),
              borderRadius: BorderRadius.circular(26),
              border: Border.all(color: AppTheme.accent.withValues(alpha: 0.4)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Pill(label: 'Your pick', color: AppTheme.warm, icon: Icons.star_rounded),
                const SizedBox(height: 16),
                Text(
                  t.title,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: <Widget>[
                    const Icon(Icons.calendar_today_rounded,
                        size: 15, color: AppTheme.muted),
                    const SizedBox(width: 6),
                    Text('${t.year}',
                        style: const TextStyle(color: AppTheme.muted)),
                    const SizedBox(width: 16),
                    const Icon(Icons.movie_outlined,
                        size: 15, color: AppTheme.muted),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        t.studio,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: AppTheme.muted),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: matched
                      .map((Genre g) => Pill(label: '${g.emoji} ${g.name}',
                          color: AppTheme.accent2))
                      .toList(),
                ),
                const SizedBox(height: 18),
                Text(
                  t.blurb,
                  style: const TextStyle(fontSize: 15, height: 1.55),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onBrowse,
              icon: const Icon(Icons.grid_view_rounded, size: 18),
              label: const Text('Browse all titles'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
                side: const BorderSide(color: AppTheme.divider),
                foregroundColor: AppTheme.text,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Horizontal, wrapping genre chooser shared by picker + browse.
class GenreSelector extends StatelessWidget {
  const GenreSelector({
    super.key,
    required this.selected,
    required this.onSelect,
  });

  final String selected;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        itemCount: NookData.genres.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (BuildContext context, int i) {
          final Genre g = NookData.genres[i];
          final bool on = g.id == selected;
          return ChoiceChip(
            selected: on,
            onSelected: (_) => onSelect(g.id),
            label: Text('${g.emoji} ${g.name}'),
            showCheckmark: false,
            labelStyle: TextStyle(
              fontWeight: FontWeight.w700,
              color: on ? Colors.white : AppTheme.muted,
            ),
            backgroundColor: AppTheme.surface,
            selectedColor: AppTheme.accent,
            side: BorderSide(
              color: on ? AppTheme.accent : AppTheme.divider,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          );
        },
      ),
    );
  }
}
