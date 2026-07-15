import '../models/address.dart';
import '../models/create_address_request.dart';
import '../models/update_address_request.dart';

/// Service layer for CRUD operations on the `user_addresses` table.
///
/// Currently stubbed — method bodies will be wired to a Supabase client
/// once the DB connection layer is in place.
class AddressService {
  /// Fetch all addresses belonging to [userId].
  Future<List<Address>> listAddresses(String userId) async {
    // TODO: Implement with Supabase client
    // e.g. supabase.from('user_addresses').select().eq('user_id', userId)
    return [];
  }

  /// Fetch a single address by [addressId], scoped to [userId].
  Future<Address?> getAddress(String userId, String addressId) async {
    // TODO: Implement with Supabase client
    return null;
  }

  /// Insert a new address for [userId].
  Future<Address> createAddress(
      String userId, CreateAddressRequest request) async {
    // TODO: Implement with Supabase client
    // The DB trigger handles demoting the old default when is_default = true.
    final data = request.toJson();
    data['user_id'] = userId;

    // Placeholder: return the request data wrapped in an Address.
    return Address.fromJson({
      ...data,
      'id': 'placeholder-uuid',
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  /// Partially update an existing address.
  Future<Address> updateAddress(
    String userId,
    String addressId,
    UpdateAddressRequest request,
  ) async {
    // TODO: Implement with Supabase client
    return Address(
      id: addressId,
      userId: userId,
      recipientName: request.recipientName ?? '',
      phoneNumber: request.phoneNumber ?? '',
      addressLine1: request.addressLine1 ?? '',
      city: request.city ?? '',
      state: request.state ?? '',
      postalCode: request.postalCode ?? '000000',
    );
  }

  /// Delete an address by [addressId], scoped to [userId].
  Future<void> deleteAddress(String userId, String addressId) async {
    // TODO: Implement with Supabase client
  }

  /// Set [addressId] as the default address for [userId].
  ///
  /// The DB trigger (`handle_default_address`) automatically demotes the
  /// previous default, so we only need to set `is_default = true` here.
  Future<void> setDefault(String userId, String addressId) async {
    // TODO: Implement with Supabase client
  }
}
