import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/customer.dart';

class CustomerService {
  // API base URL - matches React frontend configuration
  // For web: uses relative path '/api' (same as React)
  // For mobile: update to your server's IP address (e.g., 'http://192.168.1.100:3000/api')
  static const String apiBaseUrl = '/api';

  static Future<List<Customer>> searchCustomers(String query, int page) async {
    try {
      final uri = Uri.parse('$apiBaseUrl/search')
          .replace(queryParameters: {
        'q': query,
        'page': page.toString(),
      });

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List<dynamic>;
        return results.map((json) {
          try {
            return Customer.fromJson(json as Map<String, dynamic>);
          } catch (e) {
            print('Error parsing customer: $json, Error: $e');
            rethrow;
          }
        }).toList();
      } else {
        final error = json.decode(response.body);
        throw Exception(error['error'] ?? 'Search failed');
      }
    } catch (e) {
      throw Exception('Failed to load customers: $e');
    }
  }
}
