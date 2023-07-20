import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
class NetWork {
  static Future<dynamic> getNetwork({required String url, bool token = false}) async {
    try {
      var headers = <String, String>{};
      if (token) {
        // Token Logic
        headers['Authorization'] = 'Bearer <YOUR_TOKEN>';
      }
      var response = await http.get(
        Uri.parse(url),
        headers: headers,
      );
      final responseBody = response.body;
      return jsonDecode(responseBody);
    } catch (error) {
      if (kDebugMode) {
        print(error);
      }
      throw Exception('Failed to load data: $error');
    }
  }
  static Future<dynamic> postNetwork({required String url, required dynamic payload, bool token = false}) async {
    try {
      var headers = {'Content-Type': 'application/json'};
      if (token) {
        headers['Authorization'] = 'Bearer <YOUR_TOKEN>';
      }
      var response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(payload),
      );
      final responseBody = response.body;
      return jsonDecode(responseBody);
    } catch (error) {
      if (kDebugMode) {
        print(error);
      }
      throw Exception('Failed to load data: $error');
    }
  }
}