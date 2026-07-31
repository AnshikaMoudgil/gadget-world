import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  print('Testing cart endpoint...');
  final url = 'https://gadget-world-1pgn.onrender.com/api/cart/';

  try {
    final response = await http.get(Uri.parse(url));
    print('GET /api/cart/ Status: ${response.statusCode}');
    print('GET /api/cart/ Body: ${response.body}');
  } catch (e) {
    print('Error: $e');
  }
}
