import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/app_config.dart';
import '../core/api_exception.dart';

class AuthApi {
  Future<String> authenticate({
    required bool register,
    required String email,
    required String password,
    String? name,
  }) async {
    final path = register ? 'register' : 'login';
    final body = register
        ? {'email': email, 'password': password, 'name': name}
        : {'email': email, 'password': password};

    final response = await http.post(
      Uri.parse('$apiBaseUrl/auth/$path'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(responseErrorMessage(response.statusCode, response.body), statusCode: response.statusCode);
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    return decoded['token'] as String;
  }
}
