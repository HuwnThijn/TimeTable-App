import 'package:flutter/material.dart';
import 'package:timetable_fe/services/auth_services.dart';
import 'package:timetable_fe/screens/otp_verification_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final confirmPassCtrl = TextEditingController();
  bool isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    nameCtrl.dispose();
    emailCtrl.dispose();
    passCtrl.dispose();
    confirmPassCtrl.dispose();
    super.dispose();
  }

  bool _validateForm() {
    if (nameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Vui lòng nhập họ tên")));
      return false;
    }

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

    if (passCtrl.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Mật khẩu phải có ít nhất 6 ký tự")),
      );
      return false;
    }

    if (passCtrl.text != confirmPassCtrl.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Mật khẩu xác nhận không khớp")),
      );
      return false;
    }

    return true;
  }

  void register() async {
    if (!_validateForm()) return;

    setState(() {
      isLoading = true;
    });

    try {
      final success = await AuthServices.sendVerificationEmail(emailCtrl.text);

      if (success && context.mounted) {
        setState(() {
          isLoading = false;
        });

        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => OtpVerificationScreen(
                  email: emailCtrl.text,
                  name: nameCtrl.text,
                  password: passCtrl.text,
                ),
          ),
        );
      } else {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Không thể gửi mã xác nhận. Vui lòng thử lại."),
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
        title: const Text("Đăng ký"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            const Icon(Icons.person_add, size: 80, color: Colors.blue),
            const SizedBox(height: 30),
            TextField(
              controller: nameCtrl,
              decoration: InputDecoration(
                labelText: "Họ tên",
                prefixIcon: const Icon(Icons.person),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.blue, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: "Email",
                prefixIcon: const Icon(Icons.email),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.blue, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passCtrl,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: "Mật khẩu",
                prefixIcon: const Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.blue, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: confirmPassCtrl,
              obscureText: _obscureConfirmPassword,
              decoration: InputDecoration(
                labelText: "Xác nhận mật khẩu",
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirmPassword
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    });
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.blue, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: isLoading ? null : register,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child:
                    isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                          "Gửi mã xác nhận",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Mã xác nhận sẽ được gửi đến email của bạn",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
