import 'package:flutter/material.dart';
import 'package:timetable_fe/services/timetable_service.dart';

class TimetableDetailScreen extends StatefulWidget {
  final Map<String, dynamic> timetable;

  const TimetableDetailScreen({super.key, required this.timetable});

  @override
  State<TimetableDetailScreen> createState() => _TimetableDetailScreenState();
}

class _TimetableDetailScreenState extends State<TimetableDetailScreen> {
  int selectedDay = DateTime.now().weekday - 1; // 0 = Monday, 6 = Sunday
  List<Map<String, dynamic>> scheduleData = [];
  bool isLoading = false;
  String? errorMessage;

  final List<String> daysOfWeek = [
    'Thứ 2',
    'Thứ 3',
    'Thứ 4',
    'Thứ 5',
    'Thứ 6',
    'Thứ 7',
    'Chủ nhật',
  ];

  // Mock data for demonstration - replace with real API call
  final Map<int, List<Map<String, dynamic>>> weeklySchedule = {
    0: [
      // Monday
      {
        'subject': 'Lập trình Flutter',
        'time': '07:00 - 09:30',
        'room': 'A101',
        'teacher': 'TS. Nguyễn Văn A',
        'color': Colors.blue,
      },
      {
        'subject': 'Cơ sở dữ liệu',
        'time': '13:00 - 15:30',
        'room': 'B205',
        'teacher': 'ThS. Trần Thị B',
        'color': Colors.green,
      },
    ],
    1: [
      // Tuesday
      {
        'subject': 'Mạng máy tính',
        'time': '09:30 - 12:00',
        'room': 'C301',
        'teacher': 'PGS. Lê Văn C',
        'color': Colors.orange,
      },
    ],
    2: [
      // Wednesday
      {
        'subject': 'Trí tuệ nhân tạo',
        'time': '07:00 - 09:30',
        'room': 'D401',
        'teacher': 'GS. Phạm Thị D',
        'color': Colors.purple,
      },
      {
        'subject': 'Thực hành Flutter',
        'time': '15:30 - 17:00',
        'room': 'LAB A',
        'teacher': 'TS. Nguyễn Văn A',
        'color': Colors.blue,
      },
    ],
    3: [
      // Thursday
      {
        'subject': 'Phân tích thiết kế hệ thống',
        'time': '13:00 - 15:30',
        'room': 'B305',
        'teacher': 'ThS. Hoàng Văn E',
        'color': Colors.teal,
      },
    ],
    4: [
      // Friday
      {
        'subject': 'Kiểm thử phần mềm',
        'time': '09:30 - 12:00',
        'room': 'A202',
        'teacher': 'TS. Đỗ Thị F',
        'color': Colors.red,
      },
    ],
    5: [], // Saturday
    6: [], // Sunday
  };

  @override
  void initState() {
    super.initState();
    _loadSchedule();
  }

  Future<void> _loadSchedule() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      // TODO: Replace with real API call to get schedule for this timetable
      // For now, using mock data
      await Future.delayed(const Duration(milliseconds: 500));
      setState(() {
        scheduleData = weeklySchedule[selectedDay] ?? [];
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Không thể tải lịch học: ${e.toString()}';
        isLoading = false;
      });
    }
  }

  void _onDaySelected(int day) {
    setState(() {
      selectedDay = day;
    });
    _loadSchedule();
  }

  Color _parseColor(String colorString) {
    try {
      String hexColor = colorString.replaceAll('#', '');
      if (hexColor.length == 6) {
        hexColor = 'FF$hexColor';
      }
      return Color(int.parse(hexColor, radix: 16));
    } catch (e) {
      return Colors.blue;
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color themeColor = _parseColor(
      widget.timetable['colorTheme'] ?? '#3b82f6',
    );

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          widget.timetable['title'] ?? 'Thời khóa biểu',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: themeColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadSchedule),
          PopupMenuButton(
            icon: const Icon(Icons.more_vert),
            itemBuilder:
                (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, color: Colors.blue),
                        SizedBox(width: 8),
                        Text('Chỉnh sửa'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'share',
                    child: Row(
                      children: [
                        Icon(Icons.share, color: Colors.green),
                        SizedBox(width: 8),
                        Text('Chia sẻ'),
                      ],
                    ),
                  ),
                ],
            onSelected: (value) {
              if (value == 'edit') {
                // TODO: Navigate to edit screen
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Tính năng chỉnh sửa sẽ được phát triển'),
                  ),
                );
              } else if (value == 'share') {
                // TODO: Share functionality
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Tính năng chia sẻ sẽ được phát triển'),
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Header with timetable info
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: themeColor,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.timetable['description'] != null &&
                    widget.timetable['description'].toString().isNotEmpty) ...[
                  Text(
                    widget.timetable['description'],
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                ],
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      color: Colors.white.withOpacity(0.8),
                      size: 16,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      '${_formatDate(widget.timetable['startDate'])} - ${_formatDate(widget.timetable['endDate'])}',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Day selector
          Container(
            height: 80,
            margin: const EdgeInsets.symmetric(vertical: 10),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              itemCount: daysOfWeek.length,
              itemBuilder: (context, index) {
                final isSelected = selectedDay == index;
                final isToday = DateTime.now().weekday - 1 == index;
                final hasSchedule = (weeklySchedule[index] ?? []).isNotEmpty;

                return GestureDetector(
                  onTap: () => _onDaySelected(index),
                  child: Container(
                    width: 70,
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    decoration: BoxDecoration(
                      color: isSelected ? themeColor : Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      border:
                          isToday
                              ? Border.all(color: Colors.orange, width: 2)
                              : null,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          daysOfWeek[index],
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.grey[600],
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        if (hasSchedule)
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.white : themeColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                        if (isToday && !hasSchedule)
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.white : Colors.orange,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Schedule list
          Expanded(
            child:
                isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : errorMessage != null
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 80,
                            color: Colors.red[400],
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Có lỗi xảy ra',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            errorMessage!,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: _loadSchedule,
                            child: const Text('Thử lại'),
                          ),
                        ],
                      ),
                    )
                    : scheduleData.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.free_breakfast,
                            size: 80,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Không có lịch học',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            '${daysOfWeek[selectedDay]} này bạn được nghỉ ngơi!',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    )
                    : ListView.builder(
                      padding: const EdgeInsets.all(15),
                      itemCount: scheduleData.length,
                      itemBuilder: (context, index) {
                        final schedule = scheduleData[index];

                        return Container(
                          margin: const EdgeInsets.only(bottom: 15),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                spreadRadius: 1,
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: IntrinsicHeight(
                            child: Row(
                              children: [
                                Container(
                                  width: 5,
                                  decoration: BoxDecoration(
                                    color: schedule['color'],
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(15),
                                      bottomLeft: Radius.circular(15),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(15),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                schedule['subject'],
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                            ),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 4,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: schedule['color']
                                                    .withOpacity(0.1),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                schedule['room'],
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                  color: schedule['color'],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.access_time,
                                              size: 16,
                                              color: Colors.grey[600],
                                            ),
                                            const SizedBox(width: 5),
                                            Text(
                                              schedule['time'],
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 5),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.person,
                                              size: 16,
                                              color: Colors.grey[600],
                                            ),
                                            const SizedBox(width: 5),
                                            Expanded(
                                              child: Text(
                                                schedule['teacher'],
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),

      // Floating action button to add new class
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Add new class to this timetable
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tính năng thêm môn học sẽ được phát triển'),
            ),
          );
        },
        backgroundColor: themeColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
