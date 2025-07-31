import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ForgotPasswordSMS extends StatefulWidget {
  const ForgotPasswordSMS({super.key});

  @override
  State<ForgotPasswordSMS> createState() => _ForgotPasswordSMSState();
}

class _ForgotPasswordSMSState extends State<ForgotPasswordSMS> {
  final phoneController = TextEditingController();
  final otpController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool otpSent = false;
  bool showPasswordFields = false;

  void showMessage(String message, {bool error = true}) {
    final color = error ? Colors.red : Colors.green;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  Future<void> sendOtp() async {
    final phone = phoneController.text.trim();
    if (phone.isEmpty) {
      showMessage("Please enter your phone number.");
      return;
    }

    final url = Uri.parse('http://192.168.137.1/liyag_batangan/send_otp.php');
    final response = await http.post(url, body: {'phone': phone});

    final data = json.decode(response.body);
    if (data['status'] == 'success') {
      setState(() {
        otpSent = true;
      });
      showMessage("OTP sent successfully!", error: false);
    } else {
      showMessage(data['message']);
    }
  }

  Future<void> verifyOtp() async {
    final phone = phoneController.text.trim();
    final otp = otpController.text.trim();

    if (otp.isEmpty) {
      showMessage("Please enter the OTP.");
      return;
    }

    final url = Uri.parse('http://192.168.137.1/liyag_batangan/verify_otp.php');
    final response = await http.post(url, body: {
      'phone': phone,
      'otp': otp,
    });

    final data = json.decode(response.body);
    if (data['status'] == 'success') {
      setState(() {
        showPasswordFields = true;
      });
      showMessage("OTP verified!", error: false);
    } else {
      showMessage(data['message']);
    }
  }

  Future<void> updatePassword() async {
    final phone = phoneController.text.trim();
    final newPassword = newPasswordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (newPassword != confirmPassword) {
      showMessage("Passwords do not match.");
      return;
    }

    final url = Uri.parse('http://192.168.137.1/liyag_batangan/update_password.php');
    final response = await http.post(url, body: {
      'phone': phone,
      'new_password': newPassword,
    });

    final data = json.decode(response.body);
    if (data['status'] == 'success') {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Success'),
          content: const Text('Your password has been updated.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } else {
      showMessage(data['message']);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Reset via SMS"), backgroundColor: Colors.orange),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: "Phone Number"),
            ),
            const SizedBox(height: 16),
            if (!otpSent)
              ElevatedButton(
                onPressed: sendOtp,
                child: const Text("Send OTP"),
              ),
            if (otpSent && !showPasswordFields) ...[
              TextField(
                controller: otpController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Enter OTP"),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: verifyOtp,
                child: const Text("Verify OTP"),
              ),
            ],
            if (showPasswordFields) ...[
              TextField(
                controller: newPasswordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: "New Password"),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: "Confirm Password"),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: updatePassword,
                child: const Text("Update Password"),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
