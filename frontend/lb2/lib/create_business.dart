import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:flutter_map/flutter_map.dart' as fmap;
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:lottie/lottie.dart';

class CreateBusinessScreen extends StatefulWidget {
  final Map<String, dynamic> user;
  const CreateBusinessScreen({super.key, required this.user});

  @override
  State<CreateBusinessScreen> createState() => _CreateBusinessScreenState();
}

class _CreateBusinessScreenState extends State<CreateBusinessScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _description = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  File? _logoImage;
  File? _documentFile;

  Future<void> _pickFile(bool isLogo) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        if (isLogo) {
          _logoImage = File(picked.path);
        } else {
          _documentFile = File(picked.path);
        }
      });
    }
  }

  Future<void> _submitBusiness() async {
    if (!_formKey.currentState!.validate() || _logoImage == null || _documentFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please complete all fields and upload files.")),
      );
      return;
    }

    final uri = Uri.parse("http://192.168.137.1/liyag_batangan/create_b2.php");
    final request = http.MultipartRequest('POST', uri);

    request.fields['user_id'] = widget.user['user_id'].toString();
    request.fields['business_name'] = _name.text.trim();
    request.fields['business_description'] = _description.text.trim();
    request.fields['business_address'] = addressController.text.trim();

    request.files.add(await http.MultipartFile.fromPath('business_logo', _logoImage!.path));
    request.files.add(await http.MultipartFile.fromPath('document', _documentFile!.path));

    final response = await request.send();

    if (!mounted) return;

    if (response.statusCode == 200) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Lottie.asset('assets/animations/success1.json', width: 120, height: 120, repeat: false),
              const SizedBox(height: 16),
              const Text(
                "Business submitted successfully!",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      );

      await Future.delayed(const Duration(seconds: 3));
      if (mounted) {
        Navigator.of(context)
          ..pop() // Close the dialog
          ..pop(); // Navigate back to previous screen
      }
    } else {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Lottie.asset('assets/animations/error.json', width: 100, height: 100, repeat: false),
              const SizedBox(height: 16),
              const Text(
                "Submission failed. Please try again.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      );

      await Future.delayed(const Duration(seconds: 3));
      if (mounted) Navigator.of(context).pop(); // Close the dialog only
    }
  }

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
        return StatefulBuilder(
          builder: (ctx, setSB) {
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
                      Navigator.pop(ctx);
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
          },
        );
      },
    );
  }

  Future<String> reverseGeocode(LatLng loc) async {
    final url = Uri.parse('https://nominatim.openstreetmap.org/reverse?format=json&lat=${loc.latitude}&lon=${loc.longitude}&addressdetails=1');
    final resp = await http.get(url, headers: {'User-Agent': 'FlutterApp'});
    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body);
      return data['display_name'] ?? '${loc.latitude}, ${loc.longitude}';
    }
    return '${loc.latitude}, ${loc.longitude}';
  }

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
          TextButton(child: const Text('OK'), onPressed: () => Navigator.of(context).pop()),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Start Selling"),
        backgroundColor: const Color(0xFFFFD500),
        titleTextStyle: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 22,
          fontWeight: FontWeight.w900,
          color: Colors.black,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Business Picture",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => _pickFile(true),
                child: Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                    image: _logoImage != null
                        ? DecorationImage(
                            image: FileImage(_logoImage!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: _logoImage == null
                      ? const Center(child: Icon(Icons.add_photo_alternate, size: 40, color: Colors.grey))
                      : null,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _name,
                decoration: const InputDecoration(
                  labelText: "Business Name",
                  border: OutlineInputBorder(),
                ),
                validator: (val) => val!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _description,
                decoration: const InputDecoration(
                  labelText: "Description",
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (val) => val!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: addressController,
                readOnly: true,
                onTap: openMapModal,
                decoration: const InputDecoration(
                  labelText: "Business Address",
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.map),
                ),
                validator: (val) => val!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => _pickFile(false),
                icon: const Icon(Icons.attach_file),
                label: Text(_documentFile != null ? "Document Selected" : "Attach Business Document"),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitBusiness,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFD500),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 32),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text("Submit Business"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}