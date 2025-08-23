import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timetable_fe/utils/constants.dart';

class TimetableService {
  // Lấy tất cả thời khóa biểu
  static Future<List<Map<String, dynamic>>> getAllTimetables() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        throw Exception('Token not found');
      }

      final url = Uri.parse('$baseUrl/timetables');
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Get all timetables - Status: ${response.statusCode}');
      print('Get all timetables - Response: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // API trả về format {"data": [...]}
        if (data is Map<String, dynamic> && data.containsKey('data')) {
          return List<Map<String, dynamic>>.from(data['data']);
        }
        // Fallback nếu API trả về trực tiếp array
        return List<Map<String, dynamic>>.from(data);
      } else {
        throw Exception('Failed to load timetables');
      }
    } catch (e) {
      print('Error getting timetables: $e');
      throw Exception('Error getting timetables: $e');
    }
  }

  // Lấy thời khóa biểu theo ID
  static Future<Map<String, dynamic>?> getTimetableById(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        throw Exception('Token not found');
      }

      final url = Uri.parse('$baseUrl/timetables/$id');
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Get timetable by ID - Status: ${response.statusCode}');
      print('Get timetable by ID - Response: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // API trả về format {"data": {...}}
        if (data is Map<String, dynamic> && data.containsKey('data')) {
          return data['data'];
        }
        // Fallback nếu API trả về trực tiếp object
        return data;
      } else {
        throw Exception('Failed to load timetable');
      }
    } catch (e) {
      print('Error getting timetable by ID: $e');
      throw Exception('Error getting timetable by ID: $e');
    }
  }

  // Tạo thời khóa biểu mới
  static Future<bool> createTimetable({
    required String subject,
    required String teacher,
    required String room,
    required String startTime,
    required String endTime,
    required int dayOfWeek, // 0 = Monday, 6 = Sunday
    String? description,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        throw Exception('Token not found');
      }

      final url = Uri.parse('$baseUrl/timetables');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'subject': subject,
          'teacher': teacher,
          'room': room,
          'startTime': startTime,
          'endTime': endTime,
          'dayOfWeek': dayOfWeek,
          'description': description,
        }),
      );

      print('Create timetable - Status: ${response.statusCode}');
      print('Create timetable - Response: ${response.body}');

      return response.statusCode == 201;
    } catch (e) {
      print('Error creating timetable: $e');
      throw Exception('Error creating timetable: $e');
    }
  }

  // Cập nhật thời khóa biểu
  static Future<bool> updateTimetable({
    required String id,
    required String subject,
    required String teacher,
    required String room,
    required String startTime,
    required String endTime,
    required int dayOfWeek,
    String? description,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        throw Exception('Token not found');
      }

      final url = Uri.parse('$baseUrl/timetables/$id');
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'subject': subject,
          'teacher': teacher,
          'room': room,
          'startTime': startTime,
          'endTime': endTime,
          'dayOfWeek': dayOfWeek,
          'description': description,
        }),
      );

      print('Update timetable - Status: ${response.statusCode}');
      print('Update timetable - Response: ${response.body}');

      return response.statusCode == 200;
    } catch (e) {
      print('Error updating timetable: $e');
      throw Exception('Error updating timetable: $e');
    }
  }

  // Xóa thời khóa biểu
  static Future<bool> deleteTimetable(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        throw Exception('Token not found');
      }

      final url = Uri.parse('$baseUrl/timetables/$id');
      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Delete timetable - Status: ${response.statusCode}');
      print('Delete timetable - Response: ${response.body}');

      return response.statusCode == 200;
    } catch (e) {
      print('Error deleting timetable: $e');
      throw Exception('Error deleting timetable: $e');
    }
  }

  // Lọc thời khóa biểu theo ngày trong tuần
  static List<Map<String, dynamic>> filterByDay(
    List<Map<String, dynamic>> timetables,
    int dayOfWeek,
  ) {
    return timetables.where((timetable) {
      return timetable['dayOfWeek'] == dayOfWeek;
    }).toList();
  }

  // Sắp xếp thời khóa biểu theo thời gian
  static List<Map<String, dynamic>> sortByTime(
    List<Map<String, dynamic>> timetables,
  ) {
    timetables.sort((a, b) {
      final timeA = a['startTime'] as String;
      final timeB = b['startTime'] as String;
      return timeA.compareTo(timeB);
    });
    return timetables;
  }

  // Lấy màu sắc cho môn học
  static Color getSubjectColor(String subject) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.red,
      Colors.indigo,
      Colors.pink,
      Colors.cyan,
      Colors.amber,
    ];

    final hash = subject.hashCode.abs();
    return colors[hash % colors.length];
  }
}
