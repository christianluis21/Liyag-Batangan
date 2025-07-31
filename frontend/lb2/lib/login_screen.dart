import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
// import 'package:lb2/forgot_password_sms_screen.dart'; // This import is not used in the provided code.
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'home_screen.dart';
import 'register_screen.dart';
import 'forgot_password_gmail_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isPasswordVisible = false;
  bool rememberMe = false;
  DateTime? _lastBackPressTime;

  @override
  void initState() {
    super.initState();
    loadSavedCredentials();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> loadSavedCredentials() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('saved_email') ?? '';
    final savedPassword = prefs.getString('saved_password') ?? '';
    final savedRemember = prefs.getBool('remember_me') ?? false;

    if (savedRemember) {
      emailController.text = savedEmail;
      passwordController.text = savedPassword;
      setState(() {
        rememberMe = true;
      });
    }
  }

  void showForgotPasswordOptions() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Forgot Password'),
        content: const Text('Choose how you want to reset your password.'),
        actions: [
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => const ForgotPasswordGmail(),
                    ));
                  },
                  icon: const Icon(Icons.email_outlined, color: Colors.orange),
                  label: const Text('Reset via Email'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.black,
                  ),
                ),
                // Removed the SMS option as it's not present in the provided imports/screens.
                // TextButton.icon(
                //   onPressed: () {
                //     Navigator.of(context).pop();
                //     Navigator.of(context).push(MaterialPageRoute(
                //       builder: (_) => const ForgotPasswordSmsScreen(),
                //     ));
                //   },
                //   icon: const Icon(Icons.sms_outlined, color: Colors.orange),
                //   label: const Text('Reset via SMS'),
                //   style: TextButton.styleFrom(
                //     foregroundColor: Colors.black,
                //   ),
                // ),
              ],
            ),
          )
        ],
      ),
    );
  }

  void showLottieErrorDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 150, // Smaller height for error animation
              width: 150, // Smaller width for error animation
              child: Lottie.asset('assets/animations/error2.json', repeat: true),
            ),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center, style: GoogleFonts.poppins()),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFD500),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text('OK', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
            )
          ],
        ),
      ),
    );
  }

  void showLottieSuccessDialog(String message, {VoidCallback? onDismiss}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 150, // Smaller height for success animation
              width: 150, // Smaller width for success animation
              child: Lottie.asset('assets/animations/success1.json', repeat: true), // Assuming you have a success.json
            ),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center, style: GoogleFonts.poppins()),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                onDismiss?.call();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFD500),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text('OK', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
            )
          ],
        ),
      ),
    );
  }


  void showLottieLoading() {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.3),
      builder: (_) => Center(
        child: Container(
          width: 140,
          height: 140,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [BoxShadow(blurRadius: 10, color: Colors.black26)],
          ),
          child: Lottie.asset('assets/animations/loading.json', repeat: true), // Repeat loading animation
        ),
      ),
    );
  }

  void hideLottieLoading() {
    Navigator.of(context, rootNavigator: true).pop();
  }

  Future<void> loginUser() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      showLottieErrorDialog("Please enter both email and password.");
      return;
    }

    if (!email.endsWith('@gmail.com')) {
      showLottieErrorDialog("Please enter a valid Gmail address (e.g., example@gmail.com).");
      return;
    }

    if (password.length < 4) {
      showLottieErrorDialog("Password must be at least 4 characters long.");
      return;
    }

    showLottieLoading();

    final url = Uri.parse('http://192.168.137.1/liyag_batangan/login_users.php');
    try {
      final response = await http.post(url, body: {
        'email': email,
        'password': password,
      });

      hideLottieLoading();

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          final SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('email', data['user']['email']);

          if (rememberMe) {
            await prefs.setString('saved_email', email);
            await prefs.setString('saved_password', password);
            await prefs.setBool('remember_me', true);
          } else {
            await prefs.remove('saved_email');
            await prefs.remove('saved_password');
            await prefs.setBool('remember_me', false);
          }

          showLottieSuccessDialog("Login Successful!", onDismiss: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => HomeScreen(user: data['user'])),
            );
          });
        } else {
          showLottieErrorDialog(data['message']);
        }
      } else {
        showLottieErrorDialog("Server error: ${response.statusCode}. Please try again later.");
      }
    } catch (e) {
      hideLottieLoading();
      showLottieErrorDialog("Connection failed: $e. Please check your internet connection.");
    }
  }

  Future<bool> _onWillPop() async {
    final now = DateTime.now();
    if (_lastBackPressTime == null ||
        now.difference(_lastBackPressTime!) > const Duration(seconds: 2)) {
      _lastBackPressTime = now;

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Exit App", style: TextStyle(fontWeight: FontWeight.bold)),
          content: const Text("Do you want to exit the app?"),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("Cancel"),
              style: TextButton.styleFrom(
                foregroundColor: Colors.black,
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFD500),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                SystemNavigator.pop();
              },
              child: const Text("Exit"),
            ),
          ],
        ),
      );

      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final yellow = const Color(0xFFFFD500);

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                Center(
                  child: Text(
                    'LIYAG BATANGAN',
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Center(
                  child: Text(
                    'Sign in to your account to continue shopping',
                    style: GoogleFonts.poppins(fontSize: 12, color: Colors.black54),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 32),
                Text('Email Address',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 13)),
                const SizedBox(height: 6),
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: 'Enter your email',
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                  ),
                ),
                const SizedBox(height: 16),
                Text('Password',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 13)),
                const SizedBox(height: 6),
                TextField(
                  controller: passwordController,
                  obscureText: !isPasswordVisible,
                  decoration: InputDecoration(
                    hintText: 'Enter your password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        isPasswordVisible
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () {
                        setState(() {
                          isPasswordVisible = !isPasswordVisible;
                        });
                      },
                    ),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Checkbox(
                          value: rememberMe,
                          onChanged: (value) {
                            setState(() {
                              rememberMe = value ?? false;
                            });
                          },
                          activeColor: Colors.orange,
                        ),
                        Text('Remember me', style: GoogleFonts.poppins(fontSize: 12)),
                      ],
                    ),
                    GestureDetector(
                      onTap: showForgotPasswordOptions,
                      child: Text(
                        'Forgot password?',
                        style: GoogleFonts.poppins(color: Colors.orange, fontSize: 12),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: loginUser,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: yellow,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Sign In',
                            style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Center(
                  child: Text.rich(
                    TextSpan(
                      text: "Don't have an account? ",
                      style: GoogleFonts.poppins(),
                      children: [
                        TextSpan(
                          text: "Sign up here",
                          style: GoogleFonts.poppins(color: Colors.orange),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const RegisterScreen()),
                              );
                            },
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}