import 'dart:convert';

import 'package:shelf/shelf.dart';

import '../models/create_address_request.dart';
import '../models/update_address_request.dart';
import '../services/address_service.dart';

/// Shelf request handlers for the address feature.
///
/// Each method extracts the user ID from the request context (to be supplied
/// by an auth middleware later) and delegates to [AddressService].
class AddressController {
  final AddressService _service = AddressService();

  static const _jsonHeaders = {'Content-Type': 'application/json'};

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  /// Extract the authenticated user's ID from the request.
  ///
  /// TODO: Wire this to the real auth middleware context value.
  String _userId(Request request) {
    // Placeholder — returns a fixed value until auth middleware is wired up.
    return request.context['userId'] as String? ?? 'anonymous';
  }

  Response _error(int status, String message) {
    return Response(status,
        body: jsonEncode({'error': message}), headers: _jsonHeaders);
  }

  Response _ok(Object? body) {
    return Response.ok(jsonEncode(body), headers: _jsonHeaders);
  }

  // ---------------------------------------------------------------------------
  // Handlers
  // ---------------------------------------------------------------------------

  /// `GET /` — list all addresses for the authenticated user.
  Future<Response> list(Request request) async {
    final userId = _userId(request);
    final addresses = await _service.listAddresses(userId);
    return _ok(addresses.map((a) => a.toJson()).toList());
  }

  /// `GET /<id>` — get a single address.
  Future<Response> get(Request request, String id) async {
    final userId = _userId(request);
    final address = await _service.getAddress(userId, id);
    if (address == null) {
      return _error(404, 'Address not found');
    }
    return _ok(address.toJson());
  }

  /// `POST /` — create a new address.
  Future<Response> create(Request request) async {
    final userId = _userId(request);

    final body = await request.readAsString();
    final json = jsonDecode(body) as Map<String, dynamic>;
    final dto = CreateAddressRequest.fromJson(json);

    final errors = dto.validate();
    if (errors.isNotEmpty) {
      return _error(400, errors.join('; '));
    }

    final address = await _service.createAddress(userId, dto);
    return Response(201,
        body: jsonEncode(address.toJson()), headers: _jsonHeaders);
  }

  /// `PUT /<id>` — update an existing address (partial).
  Future<Response> update(Request request, String id) async {
    final userId = _userId(request);

    final body = await request.readAsString();
    final json = jsonDecode(body) as Map<String, dynamic>;
    final dto = UpdateAddressRequest.fromJson(json);

    if (dto.isEmpty) {
      return _error(400, 'No fields to update');
    }

    final errors = dto.validate();
    if (errors.isNotEmpty) {
      return _error(400, errors.join('; '));
    }

    final address = await _service.updateAddress(userId, id, dto);
    return _ok(address.toJson());
  }

  /// `DELETE /<id>` — delete an address.
  Future<Response> delete(Request request, String id) async {
    final userId = _userId(request);
    await _service.deleteAddress(userId, id);
    return Response(204);
  }

  /// `PATCH /<id>/set-default` — mark an address as the default.
  Future<Response> setDefault(Request request, String id) async {
    final userId = _userId(request);
    await _service.setDefault(userId, id);
    return _ok({'message': 'Address set as default'});
  }
}
