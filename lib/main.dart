import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/root_shell.dart';
import 'state/nook_state.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const AnimeNookApp());
}

/// AnimeNook — a fully offline, ad-free random anime picker.
class AnimeNookApp extends StatelessWidget {
  const AnimeNookApp({super.key, this.state});

  final NookState? state;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<NookState>(
      create: (_) => state ?? NookState(),
      child: MaterialApp(
        title: 'AnimeNook',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark(),
        home: const RootShell(),
      ),
    );
  }
}
