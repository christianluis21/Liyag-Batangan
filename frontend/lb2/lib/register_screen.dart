
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart' as fmap;
import 'package:latlong2/latlong.dart';
import 'package:lottie/lottie.dart' hide Marker;
import 'login_screen.dart';
import 'package:flutter/gestures.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final otpController = TextEditingController();

  bool isLoading = false;
  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;
  bool isTermsAccepted = false;

  String generatedOtp = '';

  @override
  void initState() {
    super.initState();
    phoneController.text = '+63';
    phoneController.addListener(_phoneListener);
  }

  void _phoneListener() {
    String digitsOnly = phoneController.text.replaceAll(RegExp(r'\D'), '');
    if (digitsOnly.startsWith('6390')) {
      digitsOnly = '639' + digitsOnly.substring(4);
    } else if (digitsOnly.startsWith('0')) {
      digitsOnly = '63' + digitsOnly.substring(1);
    } else if (!digitsOnly.startsWith('63')) {
      digitsOnly = '63' + digitsOnly;
    }

    if (digitsOnly.length > 12) {
      digitsOnly = digitsOnly.substring(0, 12);
    }

    String formatted = '+';
    if (digitsOnly.length >= 2) formatted += digitsOnly.substring(0, 2);
    if (digitsOnly.length > 2) formatted += ' ' + digitsOnly.substring(2, min(5, digitsOnly.length));
    if (digitsOnly.length > 5) formatted += ' ' + digitsOnly.substring(5, min(8, digitsOnly.length));
    if (digitsOnly.length > 8) formatted += ' ' + digitsOnly.substring(8, min(12, digitsOnly.length));

    if (phoneController.text != formatted) {
      phoneController.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }
  }

  Future<void> registerUser() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final phone = phoneController.text.trim();
    final address = addressController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if ([name, email, password, confirmPassword].any((e) => e.isEmpty)) {
      return showLottieDialog('assets/animations/error.json', "Please fill all required fields");
    }

    final emailPattern = RegExp(r'^[a-zA-Z0-9._%+-]+@gmail\.com$');
    if (!emailPattern.hasMatch(email)) {
      return showLottieDialog('assets/animations/error.json', "Please use a valid Gmail address");
    }

    if (name.length < 5) {
      return showLottieDialog('assets/animations/error.json', "Name must be at least 5 characters");
    }

    final phonePattern = RegExp(r'^\+63 \d{3} \d{3} \d{4}$');
    if (!phonePattern.hasMatch(phone)) {
      return showLottieDialog('assets/animations/error.json', "Phone must follow +63 968 123 4567");
    }

    if (password != confirmPassword) {
      return showLottieDialog('assets/animations/error.json', "Passwords do not match");
    }

    final passwordPattern = RegExp(r'^(?=.*[A-Za-z])(?=.*[\d!@#\$&*~]).{5,}$');
    if (!passwordPattern.hasMatch(password)) {
      return showLottieDialog('assets/animations/error.json', "Password must be 5+ chars with 1 letter and 1 number/symbol");
    }

    if (!isTermsAccepted) {
      return showLottieDialog('assets/animations/error.json', "You must accept the Terms and Privacy Policy");
    }

    generatedOtp = (Random().nextInt(899999) + 100000).toString();

    final sendOtpUrl = Uri.parse('http://192.168.137.1/liyag_batangan/send_otp_reg.php');
    final sendResponse = await http.post(sendOtpUrl, body: {
      'email': email,
      'otp': generatedOtp,
    });

    if (sendResponse.statusCode == 200 && sendResponse.body.contains("success")) {
      showOtpDialog(name, email, phone, address, password);
    } else {
      showLottieDialog('assets/animations/error2.json', "Failed to send OTP: ${sendResponse.body}");
    }
  }

  void showOtpDialog(String name, String email, String phone, String address, String password) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text("Enter OTP"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("An OTP has been sent to your Gmail"),
            const SizedBox(height: 12),
            TextField(
              controller: otpController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              style: const TextStyle(color: Colors.black),
              cursorColor: Colors.black,
              decoration: InputDecoration(
                labelText: "OTP Code",
                labelStyle: const TextStyle(color: Colors.grey),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black, width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(8),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                counterText: "",
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Cancel"),
            style: TextButton.styleFrom(foregroundColor: Colors.black),
          ),
          ElevatedButton(
            onPressed: () async {
              final verifyOtpUrl = Uri.parse('http://192.168.137.1/liyag_batangan/verify_otp_reg.php');
              final verifyResponse = await http.post(verifyOtpUrl, body: {
                'email': email,
                'otp': otpController.text.trim(),
              });

              final result = jsonDecode(verifyResponse.body);
              if (result['status'] == 'success') {
                Navigator.of(context).pop();
                await finalizeRegistration(name, email, phone, address, password);
              } else {
                showLottieDialog('assets/animations/error2.json', result['message']);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFD500),
              foregroundColor: Colors.black,
            ),
            child: const Text("Verify"),
          )
        ],
      ),
    );
  }

  Future<void> finalizeRegistration(String name, String email, String phone, String address, String password) async {
    setState(() => isLoading = true);
    final url = Uri.parse('http://192.168.137.1/liyag_batangan/register_users.php');
    try {
      final response = await http.post(url, body: {
        'name': name,
        'email': email,
        'phone': phone,
        'address': address,
        'password': password,
      });

      setState(() => isLoading = false);
      if (response.statusCode == 200 && response.body.contains("success")) {
        clearFields();
        showLottieDialog('assets/animations/success1.json', "Registration successful!");
      } else {
        showLottieDialog('assets/animations/error2.json', "Failed: ${response.body}");
      }
    } catch (e) {
      setState(() => isLoading = false);
      showLottieDialog('assets/animations/error2.json', "Error: $e");
    }
  }

  void clearFields() {
    nameController.clear();
    emailController.clear();
    phoneController.text = '+63';
    addressController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
  }

  void showLottieDialog(String assetPath, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 120, width: 120, child: Lottie.asset(assetPath, repeat: true)),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (assetPath.contains('success')) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFD500),
                foregroundColor: Colors.black,
              ),
              child: const Text('OK'),
            )
          ],
        ),
      ),
    );
  }

  void showTermsDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Terms and Conditions"),
        content: const SingleChildScrollView(
          child: Text.rich(
            TextSpan(
              style: TextStyle(color: Colors.black, fontSize: 14, height: 1.5),
              children: [
                TextSpan(
                  text: "Welcome to LIYAG BATANGAN. Please read these Terms and Conditions carefully before registering or using our services.\n\n",
                ),
                TextSpan(
                  text: "1. Acceptance of Terms\n",
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),
                ),
                TextSpan(
                  text:
                      "By creating an account or using our platform, you agree to be bound by these Terms and Conditions, as well as our Privacy Policy.\n\n",
                ),
                TextSpan(
                  text: "2. User Responsibilities\n",
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),
                ),
                TextSpan(
                  text:
                      "- You agree to provide accurate, current, and complete personal information during registration.\n"
                      "- You are solely responsible for maintaining the confidentiality of your account credentials.\n"
                      "- You agree not to use the app for any unlawful, harmful, or fraudulent purposes.\n\n",
                ),
                TextSpan(
                  text: "3. Prohibited Activities\n",
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),
                ),
                TextSpan(
                  text:
                      "- Impersonation of any person or entity.\n"
                      "- Unauthorized use or access of data belonging to other users.\n"
                      "- Attempting to interfere with or compromise the integrity of our systems.\n\n",
                ),
                TextSpan(
                  text: "4. Content and Intellectual Property\n",
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),
                ),
                TextSpan(
                  text:
                      "All content, branding, and logos on the LIYAG BATANGAN platform are the intellectual property of LIYAG BATANGAN or its partners. "
                      "You may not copy, distribute, or modify any part of the service without prior written consent.\n\n",
                ),
                TextSpan(
                  text: "5. Termination\n",
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),
                ),
                TextSpan(
                  text:
                      "We reserve the right to suspend or terminate your account at our sole discretion if you violate any of these Terms.\n\n",
                ),
                TextSpan(
                  text: "6. Modifications\n",
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),
                ),
                TextSpan(
                  text:
                      "LIYAG BATANGAN reserves the right to update or modify these Terms at any time. Continued use of the app after changes are made constitutes your acceptance of the new terms.\n\n",
                ),
                TextSpan(
                  text: "7. Limitation of Liability\n",
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),
                ),
                TextSpan(
                  text:
                      "We are not liable for any direct or indirect damages arising from your use of the app, including but not limited to loss of data or service interruption.\n\n",
                ),
                TextSpan(
                  text: "8. Governing Law\n",
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),
                ),
                TextSpan(
                  text:
                      "These Terms are governed by and construed in accordance with the laws of the Republic of the Philippines.\n\n"
                      "By using LIYAG BATANGAN, you acknowledge that you have read, understood, and agreed to these Terms and Conditions.",
                ),
              ],
            ),
          ),
        ),

        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Close"),
            style: TextButton.styleFrom(foregroundColor: Colors.black,)
          ),
        ],
      ),
    );
  }

  void showPrivacyDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Privacy Policy"),
        content: const SingleChildScrollView(
           child: Text.rich(
            TextSpan(
              style: TextStyle(color: Colors.black, fontSize: 14, height: 1.5),
              children: [
                TextSpan(
                  text:
                      "LIYAG BATANGAN is committed to protecting your privacy. This Privacy Policy outlines how we collect, use, disclose, and safeguard your personal data when you use our app and services.\n\n",
                ),
                TextSpan(
                  text: "1. Information We Collect\n",
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),
                ),
                TextSpan(
                  text:
                      "- Personal Information: Includes your full name, email address, phone number, physical address, and other registration data.\n"
                      "- Device Information: We may collect information about your device, such as device ID, operating system, browser type, and IP address.\n"
                      "- Location Data: With your permission, we may access your location to enhance service accuracy.\n\n",
                ),
                TextSpan(
                  text: "2. How We Use Your Information\n",
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),
                ),
                TextSpan(
                  text:
                      "- To create and manage your user account.\n"
                      "- To communicate with you, including sending updates, OTPs, or notifications.\n"
                      "- To provide customer support and resolve issues.\n"
                      "- To improve our platform by analyzing user behavior and preferences.\n\n",
                ),
                TextSpan(
                  text: "3. Sharing and Disclosure\n",
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),
                ),
                TextSpan(
                  text:
                      "- We do not sell or rent your personal information.\n"
                      "- We may share data with trusted service providers (e.g., OTP email service, hosting provider) only as necessary.\n"
                      "- Your data may be disclosed when required by law or for legal investigations.\n\n",
                ),
                TextSpan(
                  text: "4. Data Security\n",
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),
                ),
                TextSpan(
                  text:
                      "- We use reasonable technical and administrative measures to safeguard your data.\n"
                      "- Despite our efforts, no online system is ever completely secure. Use the app at your own risk.\n\n",
                ),
                TextSpan(
                  text: "5. User Rights and Access\n",
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),
                ),
                TextSpan(
                  text:
                      "- You have the right to access, correct, or delete your personal information.\n"
                      "- You can request a copy of your data or ask us to delete your account.\n"
                      "- To make such requests, contact our support team.\n\n",
                ),
                TextSpan(
                  text: "6. Cookies and Analytics\n",
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),
                ),
                TextSpan(
                  text:
                      "- We may use cookies and analytics tools to understand app usage and improve performance.\n"
                      "- These tools collect aggregated, non-identifiable data.\n\n",
                ),
                TextSpan(
                  text: "7. Children's Privacy\n",
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),
                ),
                TextSpan(
                  text:
                      "- The app is not intended for children under the age of 13.\n"
                      "- We do not knowingly collect personal information from minors. If you believe we have, please notify us immediately.\n\n",
                ),
                TextSpan(
                  text: "8. Changes to This Policy\n",
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),
                ),
                TextSpan(
                  text:
                      "- We may update this Privacy Policy from time to time. Changes will be posted within the app.\n"
                      "- Continued use of the app after any modifications implies your acceptance of the updated policy.\n\n"
                      "By using LIYAG BATANGAN, you consent to the practices described in this Privacy Policy.",
                ),
              ],
            ),
          ),
        ),
          actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Close"),
            style: TextButton.styleFrom(foregroundColor: Colors.black,)
          ),
        ],
      ),
    );
  }

      Future<void> openMapModal() async {
        if (!await Geolocator.isLocationServiceEnabled()) {
          return showLottieDialog('assets/animations/error.json', 'Location services are disabled.');
        }

        var permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
          if (permission == LocationPermission.denied) {
            return showLottieDialog('assets/animations/error.json', 'Location permission denied.');
          }
        }
        if (permission == LocationPermission.deniedForever) {
          return showLottieDialog('assets/animations/error.json', 'Location permission permanently denied.');
        }

        final Position pos = await Geolocator.getCurrentPosition();
        LatLng selectedLatLng = LatLng(pos.latitude, pos.longitude);
        final mapController = fmap.MapController();

        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          builder: (context) {
            return StatefulBuilder(builder: (ctx, setSB) {
              return SizedBox(
                height: MediaQuery.of(ctx).size.height * 0.75,
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    const Text("Select Your Location", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Expanded(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          fmap.FlutterMap(
                            mapController: mapController,
                            options: fmap.MapOptions(
                              initialCenter: selectedLatLng,
                              initialZoom: 16,
                              onPositionChanged: (position, hasGesture) {
                                if (hasGesture && position.center != null) {
                                  setSB(() {
                                    selectedLatLng = position.center!;
                                  });
                                }
                              },
                              interactionOptions: const fmap.InteractionOptions(
                                flags: fmap.InteractiveFlag.all & ~fmap.InteractiveFlag.rotate, // Disable rotation only
                              ),
                            ),
                            children: [
                              fmap.TileLayer(
                                urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png", // ✅ no `{s}` subdomain
                                userAgentPackageName: 'com.liyag.batangan',
                                additionalOptions: const {
                                  'User-Agent': 'liyag-batangan-app/1.0 (liyagbatangan@gmail.com)',
                                },
                              ),
                            ],
                          ),
                          const Icon(Icons.location_on, color: Colors.orange, size: 40),
                        ],
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () async {
                        final address = await reverseGeocode(selectedLatLng);
                        setState(() {
                          addressController.text = address;
                        });
                        Navigator.pop(ctx);
                      },
                      icon: const Icon(Icons.check),
                      label: const Text("Set Location"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFD500),
                        foregroundColor: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              );
            });
          },
        );
      }

      Future<String> reverseGeocode(LatLng loc) async {
        final url = Uri.parse(
          'https://nominatim.openstreetmap.org/reverse?format=json&lat=${loc.latitude}&lon=${loc.longitude}&addressdetails=1',
        );
        final resp = await http.get(url, headers: {'User-Agent': 'FlutterApp'});
        if (resp.statusCode == 200) {
          final data = jsonDecode(resp.body);
          return data['display_name'] ?? '${loc.latitude}, ${loc.longitude}';
        }
        return '${loc.latitude}, ${loc.longitude}';
      }

       @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('LIYAG BATANGAN',
                style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w900),
              ),
               const SizedBox(height: 6),
                Center(
                  child: Text(
                    'Join Liyag Batangan and explore the best local products Batangas has to offer',
                    style: GoogleFonts.poppins(fontSize: 12, color: Colors.black54),
                    textAlign: TextAlign.center,
                  ),
                ),
              const SizedBox(height: 30),
              buildInputField(controller: nameController, label: 'Full Name', icon: Icons.person_outline),
              buildInputField(controller: emailController, label: 'Email Address', icon: Icons.email_outlined),
              buildInputField(controller: phoneController, label: 'Phone Number', icon: Icons.phone_outlined, keyboardType: TextInputType.phone),
              buildInputField(controller: addressController, label: 'Address', icon: Icons.home_outlined, readOnly: true, onTap: openMapModal),
              buildInputField(controller: passwordController, label: 'Password', icon: Icons.lock_outline, isPassword: true),
              buildInputField(controller: confirmPasswordController, label: 'Confirm Password', icon: Icons.lock_outline, isPassword: true, isConfirmPassword: true),

              Row(
  crossAxisAlignment: CrossAxisAlignment.center,
  children: [
    Theme(
      data: Theme.of(context).copyWith(
        unselectedWidgetColor: Colors.orange, // Checkbox border when unchecked
      ),
      child: Checkbox(
        value: isTermsAccepted,
        activeColor: Colors.orange, // Color when checked
        checkColor: Colors.white,
        onChanged: (value) => setState(() => isTermsAccepted = value ?? false),
      ),
    ),
    Expanded(
      child: RichText(
        text: TextSpan(
          style: const TextStyle(color: Colors.black, fontSize: 14),
          children: [
            const TextSpan(text: "I agree to the "),
            TextSpan(
              text: "Terms and Conditions",
              style: const TextStyle(
                color: Colors.orange,
                decoration: TextDecoration.underline,
              ),
              recognizer: TapGestureRecognizer()..onTap = showTermsDialog,
            ),
            const TextSpan(text: " and "),
            TextSpan(
              text: "Privacy Policy",
              style: const TextStyle(
                color: Colors.orange,
                decoration: TextDecoration.underline,
              ),
              recognizer: TapGestureRecognizer()..onTap = showPrivacyDialog,
            ),
          ],
        ),
      ),
    ),
  ],
),

              const SizedBox(height: 8),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: isLoading ? null : registerUser,
                  icon: const Icon(Icons.person_add_alt),
                  label: isLoading
                      ? const CircularProgressIndicator(color: Colors.black)
                      : const Text('Create Account', style: TextStyle(fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFD500),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),

              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Already have an account?"),
                  TextButton(
                    onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen())),
                    style: TextButton.styleFrom(foregroundColor: Colors.orange),
                    child: Text("Login", style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    bool isConfirmPassword = false,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        obscureText: isPassword ? (isConfirmPassword ? !isConfirmPasswordVisible : !isPasswordVisible) : false,
        maxLines: maxLines,
        keyboardType: keyboardType,
        readOnly: readOnly,
        onTap: onTap,
        decoration: InputDecoration(
          prefixIcon: Icon(icon),
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon((isConfirmPassword ? isConfirmPasswordVisible : isPasswordVisible) ? Icons.visibility : Icons.visibility_off),
                  onPressed: () {
                    setState(() {
                      if (isConfirmPassword) {
                        isConfirmPasswordVisible = !isConfirmPasswordVisible;
                      } else {
                        isPasswordVisible = !isPasswordVisible;
                      }
                    });
                  },
                )
              : null,
        ),
      ),
    );
  }
}