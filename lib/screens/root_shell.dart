import 'package:flutter/material.dart';

import '../core/nook_data.dart';
import '../widgets/brand.dart';
import 'about_screen.dart';
import 'browse_screen.dart';
import 'picker_screen.dart';

/// Root shell with the two AnimeNook destinations.
class RootShell extends StatefulWidget {
  const RootShell({super.key});

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        title: BrandHeader(showSubtitle: _index == 0),
        actions: const <Widget>[
          SizedBox(width: 12),
          Center(child: OfflineChip()),
          SizedBox(width: 16),
        ],
      ),
      body: SafeArea(
        top: false,
        child: IndexedStack(
          index: _index,
          children: <Widget>[
            PickerScreen(onBrowse: () => setState(() => _index = 1)),
            const BrowseScreen(),
            AboutScreen(titleCount: NookData.titles.length),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (int i) => setState(() => _index = i),
        destinations: const <NavigationDestination>[
          NavigationDestination(
            icon: Icon(Icons.casino_outlined),
            selectedIcon: Icon(Icons.casino_rounded),
            label: 'Pick',
          ),
          NavigationDestination(
            icon: Icon(Icons.grid_view_outlined),
            selectedIcon: Icon(Icons.grid_view_rounded),
            label: 'Browse',
          ),
          NavigationDestination(
            icon: Icon(Icons.info_outline_rounded),
            selectedIcon: Icon(Icons.info_rounded),
            label: 'About',
          ),
        ],
      ),
    );
  }
}
