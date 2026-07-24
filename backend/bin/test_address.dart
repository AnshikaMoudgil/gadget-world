import 'package:backend/core/config/env.dart';
import 'package:backend/core/database/supabase_db.dart';
import 'package:backend/features/address/services/address_service.dart';
import 'package:backend/features/address/models/create_address_request.dart';
import 'package:backend/features/address/models/address.dart';

void main() async {
  Env.load();
  SupabaseDb.init();

  final service = AddressService();
  final req = CreateAddressRequest(
    recipientName: 'Mukesh',
    phoneNumber: '9876543210',
    addressLine1: 'Test',
    city: 'Mumbai',
    state: 'Maharashtra',
    postalCode: '400001',
    addressType: AddressType.home,
  );

  try {
    final addr = await service.createAddress('user_1', req);
    print('Created: \${addr.id}');
  } catch (e) {
    print('Error: \$e');
  }
}
