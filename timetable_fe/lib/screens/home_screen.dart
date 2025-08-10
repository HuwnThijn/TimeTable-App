import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedWeekDay = DateTime.now().weekday - 1; // 0 = Monday
  final List<String> _weekDays = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
  final List<String> _fullWeekDays = ['Thứ 2', 'Thứ 3', 'Thứ 4', 'Thứ 5', 'Thứ 6', 'Thứ 7', 'Chủ nhật'];

  // Sample schedule data
  final Map<int, List<Map<String, String>>> _schedule = {
    0: [ // Monday
      {'time': '07:00 - 09:30', 'subject': 'Toán cao cấp', 'room': 'A101', 'teacher': 'GV. Nguyễn Văn A'},
      {'time': '10:00 - 11:30', 'subject': 'Lập trình Web', 'room': 'B205', 'teacher': 'GV. Trần Thị B'},
    ],
    1: [ // Tuesday
      {'time': '13:00 - 15:30', 'subject': 'Cơ sở dữ liệu', 'room': 'C302', 'teacher': 'GV. Lê Văn C'},
    ],
    2: [ // Wednesday
      {'time': '07:00 - 09:30', 'subject': 'Mạng máy tính', 'room': 'D104', 'teacher': 'GV. Phạm Thị D'},
      {'time': '13:00 - 15:30', 'subject': 'Kỹ thuật phần mềm', 'room': 'A201', 'teacher': 'GV. Hoàng Văn E'},
    ],
    3: [ // Thursday
      {'time': '10:00 - 11:30', 'subject': 'Tiếng Anh chuyên ngành', 'room': 'B101', 'teacher': 'GV. Đỗ Thị F'},
    ],
    4: [ // Friday
      {'time': '07:00 - 09:30', 'subject': 'Phát triển ứng dụng', 'room': 'C203', 'teacher': 'GV. Vũ Văn G'},
      {'time': '13:00 - 15:30', 'subject': 'Thực tập dự án', 'room': 'Lab1', 'teacher': 'GV. Bùi Thị H'},
    ],
    5: [], // Saturday
    6: [], // Sunday
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        title: Row(
          children: [
            Icon(Icons.calendar_today, size: 24),
            SizedBox(width: 8),
            Text(
              'Thời khóa biểu',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              _showSettingsDialog();
            },
            icon: Icon(Icons.settings),
            tooltip: 'Cài đặt',
          ),
          IconButton(
            onPressed: () {
              _showProfileDialog();
            },
            icon: Icon(Icons.person),
            tooltip: 'Hồ sơ',
          ),
        ],
      ),
      body: Column(
        children: [
          // Header with current date
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.blue[600],
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 0, 20, 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hôm nay',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    _getCurrentDateString(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Week days selector
          Container(
            margin: EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(7, (index) {
                bool isSelected = index == _selectedWeekDay;
                bool isToday = index == DateTime.now().weekday - 1;
                
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedWeekDay = index;
                    });
                  },
                  child: Container(
                    width: 45,
                    height: 45,
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? Colors.blue[600] 
                          : isToday 
                              ? Colors.blue[100] 
                              : Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                      border: isToday && !isSelected 
                          ? Border.all(color: Colors.blue[300]!, width: 2)
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        _weekDays[index],
                        style: TextStyle(
                          color: isSelected 
                              ? Colors.white 
                              : isToday 
                                  ? Colors.blue[700] 
                                  : Colors.grey[600],
                          fontWeight: isSelected || isToday 
                              ? FontWeight.bold 
                              : FontWeight.normal,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),

          // Schedule content
          Expanded(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _fullWeekDays[_selectedWeekDay],
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  SizedBox(height: 16),
                  Expanded(
                    child: _buildScheduleList(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddSubjectDialog();
        },
        backgroundColor: Colors.blue[600],
        child: Icon(Icons.add, color: Colors.white),
        tooltip: 'Thêm môn học',
      ),
    );
  }

  Widget _buildScheduleList() {
    List<Map<String, String>> todaySchedule = _schedule[_selectedWeekDay] ?? [];
    
    if (todaySchedule.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.free_breakfast,
              size: 80,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16),
            Text(
              'Không có lịch học',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Hôm nay bạn được nghỉ!',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: todaySchedule.length,
      itemBuilder: (context, index) {
        final subject = todaySchedule[index];
        return Container(
          margin: EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 10,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 60,
                  decoration: BoxDecoration(
                    color: _getSubjectColor(index),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        subject['subject']!,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                          SizedBox(width: 4),
                          Text(
                            subject['time']!,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
                          SizedBox(width: 4),
                          Text(
                            subject['room']!,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          SizedBox(width: 16),
                          Icon(Icons.person, size: 14, color: Colors.grey[600]),
                          SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              subject['teacher']!,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getSubjectColor(int index) {
    List<Color> colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.indigo,
    ];
    return colors[index % colors.length];
  }

  String _getCurrentDateString() {
    DateTime now = DateTime.now();
    List<String> months = [
      'Tháng 1', 'Tháng 2', 'Tháng 3', 'Tháng 4', 'Tháng 5', 'Tháng 6',
      'Tháng 7', 'Tháng 8', 'Tháng 9', 'Tháng 10', 'Tháng 11', 'Tháng 12'
    ];
    return '${now.day} ${months[now.month - 1]}, ${now.year}';
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.settings, color: Colors.blue[600]),
            SizedBox(width: 8),
            Text('Cài đặt'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.notifications),
              title: Text('Thông báo'),
              subtitle: Text('Quản lý thông báo'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to notifications settings
              },
            ),
            ListTile(
              leading: Icon(Icons.color_lens),
              title: Text('Giao diện'),
              subtitle: Text('Tùy chỉnh màu sắc'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to theme settings
              },
            ),
            ListTile(
              leading: Icon(Icons.backup),
              title: Text('Sao lưu'),
              subtitle: Text('Đồng bộ dữ liệu'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to backup settings
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Đóng'),
          ),
        ],
      ),
    );
  }

  void _showProfileDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.person, color: Colors.blue[600]),
            SizedBox(width: 8),
            Text('Hồ sơ cá nhân'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: Colors.blue[100],
              child: Icon(Icons.person, size: 40, color: Colors.blue[600]),
            ),
            SizedBox(height: 16),
            Text(
              'Người dùng',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              'user@example.com',
              style: TextStyle(color: Colors.grey[600]),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    // TODO: Edit profile
                  },
                  icon: Icon(Icons.edit),
                  label: Text('Sửa'),
                ),
                TextButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    // TODO: Logout
                  },
                  icon: Icon(Icons.logout, color: Colors.red),
                  label: Text('Đăng xuất', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Đóng'),
          ),
        ],
      ),
    );
  }

  void _showAddSubjectDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.add, color: Colors.blue[600]),
            SizedBox(width: 8),
            Text('Thêm môn học'),
          ],
        ),
        content: Text('Chức năng thêm môn học sẽ được phát triển sau.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
}
