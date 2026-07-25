import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/wishlist.dart';

class WishlistProvider extends ChangeNotifier {
  final _supabase = Supabase.instance.client;

  List<WishlistItem> _items = [];
  bool _isLoading = false;
  String? _error;
  String? _wishlistId;

  List<WishlistItem> get items => _items;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<String?> _getWishlistId() async {
    if (_supabase.auth.currentUser == null) return null;
    if (_wishlistId != null) return _wishlistId;

    final wishlistResponse = await _supabase
        .from('wishlists')
        .select('id')
        .eq('user_id', _supabase.auth.currentUser!.id)
        .maybeSingle();

    if (wishlistResponse == null) {
      final newWishlist = await _supabase
          .from('wishlists')
          .insert({'user_id': _supabase.auth.currentUser!.id})
          .select('id')
          .single();
      _wishlistId = newWishlist['id'] as String;
    } else {
      _wishlistId = wishlistResponse['id'] as String;
    }
    return _wishlistId;
  }

  Future<void> fetchWishlist() async {
    if (_supabase.auth.currentUser == null) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final wishlistId = await _getWishlistId();
      if (wishlistId == null) {
        _isLoading = false;
        notifyListeners();
        return;
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
      final wishlistId = await _getWishlistId();
      if (wishlistId == null) return;

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
      _error = e.toString();
      notifyListeners();
      // Optionally refresh to ensure state is consistent
      fetchWishlist();
    }
  }

  void clearWishlistLocal() {
    _items = [];
    _error = null;
    _wishlistId = null;
    notifyListeners();
  }
}
