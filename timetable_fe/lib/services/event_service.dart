import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timetable_fe/utils/constants.dart';

class EventService {
  // Lấy tất cả events
  static Future<List<Map<String, dynamic>>> getAllEvents() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      
      if (token == null) {
        throw Exception('Token not found');
      }

      final url = Uri.parse('$baseUrl/events');
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Get all events - Status: ${response.statusCode}');
      print('Get all events - Response: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['data']);
      } else {
        throw Exception('Failed to load events');
      }
    } catch (e) {
      print('Error getting events: $e');
      throw Exception('Error getting events: $e');
    }
  }

  // Lấy events theo timetable ID
  static Future<List<Map<String, dynamic>>> getEventsByTimetableId(String timetableId) async {
    try {
      final allEvents = await getAllEvents();
      return allEvents.where((event) => event['timetableId'] == timetableId).toList();
    } catch (e) {
      print('Error getting events by timetable ID: $e');
      throw Exception('Error getting events by timetable ID: $e');
    }
  }

  // Lấy event theo ID
  static Future<Map<String, dynamic>?> getEventById(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      
      if (token == null) {
        throw Exception('Token not found');
      }

      final url = Uri.parse('$baseUrl/events/$id');
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Get event by ID - Status: ${response.statusCode}');
      print('Get event by ID - Response: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'];
      } else {
        throw Exception('Failed to load event');
      }
    } catch (e) {
      print('Error getting event by ID: $e');
      throw Exception('Error getting event by ID: $e');
    }
  }

  // Tạo event mới
  static Future<bool> createEvent({
    required String timetableId,
    required String title,
    required String description,
    required String location,
    required DateTime startTime,
    required DateTime endTime,
    Map<String, dynamic>? repeat,
    int? notifyBeforeMinutes,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      
      if (token == null) {
        throw Exception('Token not found');
      }

      final url = Uri.parse('$baseUrl/events');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'timetableId': timetableId,
          'title': title,
          'description': description,
          'location': location,
          'startTime': startTime.toIso8601String(),
          'endTime': endTime.toIso8601String(),
          'repeat': repeat,
          'notifyBeforeMinutes': notifyBeforeMinutes ?? 30,
        }),
      );

      print('Create event - Status: ${response.statusCode}');
      print('Create event - Response: ${response.body}');

      return response.statusCode == 201;
    } catch (e) {
      print('Error creating event: $e');
      throw Exception('Error creating event: $e');
    }
  }

  // Cập nhật event
  static Future<bool> updateEvent({
    required String id,
    required String timetableId,
    required String title,
    required String description,
    required String location,
    required DateTime startTime,
    required DateTime endTime,
    Map<String, dynamic>? repeat,
    int? notifyBeforeMinutes,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      
      if (token == null) {
        throw Exception('Token not found');
      }

      final url = Uri.parse('$baseUrl/events/$id');
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'timetableId': timetableId,
          'title': title,
          'description': description,
          'location': location,
          'startTime': startTime.toIso8601String(),
          'endTime': endTime.toIso8601String(),
          'repeat': repeat,
          'notifyBeforeMinutes': notifyBeforeMinutes ?? 30,
        }),
      );

      print('Update event - Status: ${response.statusCode}');
      print('Update event - Response: ${response.body}');

      return response.statusCode == 200;
    } catch (e) {
      print('Error updating event: $e');
      throw Exception('Error updating event: $e');
    }
  }

  // Xóa event
  static Future<bool> deleteEvent(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      
      if (token == null) {
        throw Exception('Token not found');
      }

      final url = Uri.parse('$baseUrl/events/$id');
      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Delete event - Status: ${response.statusCode}');
      print('Delete event - Response: ${response.body}');

      return response.statusCode == 200;
    } catch (e) {
      print('Error deleting event: $e');
      throw Exception('Error deleting event: $e');
    }
  }

  // Lọc events theo ngày
  static List<Map<String, dynamic>> filterEventsByDate(
    List<Map<String, dynamic>> events,
    DateTime targetDate,
  ) {
    return events.where((event) {
      try {
        final startTime = DateTime.parse(event['startTime']);
        return startTime.year == targetDate.year &&
               startTime.month == targetDate.month &&
               startTime.day == targetDate.day;
      } catch (e) {
        return false;
      }
    }).toList();
  }

  // Sắp xếp events theo thời gian
  static List<Map<String, dynamic>> sortEventsByTime(
    List<Map<String, dynamic>> events,
  ) {
    events.sort((a, b) {
      try {
        final timeA = DateTime.parse(a['startTime']);
        final timeB = DateTime.parse(b['startTime']);
        return timeA.compareTo(timeB);
      } catch (e) {
        return 0;
      }
    });
    return events;
  }

  // Format thời gian hiển thị
  static String formatTime(String timeString) {
    try {
      final time = DateTime.parse(timeString);
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return timeString;
    }
  }

  // Format ngày hiển thị
  static String formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  // Lấy màu sắc cho event
  static Color getEventColor(String title) {
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
    
    final hash = title.hashCode.abs();
    return colors[hash % colors.length];
  }

  // Kiểm tra có events trong ngày không
  static bool hasEventsOnDate(
    List<Map<String, dynamic>> events,
    DateTime targetDate,
  ) {
    return filterEventsByDate(events, targetDate).isNotEmpty;
  }
}
