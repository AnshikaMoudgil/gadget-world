import 'dart:convert';
import 'package:shelf/shelf.dart';
import '../database/supabase_db.dart';

/// Middleware to extract and validate the Supabase JWT from the Authorization header.
///
/// If valid, the user's ID is injected into `request.context['userId']`.
/// If invalid or missing, it returns a 401 Unauthorized response.
Middleware authMiddleware() {
  return (Handler innerHandler) {
    return (Request request) async {
      final authHeader = request.headers['Authorization'];
      if (authHeader == null || !authHeader.startsWith('Bearer ')) {
        return Response(401,
            body: jsonEncode(
                {'error': 'Missing or invalid Authorization header'}),
            headers: {'Content-Type': 'application/json'});
      }

      final token = authHeader.substring(7);
      try {
        // Validate the JWT using Supabase Auth
        final userResponse = await SupabaseDb.client.auth.getUser(token);
        final user = userResponse.user;

        if (user == null) {
          return Response(401,
              body: jsonEncode({'error': 'Invalid or expired token'}),
              headers: {'Content-Type': 'application/json'});
        }

        // Inject the userId into the request context
        final updatedRequest = request.change(context: {'userId': user.id});
        return await innerHandler(updatedRequest);
      } catch (e) {
        return Response(401,
            body:
                jsonEncode({'error': 'Authentication failed: ${e.toString()}'}),
            headers: {'Content-Type': 'application/json'});
      }
    };
  };
}
