/// App-wide constants: brand identity, links and legal pointers.
///
/// Pure Dart (no Flutter imports) so it can be unit tested and reused.
class AppInfo {
  const AppInfo._();

  static const String name = 'AnimeNook';
  static const String tagline = 'What should I watch?';
  static const String company = 'codex-zubair';
  static const String version = '1.0.0';
  static const String packageName = 'com.veranime.watchanime';

  /// Hosted privacy policy (central GitHub Pages site for all factory apps).
  static const String privacyPolicyUrl =
      'https://codex-zubair.github.io/all_privacy_policy/animenook/';

  /// Public source repository.
  static const String githubUrl =
      'https://github.com/codex-zubair/AnimeNook';

  static const String companyUrl = 'https://github.com/codex-zubair';
  static const String contactEmail = 'iam.nmzar@gmail.com';

  /// One-line privacy promise shown in the UI.
  static const String privacyPromise =
      'No internet, no ads, no tracking. AnimeNook has nothing to collect and '
      'never connects to the network.';
}
