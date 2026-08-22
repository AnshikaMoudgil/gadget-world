import 'package:supabase/supabase.dart';

import '../config/env.dart';
import '../network/safe_error.dart';
import 'db_result.dart';

export 'db_result.dart';

/// A reusable, singleton Supabase client for the backend.
///
/// ### Quick start
/// ```dart
/// // 1. At server boot (call once):
/// Env.load();
/// SupabaseDb.init();
///
/// // 2. Anywhere you need Supabase:
/// final client = SupabaseDb.client;         // anon-key client (respects RLS)
/// final admin  = SupabaseDb.adminClient;    // service-role client (bypasses RLS)
///
/// // 3. Use the safe query helpers for graceful error handling:
/// final result = await SupabaseDb.query(() async {
///   return await client.from('user_addresses').select().eq('user_id', uid);
/// });
/// if (result.isError) { /* handle */ }
/// ```
///
/// ### Design
/// - **Singleton** — one Supabase instance per process. No redundant connections.
/// - **Two clients** — `client` (anon key, RLS-aware) for user-scoped queries,
///   `adminClient` (service role key, bypasses RLS) for admin / server-side ops.
/// - **`query` / `querySingle`** — wrapper methods that catch Supabase and
///   Postgrest exceptions, convert them into a typed [DbResult], and log the
///   error. No more bare try/catch everywhere.
class SupabaseDb {
  SupabaseDb._(); // Prevent instantiation.

  static SupabaseClient? _client;
  static SupabaseClient? _adminClient;

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  /// Initialize both Supabase clients. Call **once** after [Env.load()].
  ///
  /// Safe to call multiple times — subsequent calls are no-ops.
  static void init() {
    if (_client != null) return;

    _client = SupabaseClient(
      Env.supabaseUrl,
      Env.supabaseAnonKey,
    );

    _adminClient = SupabaseClient(
      Env.supabaseUrl,
      Env.supabaseServiceRoleKey,
    );
  }

  // ---------------------------------------------------------------------------
  // Clients
  // ---------------------------------------------------------------------------

  /// The **anon-key** client. Respects Row Level Security.
  ///
  /// Use this for all user-scoped queries where the JWT is set via
  /// `client.auth.setSession(...)`.
  static SupabaseClient get client {
    _ensureInitialized();
    return _client!;
  }

  /// The **service-role** client. Bypasses Row Level Security.
  ///
  /// Use this for admin operations, background jobs, or anywhere you need
  /// full table access regardless of the calling user.
  static SupabaseClient get adminClient {
    _ensureInitialized();
    return _adminClient!;
  }

  // ---------------------------------------------------------------------------
  // Safe query helpers
  // ---------------------------------------------------------------------------

  /// Execute a query that returns a **list** of rows.
  ///
  /// Wraps the call in a try/catch and returns a [DbResult].
  /// On failure, the error is logged and a user-safe message is returned.
  ///
  /// ```dart
  /// final result = await SupabaseDb.query<List<Map<String, dynamic>>>(() =>
  ///   client.from('user_addresses').select().eq('user_id', uid),
  /// );
  /// ```
  static Future<DbResult<T>> query<T>(Future<T> Function() operation) async {
    try {
      final data = await operation();
      return DbResult.success(data);
    } on PostgrestException catch (e) {
      return _handlePostgrestError(e);
    } on AuthException catch (e) {
      final errorId = SafeError.report('database.auth', e, statusCode: 401);
      return DbResult.error(
        'Authentication failed.',
        statusCode:
            e.statusCode != null ? int.tryParse(e.statusCode!) ?? 401 : 401,
        errorId: errorId,
      );
    } catch (e) {
      final errorId = SafeError.report('database.query', e);
      return DbResult.error(
        'An unexpected error occurred. Please try again later.',
        statusCode: 500,
        errorId: errorId,
      );
    }
  }

  /// Execute a query that returns a **single row** (or null).
  ///
  /// Convenience wrapper around [query] for `.maybeSingle()` style calls.
  ///
  /// ```dart
  /// final result = await SupabaseDb.querySingle<Map<String, dynamic>?>(() =>
  ///   client.from('user_addresses').select().eq('id', id).maybeSingle(),
  /// );
  /// ```
  static Future<DbResult<T?>> querySingle<T>(
    Future<T?> Function() operation,
  ) async {
    try {
      final data = await operation();
      if (data == null) {
        return DbResult.notFound();
      }
      return DbResult.success(data);
    } on PostgrestException catch (e) {
      return _handlePostgrestError(e);
    } on AuthException catch (e) {
      final errorId = SafeError.report('database.auth', e, statusCode: 401);
      return DbResult.error(
        'Authentication failed.',
        statusCode:
            e.statusCode != null ? int.tryParse(e.statusCode!) ?? 401 : 401,
        errorId: errorId,
      );
    } catch (e) {
      final errorId = SafeError.report('database.query_single', e);
      return DbResult.error(
        'An unexpected error occurred. Please try again later.',
        statusCode: 500,
        errorId: errorId,
      );
    }
  }

  /// Execute a **void** operation (DELETE, RPC with no return, etc.).
  static Future<DbResult<void>> execute(
    Future<void> Function() operation,
  ) async {
    try {
      await operation();
      return DbResult.success(null);
    } on PostgrestException catch (e) {
      return _handlePostgrestError(e);
    } on AuthException catch (e) {
      final errorId = SafeError.report('database.auth', e, statusCode: 401);
      return DbResult.error(
        'Authentication failed.',
        statusCode:
            e.statusCode != null ? int.tryParse(e.statusCode!) ?? 401 : 401,
        errorId: errorId,
      );
    } catch (e) {
      final errorId = SafeError.report('database.execute', e);
      return DbResult.error(
        'An unexpected error occurred. Please try again later.',
        statusCode: 500,
        errorId: errorId,
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Internal
  // ---------------------------------------------------------------------------

  static void _ensureInitialized() {
    if (_client == null) {
      throw StateError(
        'SupabaseDb.init() must be called before accessing the client.\n'
        'Call it in your server.dart after Env.load().',
      );
    }
  }

  /// Map Postgrest error codes to meaningful HTTP statuses and messages.
  static DbResult<T> _handlePostgrestError<T>(PostgrestException e) {
    final code = e.code;
    final errorId = SafeError.report('database.postgrest.$code', e);

    // Common Postgres error codes → HTTP status mapping
    switch (code) {
      // 23505 = unique_violation
      case '23505':
        return DbResult.error(
          'A record with that value already exists.',
          statusCode: 409,
          errorId: errorId,
        );

      // 23503 = foreign_key_violation
      case '23503':
        return DbResult.error(
          'Referenced record does not exist.',
          statusCode: 400,
          errorId: errorId,
        );

      // 23514 = check_violation (e.g. postal_code format)
      case '23514':
        return DbResult.error(
          'Value does not meet the required constraints.',
          statusCode: 400,
          errorId: errorId,
        );

      // 42501 = insufficient_privilege (RLS denied)
      case '42501':
        return DbResult.error(
          'You do not have permission to perform this action.',
          statusCode: 403,
          errorId: errorId,
        );

      // PGRST116 = not exactly one row (used by .single())
      case 'PGRST116':
        return DbResult.error(
          'The requested resource was not found.',
          statusCode: 404,
          errorId: errorId,
        );

      default:
        return DbResult.error(
          'The database operation could not be completed.',
          statusCode: 500,
          errorId: errorId,
        );
    }
  }
}
