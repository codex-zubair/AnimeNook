import 'package:flutter_test/flutter_test.dart';
import 'package:watchanime/core/nook_data.dart';
import 'package:watchanime/main.dart';
import 'package:watchanime/state/nook_state.dart';

void main() {
  testWidgets('AnimeNook shows the offline picker home', (WidgetTester tester) async {
    await tester.pumpWidget(const AnimeNookApp());
    await tester.pumpAndSettle();

    expect(find.text('AnimeNook'), findsWidgets);
    expect(find.text('Offline'), findsOneWidget);
    expect(find.text('Pick for me'), findsOneWidget);
    expect(find.text('What should I watch?'), findsWidgets);
    expect(find.text('Pick'), findsOneWidget);
    expect(find.text('Browse'), findsOneWidget);
    expect(find.text('About'), findsOneWidget);
  });

  testWidgets('picking a title reveals a result card', (WidgetTester tester) async {
    await tester.pumpWidget(const AnimeNookApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Pick for me'));
    await tester.pumpAndSettle();

    expect(find.text('Your pick'), findsOneWidget);
    expect(find.text('Spin again'), findsOneWidget);
    expect(find.text('Browse all titles'), findsOneWidget);
  });

  testWidgets('Browse tab lists titles', (WidgetTester tester) async {
    await tester.pumpWidget(const AnimeNookApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Browse'));
    await tester.pumpAndSettle();

    expect(find.text('Bundled offline'), findsOneWidget);
    expect(find.textContaining('titles'), findsWidgets);
  });

  testWidgets('About tab exposes the privacy policy button',
      (WidgetTester tester) async {
    await tester.pumpWidget(const AnimeNookApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('About'));
    await tester.pumpAndSettle();

    expect(find.text('Read Privacy Policy'), findsOneWidget);
    expect(find.text('Private by design'), findsOneWidget);
  });

  test('NookState.pick sets a current title and filters by genre', () {
    final NookState state = NookState();
    expect(state.hasPick, isFalse);
    state.selectGenre('sports');
    state.pick();
    expect(state.hasPick, isTrue);
    expect(state.current!.genres.contains('sports'), isTrue);
    state.reset();
    expect(state.hasPick, isFalse);
  });

  test('selecting all genres exposes the full catalogue', () {
    final NookState state = NookState();
    state.selectGenre(NookData.allGenres);
    expect(state.pool.length, NookData.titles.length);
  });
}
