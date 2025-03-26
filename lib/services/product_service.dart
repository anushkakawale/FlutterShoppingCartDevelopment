import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';

class ProductService {
  final String baseUrl = 'https://dummyjson.com';

  Future<List<Product>> getProducts({int limit = 10, int skip = 0}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/products?limit=$limit&skip=$skip'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> productsJson = data['products'];
        return productsJson.map((json) => Product.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load products: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching products: $e');
      throw Exception('Failed to load products: $e');
    }
  }
}