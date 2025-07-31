import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart' as fmap;
import 'package:latlong2/latlong.dart';

import 'login_screen.dart';

class AccountManagementScreen extends StatefulWidget {
  final Map<String, dynamic> user;

  const AccountManagementScreen({super.key, required this.user});

  @override
  State<AccountManagementScreen> createState() => _AccountManagementScreenState();
}

class _AccountManagementScreenState extends State<AccountManagementScreen> {
  // Text editing controllers for user profile fields
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController addressController;

  // State flags for UI control
  bool isEditing = false;
  bool isLoading = false;
  File? profileImage; // Stores the selected profile image file
  int refreshTimestamp = DateTime.now().millisecondsSinceEpoch; // Forces image refresh

  // Regex for Philippine phone number validation
  final RegExp phonePattern = RegExp(r'^\+63 \d{3} \d{3} \d{4}$');

  @override
  void initState() {
    super.initState();
    // Initialize controllers with current user data
    nameController = TextEditingController(text: widget.user['name']);
    emailController = TextEditingController(text: widget.user['email']);
    phoneController = TextEditingController(text: widget.user['phone_number']);
    addressController = TextEditingController(text: widget.user['address']);

    // Add listener for phone number formatting
    phoneController.addListener(_phoneListener);
  }

  @override
  void dispose() {
    // Dispose controllers to prevent memory leaks
    nameController.dispose();
    emailController.dispose();
    phoneController.removeListener(_phoneListener);
    phoneController.dispose();
    addressController.dispose();
    super.dispose();
  }

  // Formats phone number as user types
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

  // Allows user to pick an image from gallery
  Future<void> pickImageFromGallery() async {
    final picker = ImagePicker();
    try {
      final XFile? picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
      if (picked != null) {
        setState(() => profileImage = File(picked.path));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error picking image: $e")));
      }
    }
  }

