import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum RequestMethod { GET, POST, PUT, DELETE, MULTIPART }

class NetworkCaller {
  static const _jsonHeaders = {"Content-Type": "application/json"};

  Future<dynamic> request({
    required RequestMethod method,
    required String url,
    Map<String, dynamic>? body,
    bool isAuth = false,
    Map<String, File>? files,
  }) async {
    final hasConnection = await _hasInternetConnection();
    if (!hasConnection) {
      _showError("No internet connection.");
      return null;
    }

    try {
      final headers = Map<String, String>.from(_jsonHeaders);

      if (isAuth) {
        final token = await _getToken();
        if (token != null) {
          headers['Authorization'] = 'Bearer $token';
        }
      }

      if (method == RequestMethod.MULTIPART) {
        return await _multipartRequest(url, body ?? {}, files ?? {}, headers);
      }

      http.Response response;

      switch (method) {
        case RequestMethod.GET:
          response = await http.get(Uri.parse(url), headers: headers);
          break;
        case RequestMethod.POST:
          response = await http.post(
            Uri.parse(url),
            headers: headers,
            body: jsonEncode(body ?? {}),
          );
          break;
        case RequestMethod.PUT:
          response = await http.put(
            Uri.parse(url),
            headers: headers,
            body: jsonEncode(body ?? {}),
          );
          break;
        case RequestMethod.DELETE:
          response = await http.delete(Uri.parse(url), headers: headers);
          break;
        case RequestMethod.MULTIPART:
          return;
      }

      if (kDebugMode) {
        print("Status Code: ${response.statusCode}");
        print("Response Body: ${response.body}");
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(response.body);
      } else {
        _showError("Server Error: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      _showError("Error: $e");
      return null;
    }
  }

  Future<dynamic> _multipartRequest(
    String url,
    Map<String, dynamic> fields,
    Map<String, File> files,
    Map<String, String> headers,
  ) async {
    final uri = Uri.parse(url);
    final request = http.MultipartRequest("POST", uri);

    request.headers.addAll(headers);

    // Add fields
    fields.forEach((key, value) {
      request.fields[key] = value.toString();
    });

    // Add files
    for (var entry in files.entries) {
      final fileStream = http.ByteStream(entry.value.openRead());
      final length = await entry.value.length();
      final multipartFile = http.MultipartFile(
        entry.key,
        fileStream,
        length,
        filename: entry.value.path.split('/').last,
      );
      request.files.add(multipartFile);
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (kDebugMode) {
      print("Multipart Status Code: ${response.statusCode}");
      print("Multipart Response: ${response.body}");
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      _showError("Upload failed: ${response.statusCode}");
      return null;
    }
  }

  Future<bool> _hasInternetConnection() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }

  void _showError(String message) {
    Fluttertoast.showToast(
      msg: message,
      backgroundColor: Colors.red,
      textColor: Colors.white,
    );
  }
}
