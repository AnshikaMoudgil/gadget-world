import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/profile_model.dart';
import '../services/profile_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileProvider extends ChangeNotifier {
  final ProfileService _profileService = ProfileService();

  Profile? _profile;
  bool _isLoading = false;
  String? _errorMessage;

  Profile? get profile => _profile;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  void clearProfile() {
    _profile = null;
    notifyListeners();
  }

  Future<bool> fetchProfile() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      clearProfile();
      return false;
    }

    _setLoading(true);
    _setError(null);
    try {
      _profile = await _profileService.getProfile(user.id);
      return _profile != null;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateProfile(Profile updatedProfile) async {
    _setLoading(true);
    _setError(null);
    try {
      _profile = await _profileService.updateProfile(updatedProfile);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> uploadAvatar(XFile imageFile) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      _setError('Please sign in again before updating your profile picture.');
      return false;
    }

    _setLoading(true);
    _setError(null);
    try {
      _profile ??= await _profileService.getProfile(user.id);
      if (_profile == null) {
        throw Exception('Your profile could not be loaded. Please try again.');
      }

      final rawExtension = imageFile.name.contains('.')
          ? imageFile.name.split('.').last.toLowerCase()
          : 'jpg';
      final fileExtension = rawExtension == 'jpeg' ? 'jpg' : rawExtension;
      final contentType = switch (fileExtension) {
        'png' => 'image/png',
        'webp' => 'image/webp',
        _ => 'image/jpeg',
      };
      final fileName =
          '${user.id}/avatar_${DateTime.now().millisecondsSinceEpoch}.$fileExtension';
      final imageBytes = await imageFile.readAsBytes();

      await Supabase.instance.client.storage
          .from('avatars')
          .uploadBinary(
            fileName,
            imageBytes,
            fileOptions: FileOptions(contentType: contentType, upsert: false),
          );

      final imageUrl = Supabase.instance.client.storage
          .from('avatars')
          .getPublicUrl(fileName);

      final updatedProfile = _profile!.copyWith(avatarUrl: imageUrl);

      _profile = await _profileService.updateProfile(updatedProfile);
      try {
        await Supabase.instance.client.auth.updateUser(
          UserAttributes(data: {'avatar_url': imageUrl}),
        );
      } catch (_) {
        // The profiles row is authoritative. Auth metadata is only a helpful
        // fallback for surfaces that render before the profile is loaded.
      }
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteAvatar() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null || _profile == null) return false;

    _setLoading(true);
    _setError(null);
    try {
      final updatedProfile = _profile!.copyWith(clearAvatarUrl: true);
      _profile = await _profileService.updateProfile(updatedProfile);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }
}
