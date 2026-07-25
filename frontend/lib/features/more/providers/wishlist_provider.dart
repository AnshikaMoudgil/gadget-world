import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/wishlist.dart';

class WishlistProvider extends ChangeNotifier {
  final _supabase = Supabase.instance.client;

  List<WishlistItem> _items = [];
  bool _isLoading = false;
  String? _error;

  List<WishlistItem> get items => _items;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchWishlist() async {
    if (_supabase.auth.currentUser == null) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // 1. First ensure the wishlist exists for the user.
      final wishlistResponse = await _supabase
          .from('wishlists')
          .select('id')
          .eq('user_id', _supabase.auth.currentUser!.id)
          .maybeSingle();

      String wishlistId;
      if (wishlistResponse == null) {
        // Create one if it doesn't exist
        final newWishlist = await _supabase
            .from('wishlists')
            .insert({'user_id': _supabase.auth.currentUser!.id})
            .select('id')
            .single();
        wishlistId = newWishlist['id'] as String;
      } else {
        wishlistId = wishlistResponse['id'] as String;
      }

      // 2. Fetch the items with product details
      final response = await _supabase
          .from('wishlist_items')
          .select('*, products(*), product_variants(*)')
          .eq('wishlist_id', wishlistId)
          .order('added_at', ascending: false);

      _items = (response as List)
          .map((item) => WishlistItem.fromJson(item))
          .toList();
    } catch (e) {
      print('WISHLIST FETCH ERROR: $e');
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  bool isInWishlist(String productId, {String? variantId}) {
    if (variantId != null) {
      return _items.any(
        (item) => item.productId == productId && item.variantId == variantId,
      );
    }
    return _items.any((item) => item.productId == productId);
  }

  Future<void> toggleWishlist(String productId, {String? variantId}) async {
    if (_supabase.auth.currentUser == null) {
      _error = 'Please log in to manage your wishlist';
      notifyListeners();
      return;
    }

    // Optimistically update the UI if possible?
    // Usually toggles are fast enough to just show loading or update instantly.
    try {
      // Get the user's wishlist ID
      final wishlistResponse = await _supabase
          .from('wishlists')
          .select('id')
          .eq('user_id', _supabase.auth.currentUser!.id)
          .maybeSingle();

      String wishlistId;
      if (wishlistResponse == null) {
        final newWishlist = await _supabase
            .from('wishlists')
            .insert({'user_id': _supabase.auth.currentUser!.id})
            .select('id')
            .single();
        wishlistId = newWishlist['id'] as String;
      } else {
        wishlistId = wishlistResponse['id'] as String;
      }

      final alreadyInWishlist = isInWishlist(productId, variantId: variantId);

      if (alreadyInWishlist) {
        // Remove from wishlist
        var query = _supabase
            .from('wishlist_items')
            .delete()
            .eq('wishlist_id', wishlistId)
            .eq('product_id', productId);

        if (variantId != null) {
          query = query.eq('variant_id', variantId);
        } else {
          query = query.isFilter('variant_id', null);
        }

        await query;

        _items.removeWhere(
          (item) => item.productId == productId && item.variantId == variantId,
        );
      } else {
        // Add to wishlist
        final Map<String, dynamic> insertData = {
          'wishlist_id': wishlistId,
          'product_id': productId,
        };
        if (variantId != null) {
          insertData['variant_id'] = variantId;
        }

        await _supabase.from('wishlist_items').insert(insertData);
        // Refresh to get the product details joined
        await fetchWishlist();
        return;
      }

      notifyListeners();
    } catch (e) {
      print('WISHLIST TOGGLE ERROR: $e');
      _error = e.toString();
      notifyListeners();
      // Optionally refresh to ensure state is consistent
      fetchWishlist();
    }
  }

  void clearWishlistLocal() {
    _items = [];
    _error = null;
    notifyListeners();
  }
}
