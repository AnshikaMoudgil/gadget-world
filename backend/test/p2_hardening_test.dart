import 'dart:convert';

import 'package:backend/core/network/json_request.dart';
import 'package:backend/features/address/controllers/address_controller.dart';
import 'package:backend/features/cart/models/add_to_cart_request.dart';
import 'package:backend/features/products/controllers/catalog_controller.dart';
import 'package:backend/features/payments/controllers/payment_controller.dart';
import 'package:shelf/shelf.dart';
import 'package:test/test.dart';

void main() {
  group('catalog query bounds', () {
    final controller = CatalogController();

    test('rejects an excessive page size before querying', () async {
      final response = await controller.getProducts(
        Request('GET', Uri.parse('http://localhost/products?limit=101')),
      );
      expect(response.statusCode, 400);
    });

    test('rejects oversized search input before querying', () async {
      final search = List.filled(101, 'a').join();
      final response = await controller.getProducts(
        Request(
          'GET',
          Uri.parse('http://localhost/products?search=$search'),
        ),
      );
      expect(response.statusCode, 400);
    });

    test('rejects invalid numeric ranges before querying', () async {
      final response = await controller.getProducts(
        Request(
          'GET',
          Uri.parse('http://localhost/products?minPrice=100&maxPrice=10'),
        ),
      );
      expect(response.statusCode, 400);
    });
  });

  test('address controller fails closed without authenticated context',
      () async {
    final response = await AddressController().list(
      Request('GET', Uri.parse('http://localhost/addresses')),
    );
    expect(response.statusCode, 401);
  });

  group('JSON request validation', () {
    test('rejects non-object JSON', () async {
      final request = Request(
        'POST',
        Uri.parse('http://localhost/test'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(['not', 'an', 'object']),
      );
      expect(() => readJsonObject(request), throwsFormatException);
    });

    test('rejects unknown fields', () async {
      final request = Request(
        'POST',
        Uri.parse('http://localhost/test'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'quantity': 1, 'admin': true}),
      );
      expect(
        () => readJsonObject(request, allowedKeys: {'quantity'}),
        throwsFormatException,
      );
    });
  });

  test('cart input enforces UUID and quantity bounds', () {
    final request = AddToCartRequest(
      productId: 'not-a-uuid',
      quantity: 100,
    );
    expect(request.validate(), isNotNull);
  });

  group('payment webhook request bounds', () {
    final controller = PaymentController();

    test('requires a provider event ID for replay protection', () async {
      final response = await controller.webhook(Request(
        'POST',
        Uri.parse('http://localhost/webhook'),
        headers: {'x-razorpay-signature': 'signature'},
        body: '{}',
      ));
      expect(response.statusCode, 400);
    });

    test('rejects an oversized declared body before processing', () async {
      final response = await controller.webhook(Request(
        'POST',
        Uri.parse('http://localhost/webhook'),
        headers: {
          'x-razorpay-signature': 'signature',
          'x-razorpay-event-id': 'event-1',
        },
        body: List.filled(256 * 1024 + 1, 0),
      ));
      expect(response.statusCode, 413);
    });
  });
}
