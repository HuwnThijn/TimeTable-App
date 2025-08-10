import 'dart:convert';

import 'package:timetable_fe/utils/constants.dart';
import 'package:timetable_fe/utils/auth_manager.dart';
import 'package:http/http.dart' as http;

class AuthServices {
  static Future<bool> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/api/auth/login');
    final res = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);

      // Save user data using AuthManager
      await AuthManager.saveUserData(
        token: data['token'],
        email: email,
        name: data['user']['name'] ?? 'Người dùng',
      );

      return true;
    } else {
      return false;
    }
  }

  static Future<bool> register(
    String name,
    String email,
    String password,
  ) async {
    final url = Uri.parse('$baseUrl/api/auth/register');
    final res = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'email': email, 'password': password}),
    );

    if (res.statusCode == 201) {
      // Don't auto-login after register, wait for email verification
      return true;
    } else {
      return false;
    }
  }

  static Future<bool> sendVerificationEmail(String email) async {
    final url = Uri.parse('$baseUrl/api/auth/send-verification');
    print('Sending verification email to: $email');
    print('URL: $url');

    final res = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );

    print('Response status: ${res.statusCode}');
    print('Response body: ${res.body}');

    return res.statusCode == 200;
  }

  static Future<bool> verifyOtp(String email, String otp) async {
    final url = Uri.parse('$baseUrl/api/auth/verify-otp');
    print('Verifying OTP for: $email with OTP: $otp');
    print('URL: $url');

    final res = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'otp': otp}),
    );

    print('Response status: ${res.statusCode}');
    print('Response body: ${res.body}');

    return res.statusCode == 200;
  }

  static Future<bool> forgetPassword(String email) async {
    final url = Uri.parse('$baseUrl/api/auth/forget-password');
    print('Sending forget password request for: $email');
    print('URL: $url');

    final res = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );

    print('Response status: ${res.statusCode}');
    print('Response body: ${res.body}');

    return res.statusCode == 200;
  }

  static Future<bool> logout() async {
    await AuthManager.logout();
    return true;
  }
}
