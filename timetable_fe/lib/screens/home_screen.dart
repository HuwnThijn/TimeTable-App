import 'package:flutter/material.dart';
import '../services/timetable_services.dart';
import '../utils/auth_manager.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedWeekDay = DateTime.now().weekday - 1; // 0 = Monday
  final List<String> _weekDays = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
  final List<String> _fullWeekDays = [
    'Thứ 2',
    'Thứ 3',
    'Thứ 4',
    'Thứ 5',
    'Thứ 6',
    'Thứ 7',
    'Chủ nhật',
  ];

  List<Map<String, dynamic>> _timetables = [];
  bool _isLoading = true;
  String _userToken = "";
  String _userEmail = "";
  String _userName = "";

  @override
  void initState() {
    super.initState();
    _initializeUser();
  }

  Future<void> _initializeUser() async {
    try {
      final token = await AuthManager.getToken();
      final email = await AuthManager.getUserEmail();
      final name = await AuthManager.getUserName();

      setState(() {
        _userToken = token ?? "";
        _userEmail = email ?? "";
        _userName = name ?? "";
      });

      if (_userToken.isNotEmpty) {
        _loadTimetables();
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadTimetables() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // TODO: Get actual user token from storage/auth
      if (_userToken.isNotEmpty) {
        final timetables = await TimetableService.getAllTimetables(_userToken);
        setState(() {
          _timetables = timetables;
          _isLoading = false;
        });
      } else {
        // For now, show empty state when no token
        setState(() {
          _timetables = [];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Lỗi khi tải thời khóa biểu: $e');
    }
  }

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
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
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
                    style: TextStyle(color: Colors.white70, fontSize: 16),
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
                      color:
                          isSelected
                              ? Colors.blue[600]
                              : isToday
                              ? Colors.blue[100]
                              : Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                      border:
                          isToday && !isSelected
                              ? Border.all(color: Colors.blue[300]!, width: 2)
                              : null,
                    ),
                    child: Center(
                      child: Text(
                        _weekDays[index],
                        style: TextStyle(
                          color:
                              isSelected
                                  ? Colors.white
                                  : isToday
                                  ? Colors.blue[700]
                                  : Colors.grey[600],
                          fontWeight:
                              isSelected || isToday
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
                  Expanded(child: _buildScheduleList()),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showCreateTimetableDialog();
        },
        backgroundColor: Colors.blue[600],
        child: Icon(Icons.add, color: Colors.white),
        tooltip: 'Tạo thời khóa biểu',
      ),
    );
  }

  Widget _buildScheduleList() {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[600]!),
        ),
      );
    }

    if (_timetables.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16),
            Text(
              'Chưa có thời khóa biểu',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Hãy tạo thời khóa biểu đầu tiên!',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => _showCreateTimetableDialog(),
              icon: Icon(Icons.add),
              label: Text('Tạo thời khóa biểu'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[600],
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _timetables.length,
      itemBuilder: (context, index) {
        final timetable = _timetables[index];
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
          child: InkWell(
            onTap: () => _showTimetableOptionsDialog(timetable),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 60,
                    decoration: BoxDecoration(
                      color: _getColorFromTheme(timetable['colorTheme']),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          timetable['title'] ?? 'Không có tiêu đề',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                        SizedBox(height: 4),
                        if (timetable['description'] != null &&
                            timetable['description'].isNotEmpty)
                          Text(
                            timetable['description'],
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.date_range,
                              size: 14,
                              color: Colors.grey[600],
                            ),
                            SizedBox(width: 4),
                            Text(
                              '${_formatDate(timetable['startDate'])} - ${_formatDate(timetable['endDate'])}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.more_vert, color: Colors.grey[400]),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Color _getColorFromTheme(String? colorTheme) {
    switch (colorTheme?.toLowerCase()) {
      case 'blue':
        return Colors.blue;
      case 'green':
        return Colors.green;
      case 'orange':
        return Colors.orange;
      case 'purple':
        return Colors.purple;
      case 'red':
        return Colors.red;
      case 'teal':
        return Colors.teal;
      case 'indigo':
        return Colors.indigo;
      default:
        return Colors.blue;
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return '';
    try {
      DateTime date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  String _getCurrentDateString() {
    DateTime now = DateTime.now();
    List<String> months = [
      'Tháng 1',
      'Tháng 2',
      'Tháng 3',
      'Tháng 4',
      'Tháng 5',
      'Tháng 6',
      'Tháng 7',
      'Tháng 8',
      'Tháng 9',
      'Tháng 10',
      'Tháng 11',
      'Tháng 12',
    ];
    return '${now.day} ${months[now.month - 1]}, ${now.year}';
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
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
      builder:
          (context) => AlertDialog(
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
                  _userName.isNotEmpty ? _userName : 'Người dùng',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  _userEmail.isNotEmpty ? _userEmail : 'user@example.com',
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
                      onPressed: () async {
                        Navigator.pop(context);
                        await _logout();
                      },
                      icon: Icon(Icons.logout, color: Colors.red),
                      label: Text(
                        'Đăng xuất',
                        style: TextStyle(color: Colors.red),
                      ),
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

  Future<void> _logout() async {
    try {
      await AuthManager.logout();
      if (mounted) {
        Navigator.of(
          context,
        ).pushReplacementNamed('/login'); // Navigate back to login
      }
    } catch (e) {
      _showErrorSnackBar('Lỗi khi đăng xuất: $e');
    }
  }

  void _showCreateTimetableDialog() {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    String selectedColor = 'blue';
    DateTime startDate = DateTime.now();
    DateTime endDate = DateTime.now().add(Duration(days: 30));

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setDialogState) => AlertDialog(
                  title: Row(
                    children: [
                      Icon(Icons.add_box, color: Colors.blue[600]),
                      SizedBox(width: 8),
                      Text('Tạo thời khóa biểu mới'),
                    ],
                  ),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: titleController,
                          decoration: InputDecoration(
                            labelText: 'Tiêu đề *',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            prefixIcon: Icon(Icons.title),
                          ),
                        ),
                        SizedBox(height: 16),
                        TextField(
                          controller: descriptionController,
                          decoration: InputDecoration(
                            labelText: 'Mô tả',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            prefixIcon: Icon(Icons.description),
                          ),
                          maxLines: 3,
                        ),
                        SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: selectedColor,
                          decoration: InputDecoration(
                            labelText: 'Màu chủ đề',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            prefixIcon: Icon(Icons.color_lens),
                          ),
                          items: [
                            DropdownMenuItem(
                              value: 'blue',
                              child: Row(
                                children: [
                                  Container(
                                    width: 16,
                                    height: 16,
                                    color: Colors.blue,
                                  ),
                                  SizedBox(width: 8),
                                  Text('Xanh dương'),
                                ],
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'green',
                              child: Row(
                                children: [
                                  Container(
                                    width: 16,
                                    height: 16,
                                    color: Colors.green,
                                  ),
                                  SizedBox(width: 8),
                                  Text('Xanh lá'),
                                ],
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'orange',
                              child: Row(
                                children: [
                                  Container(
                                    width: 16,
                                    height: 16,
                                    color: Colors.orange,
                                  ),
                                  SizedBox(width: 8),
                                  Text('Cam'),
                                ],
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'purple',
                              child: Row(
                                children: [
                                  Container(
                                    width: 16,
                                    height: 16,
                                    color: Colors.purple,
                                  ),
                                  SizedBox(width: 8),
                                  Text('Tím'),
                                ],
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'red',
                              child: Row(
                                children: [
                                  Container(
                                    width: 16,
                                    height: 16,
                                    color: Colors.red,
                                  ),
                                  SizedBox(width: 8),
                                  Text('Đỏ'),
                                ],
                              ),
                            ),
                          ],
                          onChanged: (value) {
                            setDialogState(() {
                              selectedColor = value!;
                            });
                          },
                        ),
                        SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: () async {
                                  final date = await showDatePicker(
                                    context: context,
                                    initialDate: startDate,
                                    firstDate: DateTime(2020),
                                    lastDate: DateTime(2030),
                                  );
                                  if (date != null) {
                                    setDialogState(() {
                                      startDate = date;
                                    });
                                  }
                                },
                                child: InputDecorator(
                                  decoration: InputDecoration(
                                    labelText: 'Ngày bắt đầu',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    prefixIcon: Icon(Icons.calendar_today),
                                  ),
                                  child: Text(
                                    _formatDate(startDate.toIso8601String()),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: InkWell(
                                onTap: () async {
                                  final date = await showDatePicker(
                                    context: context,
                                    initialDate: endDate,
                                    firstDate: startDate,
                                    lastDate: DateTime(2030),
                                  );
                                  if (date != null) {
                                    setDialogState(() {
                                      endDate = date;
                                    });
                                  }
                                },
                                child: InputDecorator(
                                  decoration: InputDecoration(
                                    labelText: 'Ngày kết thúc',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    prefixIcon: Icon(Icons.event),
                                  ),
                                  child: Text(
                                    _formatDate(endDate.toIso8601String()),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Hủy'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        if (titleController.text.trim().isEmpty) {
                          _showErrorSnackBar('Vui lòng nhập tiêu đề');
                          return;
                        }

                        try {
                          await TimetableService.createTimetable(
                            title: titleController.text.trim(),
                            description: descriptionController.text.trim(),
                            colorTheme: selectedColor,
                            startDate: startDate.toIso8601String(),
                            endDate: endDate.toIso8601String(),
                            token: _userToken,
                          );

                          Navigator.pop(context);
                          _showSuccessSnackBar(
                            'Tạo thời khóa biểu thành công!',
                          );
                          _loadTimetables(); // Reload data
                        } catch (e) {
                          _showErrorSnackBar('Lỗi khi tạo thời khóa biểu: $e');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[600],
                        foregroundColor: Colors.white,
                      ),
                      child: Text('Tạo'),
                    ),
                  ],
                ),
          ),
    );
  }

  void _showTimetableOptionsDialog(Map<String, dynamic> timetable) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(timetable['title'] ?? 'Thời khóa biểu'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: Icon(Icons.edit, color: Colors.blue[600]),
                  title: Text('Chỉnh sửa'),
                  onTap: () {
                    Navigator.pop(context);
                    _showEditTimetableDialog(timetable);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.delete, color: Colors.red[600]),
                  title: Text('Xóa'),
                  onTap: () {
                    Navigator.pop(context);
                    _showDeleteConfirmDialog(timetable);
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

  void _showEditTimetableDialog(Map<String, dynamic> timetable) {
    final titleController = TextEditingController(text: timetable['title']);
    final descriptionController = TextEditingController(
      text: timetable['description'],
    );
    String selectedColor = timetable['colorTheme'] ?? 'blue';
    DateTime startDate =
        DateTime.tryParse(timetable['startDate']) ?? DateTime.now();
    DateTime endDate =
        DateTime.tryParse(timetable['endDate']) ??
        DateTime.now().add(Duration(days: 30));

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setDialogState) => AlertDialog(
                  title: Row(
                    children: [
                      Icon(Icons.edit, color: Colors.blue[600]),
                      SizedBox(width: 8),
                      Text('Chỉnh sửa thời khóa biểu'),
                    ],
                  ),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: titleController,
                          decoration: InputDecoration(
                            labelText: 'Tiêu đề *',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            prefixIcon: Icon(Icons.title),
                          ),
                        ),
                        SizedBox(height: 16),
                        TextField(
                          controller: descriptionController,
                          decoration: InputDecoration(
                            labelText: 'Mô tả',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            prefixIcon: Icon(Icons.description),
                          ),
                          maxLines: 3,
                        ),
                        SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: selectedColor,
                          decoration: InputDecoration(
                            labelText: 'Màu chủ đề',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            prefixIcon: Icon(Icons.color_lens),
                          ),
                          items: [
                            DropdownMenuItem(
                              value: 'blue',
                              child: Row(
                                children: [
                                  Container(
                                    width: 16,
                                    height: 16,
                                    color: Colors.blue,
                                  ),
                                  SizedBox(width: 8),
                                  Text('Xanh dương'),
                                ],
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'green',
                              child: Row(
                                children: [
                                  Container(
                                    width: 16,
                                    height: 16,
                                    color: Colors.green,
                                  ),
                                  SizedBox(width: 8),
                                  Text('Xanh lá'),
                                ],
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'orange',
                              child: Row(
                                children: [
                                  Container(
                                    width: 16,
                                    height: 16,
                                    color: Colors.orange,
                                  ),
                                  SizedBox(width: 8),
                                  Text('Cam'),
                                ],
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'purple',
                              child: Row(
                                children: [
                                  Container(
                                    width: 16,
                                    height: 16,
                                    color: Colors.purple,
                                  ),
                                  SizedBox(width: 8),
                                  Text('Tím'),
                                ],
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'red',
                              child: Row(
                                children: [
                                  Container(
                                    width: 16,
                                    height: 16,
                                    color: Colors.red,
                                  ),
                                  SizedBox(width: 8),
                                  Text('Đỏ'),
                                ],
                              ),
                            ),
                          ],
                          onChanged: (value) {
                            setDialogState(() {
                              selectedColor = value!;
                            });
                          },
                        ),
                        SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: () async {
                                  final date = await showDatePicker(
                                    context: context,
                                    initialDate: startDate,
                                    firstDate: DateTime(2020),
                                    lastDate: DateTime(2030),
                                  );
                                  if (date != null) {
                                    setDialogState(() {
                                      startDate = date;
                                    });
                                  }
                                },
                                child: InputDecorator(
                                  decoration: InputDecoration(
                                    labelText: 'Ngày bắt đầu',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    prefixIcon: Icon(Icons.calendar_today),
                                  ),
                                  child: Text(
                                    _formatDate(startDate.toIso8601String()),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: InkWell(
                                onTap: () async {
                                  final date = await showDatePicker(
                                    context: context,
                                    initialDate: endDate,
                                    firstDate: startDate,
                                    lastDate: DateTime(2030),
                                  );
                                  if (date != null) {
                                    setDialogState(() {
                                      endDate = date;
                                    });
                                  }
                                },
                                child: InputDecorator(
                                  decoration: InputDecoration(
                                    labelText: 'Ngày kết thúc',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    prefixIcon: Icon(Icons.event),
                                  ),
                                  child: Text(
                                    _formatDate(endDate.toIso8601String()),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Hủy'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        if (titleController.text.trim().isEmpty) {
                          _showErrorSnackBar('Vui lòng nhập tiêu đề');
                          return;
                        }

                        try {
                          await TimetableService.updateTimetable(
                            id: timetable['_id'],
                            title: titleController.text.trim(),
                            description: descriptionController.text.trim(),
                            colorTheme: selectedColor,
                            startDate: startDate.toIso8601String(),
                            endDate: endDate.toIso8601String(),
                            token: _userToken,
                          );

                          Navigator.pop(context);
                          _showSuccessSnackBar(
                            'Cập nhật thời khóa biểu thành công!',
                          );
                          _loadTimetables(); // Reload data
                        } catch (e) {
                          _showErrorSnackBar(
                            'Lỗi khi cập nhật thời khóa biểu: $e',
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[600],
                        foregroundColor: Colors.white,
                      ),
                      child: Text('Cập nhật'),
                    ),
                  ],
                ),
          ),
    );
  }

  void _showDeleteConfirmDialog(Map<String, dynamic> timetable) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.warning, color: Colors.red[600]),
                SizedBox(width: 8),
                Text('Xác nhận xóa'),
              ],
            ),
            content: Text(
              'Bạn có chắc chắn muốn xóa thời khóa biểu "${timetable['title']}"?\n\nHành động này không thể hoàn tác.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Hủy'),
              ),
              ElevatedButton(
                onPressed: () async {
                  try {
                    await TimetableService.deleteTimetable(
                      timetable['_id'],
                      _userToken,
                    );
                    Navigator.pop(context);
                    _showSuccessSnackBar('Xóa thời khóa biểu thành công!');
                    _loadTimetables(); // Reload data
                  } catch (e) {
                    _showErrorSnackBar('Lỗi khi xóa thời khóa biểu: $e');
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[600],
                  foregroundColor: Colors.white,
                ),
                child: Text('Xóa'),
              ),
            ],
          ),
    );
  }
}
