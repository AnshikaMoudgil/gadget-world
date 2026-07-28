import '../../../core/database/supabase_db.dart';
import '../models/address.dart';
import '../models/create_address_request.dart';
import '../models/update_address_request.dart';

/// Service layer for CRUD operations on the `user_addresses` table.
class AddressService {
  /// Fetch all addresses belonging to [userId].
  Future<List<Address>> listAddresses(String userId) async {
    final result = await SupabaseDb.query<List<Map<String, dynamic>>>(() async {
      return await SupabaseDb.adminClient
          .from('user_addresses')
          .select()
          .eq('user_id', userId)
          .order('is_default', ascending: false)
          .order('created_at', ascending: false);
    });

    if (result.isError) {
      throw Exception('Failed to list addresses: ${result.message}');
    }

    return result.data?.map((json) => Address.fromJson(json)).toList() ?? [];
  }

  /// Fetch a single address by [addressId], scoped to [userId].
  Future<Address?> getAddress(String userId, String addressId) async {
    final result = await SupabaseDb.querySingle<Map<String, dynamic>>(() async {
      return await SupabaseDb.adminClient
          .from('user_addresses')
          .select()
          .eq('user_id', userId)
          .eq('id', addressId)
          .maybeSingle();
    });

    if (result.isError) {
      throw Exception('Failed to get address: ${result.message}');
    }

    if (result.data == null) return null;
    return Address.fromJson(result.data!);
  }

  /// Insert a new address for [userId].
  Future<Address> createAddress(
      String userId, CreateAddressRequest request) async {
    final data = request.toJson();
    data['user_id'] = userId;

    final existing = await SupabaseDb.querySingle<Map<String, dynamic>>(() async {
      return await SupabaseDb.adminClient
          .from('user_addresses')
          .select('id')
          .eq('user_id', userId)
          .limit(1)
          .maybeSingle();
    });

    if (existing.data == null) {
      data['is_default'] = true;
    }

    final result = await SupabaseDb.querySingle<Map<String, dynamic>>(() async {
      return await SupabaseDb.adminClient
          .from('user_addresses')
          .insert(data)
          .select()
          .single();
    });

    if (result.isError) {
      throw Exception('Failed to create address: ${result.message}');
    }

    return Address.fromJson(result.data!);
  }

  /// Partially update an existing address.
  Future<Address> updateAddress(
    String userId,
    String addressId,
    UpdateAddressRequest request,
  ) async {
    final data = request.toJson();
    if (data.isEmpty) {
      throw Exception('No fields to update');
    }

    final result = await SupabaseDb.querySingle<Map<String, dynamic>>(() async {
      return await SupabaseDb.adminClient
          .from('user_addresses')
          .update(data)
          .eq('user_id', userId)
          .eq('id', addressId)
          .select()
          .single();
    });

    if (result.isError) {
      throw Exception('Failed to update address: ${result.message}');
    }

    return Address.fromJson(result.data!);
  }

  /// Delete an address by [addressId], scoped to [userId].
  Future<void> deleteAddress(String userId, String addressId) async {
    final result = await SupabaseDb.execute(() async {
      await SupabaseDb.adminClient
          .from('user_addresses')
          .delete()
          .eq('user_id', userId)
          .eq('id', addressId);
    });

    if (result.isError) {
      throw Exception('Failed to delete address: ${result.message}');
    }
  }

  /// Set [addressId] as the default address for [userId].
  Future<void> setDefault(String userId, String addressId) async {
    final result = await SupabaseDb.execute(() async {
      await SupabaseDb.adminClient
          .from('user_addresses')
          .update({'is_default': true})
          .eq('user_id', userId)
          .eq('id', addressId);
    });

    if (result.isError) {
      throw Exception('Failed to set default address: ${result.message}');
    }
  }
}
