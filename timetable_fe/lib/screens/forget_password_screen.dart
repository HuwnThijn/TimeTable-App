import 'package:flutter/material.dart';
import 'package:timetable_fe/services/auth_services.dart';

class ForgetPasswordScreen extends StatefulWidget {
  const ForgetPasswordScreen({super.key});

  @override
  State<ForgetPasswordScreen> createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  final emailCtrl = TextEditingController();
  bool isLoading = false;

  @override
  void dispose() {
    emailCtrl.dispose();
    super.dispose();
  }

  bool _validateEmail() {
    if (emailCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Vui lòng nhập email")));
      return false;
    }

    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(emailCtrl.text)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Email không hợp lệ")));
      return false;
    }

    return true;
  }

  void _sendResetEmail() async {
    if (!_validateEmail()) return;

    setState(() {
      isLoading = true;
    });

    try {
      final success = await AuthServices.forgetPassword(emailCtrl.text);

      if (success && context.mounted) {
        setState(() {
          isLoading = false;
        });

        // Show success dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder:
              (context) => AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                icon: Icon(Icons.check_circle, color: Colors.green, size: 50),
                title: Text(
                  'Thành công!',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green[700],
                  ),
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Mật khẩu mới đã được gửi đến email ${emailCtrl.text}',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Vui lòng kiểm tra email và đăng nhập bằng mật khẩu mới (6 chữ số).',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close dialog
                      Navigator.of(context).pop(); // Back to login
                    },
                    child: Text(
                      'Đăng nhập ngay',
                      style: TextStyle(
                        color: Colors.blue[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
        );
      } else {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Không thể gửi email. Vui lòng thử lại."),
          ),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Có lỗi xảy ra, vui lòng thử lại")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Quên mật khẩu"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 40),
            const Icon(Icons.lock_reset, size: 100, color: Colors.blue),
            const SizedBox(height: 30),
            Text(
              'Quên mật khẩu?',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Đừng lo lắng! Chúng tôi sẽ tạo mật khẩu mới và gửi đến email của bạn.',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            TextField(
              controller: emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: "Email",
                hintText: "Nhập email của bạn",
                prefixIcon: const Icon(Icons.email),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.blue, width: 2),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: isLoading ? null : _sendResetEmail,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child:
                    isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                          "Tạo mật khẩu mới",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
              ),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                "Quay lại đăng nhập",
                style: TextStyle(color: Colors.blue),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
