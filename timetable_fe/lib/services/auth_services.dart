import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:timetable_fe/utils/constants.dart';
import 'package:http/http.dart' as http;

class AuthServices {
  static Future<bool> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/auth/login');
    final res = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      final prefs = await SharedPreferences.getInstance();

      await prefs.setString('token', data['token']);
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
    final url = Uri.parse('$baseUrl/auth/register');
    final res = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'email': email, 'password': password}),
    );

    if (res.statusCode == 201) {
      final data = jsonDecode(res.body);
      final prefs = await SharedPreferences.getInstance();

      await prefs.setString('token', data['token']);
      return true;
    } else {
      return false;
    }
  }

  static Future<bool> sendVerificationEmail(String email) async {
    final url = Uri.parse('$baseUrl/auth/send-verification');
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
    final url = Uri.parse('$baseUrl/auth/verify-otp');
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
    final url = Uri.parse('$baseUrl/auth/forget-password');
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
    final prefs = await SharedPreferences.getInstance();
    return prefs.remove('token');
  }
}
