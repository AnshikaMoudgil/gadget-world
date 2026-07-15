import 'dart:io';
import 'package:supabase/supabase.dart';
import 'package:dotenv/dotenv.dart';

void main() async {
  var env = DotEnv(includePlatformEnvironment: true)..load();
  final supabaseUrl = env['SUPABASE_URL'];
  final serviceRoleKey = env['SUPABASE_SERVICE_ROLE_KEY'];

  if (supabaseUrl == null || serviceRoleKey == null) {
    print('Missing SUPABASE_URL or SUPABASE_SERVICE_ROLE_KEY in .env');
    exit(1);
  }

  final client = SupabaseClient(supabaseUrl, serviceRoleKey);
  final imageDir = Directory(
      r'C:\Users\ankus\.gemini\antigravity-ide\brain\0de3f2b7-5f12-422d-8b96-88a055a5f0bf');

  final uploads = {
    'sony_alpha_a6400': 'cameras/sony-alpha-a6400/main.png',
    'samsung_galaxy_camera': 'cameras/samsung-galaxy-cam-2/main.png',
    'jbl_charge_5': 'speakers-woofers/jbl-charge-5/main.png',
    'boat_stone_1500': 'speakers-woofers/boat-stone-1500/main.png',
    'hp_laptop_backpack': 'laptop-bags/hp-premium-backpack-156/main.png',
    'mi_urban_backpack': 'laptop-bags/mi-urban-backpack/main.png',
    'apple_airpods_pro': 'earphones-buds/apple-airpods-pro-2/main.png',
    'boat_airdopes_141': 'earphones-buds/boat-airdopes-141/main.png',
    'apple_watch_series9': 'smart-watches/apple-watch-series-9/main.png',
    'noise_smartwatch': 'smart-watches/noise-colorfit-pro-5/main.png',
    'logitech_mx_master': 'laptop-accessories/logitech-mx-master-3s/main.png',
    'dji_om6_gimbal': 'selfie-sticks-gimbles/dji-om-6/main.png',
    'mi_selfie_stick': 'selfie-sticks-gimbles/mi-selfie-stick-tripod/main.png',
    'sandisk_pendrive': 'memory-pen-drives/sandisk-extreme-pro-256gb/main.png',
    'anker_lightning_cable':
        'cables-connectors/anker-usb-c-to-lightning-cable/main.png',
    'anker_usbc_hub': 'cables-connectors/anker-7in1-usb-c-hub/main.png',
    'apple_magsafe_charger':
        'mobile-accessories/apple-magsafe-charger/main.png',
  };

  final files = imageDir.listSync().whereType<File>().toList();

  print('Starting concurrent upload of ${uploads.length} images...');

  // Use Future.wait to upload all files concurrently at the same time
  final futures = uploads.entries.map((entry) async {
    final prefix = entry.key;
    final destPath = entry.value;

    final file = files.cast<File?>().firstWhere(
          (f) =>
              f!.uri.pathSegments.last.startsWith(prefix) &&
              f.uri.pathSegments.last.endsWith('.png'),
          orElse: () => null,
        );

    if (file == null) {
      print('[SKIP] No file found for prefix: $prefix');
      return false;
    }

    try {
      await client.storage.from('products').upload(
            destPath,
            file,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
          );
      print('[OK] Uploaded: $destPath');
      return true;
    } catch (e) {
      print('[FAIL] $destPath - $e');
      return false;
    }
  });

  final results = await Future.wait(futures);
  final success = results.where((r) => r).length;
  final fail = results.length - success;

  print('\n=== Upload Summary ===');
  print('Success: $success');
  print('Failed:  $fail');
}
