import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:gadget_store/features/products/services/catalog_service.dart';

void main() {
  test('catalog requests an explicit bounded page', () async {
    late Uri requestedUri;
    final client = MockClient((request) async {
      requestedUri = request.url;
      return http.Response(
        '[]',
        200,
        headers: {'content-type': 'application/json'},
      );
    });
    final products = await CatalogService(
      client: client,
      baseUrl: 'https://api.example.com',
    ).getProducts(search: 'phone');

    expect(products, isEmpty);
    expect(requestedUri.queryParameters['page'], '1');
    expect(requestedUri.queryParameters['limit'], '100');
    expect(requestedUri.queryParameters['search'], 'phone');
  });
}
