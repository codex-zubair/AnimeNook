import 'package:flutter/foundation.dart';

import '../core/anime_title.dart';
import '../core/nook_data.dart';
import '../core/nook_engine.dart';

/// App-wide state for AnimeNook. Holds only in-memory session state — nothing
/// is written to disk, so the app stores no data at all.
class NookState extends ChangeNotifier {
  NookState({NookEngine? engine}) : _engine = engine ?? NookEngine();

  final NookEngine _engine;

  String _genreId = NookData.allGenres;
  AnimeTitle? _current;
  bool _revealed = false;

  List<Genre> get genres => NookData.genres;
  String get genreId => _genreId;
  AnimeTitle? get current => _current;
  bool get revealed => _revealed;
  bool get hasPick => _current != null;

  int get countForGenre => _engine.countFor(_genreId);
  Map<String, int> get counts => _engine.counts;

  String get genreName {
    for (final Genre g in NookData.genres) {
      if (g.id == _genreId) return g.name;
    }
    return 'All';
  }

  /// Titles in the current genre, for the browse list.
  List<AnimeTitle> get pool => _engine.poolFor(_genreId);
  List<AnimeTitle> get allTitles => _engine.all;

  void selectGenre(String genreId) {
    if (_genreId == genreId) return;
    _genreId = genreId;
    _revealed = false;
    notifyListeners();
  }

  /// Rolls a new random pick, avoiding an immediate repeat when possible.
  void pick() {
    _current = _engine.pickDifferent(_genreId, _current);
    _revealed = true;
    notifyListeners();
  }

  void reset() {
    _current = null;
    _revealed = false;
    notifyListeners();
  }
}