  // Saves updated profile information to the server
  Future<void> saveProfile() async {
    if (!phonePattern.hasMatch(phoneController.text)) {
      return showLottieDialog("Phone must follow +63 968 123 4567", 'assets/animations/error.json');
    }

    setState(() => isLoading = true);

    final uri = Uri.parse('http://192.168.137.1/liyag_batangan/update_profile.php');
    final req = http.MultipartRequest('POST', uri)
      ..fields['user_id'] = widget.user['user_id'].toString()
      ..fields['name'] = nameController.text.trim()
      ..fields['email'] = emailController.text.trim()
      ..fields['phone_number'] = phoneController.text.trim()
      ..fields['address'] = addressController.text.trim();

    if (profileImage != null) {
      req.files.add(await http.MultipartFile.fromPath('profile_pic', profileImage!.path));
    }

    final resp = await req.send();
    final body = await resp.stream.bytesToString();

    setState(() => isLoading = false);

    try {
      final data = json.decode(body);
      if (data['status'] == 'success') {
        setState(() {
          isEditing = false;
          profileImage = null;
          widget.user['name'] = nameController.text.trim();
          widget.user['email'] = emailController.text.trim();
          widget.user['phone_number'] = phoneController.text.trim();
          widget.user['address'] = addressController.text.trim();
          if (data['profile_picture'] != null) {
            widget.user['profile_picture'] = data['profile_picture'];
          }
          refreshTimestamp = DateTime.now().millisecondsSinceEpoch;
        });

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => Dialog(
            backgroundColor: Colors.transparent,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Lottie.asset(
                  'assets/animations/success1.json',
                  repeat: false,
                  width: 150,
                  height: 150,
                  onLoaded: (composition) async {
                    await Future.delayed(composition.duration + const Duration(seconds: 1));
                    if (mounted) {
                      Navigator.pop(context);
                      Navigator.pop(context, widget.user);
                    }
                  },
                ),
                const SizedBox(height: 12),
                const Text(
                  "Profile updated successfully!",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        );
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to update: ${data['message']}")));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to parse response: $e")));
      }
    }
  }

  // Cancels editing and reverts changes
  void cancelEdit() {
    setState(() {
      isEditing = false;
      profileImage = null;
      nameController.text = widget.user['name'];
      emailController.text = widget.user['email'];
      phoneController.text = widget.user['phone_number'];
      addressController.text = widget.user['address'];
    });
  }

  // Opens a map modal to select address
  Future<void> openMapModal() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      return showLottieDialog('Location services are disabled.', 'assets/animations/error.json');
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return showLottieDialog('Location permission denied.', 'assets/animations/error.json');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return showLottieDialog('Location permission permanently denied.', 'assets/animations/error.json');
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
                const Text(
                  "Select Your Location",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
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
                              setSB(() => selectedLatLng = position.center!);
                            }
                          },
                          interactionOptions: const fmap.InteractionOptions(
                            flags: fmap.InteractiveFlag.all & ~fmap.InteractiveFlag.rotate,
                          ),
                        ),
                        children: [
                          fmap.TileLayer(
                            urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
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
                    setState(() => addressController.text = address);
                    if (mounted) {
                      Navigator.pop(ctx);
                    }
                  },
                  icon: const Icon(Icons.check),
                  label: const Text("Use Location"),
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

  // Converts coordinates to a human-readable address
  Future<String> reverseGeocode(LatLng loc) async {
    final url = Uri.parse(
      'https://nominatim.openstreetmap.org/reverse?format=json&lat=${loc.latitude}&lon=${loc.longitude}&addressdetails=1',
    );
    try {
      final resp = await http.get(url, headers: {'User-Agent': 'FlutterApp'});
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        return data['display_name'] ?? '${loc.latitude}, ${loc.longitude}';
      } else {
        print('Nominatim API error: ${resp.statusCode} - ${resp.body}');
      }
    } catch (e) {
      print('Error during reverse geocoding: $e');
    }
    return '${loc.latitude}, ${loc.longitude}';
  }

  // Shows a Lottie animation dialog with a message
  void showLottieDialog(String message, String lottieAssetPath) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.asset(lottieAssetPath, width: 100, height: 100, repeat: false),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16)),
          ],
        ),
        actions: [
          TextButton(
            child: const Text('OK'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color yellow = const Color(0xFFFFD500);
    final String? imageUrl = widget.user['profile_picture'];

    // Determine which image to display for the avatar
    final ImageProvider avatar = profileImage != null
        ? FileImage(profileImage!)
        : (imageUrl != null && imageUrl.isNotEmpty
            ? NetworkImage('http://192.168.137.1/liyag_batangan/uploads/$imageUrl?ts=$refreshTimestamp')
            : const AssetImage('assets/profile1.jpg')) as ImageProvider;

    return Scaffold(
      backgroundColor: const Color(0xFFFDFDFD),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: yellow,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'LIYAG BATANGAN',
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: Colors.black,
          ),
        ),
        actions: isEditing
            ? [
                IconButton(icon: const Icon(Icons.close), onPressed: cancelEdit),
                IconButton(
                  icon: isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Icon(Icons.save),
                  onPressed: isLoading ? null : saveProfile,
                ),
              ]
            : [
                IconButton(icon: const Icon(Icons.edit), onPressed: () => setState(() => isEditing = true)),
              ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(radius: 50, backgroundImage: avatar),
                if (isEditing)
                  Positioned(
                    bottom: 0,
                    right: 4,
                    child: GestureDetector(
                      onTap: pickImageFromGallery,
                      child: const CircleAvatar(
                        radius: 16,
                        backgroundColor: Colors.orange,
                        child: Icon(Icons.camera_alt, size: 18, color: Colors.white),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            EditableField(label: "Name", controller: nameController, enabled: isEditing),
            const SizedBox(height: 16),
            EditableField(
              label: "Email",
              controller: emailController,
              enabled: isEditing,
              inputType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            EditableField(
              label: "Phone Number",
              controller: phoneController,
              enabled: isEditing,
              inputType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            EditableField(
              label: "Address",
              controller: addressController,
              enabled: isEditing,
              maxLines: 2,
              onTap: isEditing ? openMapModal : null,
            ),
            const Spacer(),
            if (!isEditing)
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context, widget.user),
                      icon: const Icon(Icons.arrow_back),
                      label: const Text("Back"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen())),
                      icon: const Icon(Icons.logout),
                      label: const Text("Logout"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class EditableField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool enabled;
  final TextInputType inputType;
  final int maxLines;
  final VoidCallback? onTap;

  const EditableField({
    super.key,
    required this.label,
    required this.controller,
    required this.enabled,
    this.inputType = TextInputType.text,
    this.maxLines = 1,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AbsorbPointer(
        absorbing: onTap != null,
        child: TextField(
          controller: controller,
          enabled: enabled,
          keyboardType: inputType,
          maxLines: maxLines,
          decoration: InputDecoration(
            labelText: label,
            filled: true,
            fillColor: enabled || onTap != null ? Colors.white : const Color(0xFFF5F5F5),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
    );
  }
}