import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stated_management/network/network_caller.dart';

class LoginController extends GetxController {
  String _email = '';
  String _password = '';
  bool _isLoading = false;

  String get email => _email;
  String get password => _password;
  bool get isLoading => _isLoading;

  Future<void> login() async {
    _isLoading = true;

    try {
      final response = await NetworkCaller().request(
        method: RequestMethod.POST,
        url: 'https://yourapi.com/login',
        body: {"email": _email, "password": _password},
      );

      if (response != null && response['token'] != null) {
        await _saveToken(response['token']);

        if (kDebugMode) {
          print("Login successful, token saved.");
        }
      } else {
        if (kDebugMode) {
          print("Login failed. Invalid response.");
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Login error: $e");
      }
    } finally {
      _isLoading = false;
      update();
    }
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("token", token);
  }
}
