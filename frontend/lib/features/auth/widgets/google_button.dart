import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gadget_store/core/theme.dart';
import 'web_button_stub.dart' if (dart.library.html) 'web_button_web.dart';

class GoogleButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isLoading;

  const GoogleButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return buildWebButton();
    }

    // Android / iOS fallback
    return OutlinedButton(
      onPressed: isLoading ? null : onPressed,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        side: const BorderSide(color: Colors.grey),
      ),
      child: isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.g_mobiledata, color: Colors.blue, size: 32),
                SizedBox(width: 8),
                Text(
                  'Continue with Google',
                  style: TextStyle(
                    color: AppTheme.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
    );
  }
}
