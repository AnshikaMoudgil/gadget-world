/// A lightweight Result type for database operations.
///
/// Wraps either a success value (`data`) or a failure (`error` + `message`).
/// This avoids scattering try/catch across every call-site and makes error
/// handling explicit and composable.
///
/// ### Usage
/// ```dart
/// final result = await db.getAddress(userId, id);
/// if (result.isError) {
///   return Response(result.statusCode, body: result.message);
/// }
/// return Response.ok(jsonEncode(result.data!.toJson()));
/// ```
class DbResult<T> {
  /// The successful value, if any.
  final T? data;

  /// A human-readable error message, if any.
  final String? message;

  /// A suggested HTTP status code for the error (default 500).
  final int statusCode;

  const DbResult._({this.data, this.message, this.statusCode = 200});

  /// Create a successful result.
  factory DbResult.success(T data) => DbResult._(data: data);

  /// Create a failed result.
  factory DbResult.error(String message, {int statusCode = 500}) =>
      DbResult._(message: message, statusCode: statusCode);

  /// Create a 404 error.
  factory DbResult.notFound([String message = 'Resource not found']) =>
      DbResult._(message: message, statusCode: 404);

  /// Create a 400 error.
  factory DbResult.badRequest(String message) =>
      DbResult._(message: message, statusCode: 400);

  /// `true` when the operation failed.
  bool get isError => message != null;

  /// `true` when the operation succeeded.
  bool get isSuccess => message == null;
}
