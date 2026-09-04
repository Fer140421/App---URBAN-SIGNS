class AppConfig {
  const AppConfig({
    required this.demoMode,
    required this.supabaseUrl,
    required this.supabasePublishableKey,
  });

  final bool demoMode;
  final String supabaseUrl;
  final String supabasePublishableKey;

  factory AppConfig.fromEnvironment() {
    const demoRaw = String.fromEnvironment('DEMO_MODE', defaultValue: 'true');
    const url = String.fromEnvironment('SUPABASE_URL');
    const key = String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY');

    final demoMode = demoRaw.toLowerCase() != 'false';
    if (!demoMode && (url.isEmpty || key.isEmpty)) {
      throw StateError(
        'Modo LIVE sin configuración. Usa --dart-define-from-file=config/live.json',
      );
    }

    return AppConfig(
      demoMode: demoMode,
      supabaseUrl: url,
      supabasePublishableKey: key,
    );
  }
}
