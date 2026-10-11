# AnimeNook

**Can't decide what to watch? AnimeNook picks an anime for you — fully offline.**

AnimeNook is a tiny, single-purpose Android app: it suggests a random anime
title from a curated offline catalogue. No backend, **no permissions, no
INTERNET permission**, no ads, no analytics, and it stores no data at all.

- Package: `com.veranime.watchanime`
- Privacy policy: https://codex-zubair.github.io/all_privacy_policy/animenook/
- Category: Entertainment
- Platform: Android (min SDK 24)

## Features

- **Random picker** — one tap suggests a title; "Spin again" for another.
- **Genre filter** — All, Action, Adventure, Comedy, Fantasy, Romance, Sci‑Fi,
  Slice of Life, Sports, Mystery.
- **Browse** — the full 32-title catalogue with year, studio and genres.
- **Zero permissions**, no network, no ads, no tracking, no stored data.

## Privacy

- No `INTERNET` permission (removed at build time).
- No Android permissions requested at all.
- The app writes nothing to disk — no history, no profile.

## Architecture

```
lib/
  core/       Pure Dart: models, catalogue, picker engine
  state/      NookState (ChangeNotifier + provider)
  screens/    root_shell, picker, browse, about
  widgets/    brand
  theme/      app_theme
```

`lib/core` has no Flutter imports, so the picker logic and catalogue are fully
unit-testable.

## Development

```bash
flutter pub get
flutter analyze          # 0 issues
flutter test             # 16 tests
flutter run

flutter build appbundle --release   # AAB for Play
flutter build apk --release         # APK for sideload
```

Generate branding and store graphics:

```bash
python3 tool/gen_icons.py
dart run flutter_launcher_icons
dart run flutter_native_splash:create
python3 tool/make_graphics.py
```

## License

MIT — see [LICENSE](LICENSE).
