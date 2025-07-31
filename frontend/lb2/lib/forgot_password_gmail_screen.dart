import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:lottie/lottie.dart';

class ForgotPasswordGmail extends StatefulWidget {
  const ForgotPasswordGmail({super.key});

  @override
  State<ForgotPasswordGmail> createState() => _ForgotPasswordGmailState();
}

class _ForgotPasswordGmailState extends State<ForgotPasswordGmail> {
  final emailController = TextEditingController();
  final otpController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool otpSent = false;
  bool otpVerified = false;
  bool isLoading = false;
  bool showPassword = false;
  bool showConfirmPassword = false;

  void showLottieDialog({required bool success, required String message}) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.asset(
              success ? 'assets/animations/success1.json' : 'assets/animations/error2.json',
              width: 120,
              height: 120,
            ),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> sendOtp() async {
    final email = emailController.text.trim();
    if (email.isEmpty) {
      showLottieDialog(success: false, message: "Please enter your email");
      return;
    }

    setState(() => isLoading = true);
    final response = await http.post(
      Uri.parse("http://192.168.137.1/liyag_batangan/send_otp_email.php"),
      body: {'email': email},
    );
    final data = json.decode(response.body);
    setState(() => isLoading = false);

    if (data['status'] == 'success') {
      setState(() => otpSent = true);
      showLottieDialog(success: true, message: "OTP sent to your email.");
    } else {
      showLottieDialog(success: false, message: data['message']);
    }
  }

  Future<void> verifyOtp() async {
    final email = emailController.text.trim();
    final otp = otpController.text.trim();

    if (otp.isEmpty) {
      showLottieDialog(success: false, message: "Please enter the OTP");
      return;
    }

    setState(() => isLoading = true);
    final response = await http.post(
      Uri.parse("http://192.168.137.1/liyag_batangan/verify_otp.php"),
      body: {'email': email, 'otp': otp},
    );
    final result = json.decode(response.body);
    setState(() => isLoading = false);

    if (result['status'] == 'success') {
      setState(() => otpVerified = true);
      showLottieDialog(success: true, message: "OTP verified. You may now reset your password.");
    } else {
      showLottieDialog(success: false, message: result['message']);
    }
  }

  Future<void> resetPassword() async {
    final email = emailController.text.trim();
    final newPassword = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();
    final passwordRegex = RegExp(r'^(?=.*[a-zA-Z])(?=.*[0-9!@#\$%^&*]).{4,}$');

    if (newPassword.isEmpty || confirmPassword.isEmpty) {
      showLottieDialog(success: false, message: "Please fill out both password fields.");
      return;
    }

    if (newPassword != confirmPassword) {
      showLottieDialog(success: false, message: "Passwords do not match.");
      return;
    }

    if (!passwordRegex.hasMatch(newPassword)) {
      showLottieDialog(
        success: false,
        message: "Password must be at least 4 characters long and include a number or special character.",
      );
      return;
    }

    setState(() => isLoading = true);
    final response = await http.post(
      Uri.parse("http://192.168.137.1/liyag_batangan/reset_password_email.php"),
      body: {
        'email': email,
        'new_password': newPassword,
      },
    );

    final result = json.decode(response.body);
    setState(() => isLoading = false);

    if (result['status'] == 'success') {
      showLottieDialog(success: true, message: "Password reset successfully.");
      await Future.delayed(const Duration(seconds: 2));
      Navigator.of(context).pop();
    } else {
      showLottieDialog(success: false, message: result['message']);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Reset Password via Email"),
        backgroundColor: const Color(0xFFFFD500),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: ListView(
          children: [
            if (!otpSent) ...[
              Text("Enter your email", style: GoogleFonts.poppins(fontSize: 16)),
              const SizedBox(height: 10),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.email),
                  hintText: "e.g. user@example.com",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: isLoading ? null : sendOtp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFD500),
                  foregroundColor: Colors.black,
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.black)
                    : const Text("Send OTP"),
              ),
            ],
            if (otpSent && !otpVerified) ...[
              const SizedBox(height: 20),
              Text("Enter the OTP sent to your email", style: GoogleFonts.poppins(fontSize: 16)),
              const SizedBox(height: 10),
              TextField(
                controller: otpController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.lock),
                  hintText: "6-digit OTP",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: isLoading ? null : verifyOtp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Verify OTP"),
              ),
            ],
            if (otpVerified) ...[
              const SizedBox(height: 20),
              Text("Enter New Password", style: GoogleFonts.poppins(fontSize: 16)),
              const SizedBox(height: 10),
              TextField(
                controller: passwordController,
                obscureText: !showPassword,
                keyboardType: TextInputType.visiblePassword,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.lock_outline),
                  hintText: "New Password",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  suffixIcon: IconButton(
                    icon: Icon(showPassword ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => showPassword = !showPassword),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: confirmPasswordController,
                obscureText: !showConfirmPassword,
                keyboardType: TextInputType.visiblePassword,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.lock),
                  hintText: "Confirm New Password",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  suffixIcon: IconButton(
                    icon: Icon(showConfirmPassword ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => showConfirmPassword = !showConfirmPassword),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: isLoading ? null : resetPassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFD500),
                  foregroundColor: Colors.black,
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.black)
                    : const Text("Reset Password"),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
