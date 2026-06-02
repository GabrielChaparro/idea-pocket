import 'dart:convert';

import 'package:http/http.dart' as http;

import '../items/item.dart';
import '../tags/tag.dart';
import 'app_config.dart';
import 'api_exception.dart';

class ApiClient {
  ApiClient(this.token);

  final String token;

  Map<String, String> get headers => {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

  Future<List<Item>> items({String? type, String? status, String? search, String? tagId}) async {
    final params = <String, String>{'sort': 'createdAt,desc'};
    if (type != null) params['type'] = type;
    if (status != null) params['status'] = status;
    if (search != null && search.trim().isNotEmpty) params['search'] = search.trim();
    if (tagId != null) params['tagId'] = tagId;

    final uri = Uri.parse('$apiBaseUrl/items').replace(queryParameters: params);
    final response = await http.get(uri, headers: headers);
    _ensureOk(response);
    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    return (decoded['content'] as List<dynamic>).map((json) => Item.fromJson(json)).toList();
  }

  Future<List<Tag>> tags() async {
    final response = await http.get(Uri.parse('$apiBaseUrl/tags'), headers: headers);
    _ensureOk(response);
    final decoded = jsonDecode(response.body) as List<dynamic>;
    return decoded.map((json) => Tag.fromJson(json as Map<String, dynamic>)).toList();
  }

  Future<void> createItem({
    required String type,
    required String content,
    String? title,
    String priority = 'NORMAL',
    List<String> tagIds = const [],
  }) async {
    final response = await http.post(
      Uri.parse('$apiBaseUrl/items'),
      headers: headers,
      body: jsonEncode({
        'type': type,
        'title': title?.trim().isEmpty == true ? null : title?.trim(),
        'content': content.trim(),
        'priority': priority,
        'tagIds': tagIds,
      }),
    );
    _ensureOk(response);
  }

  Future<void> updateItem({
    required Item item,
    required String type,
    required String content,
    String? title,
    String priority = 'NORMAL',
    List<String> tagIds = const [],
  }) async {
    final response = await http.put(
      Uri.parse('$apiBaseUrl/items/${item.id}'),
      headers: headers,
      body: jsonEncode({
        'type': type,
        'title': title?.trim().isEmpty == true ? null : title?.trim(),
        'content': content.trim(),
        'priority': priority,
        'tagIds': tagIds,
      }),
    );
    _ensureOk(response);
  }

  Future<Tag> createTag(String name) async {
    final response = await http.post(
      Uri.parse('$apiBaseUrl/tags'),
      headers: headers,
      body: jsonEncode({'name': name.trim(), 'color': null}),
    );
    _ensureOk(response);
    return Tag.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<void> deleteTag(String id) async {
    final response = await http.delete(Uri.parse('$apiBaseUrl/tags/$id'), headers: headers);
    _ensureOk(response);
  }

  Future<void> complete(String id, bool completed) async {
    final action = completed ? 'reopen' : 'complete';
    final response = await http.patch(Uri.parse('$apiBaseUrl/items/$id/$action'), headers: headers);
    _ensureOk(response);
  }

  Future<void> delete(String id) async {
    final response = await http.delete(Uri.parse('$apiBaseUrl/items/$id'), headers: headers);
    _ensureOk(response);
  }

  void _ensureOk(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(responseErrorMessage(response.statusCode, response.body), statusCode: response.statusCode);
    }
  }
}
