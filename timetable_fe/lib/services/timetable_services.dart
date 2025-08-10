import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';

class TimetableService {
  // Get all timetables for user
  static Future<List<Map<String, dynamic>>> getAllTimetables(
    String token,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/timetables'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['data']);
      } else {
        throw Exception('Failed to load timetables');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Get timetable by ID
  static Future<Map<String, dynamic>> getTimetableById(
    String id,
    String token,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/timetables/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'];
      } else {
        throw Exception('Failed to load timetable');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Create new timetable
  static Future<Map<String, dynamic>> createTimetable({
    required String title,
    required String description,
    required String colorTheme,
    required String startDate,
    required String endDate,
    required String token,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/timetables'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'title': title,
          'description': description,
          'colorTheme': colorTheme,
          'startDate': startDate,
          'endDate': endDate,
        }),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return data['data'];
      } else {
        throw Exception('Failed to create timetable');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Update timetable
  static Future<Map<String, dynamic>> updateTimetable({
    required String id,
    required String title,
    required String description,
    required String colorTheme,
    required String startDate,
    required String endDate,
    required String token,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/api/timetables/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'title': title,
          'description': description,
          'colorTheme': colorTheme,
          'startDate': startDate,
          'endDate': endDate,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'];
      } else {
        throw Exception('Failed to update timetable');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Delete timetable
  static Future<bool> deleteTimetable(String id, String token) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/api/timetables/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
