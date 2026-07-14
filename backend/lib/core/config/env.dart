import 'package:dotenv/dotenv.dart';

/// Centralized environment configuration.
///
/// Loads variables from the `.env` file (at the project root) and merges
/// them with `Platform.environment`. Every secret / URL that the backend
/// needs should be accessed through this class so there's a single place
/// to validate and document required keys.
///
/// ### Usage
/// ```dart
/// // At server startup (call once):
/// Env.load();
///
/// // Anywhere else:
/// final url = Env.supabaseUrl;
/// ```
class Env {
  Env._(); // Prevent instantiation.

  static DotEnv? _dotEnv;
  static bool _loaded = false;

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  /// Load and validate the `.env` file. Call this once at server startup.
  ///
  /// Throws a [StateError] if any required variable is missing.
  static void load({String filename = '.env'}) {
    if (_loaded) return;

    _dotEnv = DotEnv(includePlatformEnvironment: true)..load([filename]);
    _loaded = true;

    // Validate required keys immediately so we fail fast.
    _requireAll([
      'SUPABASE_URL',
      'SUPABASE_ANON_KEY',
      'SUPABASE_SERVICE_ROLE_KEY',
    ]);
  }

  // ---------------------------------------------------------------------------
  // Accessor helpers
  // ---------------------------------------------------------------------------

  /// Get a required env variable. Throws [StateError] if missing.
  static String get(String key) {
    _ensureLoaded();
    final value = _dotEnv![key];
    if (value == null || value.isEmpty) {
      throw StateError('Missing required environment variable: $key');
    }
    return value;
  }

  /// Get an optional env variable. Returns [fallback] if missing.
  static String getOr(String key, String fallback) {
    _ensureLoaded();
    final value = _dotEnv![key];
    return (value != null && value.isNotEmpty) ? value : fallback;
  }

  /// Get an optional env variable. Returns `null` if missing.
  static String? getOrNull(String key) {
    _ensureLoaded();
    return _dotEnv![key];
  }

  // ---------------------------------------------------------------------------
  // Convenience shortcuts — add more as needed
  // ---------------------------------------------------------------------------

  static String get supabaseUrl => get('SUPABASE_URL');
  static String get supabaseAnonKey => get('SUPABASE_ANON_KEY');
  static String get supabaseServiceRoleKey => get('SUPABASE_SERVICE_ROLE_KEY');
  static String? get databaseUrl => getOrNull('DATABASE_URL');
  static int get port => int.parse(getOr('PORT', '8080'));

  // ---------------------------------------------------------------------------
  // Internal
  // ---------------------------------------------------------------------------

  static void _ensureLoaded() {
    if (!_loaded) {
      throw StateError('Env.load() must be called before accessing variables.');
    }
  }

  static void _requireAll(List<String> keys) {
    final missing = keys.where((k) {
      final v = _dotEnv![k];
      return v == null || v.isEmpty;
    }).toList();

    if (missing.isNotEmpty) {
      throw StateError(
        'Missing required environment variable(s): ${missing.join(', ')}.\n'
        'Check your .env file.',
      );
    }
  }
}
