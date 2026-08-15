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

  final uploads = {
    r'C:\Users\mukes\.gemini\antigravity-ide\brain\beecba20-f86d-42a1-8fb1-f03d129e9039\hp_dock_1786195313110.png':
        'laptop-accessories/hp-usb-c-docking-station/main.png',
    r'C:\Users\mukes\.gemini\antigravity-ide\brain\beecba20-f86d-42a1-8fb1-f03d129e9039\samsung_adapter_1786195234667.png':
        'mobile-accessories/samsung-25w-travel-adapter/main.png',
    r'C:\Users\mukes\.gemini\antigravity-ide\brain\beecba20-f86d-42a1-8fb1-f03d129e9039\samsung_sdcard_1786195254010.png':
        'memory-pen-drives/samsung-evo-plus-128gb-sdcard/main.png',
    r'C:\Users\mukes\.gemini\antigravity-ide\brain\beecba20-f86d-42a1-8fb1-f03d129e9039\boat_combo_1786195271223.png':
        'gift-items/boat-smartwatch-earbuds-combo/main.png',
    r'C:\Users\mukes\.gemini\antigravity-ide\brain\beecba20-f86d-42a1-8fb1-f03d129e9039\mi_giftset_1786195288688.png':
        'gift-items/mi-3-in-1-gift-set/main.png',
  };

  for (var entry in uploads.entries) {
    final localPath = entry.key;
    final destPath = entry.value;

    final file = File(localPath);
    if (!file.existsSync()) {
      print('[SKIP] File not found: $localPath');
      continue;
    }

    try {
      await client.storage.from('products').upload(
            destPath,
            file,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
          );
      print('[OK] Uploaded: $destPath');
    } catch (e) {
      print('[FAIL] $destPath - $e');
    }
  }
}
